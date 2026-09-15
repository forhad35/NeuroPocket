import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/ai_result_model.dart';
import '../../../data/repositories/ai_repository.dart';
import 'ai_event.dart';
import 'ai_state.dart';

class AiBloc extends Bloc<AiEvent, AiState> {
  final IAiRepository _aiRepository;

  AiBloc({required this._aiRepository})
      : super(const AiState()) {
    on<ProcessTextEvent>(_onProcessText);
    on<ChangeTaskTypeEvent>(_onChangeTaskType);
    on<ClearAiResultEvent>(_onClearAiResult);
    on<ApplyAlternativeEvent>(_onApplyAlternative);
  }

  Future<void> _onProcessText(
    ProcessTextEvent event,
    Emitter<AiState> emit,
  ) async {
    if (event.text.trim().isEmpty) {
      emit(state.copyWith(
        status: AiStatus.failure,
        errorMessage: 'অনুগ্রহ করে কোনো টেক্সট বা বাক্য লিখুন।',
      ));
      return;
    }

    emit(state.copyWith(
      status: AiStatus.loading,
      currentTaskType: event.taskType,
      errorMessage: null,
    ));

    try {
      final result = await _aiRepository.processText(
        text: event.text,
        taskType: event.taskType,
      );

      emit(state.copyWith(
        status: AiStatus.success,
        result: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AiStatus.failure,
        errorMessage: 'অফলাইন এআই প্রসেসিংয়ে সমস্যা হয়েছে: ${e.toString()}',
      ));
    }
  }

  void _onChangeTaskType(
    ChangeTaskTypeEvent event,
    Emitter<AiState> emit,
  ) {
    emit(state.copyWith(currentTaskType: event.taskType));
  }

  void _onClearAiResult(
    ClearAiResultEvent event,
    Emitter<AiState> emit,
  ) {
    emit(state.copyWith(
      status: AiStatus.initial,
      clearResult: true,
      errorMessage: null,
    ));
  }

  void _onApplyAlternative(
    ApplyAlternativeEvent event,
    Emitter<AiState> emit,
  ) {
    if (state.result != null) {
      final updatedResult = AiResultModel(
        originalText: state.result!.originalText,
        correctedText: event.selectedText,
        explanation: state.result!.explanation,
        alternatives: state.result!.alternatives,
        taskType: state.result!.taskType,
        processingDurationMs: state.result!.processingDurationMs,
        timestamp: DateTime.now(),
      );

      emit(state.copyWith(result: updatedResult));
    }
  }
}
