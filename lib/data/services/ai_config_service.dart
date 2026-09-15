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

  static Future<bool> isRealModelEnabled() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }
}
