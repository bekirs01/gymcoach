import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../domain/shared_workout_snapshot.dart';
import 'shared_workout_preview_card.dart';

class WorkoutSharePostCard extends StatelessWidget {
  const WorkoutSharePostCard({
    super.key,
    required this.snapshot,
    required this.onCopy,
    this.copying = false,
    this.alreadyCopied = false,
  });

  final SharedWorkoutSnapshot snapshot;
  final VoidCallback? onCopy;
  final bool copying;
  final bool alreadyCopied;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SharedWorkoutPreviewCard(snapshot: snapshot, compact: true),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: copying || alreadyCopied ? null : onCopy,
          style: FilledButton.styleFrom(
            backgroundColor: PremiumColors.accentBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: PremiumColors.surfaceRaised,
            disabledForegroundColor: PremiumColors.textMuted,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PremiumRadii.pill),
            ),
          ),
          child: copying
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  alreadyCopied ? 'Already in your workouts' : 'Copy workout',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
        ),
      ],
    );
  }
}
