import 'package:equatable/equatable.dart';

abstract class FloatingBubbleEvent extends Equatable {
  const FloatingBubbleEvent();

  @override
  List<Object?> get props => [];
}

class InitializeFloatingBubbleEvent extends FloatingBubbleEvent {
  const InitializeFloatingBubbleEvent();
}

class ToggleFloatingBubbleEvent extends FloatingBubbleEvent {
  final bool? isEnabled;
  const ToggleFloatingBubbleEvent({this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class UpdateBubblePositionEvent extends FloatingBubbleEvent {
  final double dx;
  final double dy;
  const UpdateBubblePositionEvent({required this.dx, required this.dy});

  @override
  List<Object?> get props => [dx, dy];
}

class QuickTranslateTextEvent extends FloatingBubbleEvent {
  final String text;
  final String action; // 'translate_bn', 'translate_en', 'fix_grammar', 'polish'

  const QuickTranslateTextEvent({
    required this.text,
    required this.action,
  });

  @override
  List<Object?> get props => [text, action];
}

class ClearQuickTranslateResultEvent extends FloatingBubbleEvent {
  const ClearQuickTranslateResultEvent();
}

