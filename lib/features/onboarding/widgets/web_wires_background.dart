import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Futuristic animated web: bouncing nodes connected by flexible wires.
/// - Nodes oscillate around anchors; edges curve with a perpendicular bounce.
/// - Subtle upward drift to suggest motion; no settings-based adjustments.
class WebWiresBackground extends StatefulWidget {
  final int nodeCount; // number of web vertices
  final int neighborCount; // edges per node (nearest)
  final double opacity; // base opacity for lines
  final double lineWidthMin;
  final double lineWidthMax;
  final double nodeMin;
  final double nodeMax;
  final double driftUpPerSecond; // fraction of height per second

  const WebWiresBackground({
    super.key,
    this.nodeCount = 32,
    this.neighborCount = 3,
    this.opacity = 0.14,
    this.lineWidthMin = 0.9,
    this.lineWidthMax = 2.0,
    this.nodeMin = 2.0,
    this.nodeMax = 4.0,
    this.driftUpPerSecond = 0.02,
  });

  @override
  State<WebWiresBackground> createState() => _WebWiresBackgroundState();
}

class _WebWiresBackgroundState extends State<WebWiresBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;
  Size _size = Size.zero;
  late final List<_NodeSeed> _nodes;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    final count = widget.nodeCount.clamp(8, 80);
    _nodes = List.generate(count, _spawnNode);
    _ticker = createTicker((d) => setState(() => _elapsed = d))..start();
  }

  _NodeSeed _spawnNode(int i) {
    final ax = _rand.nextDouble();
    final ay = _rand.nextDouble();
    final rx = _rand.nextDouble() * 26 + 10; // x oscillation radius
    final ry = _rand.nextDouble() * 26 + 10; // y oscillation radius
    final sx = _rand.nextDouble() * 0.8 + 0.4; // x oscillation speed
    final sy = _rand.nextDouble() * 0.8 + 0.4; // y oscillation speed
    final px = _rand.nextDouble() * pi * 2;
    final py = _rand.nextDouble() * pi * 2;
    final lw = _rand.nextDouble() * (widget.lineWidthMax - widget.lineWidthMin) + widget.lineWidthMin;
    final ns = _rand.nextDouble() * (widget.nodeMax - widget.nodeMin) + widget.nodeMin;
    return _NodeSeed(
      ax: ax,
      ay: ay,
      rx: rx,
      ry: ry,
      sx: sx,
      sy: sy,
      px: px,
      py: py,
      lineWidth: lw,
      nodeSize: ns,
      hueIndex: i % 3,
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = <Color>[
      cs.primary.withValues(alpha: widget.opacity),
      cs.tertiary.withValues(alpha: widget.opacity * 0.95),
      cs.primary.withValues(alpha: widget.opacity * 0.70),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = Size(constraints.maxWidth, constraints.maxHeight);
        return RepaintBoundary(
          child: CustomPaint(
            painter: _WebPainter(
              nodes: _nodes,
              elapsed: _elapsed,
              size: _size,
              colors: colors,
              driftUpPerSecond: widget.driftUpPerSecond,
              neighborCount: widget.neighborCount,
            ),
          ),
        );
      },
    );
  }
}

class _NodeSeed {
  final double ax, ay; // anchor 0..1
  final double rx, ry; // oscillation radii (px)
  final double sx, sy; // speeds (cycles per second)
  final double px, py; // phases
  final double lineWidth;
  final double nodeSize;
  final int hueIndex;
  const _NodeSeed({
    required this.ax,
    required this.ay,
    required this.rx,
    required this.ry,
    required this.sx,
    required this.sy,
    required this.px,
    required this.py,
    required this.lineWidth,
    required this.nodeSize,
    required this.hueIndex,
  });
}

class _WebPainter extends CustomPainter {
  final List<_NodeSeed> nodes;
  final Duration elapsed;
  final Size size;
  final List<Color> colors;
  final double driftUpPerSecond;
  final int neighborCount;
  _WebPainter({
    required this.nodes,
    required this.elapsed,
    required this.size,
    required this.colors,
    required this.driftUpPerSecond,
    required this.neighborCount,
  });

  @override
  void paint(Canvas canvas, Size _) {
    final t = elapsed.inMilliseconds / 1000.0;
    final drift = (t * driftUpPerSecond) % 1.0; // 0..1 upward

    // Compute positions
    final positions = List<Offset>.generate(nodes.length, (i) {
      final n = nodes[i];
      final x = n.ax * size.width + sin(n.px + t * n.sx) * n.rx;
      final yNorm = (n.ay - drift);
      final y = (yNorm - yNorm.floorToDouble()) * size.height + cos(n.py + t * n.sy) * n.ry;
      return Offset(x, y);
    });

    // Draw edges (k-nearest neighbors with bouncing midpoint)
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

    for (var i = 0; i < positions.length; i++) {
      // Find nearest neighbors
      final src = positions[i];
      final distances = <int, double>{};
      for (var j = 0; j < positions.length; j++) {
        if (i == j) continue;
        final d2 = (positions[j] - src).distanceSquared;
        distances[j] = d2;
      }
      final nearest = distances.keys.toList()
        ..sort((a, b) => distances[a]!.compareTo(distances[b]!));
      final connectTo = nearest.take(neighborCount);

      for (final j in connectTo) {
        final dst = positions[j];
        final len = (dst - src).distance;
        if (len < 1) continue;
        final mid = Offset((src.dx + dst.dx) * 0.5, (src.dy + dst.dy) * 0.5);
        final normal = Offset(-(dst.dy - src.dy) / len, (dst.dx - src.dx) / len);
        final wobble = sin(t * 0.9 + (i + j) * 0.3) * min(12.0, len * 0.06);
        final cp = mid + normal * wobble; // bouncing midpoint control point

        edgePaint
          ..color = colors[(i + j) % colors.length]
          ..strokeWidth = (nodes[i].lineWidth + nodes[j].lineWidth) * 0.5;
        final path = Path()
          ..moveTo(src.dx, src.dy)
          ..quadraticBezierTo(cp.dx, cp.dy, dst.dx, dst.dy);
        canvas.drawPath(path, edgePaint);
      }
    }

    // Draw nodes with soft glow and subtle pulse
    final nodePaint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < positions.length; i++) {
      final n = nodes[i];
      final p = positions[i];
      final base = colors[n.hueIndex % colors.length];
      final pulse = 0.5 + 0.5 * sin(t * 1.2 + i * 0.7);
      final r = n.nodeSize + pulse * 0.8;

      // glow
      final glow = Paint()
        ..color = base.withValues(alpha: base.a * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(p, r * 1.8, glow);

      nodePaint.color = base.withValues(alpha: base.a * 1.0);
      canvas.drawCircle(p, r, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WebPainter old) => old.elapsed != elapsed;
}
