import 'package:flutter/material.dart';

import '../theme/premium_tokens.dart';

class PremiumSectionTitle extends StatelessWidget {
  const PremiumSectionTitle(
    this.title, {
    super.key,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: PremiumColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.15,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              color: PremiumColors.textMuted,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}
