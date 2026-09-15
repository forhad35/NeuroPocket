import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatStarted extends ChatEvent {
  final bool isBangla;
  const ChatStarted({this.isBangla = false});

  @override
  List<Object?> get props => [isBangla];
}

class ChatMessageSent extends ChatEvent {
  final String message;
  final bool isBangla;

  const ChatMessageSent(this.message, {this.isBangla = false});

  @override
  List<Object?> get props => [message, isBangla];
}

class ChatHistoryCleared extends ChatEvent {
  const ChatHistoryCleared();
}

class ChatSuggestedPromptTapped extends ChatEvent {
  final String prompt;

  const ChatSuggestedPromptTapped(this.prompt);

  @override
  List<Object?> get props => [prompt];
}
