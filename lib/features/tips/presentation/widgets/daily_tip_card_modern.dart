import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/design/design_system.dart';
import '../../../../data/models/eco_tip.dart';

/// Large, theme-adaptive quote-style card for the daily eco tip.
class DailyTipCardModern extends StatefulWidget {
  final EcoTip tip;
  final bool reduceMotion;
  const DailyTipCardModern({super.key, required this.tip, this.reduceMotion = false});

  @override
  State<DailyTipCardModern> createState() => _DailyTipCardModernState();
}

class _DailyTipCardModernState extends State<DailyTipCardModern>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: GWDs.animSlow);

  @override
  void initState() {
    super.initState();
    if (widget.reduceMotion) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.stop();
    _c.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DailyTipCardModern oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tip.id != widget.tip.id) {
      if (widget.reduceMotion) {
        _c.value = 1;
      } else {
        _c
          ..value = 0
          ..forward();
      }
    }
  }

  Color _categoryColor(EcoTipCategory c, ColorScheme cs) {
    switch (c) {
      case EcoTipCategory.energySaving:
        return cs.secondaryContainer;
      case EcoTipCategory.deviceCare:
        return cs.tertiaryContainer;
      case EcoTipCategory.disposal:
        return cs.errorContainer;
      case EcoTipCategory.ecoBuying:
        return cs.primaryContainer;
    }
  }

  String _label(EcoTipCategory c) =>
      c.name.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}').trim();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final category = _label(widget.tip.category);
    final badgeColor = _categoryColor(widget.tip.category, cs);
    final source = widget.tip.source;
    
    // Build accessibility label
    final sourceLabel = (source != null && source != 'AI-Generated')
        ? ' Verified source: $source.'
        : '';
    final accessibilityLabel = '${widget.tip.text}. Category: $category.$sourceLabel';

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_c.value);
        final slide = (1 - t) * 18;
        return Semantics(
          label: accessibilityLabel,
          readOnly: true,
          child: Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, slide),
              child: RepaintBoundary(
                child: _QuoteStyleCard(
                  text: widget.tip.text,
                  categoryLabel: category,
                  badgeColor: badgeColor,
                  source: source,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuoteStyleCard extends StatelessWidget {
  final String text;
  final String categoryLabel;
  final Color badgeColor;
  final String? source;
  const _QuoteStyleCard({
    required this.text,
    required this.categoryLabel,
    required this.badgeColor,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Stacked soft shadows
        Positioned(
          bottom: 12,
          left: 18,
          right: 18,
          child: Container(
            height: 16,
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          left: 12,
          right: 12,
          child: Container(
            height: 14,
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.50),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
        // Main content card
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 260),
          child: GWCard(
            padding: const EdgeInsets.fromLTRB(28, 44, 28, 30),
            gradient: LinearGradient(
              colors: [
                cs.surfaceContainerHighest.withValues(alpha: 0.98),
                cs.surfaceContainerHigh.withValues(alpha: 0.96),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: const Offset(0, -36),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.eco_rounded,
                      color: cs.onPrimary,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(
                    categoryLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: .2,
                    ),
                  ),
                ),
                // Source attribution badge
                if (source != null && source != 'AI-Generated') ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: cs.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          source!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Share button
                const SizedBox(height: 16),
                Semantics(
                  button: true,
                  label: 'Share this eco tip',
                  child: InkWell(
                    onTap: () {
                      final sourceText = source != null && source != 'AI-Generated'
                          ? '\n\n📚 Source: $source'
                          : '';
                      Share.share(
                        '🌱 $text$sourceText\n\nJoin me on GreenWise - Daily eco-tips for sustainable electronics!',
                        subject: 'GreenWise Eco Tip',
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: cs.secondary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.share_rounded,
                            size: 18,
                            color: cs.onSecondaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Share this tip',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
