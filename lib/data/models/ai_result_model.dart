import 'package:equatable/equatable.dart';
import 'ai_task_type.dart';

class AlternativeOption extends Equatable {
  final String label; // e.g. "Formal", "Casual", "Concise", "Native English"
  final String text;

  const AlternativeOption({required this.label, required this.text});

  @override
  List<Object?> get props => [label, text];
}

class AiResultModel extends Equatable {
  final String originalText;
  final String correctedText;
  final String explanation;
  final List<AlternativeOption> alternatives;
  final AiTaskType taskType;
  final int processingDurationMs;
  final DateTime timestamp;

  const AiResultModel({
    required this.originalText,
    required this.correctedText,
    this.explanation = '',
    this.alternatives = const [],
    required this.taskType,
    required this.processingDurationMs,
    required this.timestamp,
  });

  bool get hasChanges => originalText.trim() != correctedText.trim();
  bool get hasAlternatives => alternatives.isNotEmpty;
  bool get hasExplanation => explanation.trim().isNotEmpty;

  @override
  List<Object?> get props => [
        originalText,
        correctedText,
        explanation,
        alternatives,
        taskType,
        processingDurationMs,
        timestamp,
      ];
}

