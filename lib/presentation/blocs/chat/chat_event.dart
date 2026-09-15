import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatStarted extends ChatEvent {
  const ChatStarted();
}

class ChatMessageSent extends ChatEvent {
  final String message;

  const ChatMessageSent(this.message);

  @override
  List<Object?> get props => [message];
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

