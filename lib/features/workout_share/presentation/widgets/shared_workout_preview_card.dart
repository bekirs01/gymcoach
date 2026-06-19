import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../domain/shared_workout_snapshot.dart';

class SharedWorkoutPreviewCard extends StatelessWidget {
  const SharedWorkoutPreviewCard({
    super.key,
    required this.snapshot,
    this.compact = false,
  });

  final SharedWorkoutSnapshot snapshot;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final previewExercises = snapshot.exercises.take(compact ? 2 : 3).toList();

    return Container(
      decoration: BoxDecoration(
        color: PremiumColors.midnightBottom,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: compact ? 120 : 148,
            child: _WorkoutShareImage(imageUrl: snapshot.imageUrl),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _MetaChip(
                      icon: Icons.fitness_center_rounded,
                      label: '${snapshot.exerciseCount} exercises',
                    ),
                    if (snapshot.estimatedDuration > 0)
                      _MetaChip(
                        icon: Icons.timer_outlined,
                        label: '${snapshot.estimatedDuration} min',
                      ),
                    if (snapshot.scheduledTime.isNotEmpty)
                      _MetaChip(
                        icon: Icons.schedule_rounded,
                        label: snapshot.scheduledTime,
                      ),
                  ],
                ),
                if (previewExercises.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  for (final exercise in previewExercises) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: PremiumColors.accentBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              exercise.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: PremiumColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutShareImage extends StatelessWidget {
  const _WorkoutShareImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _WorkoutShareImageFallback(),
      );
    }
    if (imageUrl.trim().isEmpty) {
      return const _WorkoutShareImageFallback();
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _WorkoutShareImageFallback(),
    );
  }
}

class _WorkoutShareImageFallback extends StatelessWidget {
  const _WorkoutShareImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PremiumColors.accentBlue.withValues(alpha: 0.16),
      child: const Center(
        child: Icon(
          Icons.fitness_center_rounded,
          color: PremiumColors.accentBlue,
          size: 42,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: PremiumColors.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: PremiumColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
