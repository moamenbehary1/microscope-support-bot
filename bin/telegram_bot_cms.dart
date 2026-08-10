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
  print('Health server listening on port $port');

  await for (final request in server) {
    request.response
      ..headers.contentType = ContentType.text
      ..write('Bot is alive and running!');
    await request.response.close();
  }
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
    print('Bot Error: $err');
  });

  // Register Handlers
  registerStudentHandlers(bot);
  registerAdminHandlers(bot);
  registerContributorAndUploadHandlers(bot);

  print('Bot is polling...');
  bot.start();
}
