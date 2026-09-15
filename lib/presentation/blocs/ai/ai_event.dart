import 'package:equatable/equatable.dart';
import '../../../data/models/ai_task_type.dart';

abstract class AiEvent extends Equatable {
  const AiEvent();

  @override
  List<Object?> get props => [];
}

class ProcessTextEvent extends AiEvent {
  final String text;
  final AiTaskType taskType;

  const ProcessTextEvent({
    required this.text,
    required this.taskType,
  });

  @override
  List<Object?> get props => [text, taskType];
}

class ChangeTaskTypeEvent extends AiEvent {
  final AiTaskType taskType;

  const ChangeTaskTypeEvent(this.taskType);

  @override
  List<Object?> get props => [taskType];
}

class ClearAiResultEvent extends AiEvent {}

class ApplyAlternativeEvent extends AiEvent {
  final String selectedText;

  const ApplyAlternativeEvent(this.selectedText);

  @override
  List<Object?> get props => [selectedText];
}

