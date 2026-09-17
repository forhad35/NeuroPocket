import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/ai_task_type.dart';
import '../repositories/ai_repository.dart';
import 'ai_config_service.dart';
import 'ai_prompt_builder.dart';
import 'gemini_ai_service.dart';
import 'on_device_llm_service.dart';

class AccessibilityServiceHelper {
  static const MethodChannel _channel =
      MethodChannel('com.example.flutter_ai/accessibility');

  /// Register method call handler to provide high-quality on-device AI translations to native Android overlay
  static void initializeAiBridge({AiRepository? aiRepository}) {
    if (!Platform.isAndroid) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'translateWithAi') {
        final text = (call.arguments is Map)
            ? (call.arguments['text'] as String? ?? '')
            : (call.arguments as String? ?? '');
        if (text.trim().isEmpty) return '';

        // Determine user configured target language
        final targetLanguage = await AiConfigService.getTargetLanguage();

        String cleanTranslation(String raw) {
          var s = raw.trim();
          // Strip code blocks
          s = s.replaceAll(RegExp(r'```[\w]*\n?'), '').replaceAll('```', '').trim();
          // Remove conversational prefixes and tags
          s = s.replaceAll(RegExp(r'^(ইনপুট|উত্তর|অনুবাদ|অনুবাদের ফলাফল|Translation|Output|Text|Bengali|English)\s*[:：\-]\s*', caseSensitive: false), '').trim();
          final lines = s.split('\n')
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty && !l.startsWith('ইনপুট:') && !l.startsWith('Input:') && !l.startsWith('Text:'))
              .toList();
          if (lines.isNotEmpty) {
            s = lines.map((l) => l.replaceAll(RegExp(r'^(উত্তর|Output|Translation)\s*[:：\-]\s*', caseSensitive: false), '').trim()).join(' ').trim();
          }
          // Strip wrapping quotes
          if (s.startsWith('"') && s.endsWith('"') && s.length > 2) {
            s = s.substring(1, s.length - 1).trim();
          }
          if (s.startsWith('“') && s.endsWith('”') && s.length > 2) {
            s = s.substring(1, s.length - 1).trim();
          }
          if (s.startsWith("'") && s.endsWith("'") && s.length > 2) {
            s = s.substring(1, s.length - 1).trim();
          }
          return s;
        }

        // State 1: Check if Offline GGUF Local Model is downloaded & ready
        try {
          final llmService = OnDeviceLlmService();
          final activeId = llmService.activeModelId ?? 'qwen-2.5-1.5b';
          final isDownloaded = await llmService.isModelDownloaded(activeId);
          if (isDownloaded) {
            final prompt = AiPromptBuilder.buildQuickTranslatePrompt(
              text: text,
              targetLanguage: targetLanguage,
            );
            final result = await llmService.generateText(
              prompt: prompt,
              maxTokens: 256,
              temperature: 0.1,
            );
            final cleaned = cleanTranslation(result);
            if (cleaned.isNotEmpty && !cleaned.contains('ইনপুট:')) {
              return cleaned;
            }
          }
        } catch (e) {
          debugPrint('LLM translation error: $e');
        }

        // State 2: If No Local Model is downloaded/ready, fallback to Gemini AI
        try {
          final geminiService = GeminiAiService();
          if (await geminiService.isAvailable()) {
            final prompt = AiPromptBuilder.buildQuickTranslatePrompt(
              text: text,
              targetLanguage: targetLanguage,
            );
            final geminiText = await geminiService.generateText(prompt);
            if (geminiText != null) {
              final cleaned = cleanTranslation(geminiText);
              if (cleaned.isNotEmpty) {
                return cleaned;
              }
            }
          }
        } catch (e) {
          debugPrint('Gemini translation error: $e');
        }

        // State 3: Fallback to AiRepository if provided
        try {
          if (aiRepository != null) {
            final res = await aiRepository.processText(
              text: text,
              taskType: AiTaskType.multilingualRewrite,
            );
            final cleaned = cleanTranslation(res.correctedText);
            if (cleaned.isNotEmpty) {
              return cleaned;
            }
          }
        } catch (e) {
          debugPrint('AI Repository translation error: $e');
        }

        return '';
      }
      return null;
    });
  }

  /// Check if the Android Accessibility Service is currently enabled
  static Future<bool> isAccessibilityEnabled() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? result =
          await _channel.invokeMethod<bool>('isAccessibilityEnabled');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Open system Accessibility Settings page
  static Future<void> openAccessibilitySettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  /// Check if Display Over Other Apps (SYSTEM_ALERT_WINDOW) is granted
  static Future<bool> isOverlayPermissionGranted() async {
    if (!Platform.isAndroid) return true;
    try {
      final bool? result =
          await _channel.invokeMethod<bool>('isOverlayPermissionGranted');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Open system Draw Over Other Apps Settings page
  static Future<void> openOverlaySettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openOverlaySettings');
    } catch (_) {}
  }

  /// Start the system-wide Native Floating Lens Service (remains active when app is minimized)
  static Future<bool> startFloatingOverlay() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? result =
          await _channel.invokeMethod<bool>('startFloatingOverlay');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Stop the system-wide Native Floating Lens Service
  static Future<bool> stopFloatingOverlay() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? result =
          await _channel.invokeMethod<bool>('stopFloatingOverlay');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Check if the Native Floating Lens is running
  static Future<bool> isFloatingOverlayRunning() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? result =
          await _channel.invokeMethod<bool>('isFloatingOverlayRunning');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
