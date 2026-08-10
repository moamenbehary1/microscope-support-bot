# microscope-support-bot

A Telegram bot CMS for educational support, built with Dart and Firebase Realtime Database.

## Stack

- **Language**: Dart 3.10
- **Telegram library**: [televerse](https://pub.dev/packages/televerse) ^1.10.4
- **Database**: Firebase Realtime Database (via REST API)
- **Entry point**: `bin/telegram_bot_cms.dart`

## How to run

```sh
dart pub get && PORT=5000 dart run bin/telegram_bot_cms.dart
```

Or use the **Start application** workflow in Replit.

## Required secrets (Replit Secrets — NOT in `.env`)

| Key | Description |
|-----|-------------|
| `BOT_TOKEN` | Telegram bot token from BotFather |
| `SUPER_ADMIN_ID` | Telegram user ID of the super admin |
| `BACKUP_CHANNEL_ID` | Telegram channel ID for backups (e.g. `-100xxxxxxxxxx`). Optional. |
| `FIREBASE_DATABASE_URL` | Firebase Realtime Database URL (ends with `/`) |
| `FIREBASE_SECRET` | Firebase database legacy secret |

## Project structure

```
bin/
  telegram_bot_cms.dart       # Entry point — starts bot + HTTP health server
lib/
  config.dart                 # Reads env vars / .env file
  firebase_db.dart            # Firebase Realtime Database REST client
  strings.dart                # All bilingual strings (AR/EN)
  admin_handlers.dart         # Admin commands & dashboard callbacks
  student_handlers.dart       # Student browse & download handlers
  contributor_handlers.dart   # Contributor upload, dashboard & request handlers
  utils.dart                  # Shared utilities (state machine, language cache, pagination, broadcast)
```

## User preferences

- Keep the existing Dart project structure
- Do NOT modify `.md` files unless explicitly asked
- Do NOT run `dart run` to test — the bot is tested live on Telegram

---

## 🤖 Replit AI Agent — Troubleshooting Guide

Use this section to automatically diagnose and fix issues.

### ── Common errors and fixes ──────────────────────────────────────────

#### ❌ `Error: BOT_TOKEN is not set in .env`
**Cause**: The `BOT_TOKEN` environment variable is missing.
**Fix**:
1. Go to **Replit Secrets** (🔒 padlock icon in the sidebar).
2. Add a secret named `BOT_TOKEN` with the Telegram bot token value.
3. Restart the workflow.

---

#### ❌ `Error: FIREBASE_DATABASE_URL is not set in .env`
**Cause**: The `FIREBASE_DATABASE_URL` environment variable is missing.
**Fix**:
1. Go to **Replit Secrets**.
2. Add `FIREBASE_DATABASE_URL` — value should look like `https://your-project-default-rtdb.firebaseio.com/`.
3. Restart the workflow.

---

#### ❌ `dart pub get` fails / package not found
**Cause**: Network issue or corrupted `.dart_tool` cache.
**Fix**:
```sh
rm -rf .dart_tool
dart pub get
```

---

#### ❌ `Unhandled exception: SocketException` or `Connection refused`
**Cause**: Firebase REST API unreachable, or wrong `FIREBASE_DATABASE_URL`.
**Fix**:
1. Verify `FIREBASE_DATABASE_URL` is correct and ends with `/`.
2. Verify `FIREBASE_SECRET` is the legacy database secret (not a service account JSON).
3. Check Firebase console → Realtime Database → Rules are not blocking requests.

---

#### ❌ `Bad state: No such method` or `type ... is not a subtype of ...`
**Cause**: Dart type mismatch, usually from Firebase returning unexpected data shape.
**Fix**:
1. Check if the Firebase database has stale/corrupted data.
2. The bot has a `wipeCurriculum()` admin command (🗑️ Wipe Database) in the admin dashboard that clears curriculum and analytics.

---

#### ❌ Bot stops responding / polling silently dies
**Cause**: Telegram API error or uncaught exception in a handler.
**Fix**:
1. Check Replit logs for the last printed error.
2. The bot has a global error handler (`bot.onError`) — look for `Bot Error:` lines in the console.
3. Restart the workflow.

---

#### ❌ `HttpException: 409 Conflict` — another bot instance running
**Cause**: Two instances of the bot are polling at the same time (e.g., local + Replit).
**Fix**: Stop any locally running instance of the bot. Only one polling instance is allowed.

---

#### ❌ Port 5000 already in use
**Cause**: A previous run left a process bound to port 5000.
**Fix**:
```sh
pkill -f dart
dart pub get && PORT=5000 dart run bin/telegram_bot_cms.dart
```

---

#### ❌ `BACKUP_CHANNEL_ID` errors
**Cause**: The `BACKUP_CHANNEL_ID` is set to the placeholder value `-100your_channel_id_here`.
**Fix**: Either:
- Set it to a real Telegram channel ID (e.g., `-1001234567890`), **or**
- Leave the secret unset — the bot handles a missing backup channel gracefully.

---

### ── Dependency issues ─────────────────────────────────────────────────

If `pubspec.lock` is out of sync, run:
```sh
dart pub upgrade
```

If a package version conflict occurs, check `pubspec.yaml` constraints:
- `televerse: ^1.10.4`
- `dotenv: ^4.2.0`
- `http: ^1.2.0`

---

### ── How the language system works ────────────────────────────────────

- On `/start`, the bot checks if the user has a saved language preference in Firebase (`/users/{id}/language`).
- If no language is set, it prompts the user to choose Arabic (`lang_ar`) or English (`lang_en`).
- Language is cached in memory (`Utils._userLanguages`) and persisted in Firebase.
- All strings live in `lib/strings.dart` under the `S` class.

---

### ── State machine overview ────────────────────────────────────────────

The bot uses an in-memory state machine (`Utils.uploadStates`) to track multi-step conversations.
States are cleared via `Utils.clearUploadState(userId)`.

Key states:
| State | Meaning |
|-------|---------|
| `req_contribute_track` | User is typing the track name for a contribution request |
| `req_contribute_subject` | User is typing the subject name |
| `upload_admin_name` | Admin typed the material name, waiting for description |
| `upload_admin_desc` | Admin typing description before saving |
| `upload_contrib_name` | Contributor typed name, waiting for description |
| `upload_contrib_desc` | Contributor typing description before saving |
| `contrib_announce_msg` | Contributor typing broadcast announcement |
| `broadcast_msg` | Admin typing broadcast message |
| `add_admin_id` | Super admin typing new admin's Telegram ID |
| `transfer_owner_id` | Super admin typing new owner's Telegram ID |
| `replace_file` | Admin about to send replacement file |
| `contact_admin` | User typing feedback message |

---

### ── Firebase data structure ──────────────────────────────────────────

```
/users/{userId}/
  joinedAt: ISO8601
  language: "ar" | "en"

/admins/{userId}: true

/contributors/{userId}/
  track: string
  subject: string
  name?: string

/requests/{userId}/
  track: string
  subject: string
  timestamp: ISO8601
  name?: string

/curriculum/{track}/{subject}/{type}/{materialId}/
  name: string
  file_id: string
  file_type: "document" | "photo" | "video"
  added_by: string (userId)
  description?: string

/contributor_materials/{userId}/{materialId}/
  track: string
  subject: string
  type: string
  name: string
  description?: string

/analytics/top_accessed/{materialId}/
  count: int
  name: string

/super_admin/
  id: int
```
