import 'package:flutter/material.dart';

/// Represents a scanned text element with its bounds on screen
class ScannableTextNode {
  final String text;
  final Rect bounds;
  final String? id;

  ScannableTextNode({
    required this.text,
    required this.bounds,
    this.id,
  });
}

/// Global registry that allows the Magnifying Lens to scan and read any text on screen by coordinates
class ScreenTextScanner {
  static final ScreenTextScanner instance = ScreenTextScanner._();
  ScreenTextScanner._();

  final Map<String, GlobalKey> _registeredKeys = {};
  final Map<String, String> _registeredTexts = {};

  void register(String id, GlobalKey key, String text) {
    _registeredKeys[id] = key;
    _registeredTexts[id] = text;
  }

  void unregister(String id) {
    _registeredKeys.remove(id);
    _registeredTexts.remove(id);
  }

  /// Finds the text under or closest to the given screen coordinate (dx, dy)
  ScannableTextNode? findTextAt(Offset lensPosition, {double scanRadius = 120.0}) {
    ScannableTextNode? closestMatch;
    double closestDistance = double.infinity;

    for (final entry in _registeredKeys.entries) {
      final id = entry.key;
      final key = entry.value;
      final text = _registeredTexts[id];
      if (text == null || text.trim().isEmpty) continue;

      final context = key.currentContext;
      if (context == null || !context.mounted) continue;

      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) continue;

      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      final rect = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);

      // Check if lens position is directly inside the text box bounds
      if (rect.contains(lensPosition)) {
        return ScannableTextNode(text: text, bounds: rect, id: id);
      }

      // Or check distance from lens center to text rect
      final center = rect.center;
      final distance = (center - lensPosition).distance;
      if (distance < scanRadius && distance < closestDistance) {
        closestDistance = distance;
        closestMatch = ScannableTextNode(text: text, bounds: rect, id: id);
      }
    }

    return closestMatch;
  }
}

/// Widget that automatically registers its text with the ScreenTextScanner
class ScannableText extends StatefulWidget {
  final String text;
  final Widget child;
  final String? id;

  const ScannableText({
    super.key,
    required this.text,
    required this.child,
    this.id,
  });

  @override
  State<ScannableText> createState() => _ScannableTextState();
}

class _ScannableTextState extends State<ScannableText> {
  final GlobalKey _key = GlobalKey();
  late String _nodeId;

  @override
  void initState() {
    super.initState();
    _nodeId = widget.id ?? 'scannable_${identityHashCode(this)}_${DateTime.now().microsecondsSinceEpoch}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScreenTextScanner.instance.register(_nodeId, _key, widget.text);
    });
  }

  @override
  void didUpdateWidget(covariant ScannableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      ScreenTextScanner.instance.register(_nodeId, _key, widget.text);
    }
  }

  @override
  void dispose() {
    ScreenTextScanner.instance.unregister(_nodeId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      child: widget.child,
    );
  }
}

