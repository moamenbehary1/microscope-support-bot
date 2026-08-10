# microscope-support-bot

A Telegram bot CMS for educational support, built with Dart and Firebase Realtime Database.

## Stack

- **Language**: Dart 3.10
- **Telegram library**: [televerse](https://pub.dev/packages/televerse)
- **Database**: Firebase Realtime Database (via REST API)
- **Entry point**: `bin/telegram_bot_cms.dart`

## How to run

The bot runs as a console workflow. Start it with:

```sh
dart run bin/telegram_bot_cms.dart
```

Or use the **Start application** workflow in Replit.

## Required secrets

Set these as Replit Secrets (not in `.env`):

| Key | Description |
|-----|-------------|
| `BOT_TOKEN` | Telegram bot token from BotFather |
| `SUPER_ADMIN_ID` | Telegram user ID of the super admin |
| `BACKUP_CHANNEL_ID` | Telegram channel ID for backups (e.g. `-100xxxxxxxxxx`) |
| `FIREBASE_DATABASE_URL` | Firebase Realtime Database URL |
| `FIREBASE_SECRET` | Firebase database secret |

## Project structure

```
bin/
  telegram_bot_cms.dart   # Entry point
lib/
  config.dart             # Reads env vars / .env
  firebase_db.dart        # Firebase REST client
  admin_handlers.dart     # Admin command handlers
  student_handlers.dart   # Student command handlers
  contributor_handlers.dart # Contributor/upload handlers
  utils.dart              # Shared utilities
```

## User preferences

- Keep the existing Dart project structure
