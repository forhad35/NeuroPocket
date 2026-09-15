import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/ai_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/ocr_repository.dart';
import 'data/services/accessibility_service.dart';
import 'presentation/blocs/ai/ai_bloc.dart';
import 'presentation/blocs/chat/chat_bloc.dart';
import 'presentation/blocs/chat_translator/chat_translator_bloc.dart';
import 'presentation/blocs/floating_bubble/floating_bubble_bloc.dart';
import 'presentation/blocs/floating_bubble/floating_bubble_event.dart';
import 'presentation/blocs/language/language_bloc.dart';
import 'presentation/blocs/model_manager/model_manager_bloc.dart';
import 'presentation/blocs/ocr/ocr_bloc.dart';
import 'presentation/views/home_view.dart';
import 'presentation/widgets/clipboard_quick_bar.dart';
import 'presentation/widgets/floating_bubble_overlay.dart';

void main() {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  runApp(const OfflineAiApp());
}

class OfflineAiApp extends StatefulWidget {
  const OfflineAiApp({super.key});

  @override
  State<OfflineAiApp> createState() => _OfflineAiAppState();
}

class _OfflineAiAppState extends State<OfflineAiApp> with WidgetsBindingObserver {
  late final AiRepository _aiRepository;
  late final OcrRepository _ocrRepository;
  late final ChatRepository _chatRepository;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _aiRepository = AiRepository();
    _ocrRepository = OcrRepository();
    _chatRepository = ChatRepository();
    _syncFloatingOverlay();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      // When app is minimized or sent to background, ensure system overlay lens is running
      _syncFloatingOverlay();
    } else if (state == AppLifecycleState.resumed) {
      _syncFloatingOverlay();
    }
  }

  Future<void> _syncFloatingOverlay() async {
    final hasOverlay = await AccessibilityServiceHelper.isOverlayPermissionGranted();
    if (hasOverlay) {
      await AccessibilityServiceHelper.startFloatingOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LanguageBloc>(
          create: (_) => LanguageBloc(),
        ),
        BlocProvider<AiBloc>(
          create: (_) => AiBloc(aiRepository: _aiRepository),
        ),
        BlocProvider<OcrBloc>(
          create: (_) => OcrBloc(ocrRepository: _ocrRepository),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => ChatBloc(repository: _chatRepository),
        ),
        BlocProvider<ModelManagerBloc>(
          create: (_) => ModelManagerBloc(),
        ),
        BlocProvider<FloatingBubbleBloc>(
          create: (_) => FloatingBubbleBloc()..add(const InitializeFloatingBubbleEvent()),
        ),
        BlocProvider<ChatTranslatorBloc>(
          create: (_) => ChatTranslatorBloc(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        navigatorKey: AppConstants.rootNavigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        builder: (context, child) {
          if (child == null) return const SizedBox.shrink();
          return FloatingBubbleOverlay(
            child: ClipboardQuickBar(
              child: child,
            ),
          );
        },
        home: const HomeView(),
      ),
    );
  }
}
