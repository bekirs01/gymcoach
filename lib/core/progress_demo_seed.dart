import 'package:flutter/material.dart';

import '../features/plans/domain/plan_exercise.dart';
import '../features/plans/domain/workout_plan.dart';
import '../features/profile/domain/user_profile.dart';
import '../features/workout/domain/completed_exercise_log.dart';
import '../features/workout/domain/workout_completion.dart';
import 'session_calorie_estimator.dart';

final class ProgressDemoSeedResult {
  const ProgressDemoSeedResult({
    required this.plans,
    required this.completions,
    required this.addedSessions,
  });

  final List<WorkoutPlan> plans;
  final List<WorkoutCompletion> completions;
  final int addedSessions;
}

abstract final class ProgressDemoSeed {
  static const _planPrefix = 'demo_progress_plan_';
  static const _completionPrefix = 'demo_progress_completion_';

  static ProgressDemoSeedResult? applyIfNeeded({
    required List<WorkoutPlan> plans,
    required List<WorkoutCompletion> completions,
    required UserProfile profile,
    required DateTime now,
  }) {
    if (_hasDemoSeed(plans, completions)) return null;
    if (_realCompletionCount(completions, now) >= 3) return null;

    final monthStart = DateTime(now.year, now.month, 1);
    final nextPlans = List<WorkoutPlan>.from(plans);
    final nextCompletions = List<WorkoutCompletion>.from(completions);
    var added = 0;

    for (final spec in _sessionSpecs()) {
      final date = DateTime(now.year, now.month, spec.day);
      if (date.isBefore(monthStart)) continue;

      final planId =
          '$_planPrefix${now.year}_${now.month.toString().padLeft(2, '0')}_${spec.day.toString().padLeft(2, '0')}_${spec.slug}';

      if (nextPlans.any((p) => p.id == planId)) continue;

      final exercises = spec.exercises
          .map(
            (e) => PlanExercise(
              name: e.name,
              defaultSets: e.sets,
              defaultReps: e.reps,
            ),
          )
          .toList();

      final plan = WorkoutPlan(
        id: planId,
        name: spec.name,
        scheduledDate: date,
        scheduledTime: TimeOfDay(hour: spec.hour, minute: spec.minute),
        durationMinutes: spec.durationMinutes,
        difficulty: spec.difficulty,
        exercises: exercises,
        status: spec.plannedOnly ? PlanStatus.planned : PlanStatus.completed,
      );

      nextPlans.add(plan);
      added++;

      if (spec.plannedOnly) continue;

      final completionId =
          '$_completionPrefix${now.year}_${now.month.toString().padLeft(2, '0')}_${spec.day.toString().padLeft(2, '0')}_${spec.slug}';

      if (nextCompletions.any((c) => c.id == completionId)) continue;

      final completedAt = DateTime(now.year, now.month, spec.day, spec.hour, spec.minute);
      final logs = <CompletedExerciseLog>[];
      for (var i = 0; i < spec.exercises.length; i++) {
        final e = spec.exercises[i];
        final category = SessionCalorieEstimator.categoryKeyForName(e.name);
        logs.add(
          CompletedExerciseLog(
            exerciseId: '${planId}_$i',
            exerciseName: e.name,
            setsCompleted: e.sets,
            repsCompleted: e.reps,
            estimatedCalories: SessionCalorieEstimator.kcalForExercise(
              weightKg: profile.weightKg,
              heightCm: profile.heightCm,
              categoryKey: category,
              sets: e.sets,
              reps: e.reps,
            ),
            completedAt: completedAt,
            categoryKey: category,
          ),
        );
      }

      final calories = SessionCalorieEstimator.sessionKcalFromLogs(
        weightKg: profile.weightKg,
        heightCm: profile.heightCm,
        difficulty: spec.difficulty,
        durationMinutes: spec.durationMinutes,
        exerciseCount: exercises.length,
        logs: logs,
      );

      nextCompletions.add(
        WorkoutCompletion(
          id: completionId,
          title: spec.name,
          workoutType: spec.focus,
          completedAt: completedAt,
          durationMinutes: spec.durationMinutes,
          calories: calories.clamp(190, 420),
          exerciseNames: exercises.map((e) => e.name).toList(),
          exerciseLogs: logs,
          caloriesAreEstimated: true,
        ),
      );
    }

    if (added == 0) return null;
    return ProgressDemoSeedResult(
      plans: nextPlans,
      completions: nextCompletions,
      addedSessions: added,
    );
  }

  static bool _hasDemoSeed(List<WorkoutPlan> plans, List<WorkoutCompletion> completions) {
    return plans.any((p) => p.id.startsWith(_planPrefix)) ||
        completions.any((c) => c.id.startsWith(_completionPrefix));
  }

  static int _realCompletionCount(List<WorkoutCompletion> completions, DateTime now) {
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);
    return completions.where((c) {
      if (c.id.startsWith(_completionPrefix)) return false;
      final d = WorkoutPlan.dateOnly(c.completedAt);
      return !d.isBefore(monthStart) && d.isBefore(monthEnd);
    }).length;
  }

  static List<_DemoSessionSpec> _sessionSpecs() {
    return [
      _DemoSessionSpec(
        day: 4,
        slug: 'back_strength_builder',
        name: 'Back Strength Builder',
        focus: 'Back',
        durationMinutes: 58,
        hour: 19,
        minute: 0,
        difficulty: PlanDifficulty.intermediate,
        exercises: const [
          _DemoExercise(name: 'Barbell Row', sets: 4, reps: 8),
          _DemoExercise(name: 'Lat Pulldown', sets: 3, reps: 10),
          _DemoExercise(name: 'Seated Cable Row', sets: 3, reps: 12),
          _DemoExercise(name: 'Face Pull', sets: 2, reps: 15),
        ],
      ),
      _DemoSessionSpec(
        day: 6,
        slug: 'leg_day_engine',
        name: 'Leg Day Engine',
        focus: 'Legs',
        durationMinutes: 64,
        hour: 17,
        minute: 45,
        difficulty: PlanDifficulty.advanced,
        exercises: const [
          _DemoExercise(name: 'Back Squat', sets: 4, reps: 6),
          _DemoExercise(name: 'Romanian Deadlift', sets: 3, reps: 10),
          _DemoExercise(name: 'Leg Press', sets: 3, reps: 12),
          _DemoExercise(name: 'Walking Lunge', sets: 3, reps: 10),
        ],
      ),
      _DemoSessionSpec(
        day: 8,
        slug: 'shoulder_sculpt',
        name: 'Shoulder Sculpt',
        focus: 'Shoulders',
        durationMinutes: 45,
        hour: 18,
        minute: 30,
        difficulty: PlanDifficulty.intermediate,
        exercises: const [
          _DemoExercise(name: 'Overhead Press', sets: 4, reps: 8),
          _DemoExercise(name: 'Lateral Raise', sets: 3, reps: 12),
          _DemoExercise(name: 'Rear Delt Fly', sets: 3, reps: 12),
          _DemoExercise(name: 'Arnold Press', sets: 2, reps: 10),
        ],
      ),
      _DemoSessionSpec(
        day: 10,
        slug: 'biceps_density',
        name: 'Biceps Density',
        focus: 'Biceps',
        durationMinutes: 38,
        hour: 19,
        minute: 15,
        difficulty: PlanDifficulty.beginner,
        exercises: const [
          _DemoExercise(name: 'Barbell Curl', sets: 4, reps: 10),
          _DemoExercise(name: 'Hammer Curl', sets: 3, reps: 12),
          _DemoExercise(name: 'Incline Dumbbell Curl', sets: 3, reps: 10),
          _DemoExercise(name: 'Cable Curl', sets: 2, reps: 15),
        ],
      ),
      _DemoSessionSpec(
        day: 12,
        slug: 'core_control',
        name: 'Core Control',
        focus: 'Core',
        durationMinutes: 40,
        hour: 18,
        minute: 0,
        difficulty: PlanDifficulty.intermediate,
        exercises: const [
          _DemoExercise(name: 'Plank Hold', sets: 3, reps: 45),
          _DemoExercise(name: 'Hanging Leg Raise', sets: 3, reps: 12),
          _DemoExercise(name: 'Russian Twist', sets: 3, reps: 20),
          _DemoExercise(name: 'Dead Bug', sets: 3, reps: 12),
        ],
      ),
      _DemoSessionSpec(
        day: 14,
        slug: 'push_day_prime',
        name: 'Push Day Prime',
        focus: 'Chest',
        durationMinutes: 55,
        hour: 18,
        minute: 45,
        difficulty: PlanDifficulty.intermediate,
        exercises: const [
          _DemoExercise(name: 'Flat Bench Press', sets: 4, reps: 8),
          _DemoExercise(name: 'Overhead Press', sets: 3, reps: 8),
          _DemoExercise(name: 'Dips', sets: 3, reps: 10),
          _DemoExercise(name: 'Triceps Pushdown', sets: 3, reps: 12),
        ],
      ),
      _DemoSessionSpec(
        day: 15,
        slug: 'pull_day_control',
        name: 'Pull Day Control',
        focus: 'Back',
        durationMinutes: 50,
        hour: 19,
        minute: 30,
        difficulty: PlanDifficulty.intermediate,
        exercises: const [
          _DemoExercise(name: 'Pull-ups', sets: 4, reps: 6),
          _DemoExercise(name: 'Chest-Supported Row', sets: 3, reps: 10),
          _DemoExercise(name: 'Barbell Curl', sets: 3, reps: 10),
          _DemoExercise(name: 'Rear Delt Fly', sets: 3, reps: 15),
        ],
      ),
      _DemoSessionSpec(
        day: 16,
        slug: 'leg_day_engine_2',
        name: 'Leg Day Engine',
        focus: 'Legs',
        durationMinutes: 62,
        hour: 17,
        minute: 30,
        difficulty: PlanDifficulty.advanced,
        exercises: const [
          _DemoExercise(name: 'Front Squat', sets: 4, reps: 6),
          _DemoExercise(name: 'Leg Curl', sets: 3, reps: 12),
          _DemoExercise(name: 'Bulgarian Split Squat', sets: 3, reps: 10),
          _DemoExercise(name: 'Calf Raise', sets: 4, reps: 15),
        ],
      ),
      _DemoSessionSpec(
        day: 18,
        slug: 'chest_power_press_2',
        name: 'Chest Power Press',
        focus: 'Chest',
        durationMinutes: 48,
        hour: 18,
        minute: 20,
        difficulty: PlanDifficulty.intermediate,
        exercises: const [
          _DemoExercise(name: 'Dumbbell Bench Press', sets: 4, reps: 8),
          _DemoExercise(name: 'Incline Barbell Press', sets: 3, reps: 10),
          _DemoExercise(name: 'Pec Deck Fly', sets: 3, reps: 12),
          _DemoExercise(name: 'Push-ups', sets: 2, reps: 12),
        ],
      ),
      _DemoSessionSpec(
        day: 19,
        slug: 'back_strength_builder_2',
        name: 'Back Strength Builder',
        focus: 'Back',
        durationMinutes: 56,
        hour: 19,
        minute: 10,
        difficulty: PlanDifficulty.intermediate,
        exercises: const [
          _DemoExercise(name: 'Deadlift', sets: 4, reps: 5),
          _DemoExercise(name: 'Pull-ups', sets: 3, reps: 8),
          _DemoExercise(name: 'Single-Arm Dumbbell Row', sets: 3, reps: 10),
          _DemoExercise(name: 'Straight-Arm Pulldown', sets: 2, reps: 15),
        ],
      ),
      _DemoSessionSpec(
        day: 20,
        slug: 'chest_power_press',
        name: 'Chest Power Press',
        focus: 'Chest',
        durationMinutes: 52,
        hour: 18,
        minute: 0,
        difficulty: PlanDifficulty.intermediate,
        exercises: const [
          _DemoExercise(name: 'Barbell Bench Press', sets: 4, reps: 8),
          _DemoExercise(name: 'Incline Dumbbell Press', sets: 3, reps: 10),
          _DemoExercise(name: 'Cable Chest Fly', sets: 3, reps: 12),
          _DemoExercise(name: 'Push-ups', sets: 2, reps: 15),
        ],
      ),
      _DemoSessionSpec(
        day: 22,
        slug: 'core_control_2',
        name: 'Core Control',
        focus: 'Core',
        durationMinutes: 36,
        hour: 18,
        minute: 40,
        difficulty: PlanDifficulty.intermediate,
        exercises: const [
          _DemoExercise(name: 'Plank Hold', sets: 3, reps: 50),
          _DemoExercise(name: 'Cable Crunch', sets: 3, reps: 15),
          _DemoExercise(name: 'Pallof Press', sets: 3, reps: 12),
          _DemoExercise(name: 'Bicycle Crunch', sets: 3, reps: 20),
        ],
      ),
      _DemoSessionSpec(
        day: 23,
        slug: 'shoulder_sculpt_upcoming',
        name: 'Shoulder Sculpt',
        focus: 'Shoulders',
        durationMinutes: 42,
        hour: 19,
        minute: 0,
        difficulty: PlanDifficulty.intermediate,
        plannedOnly: true,
        exercises: const [
          _DemoExercise(name: 'Seated Dumbbell Press', sets: 4, reps: 8),
          _DemoExercise(name: 'Cable Lateral Raise', sets: 3, reps: 12),
          _DemoExercise(name: 'Face Pull', sets: 3, reps: 15),
          _DemoExercise(name: 'Upright Row', sets: 2, reps: 10),
        ],
      ),
      _DemoSessionSpec(
        day: 26,
        slug: 'biceps_density_upcoming',
        name: 'Biceps Density',
        focus: 'Biceps',
        durationMinutes: 34,
        hour: 18,
        minute: 50,
        difficulty: PlanDifficulty.beginner,
        plannedOnly: true,
        exercises: const [
          _DemoExercise(name: 'EZ-Bar Curl', sets: 4, reps: 10),
          _DemoExercise(name: 'Concentration Curl', sets: 3, reps: 12),
          _DemoExercise(name: 'Preacher Curl', sets: 3, reps: 10),
          _DemoExercise(name: 'Cable Curl', sets: 2, reps: 15),
        ],
      ),
      _DemoSessionSpec(
        day: 28,
        slug: 'leg_day_engine_upcoming',
        name: 'Leg Day Engine',
        focus: 'Legs',
        durationMinutes: 60,
        hour: 17,
        minute: 30,
        difficulty: PlanDifficulty.advanced,
        plannedOnly: true,
        exercises: const [
          _DemoExercise(name: 'Back Squat', sets: 4, reps: 6),
          _DemoExercise(name: 'Romanian Deadlift', sets: 3, reps: 10),
          _DemoExercise(name: 'Leg Extension', sets: 3, reps: 12),
          _DemoExercise(name: 'Calf Raise', sets: 4, reps: 15),
        ],
      ),
    ];
  }
}

final class _DemoSessionSpec {
  const _DemoSessionSpec({
    required this.day,
    required this.slug,
    required this.name,
    required this.focus,
    required this.durationMinutes,
    required this.hour,
    required this.minute,
    required this.difficulty,
    required this.exercises,
    this.plannedOnly = false,
  });

  final int day;
  final String slug;
  final String name;
  final String focus;
  final int durationMinutes;
  final int hour;
  final int minute;
  final PlanDifficulty difficulty;
  final List<_DemoExercise> exercises;
  final bool plannedOnly;
}

final class _DemoExercise {
  const _DemoExercise({
    required this.name,
    required this.sets,
    required this.reps,
  });

  final String name;
  final int sets;
  final int reps;
}
