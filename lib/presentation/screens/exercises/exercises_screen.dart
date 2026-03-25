import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/exercise.dart';

/// Egzersiz kategorileri ve listesi
class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  static const List<({ExerciseCategory category, String label, IconData icon})>
  categories = [
    (
      category: ExerciseCategory.arm,
      label: 'Руки',
      icon: Icons.sports_martial_arts,
    ),
    (category: ExerciseCategory.leg, label: 'Ноги', icon: Icons.directions_run),
    (
      category: ExerciseCategory.chest,
      label: 'Грудь',
      icon: Icons.fitness_center,
    ),
    (
      category: ExerciseCategory.back,
      label: 'Спина',
      icon: Icons.accessibility_new,
    ),
    (
      category: ExerciseCategory.shoulder,
      label: 'Плечи',
      icon: Icons.sports_gymnastics,
    ),
    (
      category: ExerciseCategory.abs,
      label: 'Пресс',
      icon: Icons.self_improvement,
    ),
    (
      category: ExerciseCategory.fullBody,
      label: 'Всё тело',
      icon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Упражнения')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: AppColors.primary.withOpacity(0.12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: AppColors.primary.withOpacity(0.35)),
            ),
            child: ListTile(
              leading: Icon(
                Icons.photo_camera_rounded,
                color: AppColors.primary,
              ),
              title: const Text(
                'Камера: жим гантелей над плечами',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Два гантеля вместе — счёт повторов для лиги. Также: главная → Лига.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/league/camera-setup'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Просмотрите категории',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...categories.map(
            (c) => _CategorySection(
              category: c.category,
              label: c.label,
              icon: c.icon,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends ConsumerWidget {
  const _CategorySection({
    required this.category,
    required this.label,
    required this.icon,
  });

  final ExerciseCategory category;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref
          .read(exerciseRepositoryProvider)
          .getExercisesByCategory(category),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final exercises = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...exercises.map(
              (ex) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ExerciseCard(exercise: ex),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/exercise/${exercise.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.fitness_center, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercise.targetMuscle} • ${exercise.difficultyDisplayName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      exercise.durationOrRepsText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
