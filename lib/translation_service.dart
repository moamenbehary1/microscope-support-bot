import 'package:translator/translator.dart';
import 'firebase_db.dart';

class TranslationService {
  static final GoogleTranslator _translator = GoogleTranslator();
  static final Map<String, Map<String, String>> _cache = {};
  static bool _initialized = false;

  /// Loads the entire translation dictionary from Firebase on startup
  static Future<void> init() async {
    if (_initialized) return;
    try {
      final arTranslations = await FirebaseDb.getTranslations('ar');
      _cache['ar'] = {};
      arTranslations.forEach((key, value) {
        final decodedKey = Uri.decodeComponent(key.replaceAll('%2E', '.'));
        _cache['ar']![decodedKey] = value;
      });
      _initialized = true;
      print('Loaded ${_cache['ar']?.length ?? 0} translations from cache.');
    } catch (e) {
      print('Translation init error: $e');
    }
  }

  /// Translates a string dynamically. Uses local cache if available,
  /// otherwise calls Google Translate and saves it to Firebase.
  static Future<String> translate(String text, {String to = 'ar'}) async {
    // We only translate when requested language is 'ar'.
    // If it's English, we return original text as it's assumed to be English/Original.
    if (to != 'ar' || text.trim().isEmpty) return text;
    
    // Some strings shouldn't be translated (e.g. urls)
    if (text.startsWith('http://') || text.startsWith('https://')) return text;

    if (_cache[to] == null) {
      _cache[to] = {};
    }

    if (_cache[to]!.containsKey(text)) {
      return _cache[to]![text]!;
    }

    try {
      final translation = await _translator.translate(text, to: to);
      final translatedText = translation.text;
      
      // Save to cache memory
      _cache[to]![text] = translatedText;
      
      // Save to Firebase asynchronously
      FirebaseDb.setTranslation(to, text, translatedText);
      
      return translatedText;
    } catch (e) {
      print('Google Translate error for "$text": $e');
      return text;
    }
  }
}
