import 'package:equatable/equatable.dart';
import '../../../data/models/ai_result_model.dart';
import '../../../data/models/ai_task_type.dart';

enum AiStatus { initial, loading, success, failure }

class AiState extends Equatable {
  final AiStatus status;
  final AiTaskType currentTaskType;
  final AiResultModel? result;
  final String? errorMessage;

  const AiState({
    this.status = AiStatus.initial,
    this.currentTaskType = AiTaskType.grammarCheck,
    this.result,
    this.errorMessage,
  });

  AiState copyWith({
    AiStatus? status,
    AiTaskType? currentTaskType,
    AiResultModel? result,
    String? errorMessage,
    bool clearResult = false,
  }) {
    return AiState(
      status: status ?? this.status,
      currentTaskType: currentTaskType ?? this.currentTaskType,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, currentTaskType, result, errorMessage];
}

