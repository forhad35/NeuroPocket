import 'package:equatable/equatable.dart';

enum MessageSender { user, ai }

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isError = false,
  });

  bool get isUser => sender == MessageSender.user;
  bool get isAi => sender == MessageSender.ai;

  ChatMessage copyWith({
    String? id,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isError,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object?> get props => [id, text, sender, timestamp, isError];
}

