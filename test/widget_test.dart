import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ai/data/models/ai_result_model.dart';
import 'package:flutter_ai/data/models/ai_task_type.dart';
import 'package:flutter_ai/data/models/chat_message.dart';
import 'package:flutter_ai/data/models/model_status.dart';
import 'package:flutter_ai/data/repositories/chat_repository.dart';
import 'package:flutter_ai/data/services/ai_engine_service.dart';
import 'package:flutter_ai/data/services/ai_prompt_builder.dart';
import 'package:flutter_ai/data/services/clipboard_watcher_service.dart';
import 'package:flutter_ai/data/services/on_device_llm_service.dart';
import 'package:flutter_ai/main.dart';
import 'package:flutter_ai/presentation/blocs/chat/chat_bloc.dart';
import 'package:flutter_ai/presentation/blocs/chat/chat_event.dart';
import 'package:flutter_ai/presentation/blocs/chat_translator/chat_translator_bloc.dart';
import 'package:flutter_ai/presentation/blocs/chat_translator/chat_translator_event.dart';
import 'package:flutter_ai/presentation/blocs/chat_translator/chat_translator_state.dart';
import 'package:flutter_ai/presentation/blocs/floating_bubble/floating_bubble_bloc.dart';
import 'package:flutter_ai/presentation/blocs/floating_bubble/floating_bubble_event.dart';
import 'package:flutter_ai/presentation/blocs/floating_bubble/floating_bubble_state.dart';
import 'package:flutter_ai/presentation/blocs/model_manager/model_manager_bloc.dart';
import 'package:flutter_ai/presentation/blocs/model_manager/model_manager_event.dart';

class FakeOnDeviceLlmService implements IOnDeviceLlmService {
  String? _activeModelId = 'qwen-2.5-0.5b';
  bool _isLoaded = true;

  @override
  String? get activeModelId => _activeModelId;

  @override
  bool get isModelLoaded => _isLoaded;

  @override
  List<LocalModelInfo> get supportedModels => OnDeviceLlmService.defaultModelCatalog;

  @override
  Future<void> cancelDownload(String modelId) async {}

  @override
  Future<void> deleteModel(String modelId) async {}

  @override
  Future<void> downloadModel(
    String modelId, {
    void Function(double progress, int downloadedBytes, int totalBytes)? onProgress,
  }) async {
    onProgress?.call(0.5, 1000, 2000);
    onProgress?.call(1.0, 2000, 2000);
  }

  @override
  Future<String?> getModelFilePath(String modelId) async => '/fake/path/$modelId.gguf';

  @override
  Future<List<LocalModelInfo>> getModelStatusList() async {
    return supportedModels.map((m) {
      if (m.id == _activeModelId) {
        return m.copyWith(state: LocalModelState.active, progress: 1.0);
      }
      return m.copyWith(state: LocalModelState.ready, progress: 1.0);
    }).toList();
  }

  @override
  Future<bool> isModelDownloaded(String modelId) async => true;

  @override
  Future<void> loadModel(String modelId) async {
    _activeModelId = modelId;
    _isLoaded = true;
  }

  @override
  Future<void> unloadModel() async {
    _isLoaded = false;
  }

  @override
  Stream<String> generateStream({
    required String prompt,
    List<ChatMessage>? conversationHistory,
    AiTaskType? taskType,
    int maxTokens = 512,
    double temperature = 0.3,
  }) async* {
    yield 'Hello from ';
    yield 'on-device GGUF model!';
  }

  @override
  Future<String> generateText({
    required String prompt,
    List<ChatMessage>? conversationHistory,
    AiTaskType? taskType,
    int maxTokens = 512,
    double temperature = 0.3,
  }) async {
    if (prompt.contains('motivational quote')) {
      return 'Continuous learning is the minimum requirement for success in any field.';
    }
    if (prompt.contains('Translate the following received chat message') || prompt.contains('Translate the given text')) {
      return 'আমি শীঘ্রই আপনার সাথে যোগাযোগ করব।';
    }
    if (prompt.contains('Compose a ready-to-send reply message')) {
      return 'Sure, I would be glad to help you with that!';
    }
    return '[CORRECTED]\nHe went to school yesterday and was very happy.\n[/CORRECTED]\n\n[EXPLANATION]\n• Corrected past tense verb agreement.\n[/EXPLANATION]\n\n[ALTERNATIVES]\n- Formal: He attended school yesterday.\n- Casual: He went to school yesterday.\n[/ALTERNATIVES]';
  }

  @override
  Future<AiResultModel> processAiTask({
    required String text,
    required AiTaskType taskType,
  }) async {
    await generateText(prompt: text, taskType: taskType);
    return AiResultModel(
      originalText: text,
      correctedText: 'He went to school yesterday and was very happy.',
      explanation: '• Corrected past tense verb agreement.',
      alternatives: const [
        AlternativeOption(label: 'Formal', text: 'He attended school yesterday.'),
        AlternativeOption(label: 'Casual', text: 'He went to school yesterday.'),
      ],
      taskType: taskType,
      processingDurationMs: 120,
      timestamp: DateTime.now(),
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AI Prompt Builder Tests', () {
    test('builds prompt for grammar check', () {
      final prompt = AiPromptBuilder.buildPrompt('He go to school', AiTaskType.grammarCheck);
      expect(prompt.contains('grammar, spelling, punctuation'), isTrue);
      expect(prompt.contains('He go to school'), isTrue);
      expect(prompt.contains('[CORRECTED]'), isTrue);
    });

    test('builds prompt for sentence alternatives', () {
      final prompt = AiPromptBuilder.buildPrompt('I need help', AiTaskType.sentenceAlternatives);
      expect(prompt.contains('[ALTERNATIVES]'), isTrue);
      expect(prompt.contains('I need help'), isTrue);
    });

    test('builds prompt for OCR structuring', () {
      final prompt = AiPromptBuilder.buildPrompt('Raw broken line', AiTaskType.ocrStructuring);
      expect(prompt.contains('OCR post-processing'), isTrue);
    });

    test('builds prompt for multilingual rewrite', () {
      final prompt = AiPromptBuilder.buildPrompt('ami ashbo na', AiTaskType.multilingualRewrite);
      expect(prompt.contains('multilingual communications'), isTrue);
    });

    test('builds prompt for social chat replies and translations', () {
      final replyPrompt = AiPromptBuilder.buildChatReplyPrompt(
        message: 'Can you help me?',
        tone: 'Casual & Friendly',
      );
      expect(replyPrompt.contains('Casual & Friendly'), isTrue);

      final transPrompt = AiPromptBuilder.buildQuickTranslatePrompt(
        text: 'Good morning',
        action: 'translate_bn',
      );
      expect(transPrompt.contains('fluent, natural Bengali'), isTrue);
    });
  });

  group('On-Device LLM & Offline Engine Tests', () {
    test('OfflineAiEngineService processes text through on-device LLM service', () async {
      final fakeService = FakeOnDeviceLlmService();
      final engine = OfflineAiEngineService(onDeviceLlmService: fakeService);

      final isAvail = await engine.isModelAvailable();
      expect(isAvail, isTrue);

      final result = await engine.processText(
        text: 'he go to school yesterday',
        taskType: AiTaskType.grammarCheck,
      );

      expect(result.correctedText, contains('went to school'));
      expect(result.explanation.isNotEmpty, isTrue);
      expect(result.alternatives.length, equals(2));
    });
  });

  group('Offline AI Chat & Conversation Tests', () {
    test('Chat repository gives initial welcome message and generates responses via LLM', () async {
      final fakeService = FakeOnDeviceLlmService();
      final repo = ChatRepository(onDeviceLlmService: fakeService);
      final initial = repo.getInitialMessages();
      expect(initial.length, equals(1));
      expect(initial.first.sender, equals(MessageSender.ai));

      final response = await repo.sendMessage(
        prompt: 'Give me a quote',
        conversationHistory: initial,
      );
      expect(response.sender, equals(MessageSender.ai));
      expect(response.text.isNotEmpty, isTrue);
    });

    test('ChatBloc processes message sending lifecycle', () async {
      final fakeService = FakeOnDeviceLlmService();
      final repo = ChatRepository(onDeviceLlmService: fakeService);
      final bloc = ChatBloc(repository: repo);
      bloc.add(const ChatStarted());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.messages.length, equals(1));

      bloc.add(const ChatMessageSent('Hello AI'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.messages.length, equals(3));
      expect(bloc.state.messages[1].isUser, isTrue);
      expect(bloc.state.messages[2].isAi, isTrue);

      await bloc.close();
    });
  });

  group('FloatingBubbleBloc Tests (Hi Translate Feature 1)', () {
    test('Toggle bubble, update position, and run quick translation', () async {
      final fakeService = FakeOnDeviceLlmService();
      final bloc = FloatingBubbleBloc(onDeviceLlmService: fakeService);

      bloc.add(const ToggleFloatingBubbleEvent(isEnabled: false));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.isEnabled, isFalse);

      bloc.add(const ToggleFloatingBubbleEvent(isEnabled: true));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.isEnabled, isTrue);

      bloc.add(const UpdateBubblePositionEvent(dx: 100, dy: 200));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.posX, equals(100));
      expect(bloc.state.posY, equals(200));

      bloc.add(const QuickTranslateTextEvent(text: 'How are you?', action: 'translate_bn'));
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state.status, equals(QuickTranslateStatus.success));
      expect(bloc.state.resultText, isNotNull);

      await bloc.close();
    });
  });

  group('ChatTranslatorBloc Tests (Hi Translate Feature 3)', () {
    test('Translate incoming message and generate outgoing reply', () async {
      final fakeService = FakeOnDeviceLlmService();
      final bloc = ChatTranslatorBloc(onDeviceLlmService: fakeService);

      bloc.add(const TranslateIncomingMessageEvent(text: 'Please send the report'));
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state.status, equals(ChatTranslatorStatus.success));
      expect(bloc.state.translatedIncoming, isNotNull);

      bloc.add(const GenerateOutgoingReplyEvent(
        draftReply: 'Ami pathiye dichi',
        tone: 'Formal & Business',
      ));
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state.status, equals(ChatTranslatorStatus.success));
      expect(bloc.state.generatedReply, isNotNull);

      await bloc.close();
    });
  });

  group('ModelManagerBloc Tests', () {
    test('Check status and test model inference', () async {
      final fakeService = FakeOnDeviceLlmService();
      final bloc = ModelManagerBloc(onDeviceLlmService: fakeService);

      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.availableModels.isNotEmpty, isTrue);

      bloc.add(const TestModelInferenceEvent(prompt: 'motivational quote'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.testInferenceSuccess, isTrue);
      expect(bloc.state.testResult, contains('Continuous learning'));

      await bloc.close();
    });

    test('Download model updates progress and status', () async {
      final fakeService = FakeOnDeviceLlmService();
      final bloc = ModelManagerBloc(onDeviceLlmService: fakeService);

      bloc.add(const DownloadModelEvent('smollm2-360m'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.successMessage, isNotNull);

      await bloc.close();
    });
  });

  group('ClipboardWatcherService Tests (Hi Translate Feature 2)', () {
    test('Service instance starts and stops properly', () {
      final service = ClipboardWatcherService();
      expect(service.isWatching, isFalse);
      service.startWatching();
      expect(service.isWatching, isTrue);
      service.stopWatching();
      expect(service.isWatching, isFalse);
    });
  });

  testWidgets('App loads and displays title and chat card', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() {
      tester.view.resetPhysicalSize();
      ClipboardWatcherService().stopWatching();
    });

    await tester.pumpWidget(const OfflineAiApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    ClipboardWatcherService().stopWatching();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data == '১০০% অফলাইন এআই প্রস্তুত' ||
                widget.data == '100% Offline AI Ready'),
      ),
      findsOneWidget,
    );
  });
}
