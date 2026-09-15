import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../data/models/ai_task_type.dart';
import '../blocs/floating_bubble/floating_bubble_bloc.dart';
import '../blocs/floating_bubble/floating_bubble_event.dart';
import '../blocs/floating_bubble/floating_bubble_state.dart';
import '../widgets/language_switch_button.dart';
import '../widgets/floating_bubble_overlay.dart';
import '../widgets/system_permission_card.dart';
import '../../data/services/screen_text_scanner.dart';
import 'ai_editor_view.dart';
import 'chat_translator_view.dart';
import 'chat_view.dart';
import 'model_manager_view.dart';
import 'ocr_scanner_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _openEditor(BuildContext context, {String? initialText, AiTaskType? taskType}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AiEditorView(
          initialText: initialText,
          initialTaskType: taskType,
        ),
      ),
    );
  }

  void _openChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ChatView(),
      ),
    );
  }

  void _openChatTranslator(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ChatTranslatorView(),
      ),
    );
  }

  void _openOcr(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const OcrScannerView(),
      ),
    );
  }

  void _openModelManager(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ModelManagerView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          const LanguageSwitchButton(compact: true),
          IconButton(
            tooltip: strings.quickTranslateTitle,
            icon: const Icon(Icons.bolt_rounded),
            onPressed: () => FloatingBubbleOverlay.showCardForText(''),
          ),
          IconButton(
            tooltip: strings.navSettings,
            icon: const Icon(Icons.memory_rounded),
            onPressed: () => _openModelManager(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Status & Hero Card
            ScannableText(
              text: '${strings.editorTitle} - ${strings.editorSubtitle}',
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4F46E5),
                      Color(0xFF06B6D4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withAlpha(60),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(50),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.offline_bolt_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    strings.isBangla ? '১০০% অফলাইন এআই প্রস্তুত' : '100% Offline AI Ready',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        BlocBuilder<FloatingBubbleBloc, FloatingBubbleState>(
                          builder: (context, bubbleState) {
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  context.read<FloatingBubbleBloc>().add(ToggleFloatingBubbleEvent());
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: bubbleState.isEnabled
                                        ? Colors.white.withAlpha(70)
                                        : Colors.white.withAlpha(30),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(100),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        bubbleState.isEnabled ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        strings.isBangla ? 'ভাসমান বল' : 'Floating Ball',
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      strings.editorTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.editorSubtitle,
                      style: TextStyle(
                        color: Colors.white.withAlpha(230),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // System Accessibility & Overlay Permission Card
            const SystemPermissionCard(),

            const SizedBox(height: 12),

            // Smart Chat Translator Action Card (Hi Translate Feature)
            ScannableText(
              text: '${strings.chatTranslatorTitle} - ${strings.chatTranslatorSubtitle}',
              child: InkWell(
                onTap: () => _openChatTranslator(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2563EB).withAlpha(20),
                        const Color(0xFF0D9488).withAlpha(20),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF2563EB).withAlpha(120),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withAlpha(25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF0D9488)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.quickreply_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    strings.chatTranslatorTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withAlpha(30),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              strings.chatTranslatorSubtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodyMedium?.color?.withAlpha(180),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Chat & Conversation Action Card
            ScannableText(
              text: strings.isBangla
                  ? 'এআই চ্যাট ও কথোপকথন - মডেলের সাথে যেকোনো বিষয়ে বাংলা ও ইংরেজিতে কথোপকথন করুন'
                  : 'AI Chat & Conversation - Chat and have fluent conversations with on-device AI in English and Bengali',
              child: InkWell(
                onTap: () => _openChat(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppConstants.primaryColor.withAlpha(90),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withAlpha(25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_rounded,
                          color: AppConstants.primaryColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    strings.isBangla ? 'এআই চ্যাট ও কথোপকথন' : 'AI Chat & Conversation',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppConstants.primaryColor.withAlpha(30),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    strings.isBangla ? 'সরাসরি' : 'LIVE',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              strings.isBangla
                                  ? 'মডেলের সাথে যেকোনো বিষয়ে বাংলা ও ইংরেজিতে কথোপকথন করুন'
                                  : 'Chat and have fluent conversations with on-device AI in English and Bengali',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodyMedium?.color?.withAlpha(180),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // OCR Camera Scanner Card
            ScannableText(
              text: '${strings.ocrCardTitle} - ${strings.ocrCardDesc}',
              child: InkWell(
                onTap: () => _openOcr(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppConstants.accentColor.withAlpha(80),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppConstants.accentColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.document_scanner_rounded,
                          color: AppConstants.accentColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.ocrCardTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              strings.ocrCardDesc,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodyMedium?.color?.withAlpha(180),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // AI Tools Grid Header
            Text(
              strings.toolsSectionTitle,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            // Grid of AI Tools
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemCount: AiTaskType.values.length,
              itemBuilder: (context, index) {
                final task = AiTaskType.values[index];
                final title = task.localizedTitle(strings.isBangla);
                final desc = task.localizedDescription(strings.isBangla);

                return InkWell(
                  onTap: () => _openEditor(context, taskType: task),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.dividerColor.withAlpha(30),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(6),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            task.icon,
                            color: AppConstants.primaryColor,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          desc,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textTheme.bodyMedium?.color?.withAlpha(160),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick Demos / Examples
            Text(
              strings.quickExamplesTitle,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            _DemoExampleTile(
              title: strings.grammarExampleTitle,
              text: 'He go to school yesterday and eat launch with frends.',
              taskType: AiTaskType.grammarCheck,
              onTap: () => _openEditor(
                context,
                initialText: 'He go to school yesterday and eat launch with frends.',
                taskType: AiTaskType.grammarCheck,
              ),
            ),
            _DemoExampleTile(
              title: strings.naturalExampleTitle,
              text: 'Make sure that you help me to finish the work.',
              taskType: AiTaskType.naturalPhrasing,
              onTap: () => _openEditor(
                context,
                initialText: 'Make sure that you help me to finish the work.',
                taskType: AiTaskType.naturalPhrasing,
              ),
            ),
            _DemoExampleTile(
              title: strings.multilingualExampleTitle,
              text: 'ami kalke office ashbo na karon amar shorir kharap',
              taskType: AiTaskType.multilingualRewrite,
              onTap: () => _openEditor(
                context,
                initialText: 'ami kalke office ashbo na karon amar shorir kharap',
                taskType: AiTaskType.multilingualRewrite,
              ),
            ),
            _DemoExampleTile(
              title: strings.ocrCleanExampleTitle,
              text: 'This is a demon-\nstration of the prod-\nuct. 1. Fast speed 2. High accuracy.',
              taskType: AiTaskType.ocrStructuring,
              onTap: () => _openEditor(
                context,
                initialText: 'This is a demon-\nstration of the prod-\nuct. 1. Fast speed 2. High accuracy.',
                taskType: AiTaskType.ocrStructuring,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoExampleTile extends StatelessWidget {
  final String title;
  final String text;
  final AiTaskType taskType;
  final VoidCallback onTap;

  const _DemoExampleTile({
    required this.title,
    required this.text,
    required this.taskType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withAlpha(20),
            ),
          ),
          child: Row(
            children: [
              Icon(taskType.icon, size: 20, color: AppConstants.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: theme.textTheme.bodyMedium?.color?.withAlpha(140),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
