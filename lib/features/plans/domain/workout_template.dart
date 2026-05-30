import 'package:flutter/material.dart';

import 'plan_exercise.dart';
import 'workout_plan.dart';

class WorkoutTemplate {
  const WorkoutTemplate({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.difficulty,
    required this.exercises,
  });

  final String id;
  final String name;
  final int durationMinutes;
  final PlanDifficulty difficulty;
  final List<PlanExercise> exercises;

  WorkoutPlan toScheduledPlan({
    required DateTime scheduledDate,
    required TimeOfDay scheduledTime,
  }) {
    return WorkoutPlan(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      durationMinutes: durationMinutes,
      difficulty: difficulty,
      exercises: List<PlanExercise>.from(exercises),
      status: PlanStatus.planned,
    );
  }

  static WorkoutTemplate fromPlan(WorkoutPlan plan) {
    return WorkoutTemplate(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: plan.name,
      durationMinutes: plan.durationMinutes,
      difficulty: plan.difficulty,
      exercises: List<PlanExercise>.from(plan.exercises),
    );
  }
}
