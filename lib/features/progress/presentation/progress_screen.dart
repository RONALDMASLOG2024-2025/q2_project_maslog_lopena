import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design_system.dart';
import '../../common/widgets/eco_app_bar.dart';
// import removed: unused
import '../../common/widgets/static_grid_bubbles_background.dart';
// import removed: background visuals now static
import '../domain/impact_provider.dart';
import '../domain/progress_provider.dart';
import '../domain/streak_provider.dart';
import 'widgets/impact_metrics_section.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);
    final weeklyAsync = ref.watch(weeklyCompletionProvider);
    final recentAsync = ref.watch(recentCompletionsProvider);
    final weeklyDaysAsync = ref.watch(weeklyDaysProvider);
    final last30StatsAsync = ref.watch(last30StatsProvider);
  // final settings = ref.watch(settingsProvider); // not used
    return Scaffold(
      appBar: const EcoAppBar(title: 'Progress'),
      body: Stack(
        children: [
          Positioned.fill(child: IgnorePointer(child: StaticGridBubblesBackground())),
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(streakProvider);
                ref.invalidate(weeklyCompletionProvider);
                ref.invalidate(recentCompletionsProvider);
                ref.invalidate(weeklyDaysProvider);
                ref.invalidate(last30StatsProvider);
                ref.invalidate(impactMetricsProvider);
                await Future.delayed(const Duration(milliseconds: 350));
              },
              child: ListView(
                padding: EdgeInsets.only(bottom: GWDs.s8),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: GWDs.s4),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: GWDs.s7),
                    child: _WeeklyRingCard(weeklyAsync: weeklyAsync, streakAsync: streakAsync),
                  ),
                  const SizedBox(height: GWDs.s6),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: GWDs.s7),
                    child: _WeeklyDaysChips(daysAsync: weeklyDaysAsync),
                  ),
                  const SizedBox(height: GWDs.s6),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: GWDs.s7),
                    child: _CompletionHeatmap(recentAsync: recentAsync),
                  ),
                  const SizedBox(height: GWDs.s6),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: GWDs.s7),
                    child: _Last30StatsCard(statsAsync: last30StatsAsync),
                  ),
                  const SizedBox(height: GWDs.s6),
                  // Environmental Impact Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: GWDs.s7),
                    child: ImpactMetricsSection(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyRingCard extends StatelessWidget {
  final AsyncValue<double> weeklyAsync; final AsyncValue streakAsync;
  const _WeeklyRingCard({required this.weeklyAsync, required this.streakAsync});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GWCard(
      child: Row(children:[
        _AnimatedWeeklyRing(valueAsync: weeklyAsync),
        const SizedBox(width: 28),
        Expanded(child: streakAsync.when(
          data: (s) => Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text('This Week', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Weekly goal completion shows how consistent you are.', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 14),
            Wrap(spacing: 12, runSpacing: 12, children:[
              _MiniStat(icon: Icons.local_fire_department, label: 'Streak', value: s.currentStreak.toString(), color: Colors.orangeAccent),
              _MiniStat(icon: Icons.emoji_events_outlined, label: 'Best', value: s.longestStreak.toString(), color: cs.secondary),
            ])
          ]),
          loading: () => const SizedBox(height:84),
          error: (error, stackTrace) => Text('Streak error', style: TextStyle(color: cs.error)),
        )),
      ]),
    );
  }
}

class _AnimatedWeeklyRing extends StatefulWidget { final AsyncValue<double> valueAsync; const _AnimatedWeeklyRing({required this.valueAsync});
  @override State<_AnimatedWeeklyRing> createState() => _AnimatedWeeklyRingState(); }
class _AnimatedWeeklyRingState extends State<_AnimatedWeeklyRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: GWDs.animSlow)..forward();
  }
  double _target = 0; double _old=0;
  @override
  void didUpdateWidget(covariant _AnimatedWeeklyRing old){
    super.didUpdateWidget(old);
    widget.valueAsync.whenData((v){
      _old=_target; _target=v.clamp(0,1);
      if (mounted) { _c
        ..value=0
        ..forward(); }
    });
  }
  @override
  void dispose(){
    // Stop animations before dispose to avoid scheduler callbacks after unmount
    _c.stop();
    _c.dispose();
    super.dispose();
  }
  @override Widget build(BuildContext context){
    final cs=Theme.of(context).colorScheme;
    return SizedBox(width:92,height:92, child: widget.valueAsync.when(
      data: (v){ _target=v.clamp(0,1); return RepaintBoundary(
        child: AnimatedBuilder(animation:_c,builder:(context, child) {
          final t=Curves.easeOutCubic.transform(_c.value); final val=_old + (_target-_old)*t; 
          return CustomPaint(painter:_WeeklyRingPainter(val, cs));
        }),
      );},
      loading: ()=> Center(child: CircularProgressIndicator(strokeWidth:3,valueColor: AlwaysStoppedAnimation(cs.primary))),
      error: (e, stackTrace){return Center(child: Icon(Icons.error_outline,color: cs.error));},
    ));
  }
}

class _WeeklyRingPainter extends CustomPainter { final double v; final ColorScheme cs; _WeeklyRingPainter(this.v,this.cs);
  @override void paint(Canvas c, Size s){
    final bg=Paint()..color=cs.primary.withValues(alpha:.12)..style=PaintingStyle.stroke..strokeWidth=10..strokeCap=StrokeCap.round;
    final fg=Paint()
      ..shader=SweepGradient(colors:[cs.primary, cs.secondary, cs.primary], startAngle:-3.14/2, endAngle:3.14*1.5).createShader(Rect.fromCircle(center:s.center(Offset.zero), radius:s.width/2))
      ..style=PaintingStyle.stroke..strokeWidth=10..strokeCap=StrokeCap.round;
    c.drawArc(Rect.fromCircle(center:s.center(Offset.zero), radius:s.width/2), 0, 3.14*2, false, bg);
    c.drawArc(Rect.fromCircle(center:s.center(Offset.zero), radius:s.width/2), -3.14/2, 3.14*2*v, false, fg);
    final tp = TextPainter(text: TextSpan(text:'${(v*100).round()}%', style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: cs.onPrimaryContainer)), textDirection: TextDirection.ltr)..layout();
    tp.paint(c, s.center(Offset(-tp.width/2,-tp.height/2)));
  }
  @override bool shouldRepaint(covariant _WeeklyRingPainter old)=> old.v!=v; }

class _MiniStat extends StatelessWidget { final IconData icon; final String label; final String value; final Color color; const _MiniStat({required this.icon, required this.label, required this.value, required this.color});
  @override Widget build(BuildContext context){ final cs=Theme.of(context).colorScheme; return Container(
    padding: const EdgeInsets.symmetric(horizontal:14, vertical:10),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: cs.primary.withValues(alpha:.08)),
    child: Row(mainAxisSize: MainAxisSize.min, children:[
      Icon(icon,size:18,color:color),
      const SizedBox(width:6),
      Flexible(
        child: Text(
          '$value $label',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    ]),
  ); }
}

class _CompletionHeatmap extends StatelessWidget { final AsyncValue<Map<DateTime,bool>> recentAsync; const _CompletionHeatmap({required this.recentAsync});
  @override Widget build(BuildContext context){
    return recentAsync.when(
      data: (map){
        final ordered = map.keys.toList()..sort(); // oldest -> newest
        return GWCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text('Last 30 Days', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(runSpacing: 6, spacing: 6, children: ordered.map((d){
              final done = map[d] ?? false;
              return _DayCell(date:d, done:done);
            }).toList()),
            const SizedBox(height: 14),
            Row(children:[
              _LegendSwatch(label:'Done', color: Theme.of(context).colorScheme.primary),
              const SizedBox(width:12),
              _LegendSwatch(label:'Missed', color: Theme.of(context).colorScheme.primary.withValues(alpha:.18)),
            ])
          ]),
        );
      },
      loading: ()=> const GWCard(child: SizedBox(height:120, child: Center(child:CircularProgressIndicator()))),
      error: (e,_)=> GWCard(child: Text('Heatmap error: $e')),
    );
  }
}

class _DayCell extends StatelessWidget { final DateTime date; final bool done; const _DayCell({required this.date, required this.done});
  @override Widget build(BuildContext context){ final cs=Theme.of(context).colorScheme; final now=DateTime.now(); final isToday = date.year==now.year && date.month==now.month && date.day==now.day; return Tooltip(
    message: '${date.month}/${date.day}: ${done ? 'Completed' : 'Missed'}',
    child: AnimatedContainer(duration:GWDs.animFast, curve:Curves.easeOutCubic,
      width: 24, height:24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: done ? cs.primary : cs.primary.withValues(alpha:.15),
        border: isToday ? Border.all(color: cs.secondary, width: 2) : null,
        boxShadow: done ? [BoxShadow(color: cs.primary.withValues(alpha:.35), blurRadius: 10, offset: const Offset(0,4))] : null,
      ),
    ),
  ); }
}

class _LegendSwatch extends StatelessWidget { final String label; final Color color; const _LegendSwatch({required this.label, required this.color});
  @override Widget build(BuildContext context){ return Row(mainAxisSize: MainAxisSize.min, children:[
    Container(width:18,height:18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))), const SizedBox(width:6),
    Text(label, style: Theme.of(context).textTheme.labelSmall),
  ]); }
}

class _WeeklyDaysChips extends StatelessWidget {
  final AsyncValue<List<({DateTime date, bool done})>> daysAsync;
  const _WeeklyDaysChips({required this.daysAsync});
  
  String _getDayLabel(DateTime date) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[date.weekday - 1]; // weekday: 1=Mon, 7=Sun
  }
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return GWCard(
      child: daysAsync.when(
        data: (days) {
          if (days.isEmpty) return const SizedBox(height: 8);
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('This Week', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (final day in days)
                _WeekChip(
                  label: _getDayLabel(day.date),
                  done: day.done,
                  isToday: day.date.year == today.year && 
                           day.date.month == today.month && 
                           day.date.day == today.day,
                  cs: cs,
                ),
            ]),
          ]);
        },
        loading: () => const SizedBox(height: 64, child: Center(child: CircularProgressIndicator())),
        error: (e, _) => Text('Weekly days error: $e', style: TextStyle(color: cs.error)),
      ),
    );
  }
}

class _WeekChip extends StatelessWidget {
  final String label;
  final bool done;
  final bool isToday;
  final ColorScheme cs;
  
  const _WeekChip({
    required this.label,
    required this.done,
    required this.isToday,
    required this.cs,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: GWDs.animFast,
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: done ? cs.primary : cs.primary.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(16),
        border: isToday ? Border.all(color: cs.secondary, width: 2.5) : null,
        boxShadow: done 
            ? [BoxShadow(color: cs.primary.withValues(alpha:.3), blurRadius: 10, offset: const Offset(0,4))]
            : null,
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: done ? cs.onPrimary : cs.onSurface,
        fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
      )),
    );
  }
}

class _Last30StatsCard extends StatelessWidget {
  final AsyncValue<Last30Stats> statsAsync; const _Last30StatsCard({required this.statsAsync});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GWCard(
      child: statsAsync.when(
        data: (s) {
          final pct = (s.rate * 100).round();
          final range = (s.bestWeekStart != null && s.bestWeekEnd != null)
              ? '${s.bestWeekStart!.month}/${s.bestWeekStart!.day} – ${s.bestWeekEnd!.month}/${s.bestWeekEnd!.day}'
              : '—';
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('30‑Day Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: s.rate,
              minHeight: 10,
              backgroundColor: cs.primary.withValues(alpha:.12),
              valueColor: AlwaysStoppedAnimation(cs.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(builder: (ctx, constraints){
              final narrow = constraints.maxWidth < 260;
              if (narrow) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _MiniStat(icon: Icons.percent, label: 'Completion', value: pct.toString(), color: cs.primary),
                    _MiniStat(icon: Icons.check_circle_outline, label: 'Done', value: '${s.completed}/${s.total}', color: cs.secondary),
                  ],
                );
              }
              return Row(children:[
                Expanded(child: _MiniStat(icon: Icons.percent, label: 'Completion', value: pct.toString(), color: cs.primary)),
                const SizedBox(width: 12),
                Expanded(child: _MiniStat(icon: Icons.check_circle_outline, label: 'Done', value: '${s.completed}/${s.total}', color: cs.secondary)),
              ]);
            }),
            const SizedBox(height: 10),
            Text('Best week: $range (${s.bestWeekCount}/7)', style: Theme.of(context).textTheme.bodySmall),
          ]);
        },
        loading: () => const SizedBox(height: 96, child: Center(child: CircularProgressIndicator())),
        error: (e, _) => Text('Stats error: $e', style: TextStyle(color: cs.error)),
      ),
    );
  }
}

