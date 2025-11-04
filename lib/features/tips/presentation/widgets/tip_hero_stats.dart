import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/design/design_system.dart';

class TipHeroStats extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final double weeklyCompletion; // 0..1
  final bool reduceMotion;
  const TipHeroStats({super.key, required this.currentStreak, required this.longestStreak, required this.weeklyCompletion, this.reduceMotion=false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.fromLTRB(GWDs.s7, GWDs.s4, GWDs.s7, GWDs.s5),
      height: 168,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: LinearGradient(
          colors: [
            cs.primary.withValues(alpha: 0.80),
            cs.primary.withValues(alpha: 0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: cs.primary.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
        child: Row(
          children: [
            _RingProgress(value: weeklyCompletion, reduceMotion: reduceMotion),
            const SizedBox(width: 26),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('GreenWise', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 18, runSpacing: 8, children: [
                    _StatChip(label: 'Streak', value: currentStreak.toString(), icon: Icons.local_fire_department, color: Colors.orangeAccent),
                    _StatChip(label: 'Best', value: longestStreak.toString(), icon: Icons.emoji_events_outlined, color: cs.secondary),
                  ]),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _RingProgress extends StatefulWidget {
  final double value; final bool reduceMotion; const _RingProgress({required this.value, required this.reduceMotion});
  @override State<_RingProgress> createState()=> _RingProgressState(); }

class _RingProgressState extends State<_RingProgress> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync:this,duration:GWDs.animSlow)..forward();
  double _oldVal=0;
  @override void didUpdateWidget(covariant _RingProgress old){super.didUpdateWidget(old); if(old.value!=widget.value){_oldVal=old.value; if(!widget.reduceMotion){_c..value=0..forward();} else {_c.value=1;}}}
  @override void dispose(){_c.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme; return SizedBox(
      width:84,height:84,
      child: AnimatedBuilder(
        animation:_c,
        builder:(context,_){
          final t=Curves.easeOutCubic.transform(_c.value);
          final v=_oldVal + (widget.value-_oldVal)*t;
          return CustomPaint(painter:_RingPainter(v,cs));
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double v; final ColorScheme cs; _RingPainter(this.v,this.cs);
  @override void paint(Canvas c, Size s){
    final bg=Paint()
      ..color=Colors.white.withValues(alpha:0.15)
      ..style=PaintingStyle.stroke
      ..strokeWidth=10
      ..strokeCap=StrokeCap.round;
    final fg=Paint()
      ..shader=SweepGradient(colors:[cs.onPrimary, cs.secondary, cs.onPrimary],startAngle: -math.pi/2,endAngle: math.pi*1.5).createShader(Rect.fromCircle(center: s.center(Offset.zero), radius:s.width/2))
      ..style=PaintingStyle.stroke
      ..strokeWidth=10
      ..strokeCap=StrokeCap.round;
    c.drawArc(Rect.fromCircle(center:s.center(Offset.zero),radius:s.width/2),0,math.pi*2,false,bg);
    c.drawArc(Rect.fromCircle(center:s.center(Offset.zero),radius:s.width/2),-math.pi/2,math.pi*2*v,false,fg);
    final txtPainter=TextPainter(text: TextSpan(text:'${(v*100).round()}%', style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w600, fontSize: 14)), textDirection: TextDirection.ltr)..layout();
    txtPainter.paint(c, s.center(Offset(-txtPainter.width/2,-txtPainter.height/2)));
  }
  @override bool shouldRepaint(covariant _RingPainter old)=> old.v!=v;
}

class _StatChip extends StatelessWidget { final String label; final String value; final IconData icon; final Color color; const _StatChip({required this.label, required this.value, required this.icon, required this.color});
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal:14, vertical:8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.onPrimary.withValues(alpha:0.15)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min,children:[
        Icon(icon,size:16,color: color), const SizedBox(width:6),
        Text('$value $label', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
