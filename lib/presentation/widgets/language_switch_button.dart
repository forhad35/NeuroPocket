import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_language.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/language/language_event.dart';
import '../blocs/language/language_state.dart';

class LanguageSwitchButton extends StatelessWidget {
  final bool compact;

  const LanguageSwitchButton({
    super.key,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        final isBangla = state.isBangla;

        if (compact) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppConstants.primaryColor.withAlpha(60),
                width: 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                context.read<LanguageBloc>().add(const ToggleLanguageEvent());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isBangla ? '🇧🇩' : '🇺🇸',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isBangla ? 'বাংলা' : 'EN',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.swap_horiz_rounded,
                      size: 14,
                      color: AppConstants.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Expanded segmented style for Settings page
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withAlpha(40),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildLangOption(
                  context: context,
                  title: '🇧🇩 বাংলা',
                  isSelected: isBangla,
                  onTap: () {
                    context
                        .read<LanguageBloc>()
                        .add(const ChangeLanguageEvent(AppLanguage.bangla));
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildLangOption(
                  context: context,
                  title: '🇺🇸 English',
                  isSelected: !isBangla,
                  onTap: () {
                    context
                        .read<LanguageBloc>()
                        .add(const ChangeLanguageEvent(AppLanguage.english));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLangOption({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppConstants.primaryColor.withAlpha(60),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }
}

