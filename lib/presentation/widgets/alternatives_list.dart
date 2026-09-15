import 'package:flutter/material.dart';
import '../../core/localization/app_strings.dart';
import '../../data/models/ai_result_model.dart';

class AlternativesList extends StatelessWidget {
  final List<AlternativeOption> alternatives;
  final ValueChanged<String>? onSelectAlternative;

  const AlternativesList({
    super.key,
    required this.alternatives,
    this.onSelectAlternative,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.alt_route_rounded,
              size: 16,
              color: Color(0xFF10B981),
            ),
            const SizedBox(width: 6),
            Text(
              strings.alternatives,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: alternatives.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final alt = alternatives[index];
            return InkWell(
              onTap: onSelectAlternative != null
                  ? () => onSelectAlternative!(alt.text)
                  : null,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF10B981).withAlpha(40),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        alt.label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        alt.text,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (onSelectAlternative != null)
                      const Icon(
                        Icons.touch_app_outlined,
                        size: 16,
                        color: Color(0xFF10B981),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
