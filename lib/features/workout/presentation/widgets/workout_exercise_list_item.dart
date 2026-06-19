import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../../../app/widgets/workout_image.dart';

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
    final resolvedName = exerciseName ?? title;

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
                  child: WorkoutImage(
                    exerciseNames: [resolvedName],
                    workoutName: resolvedName,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done
                      ? PremiumColors.successGreen.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done
                        ? PremiumColors.successGreen.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: done
                    ? const Icon(Icons.check_rounded, color: PremiumColors.successGreen, size: 14)
                    : Text(
                        '$orderNumber',
                        style: TextStyle(
                          color: active ? PremiumColors.accentBlue : PremiumColors.textSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: done ? PremiumColors.textSecondary : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Icon(
                active ? Icons.play_arrow_rounded : Icons.chevron_right_rounded,
                color: active ? PremiumColors.accentBlue : PremiumColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
