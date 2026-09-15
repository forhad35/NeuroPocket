import 'package:flutter/material.dart';
import '../../core/localization/app_strings.dart';
import '../../data/models/ai_task_type.dart';

class TaskTypeSelector extends StatelessWidget {
  final AiTaskType selectedType;
  final ValueChanged<AiTaskType> onTypeChanged;

  const TaskTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AiTaskType.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final task = AiTaskType.values[index];
          final isSelected = task == selectedType;
          final title = strings.isBangla ? task.banglaTitle : task.title;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTypeChanged(task),
              borderRadius: BorderRadius.circular(22),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? task.badgeColor
                      : Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? task.badgeColor
                        : Theme.of(context).dividerColor.withAlpha(50),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: task.badgeColor.withAlpha(80),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      task.icon,
                      size: 17,
                      color: isSelected ? Colors.white : task.badgeColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
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
