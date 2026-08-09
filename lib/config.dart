import 'package:dotenv/dotenv.dart';

class Config {
  static final DotEnv _env = DotEnv()..load();

  static String get botToken => _env['BOT_TOKEN'] ?? '';
  
  static int get superAdminId {
    final id = _env['SUPER_ADMIN_ID'];
    return id != null ? int.tryParse(id) ?? 0 : 0;
  }

  static String get backupChannelId => _env['BACKUP_CHANNEL_ID'] ?? '';

  static String get firebaseDatabaseUrl => _env['FIREBASE_DATABASE_URL'] ?? '';
  static String get firebaseSecret => _env['FIREBASE_SECRET'] ?? '';
}

// User Modes
enum UserMode { student, admin }
