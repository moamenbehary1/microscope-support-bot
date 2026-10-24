import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

/// Client for calling the n8n "Read Telegram File" webhook workflow.
///
/// The bot sends a [fileId] to n8n which:
///   1. Downloads the file from Telegram
///   2. Extracts text (PDF pages joined, plain-text files raw)
///   3. Returns `{ "status": "ok"|"unsupported_format", "text": "...", "file_path": "..." }`
///
/// Usage:
/// ```dart
/// final result = await N8nClient.readTelegramFile(someFileId);
/// if (result != null && result['status'] == 'ok') {
///   final text = result['text'] as String;
/// }
/// ```
class N8nClient {
  static String get _baseUrl => Config.n8nBaseUrl;

  // Path must match the webhook path in read_telegram_file_webhook.json
  static const String _webhookPath = '/webhook/read-file';

  /// Calls the n8n webhook to extract text from a Telegram file.
  ///
  /// Returns a map with keys:
  ///   - `status` → `"ok"` or `"unsupported_format"`
  ///   - `text`   → extracted text (up to 60,000 chars), empty string on failure
  ///   - `file_path` → the Telegram file path (optional, for debugging)
  ///
  /// Returns `null` if n8n is not configured or the request fails.
  static Future<Map<String, dynamic>?> readTelegramFile(String fileId) async {
    if (_baseUrl.isEmpty) {
      print('[N8nClient] N8N_BASE_URL is not configured – skipping.');
      return null;
    }

    final url = Uri.parse('$_baseUrl$_webhookPath');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'file_id': fileId}),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // n8n may return a list (one item per output branch) or a single map
        if (body is List && body.isNotEmpty) {
          final item = body.first;
          if (item is Map<String, dynamic>) return item;
        } else if (body is Map<String, dynamic>) {
          return body;
        }

        print('[N8nClient] Unexpected response shape: $body');
        return null;
      } else {
        print(
            '[N8nClient] HTTP ${response.statusCode} from n8n: ${response.body}');
        return null;
      }
    } catch (e) {
      print('[N8nClient] Error calling n8n webhook: $e');
      return null;
    }
  }

  /// Convenience wrapper: returns only the text string, or null.
  static Future<String?> extractText(String fileId) async {
    final result = await readTelegramFile(fileId);
    if (result == null) return null;
    if (result['status'] == 'ok') {
      final text = result['text'];
      return text is String && text.isNotEmpty ? text : null;
    }
    return null;
  }
}
