import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/providers.dart';
import '../../../domain/models/exercise.dart';
import '../../../domain/models/workout_plan.dart';
import '../../widgets/common/primary_button.dart';

/// Yeni antrenman planı oluşturma
class CreatePlanScreen extends ConsumerStatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  ConsumerState<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends ConsumerState<CreatePlanScreen> {
  final _nameController = TextEditingController();
  final List<Weekday> _selectedDays = [];
  final List<PlanExercise> _exercises = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _savePlan() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название плана')),
      );
      return;
    }
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите хотя бы один день')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final repo = ref.read(workoutPlanRepositoryProvider);
    final plan = WorkoutPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      weekdays: List.from(_selectedDays),
      exercises: List.from(_exercises),
      createdAt: DateTime.now(),
    );
    await repo.savePlan(plan);

    if (mounted) {
      setState(() => _isSaving = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать новый план'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название плана',
                hintText: 'Напр.: День верхней части тела',
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Дни тренировок',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: Weekday.values.map((d) {
                final label = _weekdayLabel(d);
                final selected = _selectedDays.contains(d);
                return FilterChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selectedDays.add(d);
                      } else {
                        _selectedDays.remove(d);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Упражнения (${_exercises.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: _showExercisePicker,
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._exercises.asMap().entries.map((e) => ListTile(
                  leading: CircleAvatar(child: Text('${e.key + 1}')),
                  title: Text(e.value.exerciseName),
                  subtitle: Text(
                    '${e.value.sets ?? 3} x ${e.value.reps ?? 10}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => setState(() => _exercises.removeAt(e.key)),
                  ),
                )),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Сохранить план',
              onPressed: _isSaving ? null : _savePlan,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayLabel(Weekday w) {
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

  Future<void> _showExercisePicker() async {
    final exercises = await ref.read(exerciseRepositoryProvider).getAllExercises();
    if (!mounted) return;

    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => ListView.builder(
          controller: scrollController,
          itemCount: exercises.length,
          itemBuilder: (context, i) {
            final ex = exercises[i];
            return ListTile(
              title: Text(ex.name),
              subtitle: Text('${ex.targetMuscle} • ${ex.durationOrRepsText}'),
              onTap: () => Navigator.pop(context, ex),
            );
          },
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _exercises.add(PlanExercise(
          exerciseId: selected.id,
          exerciseName: selected.name,
          sets: 3,
          reps: 10,
          order: _exercises.length,
        ));
      });
    }
  }
}
