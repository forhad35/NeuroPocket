import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../blocs/floating_bubble/floating_bubble_bloc.dart';
import '../blocs/floating_bubble/floating_bubble_event.dart';
import '../blocs/floating_bubble/floating_bubble_state.dart';

class QuickTranslateModal extends StatefulWidget {
  final String? initialText;
  const QuickTranslateModal({super.key, this.initialText});

  static bool _isOpen = false;
  static bool get isOpen => _isOpen;

  static void hide() {
    if (_isOpen) {
      AppConstants.rootNavigatorKey.currentState?.maybePop();
      _isOpen = false;
    }
  }

  static void showCardForText(String text) {
    show(initialText: text);
  }

  static Future<void> show({BuildContext? context, String? initialText}) async {
    if (_isOpen) {
      return;
    }
    final ctx = (context != null && Navigator.maybeOf(context) != null)
        ? context
        : (AppConstants.rootNavigatorKey.currentContext ??
            AppConstants.rootNavigatorKey.currentState?.context);
    if (ctx == null) return;

    _isOpen = true;
    try {
      await showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        useRootNavigator: true,
        builder: (_) => QuickTranslateModal(initialText: initialText),
      );
    } finally {
      _isOpen = false;
    }
  }

  @override
  State<QuickTranslateModal> createState() => _QuickTranslateModalState();
}

class _QuickTranslateModalState extends State<QuickTranslateModal> {
  late final TextEditingController _controller;
  String _selectedAction = 'translate_bn';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
    if (widget.initialText != null && widget.initialText!.trim().isNotEmpty) {
      _runAction('translate_bn');
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BlocBuilder<FloatingBubbleBloc, FloatingBubbleState>(
        builder: (context, state) {
          final isLoading = state.status == QuickTranslateStatus.loading;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.g_translate_rounded,
                      color: AppConstants.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      strings.quickTranslateTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action Buttons Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildActionChip(
                      label: strings.translateFromEnToBn,
                      action: 'translate_bn',
                      icon: Icons.translate_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildActionChip(
                      label: strings.translateFromBnToEn,
                      action: 'translate_en',
                      icon: Icons.sync_alt_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildActionChip(
                      label: strings.quickFixAction,
                      action: 'fix_grammar',
                      icon: Icons.spellcheck_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildActionChip(
                      label: strings.quickPolishAction,
                      action: 'polish',
                      icon: Icons.auto_awesome_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Input Box
              Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.dividerColor.withAlpha(50)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: 4,
                      minLines: 2,
                      decoration: InputDecoration(
                        hintText: strings.quickTranslateHint,
                        hintStyle: TextStyle(
                          color: theme.hintColor.withAlpha(140),
                          fontSize: 13.5,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        border: InputBorder.none,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        children: [
                          if (_controller.text.isEmpty)
                            InkWell(
                              onTap: _pasteFromClipboard,
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
                          if (_controller.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 16),
                              onPressed: () {
                                _controller.clear();
                                context.read<FloatingBubbleBloc>().add(
                                      const ClearQuickTranslateResultEvent(),
                                    );
                                setState(() {});
                              },
                            ),
                          ElevatedButton.icon(
                            onPressed: isLoading || _controller.text.trim().isEmpty
                                ? null
                                : () => _runAction(_selectedAction),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: isLoading
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.bolt_rounded, size: 16),
                            label: Text(
                              strings.buttonAnalyze,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Result Box
              if (isLoading) ...[
                const SizedBox(height: 16),
                Center(
                  child: SpinKitThreeBounce(
                    color: AppConstants.primaryColor,
                    size: 24,
                  ),
                ),
              ] else if (state.resultText != null && state.resultText!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppConstants.primaryColor.withAlpha(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 16, color: AppConstants.primaryColor),
                          const SizedBox(width: 6),
                          Text(
                            strings.resultTitle,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: state.resultText!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(strings.copiedToClipboardToast),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.copy_rounded, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    strings.copy,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        state.resultText!,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildActionChip({
    required String label,
    required String action,
    required IconData icon,
  }) {
    final isSelected = _selectedAction == action;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 14,
        color: isSelected ? Colors.white : AppConstants.primaryColor,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : null,
        ),
      ),
      selected: isSelected,
      selectedColor: AppConstants.primaryColor,
      onSelected: (_) => _runAction(action),
    );
  }
}

