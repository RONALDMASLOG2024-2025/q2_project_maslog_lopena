import 'dart:ui';
import 'package:flutter/material.dart';

/// Bubble specification for positioning and styling
class BubbleSpec {
  final Offset pos; // 0..1 relative
  final double radius;
  final Color color;
  const BubbleSpec(this.pos, this.radius, this.color);
}

/// Static grid + blurred bubbles background for all pages.
/// No animation, no motion. Use as a full-screen Stack background.
class StaticGridBubblesBackground extends StatelessWidget {
  final Color gridColor;
  final double gridSpacing;
  final List<BubbleSpec> bubbles;
  const StaticGridBubblesBackground({
    super.key,
    this.gridColor = const Color(0x2290A48C), // Softer green grid
    this.gridSpacing = 40, // Tighter grid for clarity
    this.bubbles = const [
      BubbleSpec(Offset(0.20, 0.30), 80, Color(0x1A90EE90)), // Sun-like, soft green
      BubbleSpec(Offset(0.65, 0.22), 60, Color(0x1490EE90)),
      BubbleSpec(Offset(0.50, 0.70), 90, Color(0x1190EE90)),
      BubbleSpec(Offset(0.80, 0.80), 70, Color(0x0F90EE90)),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          fit: StackFit.expand,
          children: [
            // Bubbles first (background)
            ...bubbles.map((b) => Positioned(
              left: b.pos.dx * size.width - b.radius,
              top: b.pos.dy * size.height - b.radius,
              child: _BlurredBubble(radius: b.radius, color: b.color),
            )),
            // Grid above bubbles
            CustomPaint(
              size: size,
              painter: _GridPainter(gridColor, gridSpacing),
            ),
          ],
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  final double spacing;
  _GridPainter(this.color, this.spacing);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.1;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant _GridPainter old) => false;
}

class _BlurredBubble extends StatelessWidget {
  final double radius;
  final Color color;
  const _BlurredBubble({required this.radius, required this.color});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 140, sigmaY: 140), // Softer, sun-like glow
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.08), // Extremely low opacity
              border: Border.all(color: Colors.transparent, width: 0),
            ),
          ),
        ),
      ),
    );
  }
}
