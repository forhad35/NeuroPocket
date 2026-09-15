import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/ai_prompt_builder.dart';
import '../../../data/services/on_device_llm_service.dart';
import 'chat_translator_event.dart';
import 'chat_translator_state.dart';

class ChatTranslatorBloc extends Bloc<ChatTranslatorEvent, ChatTranslatorState> {
  final IOnDeviceLlmService _onDeviceLlmService;

  ChatTranslatorBloc({IOnDeviceLlmService? onDeviceLlmService})
      : _onDeviceLlmService = onDeviceLlmService ?? OnDeviceLlmService(),
        super(const ChatTranslatorState()) {
    on<TranslateIncomingMessageEvent>(_onTranslateIncoming);
    on<GenerateOutgoingReplyEvent>(_onGenerateOutgoing);
    on<ChangeChatToneEvent>(_onChangeTone);
    on<SelectQuickTemplateEvent>(_onSelectTemplate);
    on<ClearChatTranslatorEvent>(_onClear);
  }

  Future<void> _onTranslateIncoming(
    TranslateIncomingMessageEvent event,
    Emitter<ChatTranslatorState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;

    emit(state.copyWith(
      status: ChatTranslatorStatus.loadingIncoming,
      incomingText: text,
      errorMessage: null,
    ));

    try {
      final prompt = AiPromptBuilder.buildIncomingTranslationPrompt(
        message: text,
        toBangla: event.toBangla,
      );

      final result = await _onDeviceLlmService.generateText(prompt: prompt);
      emit(state.copyWith(
        status: ChatTranslatorStatus.success,
        translatedIncoming: result.trim(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatTranslatorStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onGenerateOutgoing(
    GenerateOutgoingReplyEvent event,
    Emitter<ChatTranslatorState> emit,
  ) async {
    final text = event.draftReply.trim();
    if (text.isEmpty) return;

    emit(state.copyWith(
      status: ChatTranslatorStatus.loadingOutgoing,
      draftReply: text,
      selectedTone: event.tone,
      errorMessage: null,
    ));

    try {
      final prompt = AiPromptBuilder.buildChatReplyPrompt(
        message: text,
        tone: event.tone,
        isBanglaTarget: event.isBanglaTarget,
      );

      final result = await _onDeviceLlmService.generateText(prompt: prompt);
      emit(state.copyWith(
        status: ChatTranslatorStatus.success,
        generatedReply: result.trim(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatTranslatorStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onChangeTone(
    ChangeChatToneEvent event,
    Emitter<ChatTranslatorState> emit,
  ) {
    emit(state.copyWith(selectedTone: event.tone));
    if (state.draftReply != null && state.draftReply!.trim().isNotEmpty) {
      add(GenerateOutgoingReplyEvent(
        draftReply: state.draftReply!,
        tone: event.tone,
      ));
    }
  }

  void _onSelectTemplate(
    SelectQuickTemplateEvent event,
    Emitter<ChatTranslatorState> emit,
  ) {
    emit(state.copyWith(draftReply: event.templateText));
    add(GenerateOutgoingReplyEvent(
      draftReply: event.templateText,
      tone: state.selectedTone,
    ));
  }

  void _onClear(
    ClearChatTranslatorEvent event,
    Emitter<ChatTranslatorState> emit,
  ) {
    emit(const ChatTranslatorState());
  }
}

