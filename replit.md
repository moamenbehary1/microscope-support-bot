# Running on Replit

This project keeps its existing Dart backend and static HTML dashboard.

## Start

Use the **Start application** workflow (Run). It runs:

```sh
dart pub get && dart run bin/telegram_bot_cms.dart
```

The Dart 3.10 module is installed. The application listens on `0.0.0.0:5000`
by default; `/` serves the dashboard and `/health` returns a JSON health response.

## Required configuration

Add these through Replit Secrets, not source files or chat:

- `BOT_TOKEN`: Telegram bot token from BotFather.
- `SUPER_ADMIN_ID`: numeric Telegram user ID of the owner.
- `FIREBASE_DATABASE_URL`: existing Firebase Realtime Database URL.
- `FIREBASE_SECRET`: Firebase Realtime Database legacy secret.

System environment variables take precedence over a local `.env` file.
The application does not start without the bot token and database URL.
Startup registers the configured super admin in the existing Firebase database
and starts Telegram long polling; stop any other instance using the same bot
token before running this copy.

Optional features use `BACKUP_CHANNEL_ID`, `WHATSAPP_SUPPORT_NUMBER`,
`GOOGLE_DRIVE_FOLDER_ID`, `GOOGLE_SERVICE_ACCOUNT_JSON`, and `N8N_BASE_URL`.
See the README for their purposes. Do not fabricate credentials or replace
the existing Firebase database.

## Existing security limitation

The imported server injects the Firebase legacy secret into dashboard HTML,
and the dashboard uses a Telegram ID rather than verified sign-in. Do not
publish or expose this app with real data until server-side authentication,
authorization, and Firebase credential handling are hardened.

## Checks

```sh
dart analyze
```

After configuring credentials, start the workflow and check `/health` and the
dashboard. Telegram and Firebase behavior require valid external credentials.
