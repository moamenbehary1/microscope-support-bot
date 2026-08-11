import 'package:televerse/televerse.dart';
import 'config.dart';

class Utils {
  // Simple state management (In-memory for current session state)
  static final Map<int, UserMode> _userModes = {};

  // User language cache ('ar' | 'en')
  static final Map<int, String> _userLanguages = {};

  // Track ongoing uploads for admins/contributors
  // userId -> { 'action': 'upload', 'track': '', 'subject': '', 'type': '' }
  static final Map<int, Map<String, dynamic>> uploadStates = {};

  static UserMode getUserMode(int userId) {
    return _userModes[userId] ?? UserMode.student;
  }

  static void setUserMode(int userId, UserMode mode) {
    _userModes[userId] = mode;
  }

  static void clearUploadState(int userId) {
    uploadStates.remove(userId);
  }

  // ── Language helpers ────────────────────────────────────────────────

  /// Returns the cached language for [userId]. Defaults to 'en'.
  static String getUserLanguage(int userId) {
    return _userLanguages[userId] ?? 'en';
  }

  /// Caches the language preference for [userId].
  static void setUserLanguage(int userId, String lang) {
    _userLanguages[userId] = lang;
  }

  /// Returns true if a language has already been cached for [userId].
  static bool hasLanguage(int userId) {
    return _userLanguages.containsKey(userId);
  }

  // ── Pagination ──────────────────────────────────────────────────────

  /// Generates a paginated inline keyboard.
  /// [items] List of items to display.
  /// [page] Current page (0-indexed).
  /// [itemsPerPage] Defaults to 5.
  /// [prefix] The callback data prefix (e.g., 'track:'). The item string will be appended.
  /// [backData] Callback data for a 'Back' button, if any.
  static InlineKeyboard paginateKeyboard(
    List<String> items, {
    required int page,
    int itemsPerPage = 5,
    required String prefix,
    String? backData,
  }) {
    final keyboard = InlineKeyboard();

    int startIndex = page * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > items.length) endIndex = items.length;

    for (int i = startIndex; i < endIndex; i++) {
      keyboard.row().add(items[i], '$prefix${items[i]}');
    }

    final navRow = <InlineMenuData>[];
    if (page > 0) {
      navRow.add(InlineMenuData('⬅️ Prev', '${prefix}page_${page - 1}'));
    }
    if (endIndex < items.length) {
      navRow.add(InlineMenuData('Next ➡️', '${prefix}page_${page + 1}'));
    }

    if (navRow.isNotEmpty) {
      final row = keyboard.row();
      for (var item in navRow) {
        row.add(item.text, item.data!);
      }
    }

    if (backData != null) {
      keyboard.row().add('🔙 Back', backData);
    }

    return keyboard;
  }

  // ── Broadcast ───────────────────────────────────────────────────────

  /// Helper to safely send broadcast messages with a delay
  static Future<void> broadcast(Bot mainBot, List<int> userIds, String message) async {
    // Create a separate bot instance for broadcasting so we don't 
    // congest the main bot's HTTP client, which can cause LongPolling conflicts.
    final broadcastBot = Bot(Config.botToken);

    int count = 0;
    for (int id in userIds) {
      try {
        await broadcastBot.api.sendMessage(ChatID(id), message);
        count++;
        // Asynchronous delay to avoid Telegram rate limits (approx 30 msgs/sec limit)
        await Future.delayed(Duration(milliseconds: 50));
      } catch (e) {
        // User might have blocked the bot, ignore
        print('Failed to send to $id: $e');
      }
    }
    print('Broadcast complete. Sent to $count users.');
  }
}
