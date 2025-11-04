import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/design_system.dart';
import '../../../data/models/recycling_resource.dart';
import '../../common/widgets/eco_app_bar.dart';
// import removed: background visuals now static
import '../../common/widgets/static_grid_bubbles_background.dart';
import '../domain/recycling_provider.dart';

enum _DirSection { local, national, international }

class RecyclingDirectoryScreen extends ConsumerStatefulWidget {
  const RecyclingDirectoryScreen({super.key});

  @override
  ConsumerState<RecyclingDirectoryScreen> createState() => _RecyclingDirectoryScreenState();
}

class _RecyclingDirectoryScreenState extends ConsumerState<RecyclingDirectoryScreen> {
  _DirSection? _selected = _DirSection.local;

  @override
  Widget build(BuildContext context) {
    final dirAsync = ref.watch(recyclingDirectoryProvider);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const EcoAppBar(title: 'Recycle & Trade‑in'),
      body: dirAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load: $e')),
        data: (dir) {
          final counts = {
            _DirSection.local: dir.local.length,
            _DirSection.national: dir.national.length,
            _DirSection.international: dir.international.length,
          };
          return Stack(
            children: [
              Positioned.fill(child: IgnorePointer(child: StaticGridBubblesBackground())),
              Positioned.fill(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(GWDs.s7, GWDs.s4, GWDs.s7, GWDs.s7),
                  children: [
                    _HeroIntro(cs: cs),
                    const SizedBox(height: 16),
                    _CategoryGrid(
                      selected: _selected,
                      counts: counts,
                      onTap: (s) => setState(() => _selected = s),
                    ),
                    const SizedBox(height: 18),
                    _ExpandableResources(
                      section: _selected,
                      dir: dir,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroIntro extends StatelessWidget {
  final ColorScheme cs; const _HeroIntro({required this.cs});
  @override
  Widget build(BuildContext context) {
    return GWCard(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          cs.primaryContainer.withValues(alpha: .35),
          cs.surfaceContainerHighest.withValues(alpha: .9),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Stack(children: [
        // Decorative blobs
        Positioned(
          right: -18, top: -18,
          child: Container(width: 80, height: 80, decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.secondary.withValues(alpha: .12),
            boxShadow: [BoxShadow(color: cs.secondary.withValues(alpha:.12), blurRadius: 30, spreadRadius: 10)],
          )),
        ),
        Positioned(
          left: -10, bottom: -10,
          child: Container(width: 60, height: 60, decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.primary.withValues(alpha: .10),
          )),
        ),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: cs.primary.withValues(alpha:.28), blurRadius: 18, offset: const Offset(0,8))],
            ),
            child: Icon(Icons.recycling, color: cs.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Recycle & Trade‑in', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Find responsible options near you and worldwide. Tap a tile to explore.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ])),
        ]),
      ]),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final _DirSection? selected;
  final Map<_DirSection, int> counts;
  final void Function(_DirSection) onTap;
  const _CategoryGrid({required this.selected, required this.counts, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tiles = [
      (_DirSection.local, 'Local', Icons.place_rounded, [cs.primary, cs.secondary]),
      (_DirSection.national, 'Philippines', Icons.public_rounded, [cs.tertiary, cs.primary]),
      (_DirSection.international, 'International', Icons.language_rounded, [cs.secondary, cs.tertiary]),
    ];
    return LayoutBuilder(builder: (ctx, constraints) {
      final maxW = constraints.maxWidth;
      final cols = maxW < 360 ? 2 : 3;
      return GridView.count(
        crossAxisCount: cols,
        childAspectRatio: 0.9,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final t in tiles)
            _CategoryTile(
              label: t.$2,
              icon: t.$3,
              colors: t.$4,
              count: counts[t.$1] ?? 0,
              selected: selected == t.$1,
              onTap: () => onTap(t.$1),
            ),
        ],
      );
    });
  }
}

class _CategoryTile extends StatelessWidget {
  final String label; final IconData icon; final List<Color> colors; final int count; final bool selected; final VoidCallback onTap;
  const _CategoryTile({required this.label, required this.icon, required this.colors, required this.count, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: GWDs.animFast,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(colors: [
            colors.first.withValues(alpha: .18),
            colors.last.withValues(alpha: .10),
          ], begin: Alignment.topLeft, end: Alignment.bottomRight),
          border: Border.all(color: (selected ? cs.primary : cs.primary.withValues(alpha: .12))),
          boxShadow: selected ? [BoxShadow(color: cs.primary.withValues(alpha: .15), blurRadius: 16, offset: const Offset(0,8))] : null,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
          Stack(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: cs.surfaceContainerHigh, shape: BoxShape.circle),
            ),
            Positioned.fill(child: Center(child: Icon(icon, color: cs.primary))),
          ]),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('$count', style: Theme.of(context).textTheme.labelSmall),
          )
        ]),
      ),
    );
  }
}

class _ExpandableResources extends StatelessWidget {
  final _DirSection? section; final dynamic dir; const _ExpandableResources({required this.section, required this.dir});
  List<RecyclingResource> _items() {
    switch (section) {
      case _DirSection.local:
        return dir.local as List<RecyclingResource>;
      case _DirSection.national:
        return dir.national as List<RecyclingResource>;
      case _DirSection.international:
        return dir.international as List<RecyclingResource>;
      default:
        return const [];
    }
  }
  @override
  Widget build(BuildContext context) {
    final items = _items();
    return AnimatedSwitcher(
      duration: GWDs.animSlow,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Container(
        key: ValueKey(section),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section == _DirSection.local ? 'Local' : section == _DirSection.national ? 'Philippines' : 'International',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final r in items)
              _ResourceCard(name: r.name, desc: r.description, url: r.link),
          ],
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final String name; final String desc; final String url;
  const _ResourceCard({required this.name, required this.desc, required this.url});

  Future<void> _open() async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Fallback to in-app webview if external fails
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _open,
        child: GWCard(
          gradient: LinearGradient(colors: [
            cs.surfaceContainerHighest,
            cs.surfaceContainerHigh,
          ], begin: Alignment.topLeft, end: Alignment.bottomRight),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: cs.primary.withValues(alpha:.12), shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.approval_rounded)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(desc, style: Theme.of(context).textTheme.bodyMedium),
              ]),
            ),
            const SizedBox(width: 12),
            Icon(Icons.open_in_new_rounded, color: cs.primary),
          ]),
        ),
      ),
    );
  }
}
