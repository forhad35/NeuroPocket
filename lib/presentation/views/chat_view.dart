import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/localization/app_strings.dart';
import '../../data/models/chat_message.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/chat/chat_state.dart';
import '../blocs/model_manager/model_manager_bloc.dart';
import '../blocs/model_manager/model_manager_state.dart';
import '../widgets/language_switch_button.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<String> _getSuggestedPrompts(AppStrings strings) {
    if (strings.isBangla) {
      return [
        strings.quickPrompt1,
        strings.quickPrompt2,
        strings.quickPrompt3,
        'কেমন আছো? অফলাইনে কি কি কাজ করতে পারো?',
        'একটি ফরমাল ছুটির দরখাস্ত লিখে দাও',
      ];
    }
    return [
      strings.quickPrompt1,
      strings.quickPrompt2,
      strings.quickPrompt3,
      'Explain rules for Present Perfect vs Past Simple',
      'Proofread my presentation introduction',
    ];
  }

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const ChatStarted());
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatBloc>().add(ChatMessageSent(text));
    _textController.clear();
    _scrollToBottom();
  }

  void _sendSuggested(String prompt) {
    context.read<ChatBloc>().add(ChatSuggestedPromptTapped(prompt));
    _scrollToBottom();
  }

  void _confirmClearChat(AppStrings strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.isBangla ? 'কথোপকথন মুছে ফেলবেন?' : 'Clear Conversation?'),
        content: Text(strings.isBangla
            ? 'আপনার বর্তমান চ্যাট হিস্ট্রি মুছে নতুন সেশন শুরু হবে।'
            : 'Your current chat history will be cleared and a new session will begin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(strings.isBangla ? 'না' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ChatBloc>().add(const ChatHistoryCleared());
            },
            child: Text(strings.isBangla ? 'হ্যাঁ, মুছে ফেলুন' : 'Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.chatTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                BlocBuilder<ModelManagerBloc, ModelManagerState>(
                  builder: (context, modelState) {
                    final modelName = modelState.activeModel?.name ?? 'On-Device GGUF';
                    return Text(
                      '${strings.onDeviceBadge} • $modelName',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10.5,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          const LanguageSwitchButton(compact: true),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: strings.clearChat,
            onPressed: () => _confirmClearChat(strings),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Suggestion chips
            _buildSuggestionBar(theme, strings),

            const Divider(height: 1),

            // Messages list
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  _scrollToBottom();
                },
                builder: (context, state) {
                  final messages = state.messages;

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: messages.length + (state.isGenerating ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && state.isGenerating) {
                        return _buildTypingIndicator(theme);
                      }
                      final msg = messages[index];
                      return _buildMessageBubble(msg, theme);
                    },
                  );
                },
              ),
            ),

            // Input area
            _buildInputArea(theme, strings),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionBar(ThemeData theme, AppStrings strings) {
    final prompts = _getSuggestedPrompts(strings);
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: prompts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return ActionChip(
            label: Text(
              prompt,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            avatar: const Icon(Icons.auto_awesome, size: 14),
            onPressed: () => _sendSuggested(prompt),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, ThemeData theme) {
    final isUser = msg.isUser;
    final isError = msg.isError;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.smart_toy_outlined,
                size: 18,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isError
                    ? theme.colorScheme.errorContainer
                    : isUser
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isError
                      ? theme.colorScheme.error
                      : isUser
                          ? Colors.transparent
                          : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    msg.text,
                    style: TextStyle(
                      color: isError
                          ? theme.colorScheme.onErrorContainer
                          : isUser
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(msg.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: (isUser
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface)
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      if (!isUser) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: msg.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('টেক্সট কপি করা হয়েছে'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.copy_rounded,
                            size: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(
                Icons.person_outline,
                size: 18,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.smart_toy_outlined,
              size: 18,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitThreeBounce(
                  color: theme.colorScheme.primary,
                  size: 16.0,
                ),
                const SizedBox(width: 10),
                Text(
                  'Thinking offline...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: strings.chatPlaceholder,
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final isGenerating = state.isGenerating;

              return IconButton.filled(
                onPressed: isGenerating ? null : _sendMessage,
                icon: const Icon(Icons.send_rounded),
                tooltip: 'Send Message',
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
