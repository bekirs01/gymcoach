import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';

class ExerciseInfoChip extends StatelessWidget {
  const ExerciseInfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onInfoTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onInfoTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: PremiumColors.surface,
          borderRadius: BorderRadius.circular(PremiumRadii.md),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: PremiumColors.accentBlue, size: 15),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: PremiumColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (onInfoTap != null) ...[
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTap: onInfoTap,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 11,
                        color: PremiumColors.textMuted.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
