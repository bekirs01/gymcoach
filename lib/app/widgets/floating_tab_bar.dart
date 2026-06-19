import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/premium_tokens.dart';

class FloatingTabItem {
  const FloatingTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class FloatingTabBar extends StatelessWidget {
  const FloatingTabBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.items,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<FloatingTabItem> items;

  static const double barHeight = 54;

  static double reservedBottomSpace(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return barHeight + bottomInset + AppSpacing.sm + AppSpacing.md;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.sm, bottomInset + AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PremiumRadii.xxl),
          boxShadow: [
            BoxShadow(
              color: PremiumColors.accentBlue.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(PremiumRadii.xxl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: PremiumColors.dockFill,
                borderRadius: BorderRadius.circular(PremiumRadii.xxl),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: SizedBox(
                height: barHeight,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final tabWidth = constraints.maxWidth / items.length;

                      return Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            left: selectedIndex * tabWidth,
                            top: 0,
                            bottom: 0,
                            width: tabWidth,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: PremiumColors.surfaceRaised.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(PremiumRadii.lg),
                                border: Border.all(
                                  color: PremiumColors.accentBlue.withValues(alpha: 0.45),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: PremiumColors.accentBlue.withValues(alpha: 0.28),
                                    blurRadius: 14,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Row(
                          children: List.generate(items.length, (index) {
                            return Expanded(
                              child: _TabSlot(
                                item: items[index],
                                selected: index == selectedIndex,
                                onTap: () {
                                  if (index == selectedIndex) return;
                                  HapticFeedback.selectionClick();
                                  onSelected(index);
                                },
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}

class _TabSlot extends StatelessWidget {
  const _TabSlot({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final FloatingTabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        splashColor: PremiumColors.accentBlue.withValues(alpha: 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              size: 20,
              color: selected ? PremiumColors.accentBlue : PremiumColors.textMuted,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? PremiumColors.textPrimary : PremiumColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
