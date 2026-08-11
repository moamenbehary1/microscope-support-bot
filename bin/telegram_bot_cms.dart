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
    if (err is BotError) {
      final error = err.error;
      if (error is TelegramException &&
          error.description != null &&
          error.description!.contains('message is not modified')) {
        return; // Ignore this harmless error
      }
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

