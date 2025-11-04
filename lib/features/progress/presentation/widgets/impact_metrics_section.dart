import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/eco_tip.dart';
import '../../domain/impact_provider.dart';
import 'impact_card.dart';

/// Environmental Impact Metrics Section
class ImpactMetricsSection extends ConsumerWidget {
  const ImpactMetricsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final impactAsync = ref.watch(impactMetricsProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return impactAsync.when(
      data: (impact) {
        if (impact.tipsCompleted == 0) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                '🌍 Environmental Impact',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ),
            // Impact Cards Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: ImpactCard(
                        icon: Icons.delete_outline,
                        title: 'E-Waste Prevented',
                        value: impact.eWastePrevented.toStringAsFixed(1),
                        unit: 'kg',
                        color: cs.primary,
                        subtitle: 'Over device lifetime',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: ImpactCard(
                        icon: Icons.flash_on,
                        title: 'Energy Saved',
                        value: impact.energySaved.toStringAsFixed(1),
                        unit: 'kWh',
                        color: Colors.amber.shade700,
                        subtitle: 'Approx. savings',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: ImpactCard(
                        icon: Icons.co2,
                        title: 'CO₂ Reduced',
                        value: impact.co2Reduced.toStringAsFixed(1),
                        unit: 'kg',
                        color: Colors.green.shade600,
                        subtitle: 'Carbon footprint',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: ImpactCard(
                        icon: Icons.category,
                        title: 'Top Category',
                        value: _topCategory(impact.categoryBreakdown),
                        unit: '',
                        color: cs.secondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stack) => const SizedBox.shrink(),
    );
  }

  String _topCategory(Map<EcoTipCategory, int> breakdown) {
    if (breakdown.isEmpty) return 'None';
    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first.key;
    return top.name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (m) => ' ${m.group(0)}',
    ).trim();
  }
}
