import '../models/ai_result_model.dart';
import '../models/ai_task_type.dart';
import '../services/ai_config_service.dart';
import '../services/ai_engine_service.dart';
import '../services/gemini_ai_service.dart';

abstract class IAiRepository {
  Future<AiResultModel> processText({
    required String text,
    required AiTaskType taskType,
  });

  Future<bool> checkModelStatus();
}

class AiRepository implements IAiRepository {
  final IAiEngineService _offlineEngineService;
  final GeminiAiService _geminiService;

  AiRepository({
    IAiEngineService? engineService,
    GeminiAiService? geminiService,
  })  : _offlineEngineService = engineService ?? OfflineAiEngineService(),
        _geminiService = geminiService ?? GeminiAiService();

  @override
  Future<AiResultModel> processText({
    required String text,
    required AiTaskType taskType,
  }) async {
    final hasGemini = await _geminiService.isAvailable();
    if (hasGemini) {
      try {
        final geminiResult = await _geminiService.processText(
          text: text,
          taskType: taskType,
        );
        if (geminiResult != null) {
          return geminiResult;
        }
      } catch (_) {
        // Fallback to offline engine if network or API error occurs
      }
    }

    return _offlineEngineService.processText(text: text, taskType: taskType);
  }

  @override
  Future<bool> checkModelStatus() async {
    final hasGemini = await AiConfigService.isRealModelEnabled();
    if (hasGemini) return true;
    return _offlineEngineService.isModelAvailable();
  }
}
