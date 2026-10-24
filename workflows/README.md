# n8n Workflows

هذا المجلد يحتوي على كل workflows الـ n8n الخاصة بالمشروع.  
يتم **استيرادها تلقائياً** عند تشغيل `docker compose up`.

---

## الملفات

| الملف | الغرض |
|---|---|
| `read_telegram_file.json` | Workflow للـ AI Agent (يُستدعى عبر Execute Workflow) |
| `read_telegram_file_webhook.json` | **نفس المنطق** لكن بـ HTTP Webhook — هذا ما يستخدمه البوت |
| `credentials.json` | Template لـ credentials الـ Telegram في n8n (يُحقن فيه `BOT_TOKEN` تلقائياً عند التشغيل) |

---

## آلية العمل

```
Docker Compose
│
├─ n8n (port 5678)
│    └─ n8n-entrypoint.sh يعمل عند البدء:
│         1. يُنشئ credentials من BOT_TOKEN
│         2. يستورد الـ workflows
│         3. يُفعّلها جميعاً
│
└─ Bot (Dart, port 5000)
     └─ lib/n8n_client.dart
          └─ POST http://n8n:5678/webhook/read-file
               body: { "file_id": "..." }
               response: { "status": "ok", "text": "...", "file_path": "..." }
```

---

## Webhook: `read_telegram_file_webhook.json`

**Endpoint:** `POST http://n8n:5678/webhook/read-file`

### Request
```json
{ "file_id": "BQACAgQAAxkBAAE..." }
```

### Response
```json
{ "status": "ok", "text": "محتوى الملف...", "file_path": "documents/file_1.pdf" }
```

أو في حالة صيغة غير مدعومة:
```json
{ "status": "unsupported_format", "text": "", "file_path": "videos/clip.mp4" }
```

### الصيغ المدعومة
| الصيغة | المعالجة |
|---|---|
| `.pdf` | استخراج النص من كل الصفحات (joinPages) |
| `.txt` `.md` `.csv` `.json` `.html` | استخراج النص الخام |
| غير ذلك | `status: unsupported_format` |

---

## تشغيل المشروع كاملاً

```bash
# نسخ ملف البيئة
cp .env.example .env
# ثم عدّل القيم في .env

# تشغيل البوت + n8n معاً
docker compose up -d

# متابعة الـ logs
docker compose logs -f
```

> **ملاحظة:** n8n يكون جاهزاً قبل البوت — Docker Compose يضمن ذلك عبر `depends_on` مع `healthcheck`.

---

## استخدام N8nClient في الكود (Dart)

```dart
import 'n8n_client.dart';

// استخراج النص من ملف
final text = await N8nClient.extractText(fileId);
if (text != null) {
  print('النص المستخرج: $text');
}

// أو الاستجابة الكاملة
final result = await N8nClient.readTelegramFile(fileId);
// result = { "status": "ok", "text": "...", "file_path": "..." }
```
