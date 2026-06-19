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
    this.subtitle,
    this.showSteppers = true,
  });

  final String label;
  final String value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final Color valueColor;
  final String? suffix;
  final String? subtitle;
  final bool showSteppers;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: PremiumColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                if (showSteppers) ...[
                  const SizedBox(width: 3),
                  Icon(
                    Icons.info_outline_rounded,
                    size: 11,
                    color: PremiumColors.textMuted.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if (showSteppers)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepButton(icon: Icons.remove_rounded, onTap: onDecrement),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      suffix != null ? '$value $suffix' : value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: valueColor,
                        fontSize: suffix != null ? 16 : 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _StepButton(icon: Icons.add_rounded, onTap: onIncrement),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    suffix != null ? '$value $suffix' : value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: PremiumColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
          width: 28,
          height: 28,
          child: Icon(icon, color: PremiumColors.textSecondary, size: 16),
        ),
      ),
    );
  }
}
