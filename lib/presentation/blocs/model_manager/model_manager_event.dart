import 'package:equatable/equatable.dart';

abstract class ModelManagerEvent extends Equatable {
  const ModelManagerEvent();

  @override
  List<Object?> get props => [];
}

class CheckModelsStatusEvent extends ModelManagerEvent {
  const CheckModelsStatusEvent();
}

class DownloadModelEvent extends ModelManagerEvent {
  final String modelId;

  const DownloadModelEvent(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

class CancelDownloadEvent extends ModelManagerEvent {
  final String modelId;

  const CancelDownloadEvent(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

class SetActiveModelEvent extends ModelManagerEvent {
  final String modelId;

  const SetActiveModelEvent(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

class DeleteModelEvent extends ModelManagerEvent {
  final String modelId;

  const DeleteModelEvent(this.modelId);

  @override
  List<Object?> get props => [modelId];
}

class TestModelInferenceEvent extends ModelManagerEvent {
  final String prompt;

  const TestModelInferenceEvent({this.prompt = 'Write a 1-sentence motivational quote for learning.'});

  @override
  List<Object?> get props => [prompt];
}
