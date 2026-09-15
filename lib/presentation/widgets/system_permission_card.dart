import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/localization/app_strings.dart';
import '../../data/services/accessibility_service.dart';

class SystemPermissionCard extends StatefulWidget {
  const SystemPermissionCard({super.key});

  @override
  State<SystemPermissionCard> createState() => _SystemPermissionCardState();
}

class _SystemPermissionCardState extends State<SystemPermissionCard>
    with WidgetsBindingObserver {
  bool _isAccessibilityGranted = false;
  bool _isOverlayGranted = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    if (!Platform.isAndroid) {
      setState(() {
        _isAccessibilityGranted = true;
        _isOverlayGranted = true;
        _isChecking = false;
      });
      return;
    }

    final acc = await AccessibilityServiceHelper.isAccessibilityEnabled();
    final over = await AccessibilityServiceHelper.isOverlayPermissionGranted();

    if (over) {
      await AccessibilityServiceHelper.startFloatingOverlay();
    }

    if (mounted) {
      setState(() {
        _isAccessibilityGranted = acc;
        _isOverlayGranted = over;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking || (!Platform.isAndroid)) {
      return const SizedBox.shrink();
    }

    final allGranted = _isAccessibilityGranted && _isOverlayGranted;
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: allGranted
            ? const Color(0xFF10B981).withAlpha(isDark ? 25 : 15)
            : const Color(0xFFF59E0B).withAlpha(isDark ? 30 : 20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: allGranted
              ? const Color(0xFF10B981).withAlpha(80)
              : const Color(0xFFF59E0B).withAlpha(100),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: allGranted ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  allGranted ? Icons.security_rounded : Icons.lock_open_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.isBangla
                          ? (allGranted
                              ? 'অন-স্ক্রিন ট্রান্সলেশন পারমিশন একটিভ'
                              : 'অন-স্ক্রিন ড্র্যাগ ট্রান্সলেট পারমিশন প্রয়োজন')
                          : (allGranted
                              ? 'On-Screen Translation Permission Active'
                              : 'System Accessibility & Overlay Permission'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      strings.isBangla
                          ? (allGranted
                              ? 'যেকোনো অ্যাপে লেন্স দিয়ে লেখা ট্রান্সলেট করতে পারবেন।'
                              : 'অন্যান্য অ্যাপের টেক্সট স্ক্যান করতে অ্যাক্সেসিবিলিটি ও ওভারলে পারমিশন দিন।')
                          : (allGranted
                              ? 'Ready to drag & translate text across any app.'
                              : 'Grant accessibility & overlay to scan & translate on other apps.'),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!allGranted) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (!_isAccessibilityGranted)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          AccessibilityServiceHelper.openAccessibilitySettings(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0072FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.accessibility_new_rounded, size: 15),
                      label: Text(
                        strings.isBangla ? 'Accessibility অন করুন' : 'Enable Accessibility',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (!_isAccessibilityGranted && !_isOverlayGranted)
                  const SizedBox(width: 8),
                if (!_isOverlayGranted)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          AccessibilityServiceHelper.openOverlaySettings(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.layers_rounded, size: 15),
                      label: Text(
                        strings.isBangla ? 'Overlay পারমিশন' : 'Grant Overlay',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
