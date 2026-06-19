import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';

class ExerciseMetricStepperCard extends StatelessWidget {
  const ExerciseMetricStepperCard({
    super.key,
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    this.valueColor = PremiumColors.accentBlue,
    this.suffix,
    this.onInfoTap,
  });

  final String label;
  final String value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final Color valueColor;
  final String? suffix;
  final VoidCallback? onInfoTap;

  @override
  Widget build(BuildContext context) {
    final displayValue = suffix != null ? '$value $suffix' : value;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: PremiumColors.surface,
          borderRadius: BorderRadius.circular(PremiumRadii.md),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: PremiumColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (onInfoTap != null) ...[
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTap: onInfoTap,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 12,
                        color: PremiumColors.textMuted.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepButton(icon: Icons.remove_rounded, onTap: onDecrement),
                const SizedBox(width: 4),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      displayValue,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: valueColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: suffix != null ? -0.2 : 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _StepButton(icon: Icons.add_rounded, onTap: onIncrement),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PremiumColors.surfaceRaised,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 26,
          height: 26,
          child: Icon(icon, color: PremiumColors.textSecondary, size: 15),
        ),
      ),
    );
  }
}
