import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/accessibility_service.dart';
import '../../../data/services/ai_prompt_builder.dart';
import '../../../data/services/on_device_llm_service.dart';
import 'floating_bubble_event.dart';
import 'floating_bubble_state.dart';

class FloatingBubbleBloc extends Bloc<FloatingBubbleEvent, FloatingBubbleState> {
  final IOnDeviceLlmService _onDeviceLlmService;
  static const String _prefBubbleEnabledKey = 'neuropocket_floating_bubble_enabled';

  FloatingBubbleBloc({IOnDeviceLlmService? onDeviceLlmService})
      : _onDeviceLlmService = onDeviceLlmService ?? OnDeviceLlmService(),
        super(const FloatingBubbleState()) {
    on<InitializeFloatingBubbleEvent>(_onInitialize);
    on<ToggleFloatingBubbleEvent>(_onToggleFloatingBubble);
    on<UpdateBubblePositionEvent>(_onUpdateBubblePosition);
    on<QuickTranslateTextEvent>(_onQuickTranslateText);
    on<ClearQuickTranslateResultEvent>(_onClearQuickTranslateResult);
  }

  Future<void> _onInitialize(
    InitializeFloatingBubbleEvent event,
    Emitter<FloatingBubbleState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_prefBubbleEnabledKey) ?? true;
      emit(state.copyWith(isEnabled: enabled));
      if (enabled) {
        await AccessibilityServiceHelper.startFloatingOverlay();
      }
    } catch (_) {}
  }

  Future<void> _onToggleFloatingBubble(
    ToggleFloatingBubbleEvent event,
    Emitter<FloatingBubbleState> emit,
  ) async {
    final nextState = event.isEnabled ?? !state.isEnabled;
    emit(state.copyWith(isEnabled: nextState));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefBubbleEnabledKey, nextState);
      if (nextState) {
        await AccessibilityServiceHelper.startFloatingOverlay();
      } else {
        await AccessibilityServiceHelper.stopFloatingOverlay();
      }
    } catch (_) {}
  }

  void _onUpdateBubblePosition(
    UpdateBubblePositionEvent event,
    Emitter<FloatingBubbleState> emit,
  ) {
    emit(state.copyWith(posX: event.dx, posY: event.dy));
  }

  Future<void> _onQuickTranslateText(
    QuickTranslateTextEvent event,
    Emitter<FloatingBubbleState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;

    emit(state.copyWith(
      status: QuickTranslateStatus.loading,
      originalText: text,
      lastAction: event.action,
      errorMessage: null,
    ));

    try {
      final prompt = AiPromptBuilder.buildQuickTranslatePrompt(
        text: text,
        action: event.action,
      );

      final result = await _onDeviceLlmService.generateText(prompt: prompt);
      emit(state.copyWith(
        status: QuickTranslateStatus.success,
        resultText: result.trim(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: QuickTranslateStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onClearQuickTranslateResult(
    ClearQuickTranslateResultEvent event,
    Emitter<FloatingBubbleState> emit,
  ) {
    emit(state.copyWith(
      status: QuickTranslateStatus.initial,
      originalText: null,
      resultText: null,
      errorMessage: null,
    ));
  }
}

