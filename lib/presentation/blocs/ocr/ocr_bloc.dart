import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/ocr_repository.dart';
import 'ocr_event.dart';
import 'ocr_state.dart';

class OcrBloc extends Bloc<OcrEvent, OcrState> {
  final IOcrRepository _ocrRepository;

  OcrBloc({required this._ocrRepository})
      : super(const OcrState()) {
    on<PickImageAndExtractEvent>(_onPickImageAndExtract);
    on<ExtractFromFileEvent>(_onExtractFromFile);
    on<ClearOcrResultEvent>(_onClearOcrResult);
  }

  Future<void> _onPickImageAndExtract(
    PickImageAndExtractEvent event,
    Emitter<OcrState> emit,
  ) async {
    emit(state.copyWith(
      status: OcrStatus.scanning,
      errorMessage: null,
    ));

    try {
      final result = await _ocrRepository.pickImageAndExtractText(
        source: event.source,
      );

      if (result == null) {
        emit(state.copyWith(status: OcrStatus.initial));
        return;
      }

      if (result.text.trim().isEmpty) {
        emit(state.copyWith(
          status: OcrStatus.empty,
          scannedImage: result.file,
          errorMessage: 'ছবিটি লোড হয়েছে কিন্তু এতে কোনো স্পষ্ট টেক্সট বা লেখা পাওয়া যায়নি। লেখার ছবি নির্বাচন করুন।',
        ));
      } else {
        emit(state.copyWith(
          status: OcrStatus.success,
          extractedText: result.text.trim(),
          scannedImage: result.file,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: OcrStatus.failure,
        errorMessage: 'ছবি থেকে টেক্সট বের করতে সমস্যা হয়েছে: ${e.toString()}',
      ));
    }
  }

  Future<void> _onExtractFromFile(
    ExtractFromFileEvent event,
    Emitter<OcrState> emit,
  ) async {
    emit(state.copyWith(
      status: OcrStatus.scanning,
      scannedImage: event.file,
      errorMessage: null,
    ));

    try {
      final result = await _ocrRepository.extractTextFromFile(event.file);
      if (result.text.trim().isEmpty) {
        emit(state.copyWith(
          status: OcrStatus.empty,
          scannedImage: event.file,
          errorMessage: 'ছবিতে কোনো লেখা পাওয়া যায়নি। স্পষ্ট লেখা সম্বলিত ছবি দিন।',
        ));
      } else {
        emit(state.copyWith(
          status: OcrStatus.success,
          extractedText: result.text.trim(),
          scannedImage: event.file,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: OcrStatus.failure,
        errorMessage: 'OCR প্রসেসিং ত্রুটি: ${e.toString()}',
      ));
    }
  }

  void _onClearOcrResult(
    ClearOcrResultEvent event,
    Emitter<OcrState> emit,
  ) {
    emit(state.copyWith(
      status: OcrStatus.initial,
      clearImage: true,
      clearText: true,
      errorMessage: null,
    ));
  }

  @override
  Future<void> close() {
    _ocrRepository.dispose();
    return super.close();
  }
}
