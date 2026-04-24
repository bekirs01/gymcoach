import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/mock/mock_meals.dart';
import '../../../domain/models/meal.dart';
import '../../../domain/models/user_profile.dart';

/// Beslenme sayfası - hedefe göre öneriler
class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Питание')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text(AppConstants.loadDataError)),
        data: (profile) {
          final goalKey = _goalToKey(profile?.goal ?? FitnessGoal.stayFit);
          final meals = getMockMealsForGoal(goalKey);
          final toAvoid = mockFoodsToAvoid[goalKey] ?? [];
          final recommended = mockRecommendedFoods[goalKey] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMacroSummary(context),
                const SizedBox(height: 20),
                _buildSectionTitle(context, 'Примеры приёмов пищи'),
                ...meals.map((m) => _MealCard(meal: m)),
                const SizedBox(height: 20),
                _buildSectionTitle(context, 'Рекомендуемые продукты'),
                _buildChipList(context, recommended, AppColors.success),
                const SizedBox(height: 20),
                _buildSectionTitle(context, 'Чего избегать'),
                _buildChipList(context, toAvoid, AppColors.error),
              ],
            ),
          );
        },
      ),
    );
  }

  String _goalToKey(FitnessGoal? goal) {
    if (goal == null) return 'stayFit';
    switch (goal) {
      case FitnessGoal.loseWeight:
        return 'loseWeight';
      case FitnessGoal.gainMuscle:
        return 'gainMuscle';
      case FitnessGoal.stayFit:
        return 'stayFit';
    }
  }

  Widget _buildMacroSummary(BuildContext context) {
    return Card(
      color: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Дневная сводка макросов',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _macroBox(context, 'Калории', '2000', 'ккал'),
                const SizedBox(width: 12),
                _macroBox(context, 'Белок', '120', 'г'),
                const SizedBox(width: 12),
                _macroBox(context, 'Углеводы', '250', 'г'),
                const SizedBox(width: 12),
                _macroBox(context, 'Жиры', '65', 'г'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroBox(BuildContext context, String label, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '$label ($unit)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildChipList(BuildContext context, List<String> items, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((s) => Chip(
            label: Text(s),
            backgroundColor: color.withOpacity(0.2),
          )).toList(),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    meal.typeDisplayName,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Spacer(),
                if (meal.calories != null)
                  Text(
                    '${meal.calories} kcal',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              meal.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              meal.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (meal.protein != null) ...[
              const SizedBox(height: 8),
              Text(
                'Б: ${meal.protein}г | У: ${meal.carbs}г | Ж: ${meal.fat}г',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
