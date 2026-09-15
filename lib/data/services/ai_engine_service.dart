import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/ai_result_model.dart';
import '../models/ai_task_type.dart';
import 'on_device_llm_service.dart';

abstract class IAiEngineService {
  Future<bool> isModelAvailable();
  Future<File?> getModelFile();
  Future<AiResultModel> processText({
    required String text,
    required AiTaskType taskType,
  });
}

class OfflineAiEngineService implements IAiEngineService {
  final IOnDeviceLlmService _onDeviceLlmService;

  OfflineAiEngineService({IOnDeviceLlmService? onDeviceLlmService})
      : _onDeviceLlmService = onDeviceLlmService ?? OnDeviceLlmService();

  @override
  Future<bool> isModelAvailable() async {
    try {
      final activeId = _onDeviceLlmService.activeModelId ?? 'qwen-2.5-0.5b';
      return await _onDeviceLlmService.isModelDownloaded(activeId);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<File?> getModelFile() async {
    try {
      final activeId = _onDeviceLlmService.activeModelId ?? 'qwen-2.5-0.5b';
      final path = await _onDeviceLlmService.getModelFilePath(activeId);
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          return file;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error accessing model file: $e');
      return null;
    }
  }

  @override
  Future<AiResultModel> processText({
    required String text,
    required AiTaskType taskType,
  }) async {
    final cleanInput = text.trim();
    if (cleanInput.isEmpty) {
      throw ArgumentError('Input text cannot be empty');
    }

    return await _onDeviceLlmService.processAiTask(
      text: cleanInput,
      taskType: taskType,
    );
  }
}
