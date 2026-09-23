# 🔬 Microscope Support Bot

A Telegram bot CMS for educational content management, built with **Dart** and **Firebase Realtime Database**. Supports multiple user roles (Student, Contributor, Admin) with a fully interactive inline keyboard interface and a modern web dashboard.

---

## ✨ Features

- 📚 **Browse curriculum** — Tracks → Subjects → Material Types → Files
- 🏷️ **Dynamic Material Types** — Multi-select standard types or add custom types to subjects directly from the dashboard
- 📤 **Upload materials** — Admins and approved contributors can upload documents, photos, and videos
- 🤝 **Contributor system** — Users can request to become contributors; admins approve/reject
- 🛡️ **Admin web dashboard** — Manage admins, contributors, curriculum, and view analytics in a modern UI
- 👑 **Super Admin** — Transfer ownership, wipe database, full control
- 📢 **Broadcast System** — Send global messages to all users or target specific students based on their subject subscriptions
- 📊 **Analytics** — Track most-accessed materials
- 💾 **Backup channel** — Automatically backs up files uploaded via the **Bot** to a Telegram channel
- 📋 **Member Registration Form** — A beautiful RTL Arabic form for team members; submissions are saved to Firebase + uploaded as a PDF to **Google Drive**
- 🌐 **Health server & Web API** — HTTP server serving the dashboard and handling web hooks (Replit / Railway / Render compatible)

---

## 🏗️ Project Structure

```
bin/
  telegram_bot_cms.dart       # Entry point — starts bot + HTTP server + Google Drive helpers
lib/
  config.dart                 # Reads env vars / .env file (incl. Google Drive keys)
  firebase_db.dart            # Firebase Realtime Database REST client
  admin_handlers.dart         # Admin commands & dashboard callbacks
  student_handlers.dart       # Student browse & download handlers
  contributor_handlers.dart   # Contributor upload & request handlers
  table_handlers.dart         # Study-table handlers
  utils.dart                  # Shared utilities (state, pagination, broadcast)
web/
  index.html                  # Built-in Web Dashboard (Admin Panel)
  members_form.html           # Student/Member Registration Form
  team.html                   # 3D Team Showcase page
  uploads/members/            # Server-side member photo storage
```

---

## 🚀 Getting Started

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) `>=3.0.0`
- A Telegram Bot Token from [@BotFather](https://t.me/BotFather)
- A [Firebase Realtime Database](https://console.firebase.google.com/) project
- `openssl` on PATH (for Google Drive JWT signing — available by default on Linux/Mac and via Git for Windows on Windows)

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

Then edit `.env` with your actual credentials (see the full table below).

### 3. Run the Bot

```sh
dart run bin/telegram_bot_cms.dart
```

---

## ☁️ Deployment

### Replit

1. Import the repo into Replit
2. Add **all** environment variables as **Replit Secrets** (not in `.env` — secrets override `.env` automatically)
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
| `BACKUP_CHANNEL_ID` | ⚪ | Telegram channel ID for **bot** file backups (e.g. `-100xxxxxxxxxx`) |
| `WHATSAPP_SUPPORT_NUMBER` | ⚪ | WhatsApp support number shown in the bot |
| `GEMINI_API_KEY` | ⚪ | Google Gemini API key (if used) |
| `GOOGLE_DRIVE_FOLDER_ID` | ⚪ | Drive folder ID where registration PDFs are uploaded |
| `GOOGLE_SERVICE_ACCOUNT_JSON` | ⚪ | Service Account JSON key (single-line) for Drive API auth |

> **Note:** In production (Replit, Railway, etc.), set variables as system environment variables. The app checks system env first, then falls back to `.env`.

---

## 📋 Member Registration Form

The registration form is available at `/members_form.html`. It allows team members to fill in their personal data, upload a profile photo, and submit.

**Submission flow:**
1. Photo is uploaded to the server (`/web/uploads/members/`)
2. A styled PDF card is generated in-browser (jsPDF + html2canvas)
3. Member data (**without** the large base64 photo blob) is saved to Firebase → `/members/<id>`
4. The PDF is uploaded to your Google Drive folder
5. A **"📝 تسجيل عضو آخر"** (Add Another Registration) button appears so admins can register multiple members back-to-back without reloading the page

> **Admin Dashboard:** The Members tab reads from Firebase `/members` and displays all registered members with full edit, export, and delete controls.

---

## 🔗 Google Drive Integration Setup

Follow these steps to enable automatic PDF uploads to your Google Drive when a registration form is submitted.

### Step 1 — Create a Google Cloud Project

1. Go to [console.cloud.google.com](https://console.cloud.google.com/)
2. **Select a project → New Project** → name it (e.g. `microscope-bot`) → **Create**

### Step 2 — Enable the Google Drive API

1. **APIs & Services → Library**
2. Search **"Google Drive API"** → Click → **Enable**

### Step 3 — Create a Service Account

1. **APIs & Services → Credentials → + Create Credentials → Service Account**
2. Name: `microscope-drive-uploader` → **Done**
3. Click the account → **Keys** tab → **Add Key → Create New Key → JSON** → **Create**
4. A `.json` file is downloaded — keep it safe!

### Step 4 — Share Your Drive Folder

1. In Google Drive, open (or create) the target folder
2. Right-click → **Share** → paste the service account email
   *(e.g. `microscope-drive-uploader@microscope-bot.iam.gserviceaccount.com`)*
3. Role: **Editor** → **Share**
4. Copy the **Folder ID** from the URL:
   ```
   https://drive.google.com/drive/folders/ ►COPY_THIS◄
   ```

### Step 5 — Convert the JSON Key to a Single Line

The private key contains real newlines. You must collapse the entire JSON to **one line** before putting it in `.env`.

**Windows PowerShell:**
```powershell
(Get-Content "C:\path\to\key.json" -Raw) -replace "`r`n","" -replace "`n","" | Set-Clipboard
```

**Linux / Mac:**
```bash
cat key.json | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin)))" | pbcopy
```

### Step 6 — Add to `.env`

```env
GOOGLE_DRIVE_FOLDER_ID=1aBcDeFgHiJkLmNoPqRsTuVwXyZ
GOOGLE_SERVICE_ACCOUNT_JSON={"type":"service_account","project_id":"microscope-bot","private_key_id":"abc123","private_key":"-----BEGIN RSA PRIVATE KEY-----\nMIIE...\n-----END RSA PRIVATE KEY-----\n","client_email":"microscope-drive-uploader@microscope-bot.iam.gserviceaccount.com","client_id":"...","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token"}
```

> **Important:** The actual newlines inside `private_key` must appear as `\n` (two characters: backslash + n) in the `.env` file. The Dart code restores them automatically before signing.

---

## 🔒 Storage Architecture

| Source | PDF Destination | Firebase |
|--------|----------------|----------|
| **Bot file uploads** | ➜ Backup Channel (Telegram) | ✅ Material metadata |
| **Registration Form** | ➜ Google Drive folder | ✅ Member record (no photo blob) |

These two paths are **completely separate** — changing one does not affect the other.

---

## 👥 User Roles

| Role | How to get it | Permissions |
|------|--------------|-------------|
| **Student** | Default for all users | Browse & download materials |
| **Contributor** | Request via bot, approved by admin | Upload files to their assigned subject |
| **Admin** | Added by Super Admin | Full content management, contributor approval |
| **Super Admin** | Set via `SUPER_ADMIN_ID` env var | All admin powers + transfer ownership, wipe data |

---

## 🌍 Web Dashboard

The project includes a built-in, responsive web dashboard at `http://<YOUR_SERVER_URL>/`.

**Dashboard Features:**
- **Members Management** — View, edit, delete, and export all registered form members to Excel or HTML cards
- **Manage Curriculum** — Add, edit, or remove Tracks, Subjects, and Material Types
- **Targeted Broadcasting** — Send instant notifications from the dashboard to students subscribed to a specific subject
- **Analytics** — Most-accessed materials, user counts, committee charts

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
| PDF Generation | jsPDF + html2canvas (browser-side) |
| Drive Upload | Google Drive API v3 (Service Account JWT via openssl) |

---

## 📄 License

MIT License — feel free to use and modify.