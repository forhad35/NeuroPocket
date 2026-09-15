import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'NeuroPocket';
  static const String appTagline = '100% On-Device AI Writing & OCR';
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  // Available local models
  static const String defaultModelName = 'Llama-3.2-1B-Instruct (Q4_K_M)';
  static const String defaultModelSize = '774 MB';
  static const String defaultModelFileName = 'llama-3.2-1b-instruct-q4_k_m.gguf';

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration toastDuration = Duration(seconds: 2);

  // Colors
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondaryColor = Color(0xFF06B6D4); // Cyan
  static const Color accentColor = Color(0xFF10B981); // Emerald
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);
}

