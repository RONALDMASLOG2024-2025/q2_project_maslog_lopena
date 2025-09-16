import 'package:flutter/material.dart';

/// Clean, modern app bar with left-aligned title and brand mark.
class EcoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double height;
  const EcoAppBar({super.key, required this.title, this.actions, this.leading, this.height = kToolbarHeight});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.surface,
      elevation: 0,
      child: Container(
        height: preferredSize.height,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6), width: 0.6)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            if (leading != null)
              leading!
            else
        Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Image.asset(
                  'assets/images/appbar_logo.png',
          width: 40,
          height: 40,
          errorBuilder: (_, __, ___) => const Icon(Icons.eco_outlined, size: 32),
                ),
              ),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
            if (actions != null) ...actions! else const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
