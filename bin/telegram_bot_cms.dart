import 'dart:io';
import 'dart:convert';
import 'package:televerse/televerse.dart';
import '../lib/config.dart';
import '../lib/student_handlers.dart';
import '../lib/admin_handlers.dart';
import '../lib/contributor_handlers.dart';
import '../lib/table_handlers.dart';
import '../lib/firebase_db.dart';
import '../lib/utils.dart';

Future<void> startDummyServer(Bot bot) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 5000;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('Web server listening on all interfaces (0.0.0.0) on port $port');

  await for (final request in server) {
    try {
      await _handleWebRequest(request, bot);
    } catch (e) {
      print('Web server error: $e');
      try {
        request.response.statusCode = 500;
        await request.response.close();
      } catch (_) {}
    }
  }
}

Future<void> _handleWebRequest(HttpRequest req, Bot bot) async {
  // CORS — allow dashboard to call Firebase from any origin
  req.response.headers
    ..add('Access-Control-Allow-Origin', '*')
    ..add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
    ..add('Access-Control-Allow-Headers', 'Content-Type')
    ..add('Cache-Control', 'no-cache');

  if (req.method == 'OPTIONS') {
    req.response.statusCode = 204;
    await req.response.close();
    return;
  }

  final path = req.uri.path;

  if (path == '/health') {
    // JSON health endpoint for the status indicator in the dashboard
    req.response
      ..statusCode = 200
      ..headers.contentType = ContentType.json
      ..write('{"status":"ok","ts":"${DateTime.now().toIso8601String()}"}');

  } else if (path == '/' || path == '/index.html') {
    // Serve admin dashboard, injecting Firebase credentials from config
    final htmlFile = File('web/index.html');
    if (await htmlFile.exists()) {
      String html = await htmlFile.readAsString();
      // Server-side injection so browser gets credentials automatically
      html = html
          .replaceFirst('{{FB_URL}}', Config.firebaseDatabaseUrl)
          .replaceFirst('{{FB_SECRET}}', Config.firebaseSecret);
      req.response
        ..statusCode = 200
        ..headers.contentType = ContentType.html
        ..write(html);
    } else {
      req.response
        ..statusCode = 200
        ..headers.contentType = ContentType.text
        ..write('Bot is alive! (web/index.html not found)');
    }

  } else if (path == '/api/upload' && req.method == 'POST') {
    try {
      final content = await utf8.decoder.bind(req).join();
      final data = jsonDecode(content) as Map<String, dynamic>;
      
      final track = data['track'] as String;
      final subject = data['subject'] as String;
      final type = data['type'] as String;
      final fileName = data['file_name'] as String;
      final fileBase64 = data['file_base64'] as String;
      
      final bytes = base64Decode(fileBase64.split(',').last);
      
      ChatID chatId = ChatID(Config.superAdminId);
      if (Config.backupChannelId.isNotEmpty && !Config.backupChannelId.contains('your_channel')) {
        chatId = ChatID(int.parse(Config.backupChannelId));
      }

      final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
      final isVideo = ext == 'mp4' || ext == 'mkv' || ext == 'mov';
      final isAudio = ext == 'mp3' || ext == 'ogg' || ext == 'm4a' || ext == 'wav' || ext == 'mpga';
      final isPhoto = ext == 'jpg' || ext == 'jpeg' || ext == 'png';
      
      final inputFile = InputFile.fromBytes(bytes, name: fileName);
      String fileId = '';
      String fileType = 'document';

      if (isPhoto) {
        final msg = await bot.api.sendPhoto(chatId, inputFile);
        fileId = msg.photo?.last.fileId ?? '';
        fileType = 'photo';
      } else if (isVideo) {
        final msg = await bot.api.sendVideo(chatId, inputFile);
        fileId = msg.video?.fileId ?? '';
        fileType = 'video';
      } else if (isAudio) {
        final msg = await bot.api.sendAudio(chatId, inputFile);
        fileId = msg.audio?.fileId ?? '';
        fileType = 'audio';
      } else {
        final msg = await bot.api.sendDocument(chatId, inputFile);
        fileId = msg.document?.fileId ?? '';
        fileType = 'document';
      }

      if (fileId.isEmpty) {
        throw Exception('Failed to get fileId from Telegram');
      }

      await FirebaseDb.addMaterial(track, subject, type, {
        'name': fileName,
        'file_id': fileId,
        'file_type': fileType,
        'added_by': 'Admin Panel',
      });

      // Send notifications to subscribers
      final subscribers = await FirebaseDb.getSubjectSubscribers(subject);
      if (subscribers.isNotEmpty) {
        final text = '🔔 إضافة جديدة!\n\nتمت إضافة ملف جديد في مادة: **$subject**\nالنوع: $type\n\nقم بزيارة البوت لتفقدها.';
        Utils.broadcast(bot, subscribers, text);
      }

      req.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write('{"success":true}');
    } catch (e) {
      req.response
        ..statusCode = 500
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'success': false, 'error': e.toString()}));
    }

  } else if (path == '/api/broadcast_subject' && req.method == 'POST') {
    try {
      final content = await utf8.decoder.bind(req).join();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final subject = data['subject'] as String;
      final message = data['message'] as String;

      final subscribers = await FirebaseDb.getSubjectSubscribers(subject);
      if (subscribers.isNotEmpty) {
        await Utils.broadcast(bot, subscribers, message);
      }

      req.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write('{"status":"ok", "count": ${subscribers.length}}');
    } catch (e) {
      req.response
        ..statusCode = 500
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'status': 'error', 'error': e.toString()}));
    }

  } else if (path == '/api/feedback' && req.method == 'POST') {
    try {
      final content = await utf8.decoder.bind(req).join();
      final data = jsonDecode(content) as Map<String, dynamic>;

      var name = (data['name'] ?? '').toString().trim();
      if (name.isEmpty) {
        final randNum = 1000 + DateTime.now().millisecondsSinceEpoch % 90000;
        name = 'علومنجي #$randNum';
      }
      final ratingNum = (data['rating'] is int) ? data['rating'] as int : int.tryParse('${data['rating']}') ?? 0;
      final ratingStars = ratingNum > 0 ? '$ratingNum/5 ' + ('⭐' * ratingNum) : 'بدون تقييم';
      final message = (data['message'] ?? '').toString().trim();

      if (message.isEmpty) {
        req.response
          ..statusCode = 400
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'success': false, 'error': 'Empty feedback'}));
        await req.response.close();
        return;
      }

      // 1. Save to Firebase Database
      await FirebaseDb.addWebFeedback(
        name: name,
        rating: ratingNum,
        message: message,
      );

      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      // 2. Build Telegram notification message
      final notification =
          '🌟 رأي وتقييم جديد من المنصة! 🌟\n\n'
          '👤 المستخدم: $name\n'
          '⭐ التقييم: $ratingStars\n'
          '💬 الرسالة:\n$message\n\n'
          '🕒 التاريخ والوقت: $dateStr\n'
          '🌐 المصدر: منصة الفيدباك (Microscope Feedback)';

      // Send to Super Admin
      if (Config.superAdminId != 0) {
        try {
          await bot.api.sendMessage(
            ChatID(Config.superAdminId),
            notification,
          );
        } catch (e) {
          print('Failed sending feedback alert to Super Admin: $e');
        }
      }

      // Send to other admins
      try {
        final admins = await FirebaseDb.getAdmins();
        for (var adminId in admins) {
          if (adminId != Config.superAdminId) {
            try {
              await bot.api.sendMessage(
                ChatID(adminId),
                notification,
              );
            } catch (_) {}
          }
        }
      } catch (_) {}

      req.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'success': true}));
    } catch (e) {
      req.response
        ..statusCode = 500
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'success': false, 'error': e.toString()}));
    }

  } else if (path == '/members_form.html' || path == '/members_form') {
    // Serve the Members Data Registration page
    final formFile = File('web/members_form.html');
    if (await formFile.exists()) {
      final html = await formFile.readAsString();
      req.response
        ..statusCode = 200
        ..headers.contentType = ContentType.html
        ..write(html);
    } else {
      req.response.statusCode = 404;
      req.response.write('Members form page not found');
    }

  } else if (path == '/team.html' || path == '/team') {
    // Serve the 3D team showcase page
    final teamFile = File('web/team.html');
    if (await teamFile.exists()) {
      final html = await teamFile.readAsString();
      req.response
        ..statusCode = 200
        ..headers.contentType = ContentType.html
        ..write(html);
    } else {
      req.response.statusCode = 404;
      req.response.write('Team page not found');
    }

  } else if (path.startsWith('/web/') || path.endsWith('.png') || path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.webp') || path.endsWith('.svg')) {
    // Serve static images and web assets
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final filePath = cleanPath.startsWith('web/') ? cleanPath : 'web/$cleanPath';
    final file = File(filePath);
    if (await file.exists()) {
      final ext = path.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : ext == 'jpg' || ext == 'jpeg' ? 'image/jpeg' : ext == 'svg' ? 'image/svg+xml' : 'application/octet-stream';
      req.response
        ..statusCode = 200
        ..headers.contentType = ContentType.parse(mime)
        ..add(await file.readAsBytes());
    } else {
      req.response.statusCode = 404;
      req.response.write('Asset not found');
    }

  } else {
    req.response.statusCode = 404;
    req.response.write('Not found');
  }

  await req.response.close();
}


Future<void> main() async {
  print('Starting Telegram Bot CMS...');

  if (Config.botToken.isEmpty) {
    print('ERROR: BOT_TOKEN is not set in .env');
    return;
  }
  
  if (Config.firebaseDatabaseUrl.isEmpty) {
    print('ERROR: FIREBASE_DATABASE_URL is not set in .env');
    return;
  }

  // Ensure super admin is in database
  if (Config.superAdminId != 0) {
    await FirebaseDb.addAdmin(Config.superAdminId);
    print('Super Admin registered.');
  }

  final bot = Bot(Config.botToken);
  startDummyServer(bot);

  // Error handling
  bot.onError((err) {
    final error = err.error;
    if (error is TelegramException &&
        error.description != null &&
        error.description!.contains('message is not modified')) {
      return; // Ignore this harmless error
    }
    print('Bot Error: $err');
  });

  bot.use(BanCheck());

  // Register Handlers
  registerStudentHandlers(bot);
  registerTableHandlers(bot);
  registerAdminHandlers(bot);
  registerContributorAndUploadHandlers(bot);
  
  // Register generic file upload handlers
  registerContributorUploadHandlers(bot);

  // Centralized Text Handler for state machines to prevent routing conflicts
  bot.onText((ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final text = ctx.message?.text ?? '';
    if (text.startsWith('/')) return; // Ignore commands

    if (Utils.tableCreationStates.containsKey(userId)) {
      await handleTableText(ctx, bot);
    } else if (Utils.uploadStates.containsKey(userId)) {
      await handleUploadText(ctx, bot);
    }
  });

  print('Bot is polling...');
  bot.start();
}

class BanCheck implements Middleware {
  @override
  Future<void> handle(Context ctx, NextFunction next) async {
    final id = ctx.from?.id;
    if (id != null && await FirebaseDb.isBanned(id)) {
      return;
    }
    await next();
  }
}

