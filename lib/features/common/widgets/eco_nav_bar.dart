import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Eco themed translucent navigation bar with animated expanding labels.
class EcoNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<EcoNavItem> items;
  const EcoNavBar({super.key, required this.currentIndex, required this.onTap, required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: .78),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: cs.primary.withValues(alpha: .08)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    _EcoNavItem(
                      item: items[i],
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EcoNavItem {
  final IconData icon;
  final String label;
  const EcoNavItem({required this.icon, required this.label});
}

class _EcoNavItem extends StatelessWidget {
  final EcoNavItem item;
  final bool selected;
  final VoidCallback onTap;
  const _EcoNavItem({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final active = selected;
    final hasLabel = item.label.trim().isNotEmpty; // allow optional labels
    return Expanded(
      child: Semantics(
        selected: active,
        button: true,
        label: item.label,
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          splashColor: cs.primary.withValues(alpha: .12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            // If there is no label keep the pill compact
            padding: EdgeInsets.symmetric(horizontal: active ? (hasLabel ? 18 : 14) : 0, vertical: 8),
            decoration: active
                ? BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary.withValues(alpha: .90), cs.primary.withValues(alpha: .72)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: cs.primary.withValues(alpha: .30), blurRadius: 14, offset: const Offset(0, 6)),
                    ],
                  )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: 24, color: active ? cs.onPrimary : cs.primary.withValues(alpha: .70)),
                if (hasLabel)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.centerLeft,
                    child: active
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 70),
                              child: Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: cs.onPrimary,
                                    ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
