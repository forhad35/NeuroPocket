import 'package:equatable/equatable.dart';

enum ChatTranslatorStatus { initial, loadingIncoming, loadingOutgoing, success, failure }

class ChatTranslatorState extends Equatable {
  final ChatTranslatorStatus status;
  final String? incomingText;
  final String? translatedIncoming;
  final String? draftReply;
  final String selectedTone;
  final String? generatedReply;
  final String? errorMessage;

  const ChatTranslatorState({
    this.status = ChatTranslatorStatus.initial,
    this.incomingText,
    this.translatedIncoming,
    this.draftReply,
    this.selectedTone = 'Casual & Friendly',
    this.generatedReply,
    this.errorMessage,
  });

  ChatTranslatorState copyWith({
    ChatTranslatorStatus? status,
    String? incomingText,
    String? translatedIncoming,
    String? draftReply,
    String? selectedTone,
    String? generatedReply,
    String? errorMessage,
  }) {
    return ChatTranslatorState(
      status: status ?? this.status,
      incomingText: incomingText ?? this.incomingText,
      translatedIncoming: translatedIncoming ?? this.translatedIncoming,
      draftReply: draftReply ?? this.draftReply,
      selectedTone: selectedTone ?? this.selectedTone,
      generatedReply: generatedReply ?? this.generatedReply,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        incomingText,
        translatedIncoming,
        draftReply,
        selectedTone,
        generatedReply,
        errorMessage,
      ];
}

