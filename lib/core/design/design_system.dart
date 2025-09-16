import 'package:flutter/material.dart';

/// Central design tokens & helpers to keep consistent spacing, radii, durations.
class GWDs {
  // Spacing scale (4-based) for vertical rhythm
  static const s1 = 4.0; // tiny
  static const s2 = 8.0; // xsmall
  static const s3 = 12.0; // small
  static const s4 = 16.0; // base
  static const s5 = 20.0; // medium
  static const s6 = 24.0; // large
  static const s7 = 32.0; // xlarge
  static const s8 = 40.0; // xxlarge

  static const cornerL = 28.0;
  static const cornerM = 20.0;
  static const cornerS = 12.0;

  static const animFast = Duration(milliseconds: 180);
  static const anim = Duration(milliseconds: 320);
  static const animSlow = Duration(milliseconds: 600);

  static const elevationGlow = [
    BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8)),
  ];

  static BorderRadius radiusL = BorderRadius.circular(cornerL);
  static BorderRadius radiusM = BorderRadius.circular(cornerM);
  static BorderRadius radiusS = BorderRadius.circular(cornerS);

  static EdgeInsets pagePad = const EdgeInsets.symmetric(horizontal: s7, vertical: s5);
}

/// A lightly frosted surface container used for key content blocks.
class GWCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final BorderRadius? radius;
  const GWCard({super.key, required this.child, this.padding, this.color, this.gradient, this.onTap, this.radius});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radiusValue = radius ?? GWDs.radiusL;
    final inner = Container(
      decoration: BoxDecoration(
        borderRadius: radiusValue,
        gradient: gradient ?? LinearGradient(
          colors: [
            cs.surfaceContainerHighest.withValues(alpha: 0.92),
            cs.primaryContainer.withValues(alpha: 0.60),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: cs.primary.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: cs.primary.withValues(alpha: 0.08)),
      ),
      padding: padding ?? const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: child,
    );
    return onTap == null
        ? inner
        : InkWell(
            borderRadius: radiusValue,
            onTap: onTap,
            child: inner,
          );
  }
}
