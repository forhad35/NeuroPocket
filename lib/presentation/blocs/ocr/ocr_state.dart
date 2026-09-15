import 'dart:io';
import 'package:equatable/equatable.dart';

enum OcrStatus { initial, scanning, success, empty, failure }

class OcrState extends Equatable {
  final OcrStatus status;
  final String? extractedText;
  final File? scannedImage;
  final String? errorMessage;

  const OcrState({
    this.status = OcrStatus.initial,
    this.extractedText,
    this.scannedImage,
    this.errorMessage,
  });

  OcrState copyWith({
    OcrStatus? status,
    String? extractedText,
    File? scannedImage,
    String? errorMessage,
    bool clearImage = false,
    bool clearText = false,
  }) {
    return OcrState(
      status: status ?? this.status,
      extractedText: clearText ? null : (extractedText ?? this.extractedText),
      scannedImage: clearImage ? null : (scannedImage ?? this.scannedImage),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, extractedText, scannedImage, errorMessage];
}

