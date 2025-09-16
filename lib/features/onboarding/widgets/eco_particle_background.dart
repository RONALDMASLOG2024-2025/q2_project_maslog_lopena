import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Eco-themed animated background with softly drifting "leaf" particles.
/// Design goals:
/// - Calm, slow upward drift (suggests lightness & environmental rise)
/// - Gentle horizontal sway (sine wave) + subtle rotation
/// - Low overdraw & no allocations per frame (positions derived from time)
/// - Configurable density & reduced motion support
class EcoParticleBackground extends StatefulWidget {
  final Widget child;
  final int leafCount; // Number of particles
  final bool reduceMotion; // If true, animation speed is near-still
  final double densityScale; // Scales leafCount (for responsiveness)
  final List<Color>? colors;
  final double maxLeafSize;
  final bool enableBreathingOpacity;
  /// Global multiplier for animation speed (1 = normal). Lower = calmer.
  final double speedScale;

  const EcoParticleBackground({
    super.key,
    required this.child,
    this.leafCount = 18,
    this.reduceMotion = false,
    this.densityScale = 1.0,
    this.colors,
    this.maxLeafSize = 42,
    this.enableBreathingOpacity = true,
  this.speedScale = 0.55,
  });

  /// Optional global dynamic density override (e.g., from frame budget heuristic).
  static int Function(int base)? dynamicLeafCount;

  @override
  State<EcoParticleBackground> createState() => _EcoParticleBackgroundState();
}

class _EcoParticleBackgroundState extends State<EcoParticleBackground> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final int _leafCount;
  final _rand = Random();
  late final List<_LeafSeed> _seeds;
  Duration _elapsed = Duration.zero;
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
  final base = (widget.leafCount * widget.densityScale).round();
  final adjusted = EcoParticleBackground.dynamicLeafCount?.call(base) ?? base;
  _leafCount = adjusted.clamp(4, 120);
    _seeds = List.generate(_leafCount, _spawnSeed);
    _ticker = createTicker((d) {
      setState(() => _elapsed = d);
    })..start();
  }

  _LeafSeed _spawnSeed(int i) {
    // Slower rise speed range (previously 0.35..0.6)
    final baseSpeed = _rand.nextDouble() * 0.15 + 0.15; // 0.15..0.30
    return _LeafSeed(
      startX: _rand.nextDouble(),
      startY: _rand.nextDouble(),
      amplitude: _rand.nextDouble() * 28 + 12, // horizontal sway amplitude
      swaySpeed: _rand.nextDouble() * 0.3 + 0.25, // slower horizontal frequency 0.25..0.55
      riseSpeed: baseSpeed, // upward drift
      size: _rand.nextDouble() * (widget.maxLeafSize - 18) + 18,
      rotationSpeed: (_rand.nextDouble() * 0.25 + 0.1) * (_rand.nextBool() ? 1 : -1), // gentler rotation
      phase: _rand.nextDouble() * pi * 2,
      colorIndex: _rand.nextInt((widget.colors?.length ?? 0).clamp(1, 999)),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = widget.colors ?? [
      theme.colorScheme.primary.withValues(alpha: 0.18),
      theme.colorScheme.primary.withValues(alpha: 0.10),
      theme.colorScheme.primary.withValues(alpha: 0.25),
      theme.colorScheme.tertiary.withValues(alpha: 0.15),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        _size = Size(constraints.maxWidth, constraints.maxHeight);
        return RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _LeafPainter(
                  seeds: _seeds,
                  elapsed: _elapsed,
                  size: _size,
                  colors: colors,
                  reduceMotion: widget.reduceMotion,
                  breathing: widget.enableBreathingOpacity,
                  speedScale: widget.speedScale,
                ),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class _LeafSeed {
  final double startX; // 0..1 relative
  final double startY; // 0..1 relative
  final double amplitude;
  final double swaySpeed;
  final double riseSpeed;
  final double size;
  final double rotationSpeed;
  final double phase;
  final int colorIndex;
  const _LeafSeed({
    required this.startX,
    required this.startY,
    required this.amplitude,
    required this.swaySpeed,
    required this.riseSpeed,
    required this.size,
    required this.rotationSpeed,
    required this.phase,
    required this.colorIndex,
  });
}

class _LeafPainter extends CustomPainter {
  final List<_LeafSeed> seeds;
  final Duration elapsed;
  final Size size;
  final List<Color> colors;
  final bool reduceMotion;
  final bool breathing;
  final double speedScale;
  _LeafPainter({
    required this.seeds,
    required this.elapsed,
    required this.size,
    required this.colors,
    required this.reduceMotion,
    required this.breathing,
    required this.speedScale,
  });

  @override
  void paint(Canvas canvas, Size _) {
    final t = elapsed.inMilliseconds / 1000.0; // seconds
    final paint = Paint()..style = PaintingStyle.fill;

    for (final s in seeds) {
  final riseSpeed = (reduceMotion ? s.riseSpeed * 0.08 : s.riseSpeed) * speedScale;
  final swaySpeed = (reduceMotion ? s.swaySpeed * 0.12 : s.swaySpeed) * speedScale;
  final rotationSpeed = (reduceMotion ? s.rotationSpeed * 0.12 : s.rotationSpeed) * speedScale;

      // Vertical progress loops (wrap every time leaf exits top)
      final yTravel = (t * riseSpeed + s.startY) % 1.0; // 0..1
      final y = size.height * (1 - yTravel); // Start near bottom, move up
  final sway = sin(s.phase + t * swaySpeed * 1.6) * s.amplitude; // slower horizontal oscillation
      final x = (s.startX * size.width + sway).clamp(-60, size.width + 60);

      // Rotation & breathing opacity
      final rotation = (s.phase + t * rotationSpeed).clamp(-9999, 9999);
      final breathe = breathing ? (0.6 + 0.4 * sin(s.phase + t * 0.8)) : 1.0;
  final base = colors[s.colorIndex % colors.length];
  final a = ((base.a) * breathe).clamp(0.05, 0.9);
  final color = base.withValues(alpha: a);
      paint.color = color;

      // Draw leaf path (stylized teardrop with central vein implied via gradient-like layering)
      final leafSize = s.size;
      final path = Path();
      path.moveTo(0, -leafSize * 0.5);
      path.quadraticBezierTo(leafSize * 0.55, -leafSize * 0.05, 0, leafSize * 0.55);
      path.quadraticBezierTo(-leafSize * 0.55, -leafSize * 0.05, 0, -leafSize * 0.5);

      canvas.save();
  canvas.translate(x.toDouble(), y.toDouble());
      canvas.rotate(rotation * 0.25);
      canvas.drawPath(path, paint);
      // Secondary lighter highlight
      if (!reduceMotion) {
  final highlight = paint.color.withValues(alpha: (paint.color.a * 0.55));
  final m = Matrix4.identity()..scale(.55, .55);
  final hlPath = path.transform(m.storage);
        final hlPaint = Paint()..color = highlight;
        canvas.drawPath(hlPath, hlPaint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LeafPainter old) => old.elapsed != elapsed || old.reduceMotion != reduceMotion;
}
