import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../../../app/widgets/workout_image.dart';

class ExerciseHeroCard extends StatelessWidget {
  const ExerciseHeroCard({
    super.key,
    required this.exerciseName,
    required this.label,
    this.muscleGroup,
    this.onExpand,
  });

  final String exerciseName;
  final String label;
  final String? muscleGroup;
  final VoidCallback? onExpand;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: PremiumColors.accentBlue.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: const Color(0xFFF3F5F8),
              child: WorkoutImage(
                exerciseNames: [exerciseName],
                muscleGroup: muscleGroup,
                workoutName: label,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            if (onExpand != null)
              Positioned(
                right: 10,
                bottom: 10,
                child: Material(
                  color: PremiumColors.surfaceRaised.withValues(alpha: 0.92),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onExpand,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.open_in_full_rounded,
                        color: PremiumColors.accentBlue,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
