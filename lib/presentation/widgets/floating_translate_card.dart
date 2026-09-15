import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../blocs/floating_bubble/floating_bubble_bloc.dart';
import '../blocs/floating_bubble/floating_bubble_event.dart';
import '../blocs/floating_bubble/floating_bubble_state.dart';

/// Hi Translate Style Floating Translation Card that hovers directly on screen
class FloatingTranslateCard extends StatefulWidget {
  final VoidCallback onClose;
  final String? initialText;

  const FloatingTranslateCard({
    super.key,
    required this.onClose,
    this.initialText,
  });

  @override
  State<FloatingTranslateCard> createState() => _FloatingTranslateCardState();
}

class _FloatingTranslateCardState extends State<FloatingTranslateCard> {
  late final TextEditingController _controller;
  String _selectedAction = 'translate_bn';
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
    if (widget.initialText != null && widget.initialText!.trim().isNotEmpty) {
      _runAction('translate_bn');
    }
  }

  @override
  void didUpdateWidget(covariant FloatingTranslateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != null &&
        widget.initialText != oldWidget.initialText &&
        widget.initialText!.trim().isNotEmpty) {
      _controller.text = widget.initialText!;
      _runAction(_selectedAction);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runAction(String action) {
    setState(() => _selectedAction = action);
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<FloatingBubbleBloc>().add(
            QuickTranslateTextEvent(text: text, action: action),
          );
    }
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _controller.text = data.text!;
      });
      _runAction(_selectedAction);
    }
  }

  void _copyResult(String text) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppStrings.of(context);

    return SizedBox(
      width: 320,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF38BDF8).withAlpha(180),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withAlpha(90),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 90 : 30),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: BlocBuilder<FloatingBubbleBloc, FloatingBubbleState>(
            builder: (context, state) {
              final isLoading = state.status == QuickTranslateStatus.loading;
              final isEnToBn = _selectedAction == 'translate_bn';

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Bar: Language Direction & Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppConstants.primaryColor.withAlpha(60),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isEnToBn ? 'English' : 'Bengali',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.cyanAccent
                                    : AppConstants.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                final nextAction = isEnToBn
                                    ? 'translate_en'
                                    : 'translate_bn';
                                _runAction(nextAction);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.all(2),
                                child: Icon(
                                  Icons.swap_horiz_rounded,
                                  size: 16,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isEnToBn ? 'Bengali' : 'English',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.cyanAccent
                                    : AppConstants.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: widget.onClose,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withAlpha(isDark ? 60 : 30),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Input Box with Paste Button
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withAlpha(isDark ? 40 : 30),
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(fontSize: 12.5),
                            maxLines: 2,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: strings.quickTranslateInputHint,
                              hintStyle: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 4),
                            ),
                            onSubmitted: (_) => _runAction(_selectedAction),
                          ),
                        ),
                        InkWell(
                          onTap: _pasteFromClipboard,
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.content_paste_rounded,
                                size: 16, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 2),
                        InkWell(
                          onTap: () => _runAction(_selectedAction),
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.arrow_forward_rounded,
                                size: 18, color: AppConstants.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Result Section
                  if (isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SpinKitThreeBounce(
                              color: isDark
                                  ? const Color(0xFF38BDF8)
                                  : AppConstants.primaryColor,
                              size: 18.0,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              strings.quickTranslating,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (state.resultText != null &&
                      state.resultText!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0B192C)
                            : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF0284C7).withAlpha(60),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SelectableText(
                            state.resultText!,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_copied)
                                Text(
                                  strings.quickTranslateCopied,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () =>
                                    _copyResult(state.resultText!),
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(
                                    _copied
                                        ? Icons.check_circle_rounded
                                        : Icons.copy_rounded,
                                    size: 15,
                                    color: _copied
                                        ? Colors.green
                                        : AppConstants.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Action Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickChip(
                          label: isEnToBn ? 'EN ➔ BN' : 'BN ➔ EN',
                          action: isEnToBn ? 'translate_bn' : 'translate_en',
                          icon: Icons.translate_rounded,
                        ),
                        const SizedBox(width: 4),
                        _buildQuickChip(
                          label: strings.quickFixAction,
                          action: 'fix_grammar',
                          icon: Icons.spellcheck_rounded,
                        ),
                        const SizedBox(width: 4),
                        _buildQuickChip(
                          label: strings.quickPolishAction,
                          action: 'polish',
                          icon: Icons.auto_awesome_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuickChip({
    required String label,
    required String action,
    required IconData icon,
  }) {
    final isSelected = _selectedAction == action;
    return InkWell(
      onTap: () => _runAction(action),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.primaryColor
              : Colors.grey.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isSelected ? Colors.white : AppConstants.primaryColor,
            ),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
