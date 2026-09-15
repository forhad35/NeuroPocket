import 'dart:async';
import 'package:flutter/services.dart';

class ClipboardWatcherService {
  static final ClipboardWatcherService _instance = ClipboardWatcherService._internal();
  factory ClipboardWatcherService() => _instance;
  ClipboardWatcherService._internal();

  Timer? _timer;
  String _lastText = '';
  final _clipboardController = StreamController<String>.broadcast();

  Stream<String> get clipboardStream => _clipboardController.stream;
  String get lastCopiedText => _lastText;

  bool _isWatching = false;
  bool get isWatching => _isWatching;

  void startWatching({Duration interval = const Duration(seconds: 2)}) {
    if (_isWatching) return;
    _isWatching = true;
    _checkClipboard();
    _timer = Timer.periodic(interval, (_) => _checkClipboard());
  }

  void stopWatching() {
    _timer?.cancel();
    _timer = null;
    _isWatching = false;
  }

  Future<void> _checkClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.isNotEmpty && text != _lastText && text.length > 2) {
        _lastText = text;
        _clipboardController.add(text);
      }
    } catch (_) {
      // Ignore clipboard read errors if app is backgrounded or permission denied
    }
  }

  void markProcessed(String text) {
    if (_lastText == text) {
      _lastText = '';
    }
  }

  Future<void> copyText(String text) async {
    _lastText = text.trim();
    await Clipboard.setData(ClipboardData(text: text));
  }

  void dispose() {
    stopWatching();
    _clipboardController.close();
  }
}

