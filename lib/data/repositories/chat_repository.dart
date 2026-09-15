import 'dart:async';
import '../models/chat_message.dart';
import '../services/gemini_ai_service.dart';
import '../services/on_device_llm_service.dart';

abstract class IChatRepository {
  List<ChatMessage> getInitialMessages({bool isBangla = false});
  Future<ChatMessage> sendMessage({
    required String prompt,
    required List<ChatMessage> conversationHistory,
    bool isBangla = false,
  });
  Stream<String> streamMessage({
    required String prompt,
    required List<ChatMessage> conversationHistory,
  });
}

class ChatRepository implements IChatRepository {
  final GeminiAiService _geminiService;
  final IOnDeviceLlmService _onDeviceLlmService;

  ChatRepository({
    GeminiAiService? geminiService,
    IOnDeviceLlmService? onDeviceLlmService,
  })  : _geminiService = geminiService ?? GeminiAiService(),
        _onDeviceLlmService = onDeviceLlmService ?? OnDeviceLlmService();

  @override
  List<ChatMessage> getInitialMessages({bool isBangla = false}) {
    return [
      ChatMessage(
        id: 'welcome_1',
        text: isBangla
            ? 'আমি আপনার স্মার্ট অন-ডিভাইস এআই সহকারী (NeuroPocket AI)।\n\nআপনি আমাকে যেকোনো প্রশ্ন করতে পারেন, কোনো টেক্সট কারেক্ট বা রিরাইট করতে বলতে পারেন, অথবা বাংলা ও ইংরেজিতে যেকোনো বিষয়ে সম্পূর্ণ অফলাইনে কথোপকথন করতে পারেন!'
            : 'I am your smart on-device AI assistant (NeuroPocket AI).\n\nYou can ask me any question, request grammar corrections or rewrites, or have full conversational discussions in 100% offline mode!',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ),
    ];
  }

  @override
  Future<ChatMessage> sendMessage({
    required String prompt,
    required List<ChatMessage> conversationHistory,
    bool isBangla = false,
  }) async {
    final cleanPrompt = prompt.trim();
    if (cleanPrompt.isEmpty) {
      throw ArgumentError('Prompt cannot be empty');
    }

    // 1. Check if real Gemini model is enabled and available
    final hasGemini = await _geminiService.isAvailable();
    if (hasGemini) {
      try {
        final geminiReply = await _geminiService.generateChatReply(
          prompt: cleanPrompt,
          history: conversationHistory,
        );
        if (geminiReply != null && geminiReply.isNotEmpty) {
          return ChatMessage(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            text: geminiReply.trim(),
            sender: MessageSender.ai,
            timestamp: DateTime.now(),
          );
        }
      } catch (_) {
        // Fall back to on-device engine
      }
    }

    // 2. Real on-device GGUF LLM inference
    final responseText = await _onDeviceLlmService.generateText(
      prompt: cleanPrompt,
      conversationHistory: conversationHistory,
      maxTokens: 512,
      temperature: 0.3,
    );

    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: responseText.isNotEmpty
          ? responseText
          : (isBangla
              ? 'আমি আপনার অনুরোধটি প্রসেস করতে পারিনি। অনুগ্রহ করে মডেল সেটিংস যাচাই করুন।'
              : 'I could not process your request. Please check model settings.'),
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    );
  }

  @override
  Stream<String> streamMessage({
    required String prompt,
    required List<ChatMessage> conversationHistory,
  }) {
    final cleanPrompt = prompt.trim();
    if (cleanPrompt.isEmpty) {
      throw ArgumentError('Prompt cannot be empty');
    }

    return _onDeviceLlmService.generateStream(
      prompt: cleanPrompt,
      conversationHistory: conversationHistory,
      maxTokens: 512,
      temperature: 0.3,
    );
  }
}
