import 'package:flutter/material.dart';

import '../theme/premium_tokens.dart';

class PremiumPrimaryButton extends StatelessWidget {
  const PremiumPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = true,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final vPad = compact ? 10.0 : 12.0;
    final button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: PremiumColors.accentBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: vPad, horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PremiumRadii.md),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: compact ? 13 : 14,
        ),
      ),
    );

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

class PremiumOutlineButton extends StatelessWidget {
  const PremiumOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: PremiumColors.textSecondary,
        side: const BorderSide(color: PremiumColors.glassBorder),
        padding: EdgeInsets.symmetric(vertical: compact ? 10 : 12, horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PremiumRadii.md),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: compact ? 13 : 14,
        ),
      ),
    );
  }
}
