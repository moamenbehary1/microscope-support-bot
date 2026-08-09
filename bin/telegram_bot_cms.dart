import 'package:televerse/televerse.dart';
import '../lib/config.dart';
import '../lib/student_handlers.dart';
import '../lib/admin_handlers.dart';
import '../lib/contributor_handlers.dart';
import '../lib/firebase_db.dart';

void main() async {
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
