import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/ocr_service.dart';

class OcrExtractionResult {
  final File file;
  final String text;

  const OcrExtractionResult({
    required this.file,
    required this.text,
  });
}

abstract class IOcrRepository {
  Future<OcrExtractionResult?> pickImageAndExtractText({required ImageSource source});
  Future<OcrExtractionResult> extractTextFromFile(File imageFile);
  void dispose();
}

class OcrRepository implements IOcrRepository {
  final IOcrService _ocrService;
  final ImagePicker _imagePicker;

  OcrRepository({
    IOcrService? ocrService,
    ImagePicker? imagePicker,
  })  : _ocrService = ocrService ?? OfflineOcrService(),
        _imagePicker = imagePicker ?? ImagePicker();

  @override
  Future<OcrExtractionResult?> pickImageAndExtractText({required ImageSource source}) async {
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 95,
    );

    if (pickedFile == null) return null;

    final file = File(pickedFile.path);
    final extractedText = await _ocrService.extractTextFromImageFile(file);
    return OcrExtractionResult(file: file, text: extractedText);
  }

  @override
  Future<OcrExtractionResult> extractTextFromFile(File imageFile) async {
    final extractedText = await _ocrService.extractTextFromImageFile(imageFile);
    return OcrExtractionResult(file: imageFile, text: extractedText);
  }

  @override
  void dispose() {
    _ocrService.dispose();
  }
}
