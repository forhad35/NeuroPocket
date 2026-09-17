import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiConfigService {
  static const String _keyApiKey = 'gemini_api_key';
  static const String _keyModelName = 'gemini_model_name';
  static const String _keyUseRealModel = 'use_real_model';

  static const String defaultModel = 'gemini-1.5-flash';

  // In-memory fallback in case platform channels are not yet compiled/ready
  static String? _memoryApiKey;
  static String _memoryModelName = defaultModel;
  static bool _memoryUseRealModel = false;

  static Future<String?> getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyApiKey) ?? _memoryApiKey;
    } catch (e) {
      debugPrint('SharedPreferences not ready yet, using in-memory cache: $e');
      return _memoryApiKey;
    }
  }

  static Future<void> saveApiKey(String apiKey) async {
    _memoryApiKey = apiKey.trim();
    _memoryUseRealModel = _memoryApiKey!.isNotEmpty;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyApiKey, _memoryApiKey!);
      await prefs.setBool(_keyUseRealModel, _memoryUseRealModel);
    } catch (e) {
      debugPrint('SharedPreferences save failed, preserved in memory: $e');
    }
  }

  static Future<String> getModelName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyModelName) ?? _memoryModelName;
    } catch (e) {
      debugPrint('SharedPreferences not ready, using memory model: $e');
      return _memoryModelName;
    }
  }

  static Future<void> saveModelName(String modelName) async {
    _memoryModelName = modelName;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyModelName, modelName);
    } catch (e) {
      debugPrint('SharedPreferences save model failed, preserved in memory: $e');
    }
  }

  static const String _keyTargetLanguage = 'translation_target_language';
  static const String _keyAutoDetectLang = 'translation_auto_detect';
  static const String defaultTargetLanguage = 'Bengali (বাংলা)';

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'bn', 'name': 'Bengali (বাংলা)', 'flag': '🇧🇩'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'hi', 'name': 'Hindi (हिन्दी)', 'flag': '🇮🇳'},
    {'code': 'ar', 'name': 'Arabic (العربية)', 'flag': '🇸🇦'},
    {'code': 'es', 'name': 'Spanish (Español)', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'French (Français)', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'German (Deutsch)', 'flag': '🇩🇪'},
    {'code': 'ja', 'name': 'Japanese (日本語)', 'flag': '🇯🇵'},
    {'code': 'zh', 'name': 'Chinese (中文)', 'flag': '🇨🇳'},
    {'code': 'ur', 'name': 'Urdu (اردو)', 'flag': '🇵🇰'},
  ];

  static String _memoryTargetLanguage = defaultTargetLanguage;
  static bool _memoryAutoDetect = true;

  static Future<String> getTargetLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyTargetLanguage) ?? _memoryTargetLanguage;
    } catch (e) {
      return _memoryTargetLanguage;
    }
  }

  static Future<void> saveTargetLanguage(String language) async {
    _memoryTargetLanguage = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyTargetLanguage, language);
    } catch (e) {
      debugPrint('Error saving target language: $e');
    }
  }

  static Future<bool> isAutoDetectEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyAutoDetectLang) ?? _memoryAutoDetect;
    } catch (e) {
      return _memoryAutoDetect;
    }
  }

  static Future<void> saveAutoDetectEnabled(bool enabled) async {
    _memoryAutoDetect = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyAutoDetectLang, enabled);
    } catch (e) {
      debugPrint('Error saving auto detect: $e');
    }
  }

  static Future<bool> isRealModelEnabled() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }
}
