import 'package:flutter/material.dart';

import '../features/plans/domain/plan_exercise.dart';
import '../features/plans/domain/workout_plan.dart';

final class PlanFactory {
  static WorkoutPlan duplicateForDate(
    WorkoutPlan source, {
    required DateTime scheduledDate,
    TimeOfDay? scheduledTime,
  }) {
    return WorkoutPlan(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: source.name,
      scheduledDate: WorkoutPlan.dateOnly(scheduledDate),
      scheduledTime: scheduledTime ?? source.scheduledTime,
      durationMinutes: source.durationMinutes,
      difficulty: source.difficulty,
      exercises: List<PlanExercise>.from(source.exercises),
      status: PlanStatus.planned,
    );
  }
}
