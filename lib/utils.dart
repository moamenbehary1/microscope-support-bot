import 'dart:io';
import 'dart:convert';
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

  // Track table creation for students
  // userId -> { 'name': '', 'track': '', 'selected_subjects': [] }
  static final Map<int, Map<String, dynamic>> tableCreationStates = {};

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

  // ── Callback Data Shortener ─────────────────────────────────────────
  static int _idCounter = 0;
  static final Map<String, String> _shortToLong = {};
  static final Map<String, String> _longToShort = {};
  static bool _shortenerLoaded = false;

  static void _initShortener() {
    if (_shortenerLoaded) return;
    _shortenerLoaded = true;
    try {
      final f = File('.shortener_cache.json');
      if (f.existsSync()) {
        final content = f.readAsStringSync();
        final map = json.decode(content) as Map<String, dynamic>;
        map.forEach((k, v) {
          final sVal = v.toString();
          _shortToLong[k] = sVal;
          _longToShort[sVal] = k;
          final idNum = int.tryParse(k, radix: 36);
          if (idNum != null && idNum > _idCounter) {
            _idCounter = idNum;
          }
        });
      }
    } catch (_) {}
  }

  static void _saveShortener() {
    try {
      final f = File('.shortener_cache.json');
      f.writeAsStringSync(json.encode(_shortToLong));
    } catch (_) {}
  }

  static String shorten(String data) {
    if (data.isEmpty) return data;
    if (data.startsWith('page_')) return data;
    _initShortener();
    if (_longToShort.containsKey(data)) return _longToShort[data]!;

    // Keep original only if very short ascii alphanumeric with no colon or space
    if (RegExp(r'^[a-zA-Z0-9_-]{1,6}$').hasMatch(data)) {
      return data;
    }

    _idCounter++;
    final shortId = _idCounter.toRadixString(36);
    _shortToLong[shortId] = data;
    _longToShort[data] = shortId;
    _saveShortener();
    return shortId;
  }

  static String lengthen(String shortId) {
    _initShortener();
    return _shortToLong[shortId] ?? shortId;
  }

  // ── Pagination ──────────────────────────────────────────────────────

  /// Generates a paginated inline keyboard for a list of items (5 per page).
  static InlineKeyboard paginateKeyboard(
    List<String> items, {
    required int page,
    int itemsPerPage = 5,
    required String prefix,
    String? backData,
    String? backLabel,
    String lang = 'ar',
  }) {
    final keyboard = InlineKeyboard();

    int startIndex = page * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > items.length) endIndex = items.length;

    for (int i = startIndex; i < endIndex; i++) {
      keyboard.row().add(items[i], '$prefix${Utils.shorten(items[i])}');
    }

    final totalPages = (items.length / itemsPerPage).ceil();
    if (totalPages > 1) {
      final navRow = keyboard.row();
      final prevText = lang == 'en' ? '⬅️ Prev' : '⬅️ السابق';
      final nextText = lang == 'en' ? 'Next ➡️' : 'التالي ➡️';

      if (page > 0) {
        navRow.add(prevText, '${prefix}page_${page - 1}');
      }
      navRow.add('📄 ${page + 1}/$totalPages', 'ignore');
      if (endIndex < items.length) {
        navRow.add(nextText, '${prefix}page_${page + 1}');
      }
    }

    if (backData != null) {
      final defaultBack = lang == 'en' ? '🔙 Back' : '🔙 رجوع';
      keyboard.row().add(backLabel ?? defaultBack, backData);
    }
    return keyboard;
  }

  /// Generates a paginated inline keyboard for key-value items (e.g. materials) (5 per page).
  /// For a list of MapEntry, typically used when we have IDs mapping to names.
  static InlineKeyboard paginateMapKeyboard(
    List<MapEntry<String, String>> items, {
    required int page,
    int itemsPerPage = 5,
    required String prefix,
    String? backData,
    String? backLabel,
    String lang = 'ar',
  }) {
    final keyboard = InlineKeyboard();

    int startIndex = page * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > items.length) endIndex = items.length;

    for (int i = startIndex; i < endIndex; i++) {
      // Don't translate file names (items[i].value), as requested by user.
      keyboard.row().add(items[i].value, '$prefix${Utils.shorten(items[i].key)}');
    }

    final totalPages = (items.length / itemsPerPage).ceil();
    if (totalPages > 1) {
      final navRow = keyboard.row();
      final prevText = lang == 'en' ? '⬅️ Prev' : '⬅️ السابق';
      final nextText = lang == 'en' ? 'Next ➡️' : 'التالي ➡️';

      if (page > 0) {
        navRow.add(prevText, '${prefix}page_${page - 1}');
      }
      navRow.add('📄 ${page + 1}/$totalPages', 'ignore');
      if (endIndex < items.length) {
        navRow.add(nextText, '${prefix}page_${page + 1}');
      }
    }

    if (backData != null) {
      final defaultBack = lang == 'en' ? '🔙 Back' : '🔙 رجوع';
      keyboard.row().add(backLabel ?? defaultBack, backData);
    }

    return keyboard;
  }

  /// Generates a paginated inline keyboard with multi-select checkmarks.
  static InlineKeyboard paginateMultiSelectKeyboard(
    List<String> items,
    List<String> selectedItems, {
    required int page,
    int itemsPerPage = 5,
    required String togglePrefix,
    required String doneData,
    String? backData,
    String? backLabel,
    String lang = 'ar',
  }) {
    final keyboard = InlineKeyboard();

    int startIndex = page * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > items.length) endIndex = items.length;

    for (int i = startIndex; i < endIndex; i++) {
      final item = items[i];
      final isSelected = selectedItems.contains(item);
      final text = isSelected ? '✅ $item' : item;
      keyboard.row().add(text, '$togglePrefix${Utils.shorten(item)}');
    }

    final totalPages = (items.length / itemsPerPage).ceil();
    if (totalPages > 1) {
      final navRow = keyboard.row();
      final prevText = lang == 'en' ? '⬅️ Prev' : '⬅️ السابق';
      final nextText = lang == 'en' ? 'Next ➡️' : 'التالي ➡️';

      if (page > 0) {
        navRow.add(prevText, '${togglePrefix}page_${page - 1}');
      }
      navRow.add('📄 ${page + 1}/$totalPages', 'ignore');
      if (endIndex < items.length) {
        navRow.add(nextText, '${togglePrefix}page_${page + 1}');
      }
    }

    final doneText = lang == 'en' ? '✅ Done' : '✅ تم الحفظ';
    keyboard.row().add(doneText, doneData);

    if (backData != null) {
      final defaultBack = lang == 'en' ? '🔙 Back' : '🔙 رجوع';
      keyboard.row().add(backLabel ?? defaultBack, backData);
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
