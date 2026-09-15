import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../data/models/ai_task_type.dart';
import '../widgets/language_switch_button.dart';
import 'ai_editor_view.dart';
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
            Container(
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
                    color: const Color(0xFF4F46E5).withAlpha(80),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withAlpha(80)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wifi_off_rounded, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              '100% Offline AI Ready',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _openModelManager(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.settings, size: 13, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Models',
                                style: TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
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

            const SizedBox(height: 16),

            // Chat & Conversation Action Card (NEW)
            InkWell(
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
                        Icons.forum_rounded,
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
                                  strings.chatTitle,
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
                                  color: Colors.green.withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'AI',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            strings.isBangla
                                ? 'মডেলের সাথে যেকোনো বিষয়ে বাংলা ও ইংরেজিতে প্রশ্ন-উত্তর ও কথোপকথন করুন'
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

            const SizedBox(height: 12),

            // OCR Quick Action Card
            InkWell(
              onTap: () => _openOcr(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppConstants.secondaryColor.withAlpha(80),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.secondaryColor.withAlpha(20),
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
                        color: AppConstants.secondaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        color: AppConstants.secondaryColor,
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
                                  strings.ocrTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.bolt_rounded,
                                size: 16,
                                color: AppConstants.accentColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            strings.ocrSubtitle,
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

            const SizedBox(height: 22),

            Text(
              strings.isBangla ? 'এআই রাইটিং টুলস:' : 'AI Writing Tools:',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),

            // 6 AI Task Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              itemCount: AiTaskType.values.length,
              itemBuilder: (context, index) {
                final task = AiTaskType.values[index];
                return InkWell(
                  onTap: () => _openEditor(context, taskType: task),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: task.badgeColor.withAlpha(40),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: task.badgeColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            task.icon,
                            color: task.badgeColor,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          task.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task.banglaTitle,
                          style: TextStyle(
                            fontSize: 11.5,
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

            const SizedBox(height: 22),

            // Quick Demo Examples
            const Text(
              'দ্রুত টেস্ট করার জন্য উদাহরণ:',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),

            _DemoExampleTile(
              title: 'Grammar Fix Example',
              text: 'He go to school yesterday and he are very happy.',
              taskType: AiTaskType.grammarCheck,
              onTap: () => _openEditor(
                context,
                initialText: 'He go to school yesterday and he are very happy.',
                taskType: AiTaskType.grammarCheck,
              ),
            ),
            _DemoExampleTile(
              title: 'Alternative Suggestions Example',
              text: 'I want to say thanks for your help in this project.',
              taskType: AiTaskType.sentenceAlternatives,
              onTap: () => _openEditor(
                context,
                initialText: 'I want to say thanks for your help in this project.',
                taskType: AiTaskType.sentenceAlternatives,
              ),
            ),
            _DemoExampleTile(
              title: 'Natural Phrasing Example',
              text: 'Make sure that you help me to finish the work.',
              taskType: AiTaskType.naturalPhrasing,
              onTap: () => _openEditor(
                context,
                initialText: 'Make sure that you help me to finish the work.',
                taskType: AiTaskType.naturalPhrasing,
              ),
            ),
            _DemoExampleTile(
              title: 'Polite & Professional Rewrite',
              text: 'ami kalke office ashbo na karon amar shorir kharap',
              taskType: AiTaskType.multilingualRewrite,
              onTap: () => _openEditor(
                context,
                initialText: 'ami kalke office ashbo na karon amar shorir kharap',
                taskType: AiTaskType.multilingualRewrite,
              ),
            ),
            _DemoExampleTile(
              title: 'OCR Cleanup & Formatting',
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
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withAlpha(40)),
          ),
          child: Row(
            children: [
              Icon(
                taskType.icon,
                size: 16,
                color: taskType.badgeColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
