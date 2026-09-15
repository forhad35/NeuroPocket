import 'package:equatable/equatable.dart';
import '../../../core/localization/app_language.dart';

class LanguageState extends Equatable {
  final AppLanguage language;

  const LanguageState({
    this.language = AppLanguage.bangla,
  });

  bool get isBangla => language == AppLanguage.bangla;
  bool get isEnglish => language == AppLanguage.english;

  LanguageState copyWith({
    AppLanguage? language,
  }) {
    return LanguageState(
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [language];
}
