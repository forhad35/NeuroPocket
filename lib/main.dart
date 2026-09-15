import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/ai_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/ocr_repository.dart';
import 'presentation/blocs/ai/ai_bloc.dart';
import 'presentation/blocs/chat/chat_bloc.dart';
import 'presentation/blocs/language/language_bloc.dart';
import 'presentation/blocs/model_manager/model_manager_bloc.dart';
import 'presentation/blocs/ocr/ocr_bloc.dart';
import 'presentation/views/home_view.dart';

void main() {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  runApp(const OfflineAiApp());
}

class OfflineAiApp extends StatelessWidget {
  const OfflineAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize Repositories (MVVM Data Layer)
    final aiRepository = AiRepository();
    final ocrRepository = OcrRepository();
    final chatRepository = ChatRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider<LanguageBloc>(
          create: (_) => LanguageBloc(),
        ),
        BlocProvider<AiBloc>(
          create: (_) => AiBloc(aiRepository: aiRepository),
        ),
        BlocProvider<OcrBloc>(
          create: (_) => OcrBloc(ocrRepository: ocrRepository),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => ChatBloc(repository: chatRepository),
        ),
        BlocProvider<ModelManagerBloc>(
          create: (_) => ModelManagerBloc(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeView(),
      ),
    );
  }
}
