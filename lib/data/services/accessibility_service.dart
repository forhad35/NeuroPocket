import 'dart:io';
import 'package:flutter/services.dart';

class AccessibilityServiceHelper {
  static const MethodChannel _channel =
      MethodChannel('com.example.flutter_ai/accessibility');

  /// Check if the Android Accessibility Service is currently enabled
  static Future<bool> isAccessibilityEnabled() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? result =
          await _channel.invokeMethod<bool>('isAccessibilityEnabled');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Open system Accessibility Settings page
  static Future<void> openAccessibilitySettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  /// Check if Display Over Other Apps (SYSTEM_ALERT_WINDOW) is granted
  static Future<bool> isOverlayPermissionGranted() async {
    if (!Platform.isAndroid) return true;
    try {
      final bool? result =
          await _channel.invokeMethod<bool>('isOverlayPermissionGranted');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Open system Draw Over Other Apps Settings page
  static Future<void> openOverlaySettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openOverlaySettings');
    } catch (_) {}
  }

  /// Start the system-wide Native Floating Lens Service (remains active when app is minimized)
  static Future<bool> startFloatingOverlay() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? result =
          await _channel.invokeMethod<bool>('startFloatingOverlay');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Stop the system-wide Native Floating Lens Service
  static Future<bool> stopFloatingOverlay() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? result =
          await _channel.invokeMethod<bool>('stopFloatingOverlay');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Check if the Native Floating Lens is running
  static Future<bool> isFloatingOverlayRunning() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? result =
          await _channel.invokeMethod<bool>('isFloatingOverlayRunning');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}

