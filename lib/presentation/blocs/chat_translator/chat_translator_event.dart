import 'package:equatable/equatable.dart';

abstract class ChatTranslatorEvent extends Equatable {
  const ChatTranslatorEvent();

  @override
  List<Object?> get props => [];
}

class TranslateIncomingMessageEvent extends ChatTranslatorEvent {
  final String text;
  final bool toBangla;

  const TranslateIncomingMessageEvent({
    required this.text,
    this.toBangla = true,
  });

  @override
  List<Object?> get props => [text, toBangla];
}

class GenerateOutgoingReplyEvent extends ChatTranslatorEvent {
  final String draftReply;
  final String tone;
  final bool isBanglaTarget;

  const GenerateOutgoingReplyEvent({
    required this.draftReply,
    required this.tone,
    this.isBanglaTarget = false,
  });

  @override
  List<Object?> get props => [draftReply, tone, isBanglaTarget];
}

class ChangeChatToneEvent extends ChatTranslatorEvent {
  final String tone;

  const ChangeChatToneEvent(this.tone);

  @override
  List<Object?> get props => [tone];
}

class SelectQuickTemplateEvent extends ChatTranslatorEvent {
  final String templateText;

  const SelectQuickTemplateEvent(this.templateText);

  @override
  List<Object?> get props => [templateText];
}

class ClearChatTranslatorEvent extends ChatTranslatorEvent {
  const ClearChatTranslatorEvent();
}

