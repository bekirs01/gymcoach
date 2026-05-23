import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class CameraStatsRail extends StatelessWidget {
  const CameraStatsRail({
    super.key,
    required this.primaryLabel,
    required this.primaryValue,
    this.secondaryLabel,
    this.secondaryValue,
    this.highlight = false,
  });

  final String primaryLabel;
  final String primaryValue;
  final String? secondaryLabel;
  final String? secondaryValue;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 88,
      margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? AppColors.accent : Colors.white24,
          width: highlight ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            primaryLabel,
            style: theme.labelSmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            primaryValue,
            style: theme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          if (secondaryLabel != null && secondaryValue != null) ...[
            const SizedBox(height: 12),
            Container(height: 1, color: Colors.white12),
            const SizedBox(height: 10),
            Text(
              secondaryLabel!,
              style: theme.labelSmall?.copyWith(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              secondaryValue!,
              style: theme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
