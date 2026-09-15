import 'package:equatable/equatable.dart';

enum QuickTranslateStatus { initial, loading, success, failure }

class FloatingBubbleState extends Equatable {
  final bool isEnabled;
  final double posX;
  final double posY;
  final QuickTranslateStatus status;
  final String? originalText;
  final String? resultText;
  final String? errorMessage;
  final String lastAction;

  const FloatingBubbleState({
    this.isEnabled = true,
    this.posX = 320.0,
    this.posY = 350.0,
    this.status = QuickTranslateStatus.initial,
    this.originalText,
    this.resultText,
    this.errorMessage,
    this.lastAction = 'translate_bn',
  });

  FloatingBubbleState copyWith({
    bool? isEnabled,
    double? posX,
    double? posY,
    QuickTranslateStatus? status,
    String? originalText,
    String? resultText,
    String? errorMessage,
    String? lastAction,
  }) {
    return FloatingBubbleState(
      isEnabled: isEnabled ?? this.isEnabled,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      status: status ?? this.status,
      originalText: originalText ?? this.originalText,
      resultText: resultText ?? this.resultText,
      errorMessage: errorMessage ?? this.errorMessage,
      lastAction: lastAction ?? this.lastAction,
    );
  }

  @override
  List<Object?> get props => [
        isEnabled,
        posX,
        posY,
        status,
        originalText,
        resultText,
        errorMessage,
        lastAction,
      ];
}

