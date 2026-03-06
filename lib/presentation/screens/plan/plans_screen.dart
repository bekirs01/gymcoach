import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/providers.dart';
import '../../../domain/models/workout_plan.dart';

/// Antrenman planları listesi
class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(_plansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Мой план')),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (plans) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_plansProvider),
            child: plans.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: plans.length + 1,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/plan/create'),
                            icon: const Icon(Icons.add),
                            label: const Text('Создать новый план'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        );
                      }
                      final plan = plans[i - 1];
                      return _PlanCard(plan: plan);
                    },
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/plan/create'),
        icon: const Icon(Icons.add),
        label: const Text('Новый план'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          Icon(Icons.calendar_month, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          Text(
            'Вы ещё не создали план',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Начните создавать свой план тренировок.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push('/plan/create'),
            icon: const Icon(Icons.add),
            label: const Text('Yeni Plan Oluştur'),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});

  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context) {
    final days = plan.weekdays
        .map((w) => _weekdayShort(w))
        .join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/plan/${plan.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Дни: $days',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                '${plan.exercises.length} упр.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _weekdayShort(Weekday w) {
    const map = {
      Weekday.monday: 'Пн',
      Weekday.tuesday: 'Вт',
      Weekday.wednesday: 'Ср',
      Weekday.thursday: 'Чт',
      Weekday.friday: 'Пт',
      Weekday.saturday: 'Сб',
      Weekday.sunday: 'Вс',
    };
    return map[w] ?? '';
  }
}

final _plansProvider = FutureProvider<List<WorkoutPlan>>((ref) async {
  final repo = ref.watch(workoutPlanRepositoryProvider);
  return repo.getPlans();
});
