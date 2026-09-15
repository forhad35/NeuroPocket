import 'package:equatable/equatable.dart';
import '../../../data/models/chat_message.dart';

abstract class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isGenerating;

  const ChatState({
    this.messages = const [],
    this.isGenerating = false,
  });

  @override
  List<Object?> get props => [messages, isGenerating];
}

class ChatInitial extends ChatState {
  const ChatInitial() : super(messages: const [], isGenerating: false);
}

class ChatLoaded extends ChatState {
  const ChatLoaded({
    required super.messages,
    super.isGenerating,
  });

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isGenerating,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}

class ChatError extends ChatState {
  final String errorMessage;

  const ChatError({
    required super.messages,
    required this.errorMessage,
  }) : super(isGenerating: false);

  @override
  List<Object?> get props => [messages, isGenerating, errorMessage];
}

