import 'dart:io';
import 'package:televerse/televerse.dart';
import '../lib/config.dart';
import '../lib/student_handlers.dart';
import '../lib/admin_handlers.dart';
import '../lib/contributor_handlers.dart';
import '../lib/firebase_db.dart';

Future<void> startDummyServer() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('Web server listening on port $port  →  http://localhost:$port');

  await for (final request in server) {
    try {
      await _handleWebRequest(request);
    } catch (e) {
      print('Web server error: $e');
      try {
        request.response.statusCode = 500;
        await request.response.close();
      } catch (_) {}
    }
  }
}

Future<void> _handleWebRequest(HttpRequest req) async {
  // CORS — allow dashboard to call Firebase from any origin
  req.response.headers
    ..add('Access-Control-Allow-Origin', '*')
    ..add('Access-Control-Allow-Methods', 'GET, OPTIONS')
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

  startDummyServer();

  // Ensure super admin is in database
  if (Config.superAdminId != 0) {
    await FirebaseDb.addAdmin(Config.superAdminId);
    print('Super Admin registered.');
  }

  final bot = Bot(Config.botToken);

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

  // Register Handlers
  registerStudentHandlers(bot);
  registerAdminHandlers(bot);
  registerContributorAndUploadHandlers(bot);

  print('Bot is polling...');
  bot.start();
}
