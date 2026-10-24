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

  static String get whatsappSupportNumber {
    final num = _get('WHATSAPP_SUPPORT_NUMBER') ?? '';
    return num.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Google Drive folder ID where registration PDFs will be uploaded.
  static String get googleDriveFolderId => _get('GOOGLE_DRIVE_FOLDER_ID') ?? '';

  /// Full JSON content of the Google Service Account key file (single-line).
  static String get googleServiceAccountJson =>
      _get('GOOGLE_SERVICE_ACCOUNT_JSON') ?? '';

  /// Base URL of the n8n instance (e.g. http://n8n:5678).
  /// When running via Docker Compose this is set automatically to http://n8n:5678.
  /// Leave empty to disable n8n integration.
  static String get n8nBaseUrl => _get('N8N_BASE_URL') ?? '';
}

// User Modes
enum UserMode { student, admin }
