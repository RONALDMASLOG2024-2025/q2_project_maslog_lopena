import 'package:flutter/material.dart';
import '../../../../core/design/design_system.dart';

/// Card displaying a single environmental impact metric
class ImpactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final Color color;
  final String? subtitle;

  const ImpactCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Semantics(
      label: '$title: $value $unit${subtitle != null ? '. $subtitle' : ''}',
      readOnly: true,
      child: GWCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with background
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            // Value with unit
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
