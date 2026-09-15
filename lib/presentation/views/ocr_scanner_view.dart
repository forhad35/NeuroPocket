import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../data/models/ai_task_type.dart';
import '../blocs/ocr/ocr_bloc.dart';
import '../blocs/ocr/ocr_event.dart';
import '../blocs/ocr/ocr_state.dart';
import '../widgets/language_switch_button.dart';
import 'ai_editor_view.dart';

class OcrScannerView extends StatelessWidget {
  const OcrScannerView({super.key});

  void _pickImage(BuildContext context, ImageSource source) {
    context.read<OcrBloc>().add(PickImageAndExtractEvent(source: source));
  }

  void _sendToAiEditor(BuildContext context, String text, AiTaskType taskType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AiEditorView(
          initialText: text,
          initialTaskType: taskType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.ocrTitle),
        actions: [
          const LanguageSwitchButton(compact: true),
          IconButton(
            tooltip: strings.clear,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<OcrBloc>().add(ClearOcrResultEvent()),
          ),
        ],
      ),
      body: BlocConsumer<OcrBloc, OcrState>(
        listener: (context, state) {
          if (state.status == OcrStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppConstants.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          final isScanning = state.status == OcrStatus.scanning;
          final hasResult = state.status == OcrStatus.success && state.extractedText != null;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppConstants.secondaryColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppConstants.secondaryColor.withAlpha(50),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.document_scanner_rounded,
                          color: AppConstants.secondaryColor,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.offlineOcrHeader,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: AppConstants.secondaryColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                strings.ocrSubtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodyMedium?.color?.withAlpha(190),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Image Selection Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isScanning ? null : () => _pickImage(context, ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: Text(strings.scanCamera),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isScanning ? null : () => _pickImage(context, ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_rounded),
                          label: Text(strings.pickGallery),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Image Preview if captured
                  if (state.scannedImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Image.file(
                          state.scannedImage!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Scanning indicator
                  if (isScanning)
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            strings.scanningImage,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                  // Empty Result Alert
                  if (state.status == OcrStatus.empty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppConstants.warningColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppConstants.warningColor.withAlpha(50)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppConstants.warningColor,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.errorMessage ?? strings.noOcrText,
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Result Card
                  if (hasResult) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor.withAlpha(60)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(6),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppConstants.accentColor,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                strings.recognizedText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                tooltip: strings.copy,
                                icon: const Icon(Icons.copy_rounded, size: 18),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: state.extractedText!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(strings.copied),
                                      duration: AppConstants.toastDuration,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const Divider(),
                          SelectableText(
                            state.extractedText!,
                            style: const TextStyle(
                              fontSize: 14.5,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Primary Fast Action: Auto Clean & Structure
                    ElevatedButton.icon(
                      onPressed: () => _sendToAiEditor(context, state.extractedText!, AiTaskType.ocrStructuring),
                      icon: const Icon(Icons.auto_fix_normal_rounded, size: 20),
                      label: Text(
                        strings.cleanWithAi,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quick AI Actions on Scanned Text
                    Text(
                      strings.fixWithAiTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AiTaskType.values.map((task) {
                        return ActionChip(
                          avatar: Icon(task.icon, size: 16, color: task.badgeColor),
                          label: Text(strings.isBangla ? task.banglaTitle : task.title),
                          backgroundColor: task.badgeColor.withAlpha(20),
                          side: BorderSide(color: task.badgeColor.withAlpha(60)),
                          onPressed: () => _sendToAiEditor(context, state.extractedText!, task),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
