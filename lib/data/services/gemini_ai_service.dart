import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/ai_result_model.dart';
import '../models/ai_task_type.dart';
import '../models/chat_message.dart';
import 'ai_config_service.dart';

class GeminiAiService {
  final String? customApiKey;
  final String? customModelName;

  GeminiAiService({
    this.customApiKey,
    this.customModelName,
  });

  Future<GenerativeModel?> _getModel() async {
    final apiKey = customApiKey ?? await AiConfigService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return null;
    }
    final modelName = customModelName ?? await AiConfigService.getModelName();
    return GenerativeModel(
      model: modelName,
      apiKey: apiKey,
    );
  }

  Future<bool> isAvailable() async {
    final key = customApiKey ?? await AiConfigService.getApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Direct text generation for testing or prompts
  Future<String?> generateText(String prompt) async {
    final model = await _getModel();
    if (model == null) return null;
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text;
  }

  /// Process text with Real Gemini AI Model
  Future<AiResultModel?> processText({
    required String text,
    required AiTaskType taskType,
  }) async {
    final model = await _getModel();
    if (model == null) return null;

    final stopwatch = Stopwatch()..start();
    final systemPrompt = _buildSystemPromptForTask(taskType);
    final prompt = '$systemPrompt\n\nUser Input:\n"$text"';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      stopwatch.stop();

      final rawText = response.text ?? '';
      if (rawText.isEmpty) {
        throw Exception('Gemini returned an empty response');
      }

      return _parseGeminiResponse(
        originalText: text,
        taskType: taskType,
        rawText: rawText,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      rethrow;
    }
  }

  /// Chat with Real Gemini AI Model
  Future<String?> generateChatReply({
    required String prompt,
    required List<ChatMessage> history,
  }) async {
    final model = await _getModel();
    if (model == null) return null;

    final List<Content> contents = [];

    // System instruction context
    contents.add(Content.text(
      'You are a helpful, courteous, and highly intelligent AI writing and language assistant. '
      'You can assist the user in English, Bengali (বাংলা), and Banglish. '
      'Answer clearly, politely, and structure your responses with formatting when useful.',
    ));

    // Convert last 6 history messages
    final recentHistory = history.length > 6 ? history.sublist(history.length - 6) : history;
    for (final msg in recentHistory) {
      if (msg.isUser) {
        contents.add(Content.text('User: ${msg.text}'));
      } else {
        contents.add(Content.model([TextPart(msg.text)]));
      }
    }

    contents.add(Content.text('User: $prompt'));

    final response = await model.generateContent(contents);
    return response.text;
  }

  String _buildSystemPromptForTask(AiTaskType taskType) {
    switch (taskType) {
      case AiTaskType.grammarCheck:
        return 'You are an expert English & Multilingual grammar and punctuation editor. '
            'Analyze the text for spelling, grammar, tone, and punctuation errors. '
            'Format strictly as:\n'
            '[CORRECTED]\n<Accurate and corrected version of text>\n'
            '[EXPLANATION]\n<Brief explanation of errors and grammar rules applied>';

      case AiTaskType.naturalPhrasing:
        return 'You are an elite linguistic editor. '
            'Rewrite the given sentence/text to make it sound completely natural, fluent, engaging, and polished. '
            'Format strictly as:\n'
            '[CORRECTED]\n<Natural, smooth, and fluent rewritten text>\n'
            '[ALTERNATIVES]\n- Conversational: <warm natural version>\n- Professional: <polished workplace version>\n'
            '[EXPLANATION]\n<Why this sounds more native and natural>';

      case AiTaskType.sentenceAlternatives:
        return 'You are a versatile vocabulary and phrasing specialist. '
            'Provide diverse alternative expressions for the user sentence with different tones. '
            'Format strictly as:\n'
            '[CORRECTED]\n<Best overall recommendation>\n'
            '[ALTERNATIVES]\n- Formal: <executive / formal version>\n- Casual: <friendly / conversational version>\n- Concise: <crisp / compact version>\n- Polite: <humble / courteous version>\n'
            '[EXPLANATION]\n<Summary of tone variations>';

      case AiTaskType.paragraphProofread:
        return 'You are a senior publishing editor. '
            'Proofread and elevate the whole paragraph for vocabulary, flow, clarity, structure, and eliminate redundancy while keeping the core message. '
            'Format strictly as:\n'
            '[CORRECTED]\n<High quality proofread paragraph>\n'
            '[EXPLANATION]\n<Key stylistic, flow, and structural improvements>';

      case AiTaskType.ocrStructuring:
        return 'You are an OCR post-processing and document cleanup specialist. '
            'Fix broken line breaks, merge hyphenated split words, organize bullet lists, fix OCR misspellings, and format into a clean structured document. '
            'Format strictly as:\n'
            '[CORRECTED]\n<Clean structured text with lists and headings>\n'
            '[EXPLANATION]\n<List of OCR fixes applied>';

      case AiTaskType.multilingualRewrite:
        return 'You are an expert bilingual communications advisor fluent in English, Bengali, and Banglish (e.g. "ki khobor kemon acho , ami vao nai"). '
            'Understand what the user is expressing, even if written in phonetic Bengali/Banglish or broken phrasing, and provide respectful, polite, and professional versions in BOTH English and Bengali. '
            'Format strictly as:\n'
            '[CORRECTED]\n<Polished English professional translation/rewrite>\n'
            '[ALTERNATIVES]\n- Professional English: <courteous business English version>\n- Polite Bengali: <মার্জিত ও শুদ্ধ বাংলা রূপ>\n- Casual Friendly: <সহজ ও আন্তরিক রূপ>\n'
            '[EXPLANATION]\n<Explanation of meaning and tone etiquette>';
    }
  }

  AiResultModel _parseGeminiResponse({
    required String originalText,
    required AiTaskType taskType,
    required String rawText,
    required int durationMs,
  }) {
    String corrected = originalText;
    String explanation = 'Processed with Google Gemini AI Model.';
    final List<AlternativeOption> alternatives = [];

    final correctedMatch = RegExp(r'\[CORRECTED\]\s*([\s\S]*?)(?=\[ALTERNATIVES\]|\[EXPLANATION\]|$)', caseSensitive: false)
        .firstMatch(rawText);
    if (correctedMatch != null) {
      final text = correctedMatch.group(1)?.trim();
      if (text != null && text.isNotEmpty) {
        corrected = text;
      }
    } else {
      // Fallback: entire text if tags omitted
      corrected = rawText.trim();
    }

    final explanationMatch = RegExp(r'\[EXPLANATION\]\s*([\s\S]*?)$', caseSensitive: false).firstMatch(rawText);
    if (explanationMatch != null) {
      final text = explanationMatch.group(1)?.trim();
      if (text != null && text.isNotEmpty) {
        explanation = text;
      }
    }

    final altMatch = RegExp(r'\[ALTERNATIVES\]\s*([\s\S]*?)(?=\[EXPLANATION\]|$)', caseSensitive: false).firstMatch(rawText);
    if (altMatch != null) {
      final altBlock = altMatch.group(1)?.trim() ?? '';
      final lines = altBlock.split('\n');
      for (final line in lines) {
        final cleanLine = line.trim();
        if (cleanLine.startsWith('-') || cleanLine.startsWith('*') || cleanLine.startsWith('•')) {
          final stripped = cleanLine.replaceFirst(RegExp(r'^[-*•]\s*'), '');
          final colonIdx = stripped.indexOf(':');
          if (colonIdx != -1) {
            final label = stripped.substring(0, colonIdx).trim();
            final altText = stripped.substring(colonIdx + 1).trim();
            if (altText.isNotEmpty) {
              alternatives.add(AlternativeOption(
                label: label,
                text: altText,
              ));
            }
          }
        }
      }
    }

    return AiResultModel(
      originalText: originalText,
      correctedText: corrected,
      explanation: explanation,
      alternatives: alternatives,
      taskType: taskType,
      processingDurationMs: durationMs,
      timestamp: DateTime.now(),
    );
  }
}
