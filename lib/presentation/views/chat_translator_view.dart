import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../blocs/chat_translator/chat_translator_bloc.dart';
import '../blocs/chat_translator/chat_translator_event.dart';
import '../blocs/chat_translator/chat_translator_state.dart';
import '../widgets/language_switch_button.dart';
import '../widgets/floating_bubble_overlay.dart';
import '../../data/services/screen_text_scanner.dart';

class ChatTranslatorView extends StatefulWidget {
  const ChatTranslatorView({super.key});

  @override
  State<ChatTranslatorView> createState() => _ChatTranslatorViewState();
}

class _ChatTranslatorViewState extends State<ChatTranslatorView> {
  final TextEditingController _incomingController = TextEditingController();
  final TextEditingController _outgoingController = TextEditingController();

  final List<String> _tones = [
    'Casual & Friendly',
    'Formal & Business',
    'Highly Polite',
    'Short & Direct',
  ];

  List<String> _getTemplates(bool isBangla) {
    if (isBangla) {
      return [
        'ধন্যবাদ, আমি বিষয়টি দেখছি এবং দ্রুত জানাচ্ছি',
        'কালকে কি আমাদের মিটিংটি করা সম্ভব?',
        'আমার শরীর খারাপ থাকায় আজ অফিস আসতে পারছি না',
        'দয়া করে প্রজেক্টের সর্বশেষ আপডেটটি পাঠাবেন',
        'দাম কিছুটা কমিয়ে রাখা সম্ভব কি না জানাবেন',
      ];
    }
    return [
      'Thanks for reaching out, I will check and get back shortly.',
      'Could we reschedule our meeting to tomorrow afternoon?',
      'I am unwell today and requesting leave for the day.',
      'Please share the latest update on the project.',
      'Is there any room for discount on this proposal?',
    ];
  }

  @override
  void dispose() {
    _incomingController.dispose();
    _outgoingController.dispose();
    super.dispose();
  }

  void _pasteIncoming() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() => _incomingController.text = data.text!);
      _translateIncoming();
    }
  }

  void _translateIncoming() {
    final text = _incomingController.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatTranslatorBloc>().add(
            TranslateIncomingMessageEvent(text: text),
          );
    }
  }

  void _generateOutgoing(String tone) {
    final text = _outgoingController.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatTranslatorBloc>().add(
            GenerateOutgoingReplyEvent(draftReply: text, tone: tone),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final templates = _getTemplates(strings.isBangla);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.chatTranslatorTitle),
        actions: [
          const LanguageSwitchButton(compact: true),
          IconButton(
            tooltip: strings.clear,
            icon: const Icon(Icons.clear_all_rounded),
            onPressed: () {
              setState(() {
                _incomingController.clear();
                _outgoingController.clear();
              });
              context.read<ChatTranslatorBloc>().add(const ClearChatTranslatorEvent());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<ChatTranslatorBloc, ChatTranslatorState>(
          listener: (context, state) {
            if (state.draftReply != null && _outgoingController.text != state.draftReply) {
              _outgoingController.text = state.draftReply!;
            }
          },
          builder: (context, state) {
            final isLoadingIncoming = state.status == ChatTranslatorStatus.loadingIncoming;
            final isLoadingOutgoing = state.status == ChatTranslatorStatus.loadingOutgoing;
            final isDark = theme.brightness == Brightness.dark;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF0D9488)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.chatTranslatorTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              strings.chatTranslatorSubtitle,
                              style: TextStyle(
                                color: Colors.white.withAlpha(220),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ==========================================
                // SECTION: LIVE DRAG-TO-TRANSLATE CHAT DEMO
                // ==========================================
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF0284C7).withAlpha(50),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 50 : 15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0072FF), Color(0xFF00C6FF)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.isBangla
                                      ? 'লাইভ ড্র্যাগ ও ট্যাপ ট্রান্সলেটর'
                                      : 'Live Drag & Tap Translator Demo',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                                Text(
                                  strings.isBangla
                                      ? 'মেসেজে ট্যাপ করুন বা লেন্স এনে ছেড়ে দিন'
                                      : 'Tap message or drag the lens over to translate',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Simulated Chat Message 1 (Lily)
                      _buildSimulatedChatBubble(
                        sender: 'Lily • Messenger',
                        avatarColor: const Color(0xFF8B5CF6),
                        text: "Hello, I'm Lily, a toy buyer in London.",
                        isMe: false,
                        theme: theme,
                      ),
                      const SizedBox(height: 8),

                      // Simulated Chat Message 2 (You)
                      _buildSimulatedChatBubble(
                        sender: 'You',
                        avatarColor: AppConstants.primaryColor,
                        text: 'Great to meet you! How can we assist your business?',
                        isMe: true,
                        theme: theme,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ==========================================
                // SECTION 1: INCOMING MESSAGE TRANSLATOR
                // ==========================================
                Text(
                  strings.incomingMessageTitle,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.dividerColor.withAlpha(50)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _incomingController,
                        maxLines: 3,
                        minLines: 2,
                        decoration: InputDecoration(
                          hintText: strings.incomingPlaceholder,
                          hintStyle: TextStyle(
                            color: theme.hintColor.withAlpha(140),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      Row(
                        children: [
                          if (_incomingController.text.isEmpty)
                            InkWell(
                              onTap: _pasteIncoming,
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.paste_rounded, size: 14, color: AppConstants.primaryColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      strings.paste,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppConstants.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: isLoadingIncoming || _incomingController.text.trim().isEmpty
                                ? null
                                : _translateIncoming,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: isLoadingIncoming
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.translate_rounded, size: 15),
                            label: Text(
                              strings.translateIncomingBtn,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Incoming translation result
                if (isLoadingIncoming) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: SpinKitThreeBounce(color: AppConstants.primaryColor, size: 22),
                  ),
                ] else if (state.translatedIncoming != null && state.translatedIncoming!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppConstants.primaryColor.withAlpha(40)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppConstants.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SelectableText(
                            state.translatedIncoming!,
                            style: const TextStyle(fontSize: 13.5, height: 1.4),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: state.translatedIncoming!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(strings.copiedToClipboardToast), duration: const Duration(seconds: 1)),
                            );
                          },
                          child: const Icon(Icons.copy_rounded, size: 16, color: AppConstants.primaryColor),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ==========================================
                // SECTION 2: OUTGOING REPLY COMPOSER
                // ==========================================
                Text(
                  strings.outgoingReplyTitle,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                ),
                const SizedBox(height: 8),

                // Tone Selector Chips
                Text(
                  strings.selectToneTitle,
                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _tones.map((tone) {
                      final isSelected = state.selectedTone == tone;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            _getToneLabel(tone, strings),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppConstants.secondaryColor,
                          onSelected: (_) {
                            context.read<ChatTranslatorBloc>().add(ChangeChatToneEvent(tone));
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),

                // Outgoing Draft Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.dividerColor.withAlpha(50)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _outgoingController,
                        maxLines: 4,
                        minLines: 2,
                        decoration: InputDecoration(
                          hintText: strings.outgoingPlaceholder,
                          hintStyle: TextStyle(
                            color: theme.hintColor.withAlpha(140),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: isLoadingOutgoing || _outgoingController.text.trim().isEmpty
                                ? null
                                : () => _generateOutgoing(state.selectedTone),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.secondaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: isLoadingOutgoing
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.auto_awesome_rounded, size: 16),
                            label: Text(
                              strings.generateReplyBtn,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Quick Templates
                const SizedBox(height: 14),
                Text(
                  strings.quickChatTemplates,
                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: templates.map((tmpl) {
                    return ActionChip(
                      label: Text(tmpl, style: const TextStyle(fontSize: 11)),
                      avatar: const Icon(Icons.flash_on_rounded, size: 13, color: AppConstants.accentColor),
                      onPressed: () {
                        context.read<ChatTranslatorBloc>().add(SelectQuickTemplateEvent(tmpl));
                      },
                    );
                  }).toList(),
                ),

                // Generated Reply Output
                if (isLoadingOutgoing) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: SpinKitThreeBounce(color: AppConstants.secondaryColor, size: 24),
                  ),
                ] else if (state.generatedReply != null && state.generatedReply!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppConstants.secondaryColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppConstants.secondaryColor.withAlpha(50), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.stars_rounded, size: 18, color: AppConstants.secondaryColor),
                            const SizedBox(width: 6),
                            Text(
                              strings.resultTitle,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.secondaryColor,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: state.generatedReply!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(strings.copiedToClipboardToast), duration: const Duration(seconds: 1)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.secondaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.copy_rounded, size: 14),
                              label: Text(strings.copyReply, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          state.generatedReply!,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _getToneLabel(String tone, AppStrings strings) {
    switch (tone) {
      case 'Casual & Friendly':
        return strings.toneCasual;
      case 'Formal & Business':
        return strings.toneFormal;
      case 'Highly Polite':
        return strings.tonePolite;
      case 'Short & Direct':
      default:
        return strings.toneConcise;
    }
  }

  Widget _buildSimulatedChatBubble({
    required String sender,
    required Color avatarColor,
    required String text,
    required bool isMe,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return ScannableText(
      text: text,
      child: InkWell(
        onTap: () {
          FloatingBubbleOverlay.showCardForText(text);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isMe
                ? AppConstants.primaryColor.withAlpha(isDark ? 50 : 25)
                : Colors.grey.withAlpha(isDark ? 40 : 20),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isMe
                  ? AppConstants.primaryColor.withAlpha(60)
                  : Colors.grey.withAlpha(50),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: avatarColor,
                child: Text(
                  sender.isNotEmpty ? sender[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          sender,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isMe
                                ? AppConstants.primaryColor
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0072FF).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_rounded,
                                size: 11,
                                color: Color(0xFF0072FF),
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Translate',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0072FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      text,
                      style: const TextStyle(fontSize: 13, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

