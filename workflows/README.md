# n8n Workflows

This directory contains n8n workflows for the bot.

## Workflows

### 1. Read Telegram File (Agent Tool)
- **File:** [`read_telegram_file.json`](file:///f:/TELEGRAMBOT/workflows/read_telegram_file.json)
- **Description:** Sub-workflow / Tool for AI Agents to read and extract text from Telegram files.
  - **Inputs:** `file_id` (Telegram File ID)
  - **Supported Types:**
    - **PDF:** Extracts text from all pages (`joinPages: true`), truncated to 60,000 characters.
    - **Plain Text / Code:** Extracts text from `.txt`, `.md`, `.csv`, `.json`, `.html`, truncated to 60,000 characters.
    - **Fallback:** Returns `{ status: "unsupported_format", file_path: "...", text: "" }` for other file extensions.
  - **Returns:** JSON with `{ status: "ok" | "unsupported_format", text: "..." }`
