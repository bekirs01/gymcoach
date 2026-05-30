import 'package:flutter/material.dart';

import '../theme/premium_tokens.dart';

class PremiumStatCard extends StatelessWidget {
  const PremiumStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: PremiumColors.textMuted),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: PremiumColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: PremiumColors.textMuted,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
