import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/utils/diff_util.dart';
import '../../data/models/ai_result_model.dart';
import 'alternatives_list.dart';

class AiResultCard extends StatefulWidget {
  final AiResultModel result;
  final VoidCallback? onApplyToEditor;
  final ValueChanged<String>? onSelectAlternative;

  const AiResultCard({
    super.key,
    required this.result,
    this.onApplyToEditor,
    this.onSelectAlternative,
  });

  @override
  State<AiResultCard> createState() => _AiResultCardState();
}

class _AiResultCardState extends State<AiResultCard> {
  bool _showExplanation = true;
  bool _showDiff = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final result = widget.result;
    final diffSegments = DiffUtil.calculateWordDiff(
      result.originalText,
      result.correctedText,
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: result.taskType.badgeColor.withAlpha(50),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: result.taskType.badgeColor.withAlpha(20),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(
                  result.taskType.icon,
                  size: 18,
                  color: result.taskType.badgeColor,
                ),
                const SizedBox(width: 8),
                Text(
                  result.taskType.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: result.taskType.badgeColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppConstants.accentColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        size: 13,
                        color: AppConstants.accentColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${result.processingDurationMs}ms • ${strings.offlineMode}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Toggle between Raw text and Diff
                if (result.hasChanges)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        strings.isBangla ? 'পার্থক্য (Diff) দেখুন' : 'Show Word Diff',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Transform.scale(
                        scale: 0.75,
                        child: Switch(
                          value: _showDiff,
                          onChanged: (val) => setState(() => _showDiff = val),
                          activeTrackColor: result.taskType.badgeColor,
                        ),
                      ),
                    ],
                  ),

                // Corrected text or diff
                if (_showDiff)
                  _buildDiffView(diffSegments)
                else
                  SelectableText(
                    result.correctedText,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                const SizedBox(height: 16),

                // Alternatives List if present
                if (result.hasAlternatives && result.alternatives.length > 1) ...[
                  AlternativesList(
                    alternatives: result.alternatives,
                    onSelectAlternative: widget.onSelectAlternative,
                  ),
                  const SizedBox(height: 16),
                ],

                // Explanation Section
                if (result.hasExplanation) ...[
                  InkWell(
                    onTap: () => setState(() => _showExplanation = !_showExplanation),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 16,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            strings.explanation,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade800,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _showExplanation
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Colors.amber.shade800,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showExplanation)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.amber.withAlpha(50),
                        ),
                      ),
                      child: Text(
                        result.explanation,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: theme.brightness == Brightness.dark
                              ? Colors.amber.shade200
                              : const Color(0xFF78350F),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),

          // Bottom Action Bar
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Copy Button
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: result.correctedText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(strings.copied),
                        duration: AppConstants.toastDuration,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: Text(strings.copy),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: theme.textTheme.bodyMedium?.color,
                  ),
                ),

                const Spacer(),

                // Apply to editor button
                if (widget.onApplyToEditor != null)
                  ElevatedButton.icon(
                    onPressed: widget.onApplyToEditor,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: Text(strings.isBangla ? 'এডিটরে প্রয়োগ করুন' : 'Apply to Editor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: result.taskType.badgeColor,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiffView(List<DiffSegment> segments) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
        children: segments.map((seg) {
          if (seg.type == DiffType.added) {
            return TextSpan(
              text: seg.text,
              style: const TextStyle(
                backgroundColor: Color(0xFFBBF7D0),
                color: Color(0xFF14532D),
                fontWeight: FontWeight.w700,
              ),
            );
          }
          return TextSpan(
            text: seg.text,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          );
        }).toList(),
      ),
    );
  }
}
