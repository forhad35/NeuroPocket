import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_language.dart';
import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  static const String _keyLanguage = 'selected_app_language';
  static AppLanguage _inMemoryLanguage = AppLanguage.bangla;

  LanguageBloc() : super(LanguageState(language: _inMemoryLanguage)) {
    on<LoadLanguageEvent>(_onLoadLanguage);
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<ToggleLanguageEvent>(_onToggleLanguage);

    add(const LoadLanguageEvent());
  }

  Future<void> _onLoadLanguage(
    LoadLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_keyLanguage);
      if (code == 'en') {
        _inMemoryLanguage = AppLanguage.english;
        emit(state.copyWith(language: AppLanguage.english));
      } else if (code == 'bn') {
        _inMemoryLanguage = AppLanguage.bangla;
        emit(state.copyWith(language: AppLanguage.bangla));
      }
    } catch (e) {
      debugPrint('Error loading language preferences: $e');
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    _inMemoryLanguage = event.language;
    emit(state.copyWith(language: event.language));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLanguage, event.language.code);
    } catch (e) {
      debugPrint('Error saving language preferences: $e');
    }
  }

  Future<void> _onToggleLanguage(
    ToggleLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    final nextLang = state.isBangla ? AppLanguage.english : AppLanguage.bangla;
    add(ChangeLanguageEvent(nextLang));
  }
}

