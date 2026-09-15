enum AppLanguage {
  bangla,
  english,
}

extension AppLanguageExtension on AppLanguage {
  String get code => this == AppLanguage.bangla ? 'bn' : 'en';

  String get label => this == AppLanguage.bangla ? 'বাংলা' : 'English';

  String get flag => this == AppLanguage.bangla ? '🇧🇩' : '🇺🇸';

  bool get isBangla => this == AppLanguage.bangla;
  bool get isEnglish => this == AppLanguage.english;
}
