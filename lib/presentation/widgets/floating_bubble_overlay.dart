import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/screen_text_scanner.dart';
import '../blocs/floating_bubble/floating_bubble_bloc.dart';
import '../blocs/floating_bubble/floating_bubble_event.dart';
import '../blocs/floating_bubble/floating_bubble_state.dart';
import 'floating_translate_card.dart';

class FloatingBubbleOverlay extends StatefulWidget {
  final Widget child;
  const FloatingBubbleOverlay({super.key, required this.child});

  static final GlobalKey<FloatingBubbleOverlayState> overlayKey =
      GlobalKey<FloatingBubbleOverlayState>();

  static void showCardForText(String text, {Rect? targetBounds}) {
    overlayKey.currentState?.openCardWithText(text, targetBounds: targetBounds);
  }

  @override
  State<FloatingBubbleOverlay> createState() => FloatingBubbleOverlayState();
}

class FloatingBubbleOverlayState extends State<FloatingBubbleOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late AnimationController _scanLaserController;

  bool _isCardOpen = false;
  bool _isDragging = false;
  String? _preloadedText;
  ScannableTextNode? _scannedNode;
  Rect? _targetCardBounds;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();

    _scanLaserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _scanLaserController.dispose();
    super.dispose();
  }

  void openCardWithText(String text, {Rect? targetBounds}) {
    setState(() {
      _preloadedText = text;
      _targetCardBounds = targetBounds;
      _isCardOpen = true;
    });

    // Auto-detect language and trigger translation
    final isBangla = RegExp(r'[\u0980-\u09FF]').hasMatch(text);
    final action = isBangla ? 'translate_en' : 'translate_bn';
    context.read<FloatingBubbleBloc>().add(
          QuickTranslateTextEvent(text: text, action: action),
        );
  }

  void _scanTextAtLens(double lensCenterX, double lensCenterY, {bool autoOpen = false}) {
    final node = ScreenTextScanner.instance
        .findTextAt(Offset(lensCenterX, lensCenterY), scanRadius: 80.0);
    setState(() {
      _scannedNode = node;
    });

    if (autoOpen && node != null && node.text.trim().isNotEmpty) {
      openCardWithText(node.text, targetBounds: node.bounds);
    }
  }

  void _toggleCard() {
    if (_isCardOpen) {
      _closeCard();
    } else {
      final state = context.read<FloatingBubbleBloc>().state;
      const lensSize = 60.0;
      final lensCenterX = state.posX + lensSize / 2;
      final lensCenterY = state.posY + lensSize / 2;
      final node = ScreenTextScanner.instance
          .findTextAt(Offset(lensCenterX, lensCenterY), scanRadius: 100.0);

      if (node != null && node.text.trim().isNotEmpty) {
        openCardWithText(node.text, targetBounds: node.bounds);
      } else {
        setState(() {
          _isCardOpen = true;
          _targetCardBounds = null;
        });
      }
    }
  }

  void _closeCard() {
    setState(() {
      _isCardOpen = false;
      _preloadedText = null;
      _scannedNode = null;
      _targetCardBounds = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FloatingBubbleBloc, FloatingBubbleState>(
      builder: (context, state) {
        if (!state.isEnabled) {
          return widget.child;
        }

        final size = MediaQuery.of(context).size;
        const lensSize = 60.0;
        final clampedX =
            state.posX.clamp(12.0, (size.width - lensSize - 12.0).clamp(12.0, double.infinity));
        final clampedY =
            state.posY.clamp(60.0, (size.height - lensSize - 80.0).clamp(60.0, double.infinity));

        const cardWidth = 320.0;
        const cardHeightEstimate = 260.0;

        double cardLeft;
        double cardTop;

        if (_targetCardBounds != null) {
          // Align directly above or below the scanned text bounds
          cardLeft = (_targetCardBounds!.center.dx - cardWidth / 2)
              .clamp(12.0, (size.width - cardWidth - 12.0).clamp(12.0, double.infinity));
          if (_targetCardBounds!.bottom + 10 + cardHeightEstimate < size.height - 40) {
            cardTop = _targetCardBounds!.bottom + 8;
          } else {
            cardTop = (_targetCardBounds!.top - cardHeightEstimate - 8)
                .clamp(50.0, size.height);
          }
        } else {
          // Align with lens
          cardLeft = (clampedX + lensSize / 2 - cardWidth / 2)
              .clamp(12.0, (size.width - cardWidth - 12.0).clamp(12.0, double.infinity));
          if (clampedY + lensSize + 12 + cardHeightEstimate < size.height - 40) {
            cardTop = clampedY + lensSize + 10;
          } else {
            cardTop = (clampedY - cardHeightEstimate - 10).clamp(50.0, size.height);
          }
        }

        return Stack(
          key: FloatingBubbleOverlay.overlayKey,
          children: [
            widget.child,

            // Active Scanning Highlight on Detected Text Node during Drag
            if (_isDragging && _scannedNode != null)
              Positioned(
                left: _scannedNode!.bounds.left - 4,
                top: _scannedNode!.bounds.top - 4,
                width: _scannedNode!.bounds.width + 8,
                height: _scannedNode!.bounds.height + 8,
                child: AnimatedBuilder(
                  animation: _scanLaserController,
                  builder: (context, _) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF00C6FF).withAlpha(
                            (120 + 130 * _scanLaserController.value).toInt(),
                          ),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0072FF).withAlpha(60),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Align(
                        alignment: Alignment(0, -1.0 + 2.0 * _scanLaserController.value),
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFF00C6FF),
                                Colors.white,
                                Color(0xFF00C6FF),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00C6FF).withAlpha(180),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Floating Translation Card Popup
            if (_isCardOpen)
              Positioned(
                left: cardLeft,
                top: cardTop,
                child: Material(
                  type: MaterialType.transparency,
                  child: FloatingTranslateCard(
                    initialText: _preloadedText,
                    onClose: _closeCard,
                  ),
                ),
              ),

            // Draggable Magnifying Lens (Hi Translate Style)
            Positioned(
              left: clampedX,
              top: clampedY,
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _isDragging = true;
                  });
                },
                onPanUpdate: (details) {
                  final newX = state.posX + details.delta.dx;
                  final newY = state.posY + details.delta.dy;
                  context.read<FloatingBubbleBloc>().add(
                        UpdateBubblePositionEvent(
                          dx: newX,
                          dy: newY,
                        ),
                      );

                  // Real-time text node detection under the magnifying glass center
                  final lensCenterX = newX + lensSize / 2;
                  final lensCenterY = newY + lensSize / 2;
                  _scanTextAtLens(lensCenterX, lensCenterY, autoOpen: false);
                },
                onPanEnd: (details) {
                  setState(() {
                    _isDragging = false;
                  });

                  // Snap to nearest screen edge horizontally
                  final screenWidth = size.width;
                  final snapX = (clampedX + lensSize / 2 < screenWidth / 2)
                      ? 16.0
                      : screenWidth - lensSize - 16.0;

                  context.read<FloatingBubbleBloc>().add(
                        UpdateBubblePositionEvent(
                          dx: snapX,
                          dy: clampedY,
                        ),
                      );

                  // If dropped over a text node, instantly open the translation card!
                  if (_scannedNode != null && _scannedNode!.text.trim().isNotEmpty) {
                    openCardWithText(_scannedNode!.text,
                        targetBounds: _scannedNode!.bounds);
                  }
                },
                onTap: _toggleCard,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildMagnifyingLens(lensSize),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Hi Translate Magnifying Glass / Search Lens Visual
  Widget _buildMagnifyingLens(double size) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Drag Radar / Scan Ring when moving
          if (_isDragging)
            Container(
              width: size + 20,
              height: size + 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00C6FF).withAlpha(180),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0072FF).withAlpha(120),
                    blurRadius: 18,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),

          // Main Lens
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0072FF),
                  Color(0xFF00C6FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0072FF).withAlpha(100),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner Glass Refraction effect
                Container(
                  width: size - 12,
                  height: size - 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withAlpha(60),
                        Colors.white.withAlpha(10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                // Center Icon: Search / Magnifying Crosshair
                const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 26,
                ),

                // Target Crosshairs dot
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
