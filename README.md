# 🔬 Microscope Support Bot

A Telegram bot CMS for educational content management, built with **Dart** and **Firebase Realtime Database**. Supports multiple user roles (Student, Contributor, Admin) with a fully interactive inline keyboard interface.

---

## ✨ Features

- 📚 **Browse curriculum** — Tracks → Subjects → Material Types → Files
- 📤 **Upload materials** — Admins and approved contributors can upload documents, photos, and videos
- 🤝 **Contributor system** — Users can request to become contributors; admins approve/reject
- 🛡️ **Admin dashboard** — Manage admins, contributors, broadcast messages, view analytics
- 👑 **Super Admin** — Transfer ownership, wipe database, full control
- 📢 **Broadcast** — Send a message to all registered users
- 📊 **Analytics** — Track most-accessed materials
- 💾 **Backup channel** — Automatically backs up uploaded files to a Telegram channel
- 🌐 **Health server** — HTTP server for uptime monitoring (Replit / Railway / Render compatible)

---

## 🏗️ Project Structure

```
bin/
  telegram_bot_cms.dart       # Entry point — starts bot + health server
lib/
  config.dart                 # Reads env vars / .env file
  firebase_db.dart            # Firebase Realtime Database REST client
  admin_handlers.dart         # Admin commands & dashboard callbacks
  student_handlers.dart       # Student browse & download handlers
  contributor_handlers.dart   # Contributor upload & request handlers
  utils.dart                  # Shared utilities (state, pagination, broadcast)
```

---

## 🚀 Getting Started

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) `>=3.0.0`
- A Telegram Bot Token from [@BotFather](https://t.me/BotFather)
- A [Firebase Realtime Database](https://console.firebase.google.com/) project

### 1. Clone & Install Dependencies

```sh
git clone https://github.com/moamenbehary1/microscope-support-bot.git
cd microscope-support-bot
dart pub get
```

### 2. Configure Environment Variables

Copy the example file and fill in your values:

```sh
cp .env.example .env
```

Then edit `.env`:

```env
BOT_TOKEN=your_telegram_bot_token
SUPER_ADMIN_ID=your_telegram_user_id
BACKUP_CHANNEL_ID=-100your_channel_id   # Optional
FIREBASE_DATABASE_URL=https://your-project-id-default-rtdb.firebaseio.com/
FIREBASE_SECRET=your_firebase_database_secret
```

### 3. Run the Bot

```sh
dart run bin/telegram_bot_cms.dart
```

---

## ☁️ Deployment

### Replit

1. Import the repo into Replit
2. Add the environment variables as **Replit Secrets** (not in `.env`)
3. Click **Run** — the `.replit` workflow handles `dart pub get` and starts the bot automatically on port 5000

### Docker

```sh
docker build -t microscope-support-bot .
docker run --env-file .env microscope-support-bot
```

---

## 🔑 Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `BOT_TOKEN` | ✅ | Telegram bot token from BotFather |
| `SUPER_ADMIN_ID` | ✅ | Telegram user ID of the super admin |
| `FIREBASE_DATABASE_URL` | ✅ | Firebase Realtime Database URL |
| `FIREBASE_SECRET` | ✅ | Firebase database legacy secret |
| `BACKUP_CHANNEL_ID` | ⚪ | Telegram channel ID for file backups (e.g. `-100xxxxxxxxxx`) |

> **Note:** In production (Replit, Railway, etc.), set variables as system environment variables. The app checks system env first, then falls back to `.env`.

---

## 👥 User Roles

| Role | How to get it | Permissions |
|------|--------------|-------------|
| **Student** | Default for all users | Browse & download materials |
| **Contributor** | Request via bot, approved by admin | Upload files to their assigned subject |
| **Admin** | Added by Super Admin | Full content management, contributor approval |
| **Super Admin** | Set via `SUPER_ADMIN_ID` env var | All admin powers + transfer ownership, wipe data |

---

## 🤖 Bot Commands

| Command | Description |
|---------|-------------|
| `/start` | Browse the curriculum as a student |
| `/admin` | Open the Admin Dashboard (admins only) |
| `/student` | Switch back to Student mode |

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| Language | Dart 3 |
| Telegram API | [televerse](https://pub.dev/packages/televerse) ^1.10.4 |
| Database | Firebase Realtime Database (REST API) |
| HTTP client | [http](https://pub.dev/packages/http) ^1.2.0 |
| Config | [dotenv](https://pub.dev/packages/dotenv) ^4.2.0 |

---

## 📄 License

MIT License — feel free to use and modify.