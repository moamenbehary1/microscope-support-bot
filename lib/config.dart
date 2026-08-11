import 'dart:io' show Platform;
import 'package:dotenv/dotenv.dart';

class Config {
  // Load .env file for local development (silently ignored if not found)
  static final DotEnv _env = DotEnv()..load();

  /// Reads a value: checks system environment variables first (cloud/production),
  /// then falls back to the .env file (local development).
  static String? _get(String key) =>
      Platform.environment[key] ?? _env[key];

  static String get botToken => _get('BOT_TOKEN') ?? '';

  static int get superAdminId {
    final id = _get('SUPER_ADMIN_ID');
    return id != null ? int.tryParse(id) ?? 0 : 0;
  }

  static String get backupChannelId => _get('BACKUP_CHANNEL_ID') ?? '';

  static String get firebaseDatabaseUrl => _get('FIREBASE_DATABASE_URL') ?? '';
  static String get firebaseSecret => _get('FIREBASE_SECRET') ?? '';

  static String get whatsappSupportNumber => _get('WHATSAPP_SUPPORT_NUMBER') ?? '';
}

// User Modes
enum UserMode { student, admin }
