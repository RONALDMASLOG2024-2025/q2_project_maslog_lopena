import 'package:flutter/material.dart';
import 'package:greenwise/data/models/eco_tip.dart';
import 'dart:math' as math;

class DailyTipCard extends StatelessWidget {
  final EcoTip tip;
  final VoidCallback? onExplain;

  const DailyTipCard({super.key, required this.tip, this.onExplain});

  Color _categoryColor(EcoTipCategory c, ThemeData theme) {
    switch (c) {
      case EcoTipCategory.energySaving:
        return theme.colorScheme.secondaryContainer;
      case EcoTipCategory.deviceCare:
        return theme.colorScheme.tertiaryContainer;
      case EcoTipCategory.disposal:
        return theme.colorScheme.errorContainer;
      case EcoTipCategory.ecoBuying:
        return theme.colorScheme.primaryContainer;
    }
  }

  String _label(EcoTipCategory c) => c.name
      .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
      .trim()
      .replaceFirst('Eco', 'Eco-');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = LinearGradient(
      colors: [
        theme.colorScheme.surfaceVariant.withOpacity(0.9),
        theme.colorScheme.primaryContainer.withOpacity(0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onExplain,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.eco_rounded, color: theme.colorScheme.primary, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Today's Eco-Tip",
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _CategoryPill(
                      label: _label(tip.category),
                      color: _categoryColor(tip.category, theme),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                tip.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.3,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: _ExplainButton(onPressed: onExplain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final Color color;
  const _CategoryPill({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _ExplainButton extends StatefulWidget {
  final VoidCallback? onPressed;
  const _ExplainButton({this.onPressed});
  @override
  State<_ExplainButton> createState() => _ExplainButtonState();
}

class _ExplainButtonState extends State<_ExplainButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.65),
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onPressed: widget.onPressed,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          final pulse = (math.sin(t * math.pi * 2) + 1) / 2; // 0..1
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary.withOpacity(0.7 + 0.3 * pulse)),
              const SizedBox(width: 8),
              const Text('Why this matters'),
            ],
          );
        },
      ),
    );
  }
}

/// Simple shimmer skeleton used while loading the tip.
class TipSkeleton extends StatefulWidget {
  const TipSkeleton({super.key});
  @override
  State<TipSkeleton> createState() => _TipSkeletonState();
}

class _TipSkeletonState extends State<TipSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final shimmerPosition = _controller.value;
          return Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [theme.colorScheme.surfaceVariant, theme.colorScheme.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment(-1 + 2 * shimmerPosition, 0),
                    widthFactor: 0.4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
                const Center(child: CircularProgressIndicator(strokeWidth: 2.6)),
              ],
            ),
          );
        },
      ),
    );
  }
}

