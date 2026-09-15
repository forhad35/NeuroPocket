import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class IOcrService {
  Future<String> extractTextFromImageFile(File imageFile);
  Future<String> extractTextFromImagePath(String imagePath);
  void dispose();
}

class OfflineOcrService implements IOcrService {
  final TextRecognizer _textRecognizer;

  OfflineOcrService({TextRecognizer? textRecognizer})
      : _textRecognizer = textRecognizer ??
            TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String> extractTextFromImageFile(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text.trim();
    } catch (e) {
      debugPrint('Error extracting text from image file: $e');
      rethrow;
    }
  }

  @override
  Future<String> extractTextFromImagePath(String imagePath) async {
    return extractTextFromImageFile(File(imagePath));
  }

  @override
  void dispose() {
    _textRecognizer.close();
  }
}

