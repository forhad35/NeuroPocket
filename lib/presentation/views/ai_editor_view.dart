import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../data/models/ai_task_type.dart';
import '../blocs/ai/ai_bloc.dart';
import '../blocs/ai/ai_event.dart';
import '../blocs/ai/ai_state.dart';
import '../blocs/ocr/ocr_bloc.dart';
import '../blocs/ocr/ocr_event.dart';
import '../blocs/ocr/ocr_state.dart';
import '../widgets/ai_result_card.dart';
import '../widgets/language_switch_button.dart';
import '../widgets/task_type_selector.dart';

class AiEditorView extends StatefulWidget {
  final String? initialText;
  final AiTaskType? initialTaskType;

  const AiEditorView({
    super.key,
    this.initialText,
    this.initialTaskType,
  });

  @override
  State<AiEditorView> createState() => _AiEditorViewState();
}

class _AiEditorViewState extends State<AiEditorView> {
  late final TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? '');
    if (widget.initialTaskType != null) {
      context.read<AiBloc>().add(ChangeTaskTypeEvent(widget.initialTaskType!));
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = _textController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  int get _charCount => _textController.text.length;

  void _onProcess(AiTaskType currentType) {
    FocusScope.of(context).unfocus();
    context.read<AiBloc>().add(
          ProcessTextEvent(
            text: _textController.text,
            taskType: currentType,
          ),
        );
  }

  void _pasteFromClipboard(AppStrings strings) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _textController.text = data.text!;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.textPasted),
            duration: AppConstants.toastDuration,
          ),
        );
      }
    }
  }

  void _pickOcrImage(ImageSource source) {
    context.read<OcrBloc>().add(PickImageAndExtractEvent(source: source));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<OcrBloc, OcrState>(
          listener: (context, ocrState) {
            if (ocrState.status == OcrStatus.success && ocrState.extractedText != null) {
              setState(() {
                _textController.text = ocrState.extractedText!;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(strings.textFromImageAdded),
                  backgroundColor: AppConstants.accentColor,
                  duration: AppConstants.toastDuration,
                ),
              );
            } else if (ocrState.status == OcrStatus.failure && ocrState.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ocrState.errorMessage!),
                  backgroundColor: AppConstants.errorColor,
                ),
              );
            }
          },
        ),
        BlocListener<AiBloc, AiState>(
          listener: (context, aiState) {
            if (aiState.status == AiStatus.failure && aiState.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(aiState.errorMessage!),
                  backgroundColor: AppConstants.errorColor,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<AiBloc, AiState>(
        builder: (context, aiState) {
          final isProcessing = aiState.status == AiStatus.loading;

          return Scaffold(
            appBar: AppBar(
              title: Text(strings.editorTitle),
              actions: [
                const LanguageSwitchButton(compact: true),
                IconButton(
                  tooltip: strings.scanCamera,
                  icon: const Icon(Icons.camera_alt_outlined),
                  onPressed: isProcessing ? null : () => _pickOcrImage(ImageSource.camera),
                ),
                IconButton(
                  tooltip: strings.pickGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  onPressed: isProcessing ? null : () => _pickOcrImage(ImageSource.gallery),
                ),
                IconButton(
                  tooltip: strings.clear,
                  icon: const Icon(Icons.clear_all_rounded),
                  onPressed: () {
                    setState(() => _textController.clear());
                    context.read<AiBloc>().add(ClearAiResultEvent());
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // Task Type Selector Bar
                    TaskTypeSelector(
                      selectedType: aiState.currentTaskType,
                      onTypeChanged: (type) {
                        context.read<AiBloc>().add(ChangeTaskTypeEvent(type));
                        if (_textController.text.trim().isNotEmpty) {
                          _onProcess(type);
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    // Task Description Banner
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: aiState.currentTaskType.badgeColor.withAlpha(15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: aiState.currentTaskType.badgeColor.withAlpha(40),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: aiState.currentTaskType.badgeColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              strings.isBangla
                                  ? aiState.currentTaskType.banglaDescription
                                  : aiState.currentTaskType.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodyMedium?.color?.withAlpha(200),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Input Text Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.dividerColor.withAlpha(60),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(5),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            maxLines: 7,
                            minLines: 4,
                            style: const TextStyle(fontSize: 15, height: 1.45),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: strings.inputPlaceholder,
                              hintStyle: TextStyle(
                                color: theme.hintColor.withAlpha(140),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),

                          // Text Toolbar (Counters + Paste & OCR shortcuts)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLowest,
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                              border: Border(
                                top: BorderSide(
                                  color: theme.dividerColor.withAlpha(30),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  strings.wordCountLabel(_wordCount, _charCount),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                                const Spacer(),
                                if (_textController.text.isEmpty)
                                  InkWell(
                                    onTap: () => _pasteFromClipboard(strings),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action Process Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton.icon(
                        onPressed: isProcessing || _textController.text.trim().isEmpty
                            ? null
                            : () => _onProcess(aiState.currentTaskType),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: aiState.currentTaskType.badgeColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: isProcessing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_fix_high_rounded, size: 20),
                        label: Text(
                          isProcessing
                              ? strings.processingAi
                              : strings.buttonAnalyze,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Loading State with SpinKit
                    if (isProcessing) ...[
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            SpinKitThreeBounce(
                              color: aiState.currentTaskType.badgeColor,
                              size: 28,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              strings.analyzingText,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Output Result Card
                    if (aiState.result != null && !isProcessing) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AiResultCard(
                          result: aiState.result!,
                          onApplyToEditor: () {
                            setState(() {
                              _textController.text = aiState.result!.correctedText;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(strings.appliedToEditor),
                                duration: AppConstants.toastDuration,
                              ),
                            );
                          },
                          onSelectAlternative: (altText) {
                            context.read<AiBloc>().add(ApplyAlternativeEvent(altText));
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
