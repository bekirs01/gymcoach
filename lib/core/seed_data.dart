import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../features/plans/domain/workout_plan.dart';
import '../features/workout/domain/workout_completion.dart';

List<WorkoutPlan> seedPlans(AppLocalizations l10n) {
  final now = DateTime.now();
  final today = WorkoutPlan.dateOnly(now);

  return [
    WorkoutPlan(
      id: 'seed_push',
      name: l10n.seedPlanPushDay,
      scheduledDate: today,
      scheduledTime: const TimeOfDay(hour: 18, minute: 30),
      durationMinutes: 45,
      difficulty: PlanDifficulty.intermediate,
      exerciseNames: [
        l10n.exPushUps,
        l10n.exShoulderPress,
        l10n.exPullUps,
      ],
      status: PlanStatus.planned,
    ),
    WorkoutPlan(
      id: 'seed_lower',
      name: l10n.seedPlanLowerBody,
      scheduledDate: today.add(const Duration(days: 1)),
      scheduledTime: const TimeOfDay(hour: 17, minute: 0),
      durationMinutes: 50,
      difficulty: PlanDifficulty.intermediate,
      exerciseNames: [
        l10n.exSquats,
        l10n.exLunges,
        l10n.exRunning,
      ],
      status: PlanStatus.planned,
    ),
    WorkoutPlan(
      id: 'seed_cardio',
      name: l10n.seedPlanCardio,
      scheduledDate: today.subtract(const Duration(days: 1)),
      scheduledTime: const TimeOfDay(hour: 7, minute: 15),
      durationMinutes: 35,
      difficulty: PlanDifficulty.beginner,
      exerciseNames: [
        l10n.exRunning,
        l10n.exJumpingJacks,
      ],
      status: PlanStatus.completed,
    ),
    WorkoutPlan(
      id: 'seed_core',
      name: l10n.seedPlanCore,
      scheduledDate: today.subtract(const Duration(days: 3)),
      scheduledTime: const TimeOfDay(hour: 12, minute: 0),
      durationMinutes: 28,
      difficulty: PlanDifficulty.advanced,
      exerciseNames: [
        l10n.exPlank,
        l10n.exLunges,
      ],
      status: PlanStatus.missed,
    ),
  ];
}

List<WorkoutCompletion> seedCompletions(AppLocalizations l10n) {
  final now = DateTime.now();
  return [
    WorkoutCompletion(
      id: 's1',
      title: l10n.sampleCompletionLegDay,
      workoutType: l10n.sampleTypeLowerBody,
      completedAt: now.subtract(const Duration(days: 1)),
      durationMinutes: 52,
      calories: 420,
      exerciseNames: [
        l10n.exSquats,
        l10n.exLunges,
        l10n.exLegPress,
        l10n.exCalfRaises,
      ],
    ),
    WorkoutCompletion(
      id: 's2',
      title: l10n.sampleCompletionCore,
      workoutType: l10n.sampleTypeCore,
      completedAt: now.subtract(const Duration(days: 3)),
      durationMinutes: 28,
      calories: 210,
      exerciseNames: [
        l10n.exPlank,
        l10n.exBicycleCrunches,
        l10n.exRussianTwists,
      ],
    ),
    WorkoutCompletion(
      id: 's3',
      title: l10n.sampleCompletionRun,
      workoutType: l10n.sampleTypeOutdoorCardio,
      completedAt: now.subtract(const Duration(days: 6)),
      durationMinutes: 35,
      calories: 380,
      exerciseNames: [
        l10n.exRunning,
        l10n.exDynamicWarmUp,
      ],
    ),
  ];
}

List<WorkoutPlan> mergeSeedPlans(List<WorkoutPlan> current, List<WorkoutPlan> freshSeeds) {
  final user = current.where((p) => !p.id.startsWith('seed_')).toList();
  return [...user, ...freshSeeds];
}

List<WorkoutCompletion> mergeSeedCompletions(
  List<WorkoutCompletion> current,
  List<WorkoutCompletion> fresh,
) {
  const sampleIds = {'s1', 's2', 's3'};
  final user = current.where((c) => !sampleIds.contains(c.id)).toList();
  return [...fresh, ...user];
}
