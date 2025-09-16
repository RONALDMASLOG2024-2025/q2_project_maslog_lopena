import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Lightweight animated particle background (Web/Desktop/Mobile safe)
/// Avoids heavy shaders; uses repaint boundary + single ticker.
class ParticleBackground extends StatefulWidget {
  final int particleCount;
  final Duration duration;
  final List<Color>? colors;
  final Widget child;
  final double maxSize;
  final double velocityScale;

  const ParticleBackground({
    super.key,
    required this.child,
    this.particleCount = 26,
    this.duration = const Duration(milliseconds: 22),
    this.colors,
    this.maxSize = 22,
    this.velocityScale = 0.25,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _rand = Random();
  final List<_Particle> _particles = [];
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _ensureParticles() {
    if (_size == Size.zero || _particles.isNotEmpty) return;
    final colors = widget.colors ?? [
      const Color(0x331B7F4B),
      const Color(0x221B7F4B),
      const Color(0x441B7F4B),
    ];
    for (var i = 0; i < widget.particleCount; i++) {
      final speed = (_rand.nextDouble() * 0.8 + 0.2) * widget.velocityScale;
      _particles.add(_Particle(
        position: Offset(
          _rand.nextDouble() * _size.width,
          _rand.nextDouble() * _size.height,
        ),
        velocity: Offset(
          (_rand.nextDouble() * 2 - 1) * speed,
          (_rand.nextDouble() * 2 - 1) * speed,
        ),
        radius: _rand.nextDouble() * (widget.maxSize - 6) + 6,
        color: colors[_rand.nextInt(colors.length)],
      ));
    }
  }

  void _tick(Duration _) {
    if (!mounted || _size == Size.zero) return;
    setState(() {
      for (final p in _particles) {
        var next = p.position + p.velocity * 16; // scale for perceptibility
        if (next.dx < 0 || next.dx > _size.width) {
          p.velocity = Offset(-p.velocity.dx, p.velocity.dy);
          next = p.position + p.velocity * 16;
        }
        if (next.dy < 0 || next.dy > _size.height) {
          p.velocity = Offset(p.velocity.dx, -p.velocity.dy);
          next = p.position + p.velocity * 16;
        }
        p.position = next;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final newSize = Size(constraints.maxWidth, constraints.maxHeight);
        if (newSize != _size) {
          _size = newSize;
          _ensureParticles();
        }
        return RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _ParticlePainter(_particles)),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class _Particle {
  _Particle({required this.position, required this.velocity, required this.radius, required this.color});
  Offset position;
  Offset velocity;
  double radius;
  Color color;
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      paint.color = p.color;
      canvas.drawCircle(p.position, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
