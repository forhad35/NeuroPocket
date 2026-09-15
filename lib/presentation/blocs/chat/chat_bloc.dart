import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final IChatRepository _repository;

  ChatBloc({IChatRepository? repository})
      : _repository = repository ?? ChatRepository(),
        super(const ChatInitial()) {
    on<ChatStarted>(_onChatStarted);
    on<ChatMessageSent>(_onChatMessageSent);
    on<ChatHistoryCleared>(_onChatHistoryCleared);
    on<ChatSuggestedPromptTapped>(_onChatSuggestedPromptTapped);
  }

  void _onChatStarted(ChatStarted event, Emitter<ChatState> emit) {
    if (state is ChatInitial || state.messages.isEmpty) {
      final initialMessages = _repository.getInitialMessages(isBangla: event.isBangla);
      emit(ChatLoaded(messages: initialMessages));
    }
  }

  Future<void> _onChatMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.message.trim();
    if (text.isEmpty) return;

    final currentMessages = List<ChatMessage>.from(state.messages);

    final userMessage = ChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    currentMessages.add(userMessage);

    emit(ChatLoaded(
      messages: currentMessages,
      isGenerating: true,
    ));

    try {
      final aiResponse = await _repository.sendMessage(
        prompt: text,
        conversationHistory: currentMessages,
        isBangla: event.isBangla,
      );

      final updatedMessages = List<ChatMessage>.from(currentMessages)..add(aiResponse);

      emit(ChatLoaded(
        messages: updatedMessages,
        isGenerating: false,
      ));
    } catch (e) {
      final errorMessage = ChatMessage(
        id: 'err_${DateTime.now().millisecondsSinceEpoch}',
        text: 'ত্রুটি ঘটেছে: ${e.toString()}',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        isError: true,
      );
      final updatedMessages = List<ChatMessage>.from(currentMessages)..add(errorMessage);

      emit(ChatLoaded(
        messages: updatedMessages,
        isGenerating: false,
      ));
    }
  }

  void _onChatHistoryCleared(
    ChatHistoryCleared event,
    Emitter<ChatState> emit,
  ) {
    final initialMessages = _repository.getInitialMessages();
    emit(ChatLoaded(messages: initialMessages));
  }

  void _onChatSuggestedPromptTapped(
    ChatSuggestedPromptTapped event,
    Emitter<ChatState> emit,
  ) {
    add(ChatMessageSent(event.prompt));
  }
}

