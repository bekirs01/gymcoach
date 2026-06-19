import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../../../core/workout_exercise_catalog.dart';

class WorkoutExerciseListItem extends StatelessWidget {
  const WorkoutExerciseListItem({
    super.key,
    required this.orderNumber,
    required this.title,
    required this.done,
    required this.active,
    required this.onTap,
    this.exerciseName,
  });

  final int orderNumber;
  final String title;
  final bool done;
  final bool active;
  final VoidCallback onTap;
  final String? exerciseName;

  @override
  Widget build(BuildContext context) {
    final imageAsset = WorkoutExerciseCatalog.imageForName(exerciseName ?? title);

    return Material(
      color: active ? PremiumColors.surfaceRaised : PremiumColors.surface,
      borderRadius: BorderRadius.circular(PremiumRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PremiumRadii.md),
            border: Border.all(
              color: active
                  ? PremiumColors.accentBlue.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.1),
              width: active ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: imageAsset == null
                      ? Container(
                          color: PremiumColors.accentBlue.withValues(alpha: 0.16),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: PremiumColors.accentBlue,
                            size: 18,
                          ),
                        )
                      : Image.asset(
                          imageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: PremiumColors.accentBlue.withValues(alpha: 0.16),
                            child: const Icon(
                              Icons.fitness_center_rounded,
                              color: PremiumColors.accentBlue,
                              size: 18,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active
                      ? PremiumColors.accentBlue
                      : PremiumColors.surfaceRaised,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active
                        ? PremiumColors.accentBlue
                        : Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  '$orderNumber',
                  style: TextStyle(
                    color: active ? Colors.white : PremiumColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: done ? PremiumColors.successGreen : PremiumColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
