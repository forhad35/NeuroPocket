import 'package:equatable/equatable.dart';
import '../../../data/models/model_status.dart';

class ModelManagerState extends Equatable {
  final List<LocalModelInfo> availableModels;
  final String activeModelId;
  final bool isLoading;
  final bool isTestingInference;
  final String? testResult;
  final bool testInferenceSuccess;
  final String? errorMessage;
  final String? successMessage;

  const ModelManagerState({
    this.availableModels = const [],
    this.activeModelId = 'qwen-2.5-0.5b',
    this.isLoading = false,
    this.isTestingInference = false,
    this.testResult,
    this.testInferenceSuccess = false,
    this.errorMessage,
    this.successMessage,
  });

  LocalModelInfo? get activeModel {
    try {
      return availableModels.firstWhere((m) => m.id == activeModelId);
    } catch (_) {
      return availableModels.isNotEmpty ? availableModels.first : null;
    }
  }

  ModelManagerState copyWith({
    List<LocalModelInfo>? availableModels,
    String? activeModelId,
    bool? isLoading,
    bool? isTestingInference,
    String? testResult,
    bool? testInferenceSuccess,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
    bool clearTestResult = false,
  }) {
    return ModelManagerState(
      availableModels: availableModels ?? this.availableModels,
      activeModelId: activeModelId ?? this.activeModelId,
      isLoading: isLoading ?? this.isLoading,
      isTestingInference: isTestingInference ?? this.isTestingInference,
      testResult: clearTestResult ? null : (testResult ?? this.testResult),
      testInferenceSuccess: clearTestResult ? false : (testInferenceSuccess ?? this.testInferenceSuccess),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        availableModels,
        activeModelId,
        isLoading,
        isTestingInference,
        testResult,
        testInferenceSuccess,
        errorMessage,
        successMessage,
      ];
}
