import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class OcrEvent extends Equatable {
  const OcrEvent();

  @override
  List<Object?> get props => [];
}

class PickImageAndExtractEvent extends OcrEvent {
  final ImageSource source;

  const PickImageAndExtractEvent({required this.source});

  @override
  List<Object?> get props => [source];
}

class ExtractFromFileEvent extends OcrEvent {
  final File file;

  const ExtractFromFileEvent({required this.file});

  @override
  List<Object?> get props => [file];
}

class ClearOcrResultEvent extends OcrEvent {}

