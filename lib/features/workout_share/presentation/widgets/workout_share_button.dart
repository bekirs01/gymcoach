import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';

class WorkoutShareButton extends StatelessWidget {
  const WorkoutShareButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      icon: const Icon(Icons.ios_share_rounded),
      color: PremiumColors.textSecondary,
      iconSize: 20,
    );
  }
}
