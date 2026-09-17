import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../data/services/clipboard_watcher_service.dart';
import 'quick_translate_modal.dart';

class ClipboardQuickBar extends StatefulWidget {
  final Widget child;
  const ClipboardQuickBar({super.key, required this.child});

  @override
  State<ClipboardQuickBar> createState() => _ClipboardQuickBarState();
}

class _ClipboardQuickBarState extends State<ClipboardQuickBar> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  StreamSubscription<String>? _sub;
  String? _detectedText;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    final service = ClipboardWatcherService();
    service.startWatching();
    _sub = service.clipboardStream.listen((text) {
      if (mounted && text.isNotEmpty) {
        _showBar(text);
      }
    });
  }

  void _showBar(String text) {
    _autoDismissTimer?.cancel();
    setState(() => _detectedText = text);
    _animController.forward();
    _autoDismissTimer = Timer(const Duration(seconds: 7), () {
      _dismissBar();
    });
  }

  void _dismissBar() {
    _autoDismissTimer?.cancel();
    _animController.reverse().then((_) {
      if (mounted) {
        setState(() => _detectedText = null);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _autoDismissTimer?.cancel();
    ClipboardWatcherService().stopWatching();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Stack(
      children: [
        widget.child,
        if (_detectedText != null)
          Positioned(
            left: 14,
            right: 14,
            bottom: 24,
            child: SlideTransition(
              position: _slideAnimation,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: theme.colorScheme.surfaceContainerHighest,
                shadowColor: Colors.black.withAlpha(80),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppConstants.primaryColor.withAlpha(70),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.content_paste_search_rounded,
                            size: 16,
                            color: AppConstants.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              strings.clipboardDetectedTitle,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _dismissBar,
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.close_rounded, size: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _detectedText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyMedium?.color?.withAlpha(210),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildQuickButton(
                              label: strings.clipboardTranslate,
                              icon: Icons.translate_rounded,
                              color: AppConstants.primaryColor,
                              onTap: () {
                                final text = _detectedText!;
                                _dismissBar();
                                QuickTranslateModal.showCardForText(text);
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildQuickButton(
                              label: strings.clipboardGrammarFix,
                              icon: Icons.spellcheck_rounded,
                              color: AppConstants.secondaryColor,
                              onTap: () {
                                final text = _detectedText!;
                                _dismissBar();
                                QuickTranslateModal.showCardForText(text);
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildQuickButton(
                              label: strings.clipboardProfessional,
                              icon: Icons.auto_awesome_rounded,
                              color: AppConstants.accentColor,
                              onTap: () {
                                final text = _detectedText!;
                                _dismissBar();
                                QuickTranslateModal.showCardForText(text);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
