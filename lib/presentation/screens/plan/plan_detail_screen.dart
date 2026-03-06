import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/providers.dart';
import '../../../domain/models/workout_plan.dart';

/// Plan detay ekranı
class PlanDetailScreen extends ConsumerWidget {
  const PlanDetailScreen({super.key, required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(workoutPlanRepositoryProvider).getPlanById(planId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Детали плана')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final plan = snapshot.data;
        if (plan == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Детали плана')),
            body: const Center(child: Text('План не найден')),
          );
        }

        final days = plan.weekdays
            .map((w) => _weekdayLabel(w))
            .join(', ');

        return Scaffold(
          appBar: AppBar(
            title: Text(plan.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Удалить план'),
                      content: const Text(
                        'Вы уверены, что хотите удалить этот план?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await ref.read(workoutPlanRepositoryProvider).deletePlan(planId);
                    if (context.mounted) context.pop();
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Дни тренировок',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        days,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Упражнения',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              if (plan.exercises.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('Упражнения ещё не добавлены')),
                  ),
                )
              else
                ...plan.exercises.asMap().entries.map((e) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${e.key + 1}')),
                      title: Text(e.value.exerciseName),
                      subtitle: Text(
                        '${e.value.sets ?? 3} x ${e.value.reps ?? 10} повтор',
                      ),
                      onTap: () => context.push('/exercise/${e.value.exerciseId}'),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  String _weekdayLabel(Weekday w) {
    const map = {
      Weekday.monday: 'Понедельник',
      Weekday.tuesday: 'Вторник',
      Weekday.wednesday: 'Среда',
      Weekday.thursday: 'Четверг',
      Weekday.friday: 'Пятница',
      Weekday.saturday: 'Суббота',
      Weekday.sunday: 'Воскресенье',
    };
    return map[w] ?? '';
  }
}
