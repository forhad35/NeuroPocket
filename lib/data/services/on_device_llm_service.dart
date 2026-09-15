import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:llamadart/llamadart.dart';
import 'package:path_provider/path_provider.dart';

import '../models/ai_result_model.dart';
import '../models/ai_task_type.dart';
import '../models/chat_message.dart';
import '../models/model_status.dart';
import 'ai_prompt_builder.dart';

abstract class IOnDeviceLlmService {
  List<LocalModelInfo> get supportedModels;
  String? get activeModelId;
  bool get isModelLoaded;

  Future<List<LocalModelInfo>> getModelStatusList();
  Future<bool> isModelDownloaded(String modelId);
  Future<String?> getModelFilePath(String modelId);

  Future<void> downloadModel(
    String modelId, {
    void Function(double progress, int downloadedBytes, int totalBytes)? onProgress,
  });
  Future<void> cancelDownload(String modelId);
  Future<void> deleteModel(String modelId);

  Future<void> loadModel(String modelId);
  Future<void> unloadModel();

  Stream<String> generateStream({
    required String prompt,
    List<ChatMessage>? conversationHistory,
    AiTaskType? taskType,
    int maxTokens = 512,
    double temperature = 0.3,
  });

  Future<String> generateText({
    required String prompt,
    List<ChatMessage>? conversationHistory,
    AiTaskType? taskType,
    int maxTokens = 512,
    double temperature = 0.3,
  });

  Future<AiResultModel> processAiTask({
    required String text,
    required AiTaskType taskType,
  });
}

class OnDeviceLlmService implements IOnDeviceLlmService {
  static final OnDeviceLlmService _instance = OnDeviceLlmService._internal();
  factory OnDeviceLlmService() => _instance;
  OnDeviceLlmService._internal();

  static const List<LocalModelInfo> defaultModelCatalog = [
    LocalModelInfo(
      id: 'qwen-2.5-0.5b',
      name: 'Qwen 2.5 0.5B Instruct (Q4_K_M)',
      size: '398 MB',
      description: 'Ultra fast on-device model optimized for Bengali, Banglish, and English writing and quick grammar corrections.',
      banglaDescription: 'বাংলা, বাংলিশ ও ইংরেজির জন্য সেরা লাইটওয়েট দ্রুতগতির অন-ডিভাইস মডেল (দৈনন্দিন ব্যবহারের জন্য সেরা)।',
      badge: '⚡ Ultra Fast • Multilingual & Proofread (Recommended)',
      banglaBadge: '⚡ আল্ট্রা ফাস্ট • বহুভাষিক ও প্রুফরিড (রেকমেন্ডেড)',
      bestFor: 'Daily quick writing, instant grammar check, and fluent Bengali & English rewriting.',
      banglaBestFor: 'দৈনন্দিন দ্রুত লেখালেখি, তাৎক্ষণিক গ্রামার ফিক্স এবং সাবলীল বাংলা-ইংরেজি রি-রাইট।',
      downloadUrl:
          'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf',
      fileName: 'qwen2.5-0.5b-instruct-q4_k_m.gguf',
      isDefault: true,
    ),
    LocalModelInfo(
      id: 'qwen-2.5-1.5b',
      name: 'Qwen 2.5 1.5B Instruct (Q4_K_M)',
      size: '986 MB',
      description: 'High-intelligence multilingual model for complex reasoning, tone crafting, and deep offline conversation.',
      banglaDescription: 'বাংলা ও বাংলিশে উচ্চমানের বুদ্ধিমত্তা, লজিক্যাল চিন্তাভাবনা ও নিখুঁত অনুবাদের জন্য শক্তিশালী মডেল।',
      badge: '🔥 High Quality • Complex Reasoning & Multilingual',
      banglaBadge: '🔥 হাই কোয়ালিটি • গভীর যুক্তি ও বহুভাষিক',
      bestFor: 'Deep offline chat, full paragraph restructuring, and tone adaptation.',
      banglaBestFor: 'গভীর অফলাইন চ্যাট, সম্পূর্ণ প্যারাগ্রাফ রিস্ট্রাকচারিং এবং বিজনেস ফরম্যাটিং।',
      downloadUrl:
          'https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf',
      fileName: 'qwen2.5-1.5b-instruct-q4_k_m.gguf',
    ),
    LocalModelInfo(
      id: 'smollm2-360m',
      name: 'SmolLM2 360M Instruct (Q4_K_M)',
      size: '229 MB',
      description: 'Ultra-compact model specialized for fast English grammar correction and lightweight rewriting with minimal RAM.',
      banglaDescription: 'খুবই কম র‍্যামে উচ্চমানের ইংরেজি ল্যাঙ্গুয়েজ ও দ্রুত গ্রামার ফিক্সের জন্য বিশেষভাবে প্রস্তুতকৃত লাইট মডেল।',
      badge: '🔋 Lightweight • Fast English Grammar',
      banglaBadge: '🔋 লাইটওয়েট • দ্রুত ইংরেজি গ্রামার',
      bestFor: 'Lightweight phones, fast English proofreading, and vocabulary cleanup.',
      banglaBestFor: 'কম কনফিগারেশনের ফোন, দ্রুত ইংরেজি প্রুফরিডিং এবং স্পেলিং ফিক্স।',
      downloadUrl:
          'https://huggingface.co/HuggingFaceTB/SmolLM2-360M-Instruct-GGUF/resolve/main/smollm2-360m-instruct-q4_k_m.gguf',
      fileName: 'smollm2-360m-instruct-q4_k_m.gguf',
    ),
    LocalModelInfo(
      id: 'llama-3.2-1b',
      name: 'Llama 3.2 1B Instruct (Q4_K_M)',
      size: '808 MB',
      description: 'Meta\'s 1B parameter model with high precision for English text restructuring, creative writing, and alternatives.',
      banglaDescription: 'অফলাইনে উন্নত ইংরেজি রচনা, গ্রামার ও অল্টারনেটিভ বাক্যের জন্য মেটার ১ বিলিয়ন মডেল।',
      badge: '🧠 High Precision • Deep English Structuring',
      banglaBadge: '🧠 হাই প্রিসিশন • উন্নত ইংরেজি স্ট্রাকচার',
      bestFor: 'Creative English writing, 3 alternative phrasing suggestions, and document editing.',
      banglaBestFor: 'ক্রিয়েটিভ ইংরেজি রাইটিং, ৩টি বিকল্প বাক্য তৈরি ও বড় ডকুমেন্ট এডিটিং।',
      downloadUrl:
          'https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf',
      fileName: 'llama-3.2-1b-instruct-q4_k_m.gguf',
    ),
  ];

  @override
  List<LocalModelInfo> get supportedModels => defaultModelCatalog;

  LlamaEngine? _engine;
  String? _activeModelId = 'qwen-2.5-0.5b';
  final Map<String, http.Client> _activeDownloads = {};

  @override
  String? get activeModelId => _activeModelId;

  @override
  bool get isModelLoaded => _engine != null && (_engine?.isReady ?? false);

  Future<Directory> _getModelsDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${docsDir.path}/models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir;
  }

  @override
  Future<String?> getModelFilePath(String modelId) async {
    final modelInfo = supportedModels.firstWhere(
      (m) => m.id == modelId,
      orElse: () => supportedModels.first,
    );
    final dir = await _getModelsDirectory();
    final file = File('${dir.path}/${modelInfo.fileName}');
    return file.path;
  }

  @override
  Future<bool> isModelDownloaded(String modelId) async {
    final path = await getModelFilePath(modelId);
    if (path == null) return false;
    final file = File(path);
    return await file.exists() && await file.length() > 1024 * 1024;
  }

  @override
  Future<List<LocalModelInfo>> getModelStatusList() async {
    final list = <LocalModelInfo>[];
    for (final model in supportedModels) {
      final path = await getModelFilePath(model.id);
      bool downloaded = false;
      int bytesOnDisk = 0;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          bytesOnDisk = await file.length();
          downloaded = bytesOnDisk > 1024 * 1024;
        }
      }

      LocalModelState state;
      if (_activeDownloads.containsKey(model.id)) {
        state = LocalModelState.downloading;
      } else if (model.id == _activeModelId && isModelLoaded) {
        state = LocalModelState.active;
      } else if (downloaded) {
        state = LocalModelState.ready;
      } else {
        state = LocalModelState.notDownloaded;
      }

      list.add(model.copyWith(
        localPath: path,
        state: state,
        downloadedBytes: bytesOnDisk,
        progress: downloaded ? 1.0 : (state == LocalModelState.downloading ? 0.5 : 0.0),
      ));
    }
    return list;
  }

  @override
  Future<void> downloadModel(
    String modelId, {
    void Function(double progress, int downloadedBytes, int totalBytes)? onProgress,
  }) async {
    final modelInfo = supportedModels.firstWhere(
      (m) => m.id == modelId,
      orElse: () => throw ArgumentError('Unknown model ID: $modelId'),
    );

    final dir = await _getModelsDirectory();
    final targetFile = File('${dir.path}/${modelInfo.fileName}');
    final tempFile = File('${dir.path}/${modelInfo.fileName}.part');

    if (await targetFile.exists() && await targetFile.length() > 1024 * 1024) {
      onProgress?.call(1.0, await targetFile.length(), await targetFile.length());
      return;
    }

    final client = http.Client();
    _activeDownloads[modelId] = client;

    try {
      final request = http.Request('GET', Uri.parse(modelInfo.downloadUrl));
      final response = await client.send(request);

      if (response.statusCode != 200 && response.statusCode != 206) {
        throw HttpException(
          'Failed to download model. Server returned status: ${response.statusCode}',
        );
      }

      final totalBytes = response.contentLength ?? 0;
      int downloadedBytes = 0;

      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      final sink = tempFile.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        if (totalBytes > 0) {
          final fraction = downloadedBytes / totalBytes;
          onProgress?.call(fraction, downloadedBytes, totalBytes);
        } else {
          onProgress?.call(0.5, downloadedBytes, totalBytes);
        }
      }

      await sink.flush();
      await sink.close();

      // Atomically move from .part to final .gguf
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tempFile.rename(targetFile.path);

      onProgress?.call(1.0, downloadedBytes, totalBytes);
    } catch (e) {
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      rethrow;
    } finally {
      _activeDownloads.remove(modelId);
      client.close();
    }
  }

  @override
  Future<void> cancelDownload(String modelId) async {
    final client = _activeDownloads.remove(modelId);
    if (client != null) {
      client.close();
      final path = await getModelFilePath(modelId);
      if (path != null) {
        final tempFile = File('$path.part');
        if (await tempFile.exists()) {
          try {
            await tempFile.delete();
          } catch (_) {}
        }
      }
    }
  }

  @override
  Future<void> deleteModel(String modelId) async {
    if (_activeModelId == modelId) {
      await unloadModel();
    }
    final path = await getModelFilePath(modelId);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      final tempFile = File('$path.part');
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  @override
  Future<void> loadModel(String modelId) async {
    final path = await getModelFilePath(modelId);
    if (path == null) {
      throw ArgumentError('Model $modelId path not found');
    }

    final file = File(path);
    if (!await file.exists()) {
      throw StateError(
        'Model file for $modelId is not downloaded on this device yet. Please download it first.',
      );
    }

    if (_engine != null && _activeModelId == modelId && _engine!.isReady) {
      return;
    }

    await unloadModel();

    try {
      final engine = LlamaEngine(LlamaBackend());
      await engine.loadModel(
        path,
        modelParams: const ModelParams(
          contextSize: 2048,
          gpuLayers: ModelParams.maxGpuLayers,
        ),
      );
      _engine = engine;
      _activeModelId = modelId;
      debugPrint('Loaded on-device model: $modelId from $path');
    } catch (e) {
      _engine = null;
      debugPrint('Error loading on-device model $modelId: $e');
      rethrow;
    }
  }

  @override
  Future<void> unloadModel() async {
    if (_engine != null) {
      try {
        await _engine!.dispose();
      } catch (e) {
        debugPrint('Error disposing engine: $e');
      } finally {
        _engine = null;
      }
    }
  }

  @override
  Stream<String> generateStream({
    required String prompt,
    List<ChatMessage>? conversationHistory,
    AiTaskType? taskType,
    int maxTokens = 512,
    double temperature = 0.3,
  }) async* {
    if (!isModelLoaded) {
      final activeId = _activeModelId ?? 'qwen-2.5-0.5b';
      final isDownloaded = await isModelDownloaded(activeId);
      if (isDownloaded) {
        await loadModel(activeId);
      } else {
        throw StateError(
          'No offline GGUF model is downloaded or loaded. Please download a model from Models & Settings.',
        );
      }
    }

    final engine = _engine;
    if (engine == null || !engine.isReady) {
      throw StateError('On-device LLM engine is not ready.');
    }

    final messages = <LlamaChatMessage>[];

    // Add appropriate system instruction
    final systemPrompt = _buildSystemPrompt(taskType);
    if (systemPrompt.isNotEmpty) {
      messages.add(
        LlamaChatMessage.fromText(
          role: LlamaChatRole.system,
          text: systemPrompt,
        ),
      );
    }

    // Add conversation history
    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      for (final msg in conversationHistory) {
        if (msg.isError) continue;
        messages.add(
          LlamaChatMessage.fromText(
            role: msg.isUser ? LlamaChatRole.user : LlamaChatRole.assistant,
            text: msg.text,
          ),
        );
      }
    }

    // Add latest prompt
    messages.add(
      LlamaChatMessage.fromText(
        role: LlamaChatRole.user,
        text: prompt,
      ),
    );

    final stream = engine.create(
      messages,
      params: GenerationParams(
        maxTokens: maxTokens,
        temp: temperature,
      ),
    );

    await for (final chunk in stream) {
      final content = chunk.choices.first.delta.content;
      if (content != null && content.isNotEmpty) {
        yield content;
      }
    }
  }

  @override
  Future<String> generateText({
    required String prompt,
    List<ChatMessage>? conversationHistory,
    AiTaskType? taskType,
    int maxTokens = 512,
    double temperature = 0.3,
  }) async {
    final buffer = StringBuffer();
    await for (final token in generateStream(
      prompt: prompt,
      conversationHistory: conversationHistory,
      taskType: taskType,
      maxTokens: maxTokens,
      temperature: temperature,
    )) {
      buffer.write(token);
    }
    return buffer.toString().trim();
  }

  @override
  Future<AiResultModel> processAiTask({
    required String text,
    required AiTaskType taskType,
  }) async {
    final cleanInput = text.trim();
    if (cleanInput.isEmpty) {
      throw ArgumentError('Input text cannot be empty');
    }

    final stopwatch = Stopwatch()..start();
    final prompt = AiPromptBuilder.buildPrompt(cleanInput, taskType);

    final rawOutput = await generateText(
      prompt: prompt,
      taskType: taskType,
      maxTokens: 768,
      temperature: 0.3,
    );
    stopwatch.stop();

    final parsed = _parseModelOutput(rawOutput, cleanInput, taskType);

    return AiResultModel(
      originalText: cleanInput,
      correctedText: parsed.corrected,
      explanation: parsed.explanation,
      alternatives: parsed.alternatives,
      taskType: taskType,
      processingDurationMs: stopwatch.elapsedMilliseconds,
      timestamp: DateTime.now(),
    );
  }

  String _buildSystemPrompt(AiTaskType? taskType) {
    if (taskType == null) {
      return 'You are an intelligent, helpful offline AI assistant. You understand English, Bengali (বাংলা), and Banglish (Bengali written with English alphabet).\n'
          'Guidelines:\n'
          '1. If the user writes in Banglish (e.g. "ami valo achi", "eta translate koro"), accurately understand the Bengali meaning and answer cleanly.\n'
          '2. If asked to translate or write in English, output fluent English.\n'
          '3. If asked to reply in Bengali, reply in natural Bengali.\n'
          '4. Keep answers direct, correct, and avoid random or gibberish phrases.';
    }
    return 'You are an expert AI linguistic specialist, grammar corrector, and editor. Follow the precise response formatting instructions requested by the user.';
  }

  _ParsedTaskOutput _parseModelOutput(
    String output,
    String originalText,
    AiTaskType taskType,
  ) {
    String corrected = '';
    String explanation = '';
    final List<AlternativeOption> alternatives = [];

    // Parse [CORRECTED] ... [/CORRECTED]
    final correctedMatch = RegExp(
      r'\[CORRECTED\]([\s\S]*?)\[/CORRECTED\]',
      caseSensitive: false,
    ).firstMatch(output);
    if (correctedMatch != null) {
      corrected = correctedMatch.group(1)?.trim() ?? '';
    }

    // Parse [EXPLANATION] ... [/EXPLANATION]
    final explanationMatch = RegExp(
      r'\[EXPLANATION\]([\s\S]*?)\[/EXPLANATION\]',
      caseSensitive: false,
    ).firstMatch(output);
    if (explanationMatch != null) {
      explanation = explanationMatch.group(1)?.trim() ?? '';
    }

    // Parse [ALTERNATIVES] ... [/ALTERNATIVES]
    final alternativesMatch = RegExp(
      r'\[ALTERNATIVES\]([\s\S]*?)\[/ALTERNATIVES\]',
      caseSensitive: false,
    ).firstMatch(output);
    if (alternativesMatch != null) {
      final altSection = alternativesMatch.group(1)?.trim() ?? '';
      final lines = altSection.split('\n');
      for (final line in lines) {
        final cleanLine = line.trim();
        if (cleanLine.isEmpty) continue;
        final colonIdx = cleanLine.indexOf(':');
        if (colonIdx != -1) {
          var label = cleanLine.substring(0, colonIdx).trim();
          label = label.replaceAll(RegExp(r'^[\-\*\d\.\)\s]+'), '').trim();
          final text = cleanLine.substring(colonIdx + 1).trim();
          if (text.isNotEmpty) {
            alternatives.add(AlternativeOption(label: label, text: text));
          }
        } else if (cleanLine.startsWith('-') || cleanLine.startsWith('•')) {
          final text = cleanLine.replaceFirst(RegExp(r'^[\-•]\s*'), '').trim();
          if (text.isNotEmpty) {
            alternatives.add(AlternativeOption(
              label: 'Alternative ${alternatives.length + 1}',
              text: text,
            ));
          }
        }
      }
    }

    // Fallback if structured tags weren't output
    if (corrected.isEmpty) {
      corrected = output
          .replaceAll(RegExp(r'\[/?(CORRECTED|EXPLANATION|ALTERNATIVES)\]', caseSensitive: false), '')
          .trim();
    }

    if (corrected.isEmpty) {
      corrected = originalText;
    }

    if (explanation.isEmpty) {
      explanation = '• Real on-device GGUF LLM inference applied successfully.';
    }

    if (alternatives.isEmpty) {
      alternatives.add(AlternativeOption(
        label: 'On-Device Corrected',
        text: corrected,
      ));
    }

    return _ParsedTaskOutput(
      corrected: corrected,
      explanation: explanation,
      alternatives: alternatives,
    );
  }
}

class _ParsedTaskOutput {
  final String corrected;
  final String explanation;
  final List<AlternativeOption> alternatives;

  _ParsedTaskOutput({
    required this.corrected,
    required this.explanation,
    required this.alternatives,
  });
}
