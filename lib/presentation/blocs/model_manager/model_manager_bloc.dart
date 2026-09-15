import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/model_status.dart';
import '../../../data/services/on_device_llm_service.dart';
import 'model_manager_event.dart';
import 'model_manager_state.dart';

class ModelManagerBloc extends Bloc<ModelManagerEvent, ModelManagerState> {
  final IOnDeviceLlmService _onDeviceLlmService;

  ModelManagerBloc({IOnDeviceLlmService? onDeviceLlmService})
      : _onDeviceLlmService = onDeviceLlmService ?? OnDeviceLlmService(),
        super(ModelManagerState(
          availableModels: (onDeviceLlmService ?? OnDeviceLlmService()).supportedModels,
          activeModelId: (onDeviceLlmService ?? OnDeviceLlmService()).activeModelId ?? 'qwen-2.5-0.5b',
        )) {
    on<CheckModelsStatusEvent>(_onCheckStatus);
    on<DownloadModelEvent>(_onDownloadModel);
    on<CancelDownloadEvent>(_onCancelDownload);
    on<SetActiveModelEvent>(_onSetActiveModel);
    on<DeleteModelEvent>(_onDeleteModel);
    on<TestModelInferenceEvent>(_onTestModelInference);
    on<_UpdateDownloadProgressInternalEvent>(_onUpdateDownloadProgress);

    add(const CheckModelsStatusEvent());
  }

  Future<void> _onCheckStatus(
    CheckModelsStatusEvent event,
    Emitter<ModelManagerState> emit,
  ) async {
    try {
      final models = await _onDeviceLlmService.getModelStatusList();
      final activeId = _onDeviceLlmService.activeModelId ?? state.activeModelId;
      emit(state.copyWith(
        availableModels: models,
        activeModelId: activeId,
      ));
    } catch (e, stack) {
      debugPrint('🔴 [ModelManagerBloc] Status check failed:\n$e\n$stack');
    }
  }

  Future<void> _onDownloadModel(
    DownloadModelEvent event,
    Emitter<ModelManagerState> emit,
  ) async {
    var models = List<LocalModelInfo>.from(state.availableModels);
    if (models.isEmpty) {
      models = List<LocalModelInfo>.from(_onDeviceLlmService.supportedModels);
    }
    final index = models.indexWhere((m) => m.id == event.modelId);
    if (index == -1) return;

    models[index] = models[index].copyWith(
      state: LocalModelState.downloading,
      progress: 0.01,
      errorMessage: null,
    );
    emit(state.copyWith(availableModels: List.from(models), clearMessages: true));

    try {
      debugPrint('⬇️ [ModelManagerBloc] Starting download for model: ${event.modelId}');
      await _onDeviceLlmService.downloadModel(
        event.modelId,
        onProgress: (progress, downloaded, total) {
          if (isClosed) return;
          add(_UpdateDownloadProgressInternalEvent(
            modelId: event.modelId,
            progress: progress,
            downloaded: downloaded,
            total: total,
          ));
        },
      );

      final updatedModels = await _onDeviceLlmService.getModelStatusList();
      emit(state.copyWith(
        availableModels: updatedModels,
        successMessage: '${models[index].name} ডাউনলোড সম্পন্ন হয়েছে এবং ব্যবহারের জন্য প্রস্তুত!',
      ));
      debugPrint('✅ [ModelManagerBloc] Model ${event.modelId} downloaded successfully.');
    } catch (e, stack) {
      debugPrint('🔴 [ModelManagerBloc] Model download failed:\nTechnical Error: $e\nStacktrace:\n$stack');
      final friendlyError = _formatUserFriendlyError(e);
      final updatedModels = List<LocalModelInfo>.from(state.availableModels);
      final errIndex = updatedModels.indexWhere((m) => m.id == event.modelId);
      if (errIndex != -1) {
        updatedModels[errIndex] = updatedModels[errIndex].copyWith(
          state: LocalModelState.notDownloaded,
          progress: 0.0,
          errorMessage: friendlyError,
        );
      }
      emit(state.copyWith(
        availableModels: updatedModels,
        errorMessage: friendlyError,
      ));
    }
  }

  void _onUpdateDownloadProgress(
    _UpdateDownloadProgressInternalEvent event,
    Emitter<ModelManagerState> emit,
  ) {
    final models = List<LocalModelInfo>.from(state.availableModels);
    final index = models.indexWhere((m) => m.id == event.modelId);
    if (index != -1) {
      models[index] = models[index].copyWith(
        state: event.progress >= 1.0 ? LocalModelState.ready : LocalModelState.downloading,
        progress: event.progress,
        downloadedBytes: event.downloaded,
        totalBytes: event.total,
      );
      emit(state.copyWith(availableModels: List.from(models)));
    }
  }

  Future<void> _onCancelDownload(
    CancelDownloadEvent event,
    Emitter<ModelManagerState> emit,
  ) async {
    debugPrint('⚠️ [ModelManagerBloc] Cancelling download for model: ${event.modelId}');
    await _onDeviceLlmService.cancelDownload(event.modelId);
    final updatedModels = await _onDeviceLlmService.getModelStatusList();
    emit(state.copyWith(
      availableModels: updatedModels,
      successMessage: 'ডাউনলোড বাতিল করা হয়েছে।',
    ));
  }

  Future<void> _onSetActiveModel(
    SetActiveModelEvent event,
    Emitter<ModelManagerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      final isDownloaded = await _onDeviceLlmService.isModelDownloaded(event.modelId);
      if (!isDownloaded) {
        debugPrint('⚠️ [ModelManagerBloc] Cannot activate model ${event.modelId}: File not on disk.');
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'মডেলটি এখনও ডাউনলোড করা হয়নি। অনুগ্রহ করে প্রথমে ডাউনলোড করুন।',
        ));
        return;
      }

      debugPrint('🔄 [ModelManagerBloc] Loading model into memory: ${event.modelId}');
      await _onDeviceLlmService.loadModel(event.modelId);
      final models = await _onDeviceLlmService.getModelStatusList();
      emit(state.copyWith(
        availableModels: models,
        activeModelId: event.modelId,
        isLoading: false,
        successMessage: 'অ্যাক্টিভ মডেল সফলভাবে লোড ও সেট করা হয়েছে।',
      ));
      debugPrint('✅ [ModelManagerBloc] Model ${event.modelId} is now active.');
    } catch (e, stack) {
      debugPrint('🔴 [ModelManagerBloc] Failed to set active model:\nTechnical Error: $e\nStacktrace:\n$stack');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: _formatUserFriendlyError(e),
      ));
    }
  }

  Future<void> _onDeleteModel(
    DeleteModelEvent event,
    Emitter<ModelManagerState> emit,
  ) async {
    try {
      debugPrint('🗑️ [ModelManagerBloc] Deleting model file: ${event.modelId}');
      await _onDeviceLlmService.deleteModel(event.modelId);
      final models = await _onDeviceLlmService.getModelStatusList();
      emit(state.copyWith(
        availableModels: models,
        successMessage: 'মডেল ফাইল ডিভাইস থেকে সফলভাবে মুছে ফেলা হয়েছে।',
      ));
      debugPrint('✅ [ModelManagerBloc] Model ${event.modelId} deleted.');
    } catch (e, stack) {
      debugPrint('🔴 [ModelManagerBloc] Failed to delete model file:\nTechnical Error: $e\nStacktrace:\n$stack');
      emit(state.copyWith(
        errorMessage: _formatUserFriendlyError(e),
      ));
    }
  }

  Future<void> _onTestModelInference(
    TestModelInferenceEvent event,
    Emitter<ModelManagerState> emit,
  ) async {
    emit(state.copyWith(
      isTestingInference: true,
      clearTestResult: true,
    ));

    final stopwatch = Stopwatch()..start();
    try {
      debugPrint('🧪 [ModelManagerBloc] Running test inference with prompt: "${event.prompt}"');
      final response = await _onDeviceLlmService.generateText(
        prompt: event.prompt,
        maxTokens: 64,
        temperature: 0.7,
      );
      stopwatch.stop();

      final elapsedMs = stopwatch.elapsedMilliseconds;
      debugPrint('✅ [ModelManagerBloc] Test inference successful (${elapsedMs}ms): $response');
      emit(state.copyWith(
        isTestingInference: false,
        testInferenceSuccess: true,
        testResult:
            '✅ অন-ডিভাইস GGUF ইনফ্যারেন্স সফল (${elapsedMs}ms):\n\n"$response"',
      ));
    } catch (e, stack) {
      stopwatch.stop();
      debugPrint('🔴 [ModelManagerBloc] Test inference failed:\nTechnical Error: $e\nStacktrace:\n$stack');
      final friendlyError = _formatUserFriendlyError(e);
      emit(state.copyWith(
        isTestingInference: false,
        testInferenceSuccess: false,
        testResult: '❌ $friendlyError\n(মডেলটি প্রথমে ডাউনলোড ও অ্যাক্টিভ করুন)',
      ));
    }
  }

  /// Converts raw exceptions into clean, user-readable messages
  String _formatUserFriendlyError(dynamic error) {
    final str = error.toString().toLowerCase();

    // 1. Network & Internet connection errors
    if (str.contains('socketexception') ||
        str.contains('failed host lookup') ||
        str.contains('no address associated with hostname') ||
        str.contains('clientexception') ||
        str.contains('network is unreachable') ||
        str.contains('connection refused') ||
        str.contains('connection closed') ||
        str.contains('handshake') ||
        str.contains('errno = 7')) {
      return 'ইন্টারনেট সংযোগ পাওয়া যায়নি! মডেল ডাউনলোড করার জন্য দয়া করে আপনার ওয়াইফাই বা মোবাইল ডাটা চালু করুন।';
    }

    // 2. Timeout error
    if (str.contains('timeoutexception') || str.contains('timed out')) {
      return 'ইন্টারনেট সংযোগের সময়সীমা শেষ হয়েছে (Timeout)। নেটওয়ার্ক স্পিড চেক করে আবার চেষ্টা করুন।';
    }

    // 3. Model not downloaded / not found
    if (str.contains('no offline gguf model') || str.contains('model is not downloaded') || str.contains('bad state')) {
      return 'কোনো অফলাইন মডেল ডাউনলোড করা নেই। মডেল লিস্ট থেকে যেকোনো একটি মডেল ডাউনলোড করে অ্যাক্টিভ করুন।';
    }

    // 4. Storage / Disk Space error
    if (str.contains('no space') || str.contains('disk full') || str.contains('quota')) {
      return 'ফোনে পর্যাপ্ত মেমোরি খালি নেই। কিছু জায়গা খালি করে পুনরায় চেষ্টা করুন।';
    }

    // 5. General clean fallback
    final clean = error.toString().replaceFirst(RegExp(r'^(Exception|Error|Bad state):\s*'), '');
    return 'ত্রুটি: $clean';
  }
}

class _UpdateDownloadProgressInternalEvent extends ModelManagerEvent {
  final String modelId;
  final double progress;
  final int downloaded;
  final int total;

  const _UpdateDownloadProgressInternalEvent({
    required this.modelId,
    required this.progress,
    required this.downloaded,
    required this.total,
  });

  @override
  List<Object?> get props => [modelId, progress, downloaded, total];
}
