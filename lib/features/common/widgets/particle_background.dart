import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Lightweight particle background (web-focused) with moving soft dots & link lines.
/// On non-web platforms it renders a subtle gradient container only (no animation) to avoid perf cost.
class ParticleBackground extends StatefulWidget {
  final int particleCount;
  final double maxVelocity;
  final List<Color>? colors;
  const ParticleBackground({
    super.key,
    this.particleCount = 42,
    this.maxVelocity = 0.25,
    this.colors,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final _rnd = Random();

  @override
  void initState() {
    super.initState();
    // Finite repeating controller to keep framework from seeing unbounded values (avoids test pump hang).
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..addListener(_tick)
      ..repeat();
    _particles = List.generate(widget.particleCount, (_) => _randomParticle());
  }

  _Particle _randomParticle({Size? size}) {
    return _Particle(
      position: Offset(
        _rnd.nextDouble() * (size?.width ?? 1),
        _rnd.nextDouble() * (size?.height ?? 1),
      ),
      velocity: Offset(
        (_rnd.nextDouble() - 0.5) * widget.maxVelocity,
        (_rnd.nextDouble() - 0.5) * widget.maxVelocity,
      ),
      radius: 1.5 + _rnd.nextDouble() * 3.5,
      color: (widget.colors ?? _defaultColors)[_rnd.nextInt((widget.colors ?? _defaultColors).length)],
    );
  }

  static const _defaultColors = [
    Color(0x3322AA66),
    Color(0x33228A99),
    Color(0x33227755),
  ];

  void _tick() {
    if (!mounted) return;
  if (mounted) setState(() {}); // positions recalculated in paint
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      // Simple static gradient for mobile/desktop builds.
      return IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ensure particles are within bounds on first frame
        for (var i = 0; i < _particles.length; i++) {
          final p = _particles[i];
            if (p.position.dx == 0 && p.position.dy == 0) {
              _particles[i] = _randomParticle(size: constraints.biggest);
            }
        }
        return RepaintBoundary(
          child: CustomPaint(
            painter: _ParticlePainter(_particles, constraints.biggest),
            size: constraints.biggest,
          ),
        );
      },
    );
  }
}

class _Particle {
  Offset velocity;
  final double radius;
  final Color color;
  Offset position;
  _Particle({required this.position, required this.velocity, required this.radius, required this.color});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Size size;
  final Paint _paintFill = Paint()..style = PaintingStyle.fill;
  final Paint _linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.6;
  _ParticlePainter(this.particles, this.size);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final p in particles) {
      // Update position
      var newPos = p.position + p.velocity * 16; // ~16ms/frame
      if (newPos.dx < 0 || newPos.dx > size.width) {
        newPos = Offset(newPos.dx.clamp(0, size.width), newPos.dy);
        p.velocity = Offset(-p.velocity.dx, p.velocity.dy);
      }
      if (newPos.dy < 0 || newPos.dy > size.height) {
        newPos = Offset(newPos.dx, newPos.dy.clamp(0, size.height));
        p.velocity = Offset(p.velocity.dx, -p.velocity.dy);
      }
      p.position = newPos;
    }
    // Draw connecting lines for nearby particles
    for (var i = 0; i < particles.length; i++) {
      for (var j = i + 1; j < particles.length; j++) {
        final a = particles[i];
        final b = particles[j];
        final dist = (a.position - b.position).distance;
        const maxDist = 140.0;
        if (dist < maxDist) {
          final t = 1 - (dist / maxDist);
          _linePaint.color = a.color.withValues(alpha: 0.15 * t);
          canvas.drawLine(a.position, b.position, _linePaint);
        }
      }
    }
    for (final p in particles) {
      final pulse = (sin((now / 1000) + p.radius) + 1) / 2; // 0..1
  _paintFill.color = p.color.withValues(alpha: 0.25 + 0.35 * pulse);
      canvas.drawCircle(p.position, p.radius, _paintFill);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
