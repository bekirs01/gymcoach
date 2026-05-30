import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym/data/local/training_snapshot_codec.dart';
import 'package:gym/features/plans/domain/plan_exercise.dart';
import 'package:gym/features/plans/domain/workout_plan.dart';
import 'package:gym/features/plans/domain/workout_template.dart';
import 'package:gym/features/profile/domain/user_profile.dart';
import 'package:gym/features/workout/domain/completed_exercise_log.dart';
import 'package:gym/features/workout/domain/workout_completion.dart';

void main() {
  test('TrainingSnapshot round-trip preserves data', () {
    final today = WorkoutPlan.dateOnly(DateTime.now());
    final plans = [
      WorkoutPlan(
        id: 'p1',
        name: 'Leg day',
        scheduledDate: today,
        scheduledTime: const TimeOfDay(hour: 9, minute: 5),
        durationMinutes: 40,
        difficulty: PlanDifficulty.intermediate,
        exercises: const [PlanExercise(name: 'Squats', defaultSets: 4, defaultReps: 8)],
        status: PlanStatus.planned,
      ),
    ];
    const templates = [
      WorkoutTemplate(
        id: 't1',
        name: 'Leg template',
        durationMinutes: 45,
        difficulty: PlanDifficulty.intermediate,
        exercises: [PlanExercise(name: 'Squats', defaultSets: 5, defaultReps: 5)],
      ),
    ];
    final completions = [
      WorkoutCompletion(
        id: 'c1',
        title: 'Run',
        workoutType: 'Cardio',
        completedAt: DateTime.utc(2026, 3, 15, 12, 30),
        durationMinutes: 30,
        calories: 300,
        exerciseNames: const ['Run'],
        exerciseLogs: [
          CompletedExerciseLog(
            exerciseId: 'p1_0',
            exerciseName: 'Run',
            setsCompleted: 3,
            repsCompleted: 10,
            estimatedCalories: 42,
            completedAt: DateTime.utc(2026, 3, 15, 12, 0),
            categoryKey: 'cardio',
          ),
        ],
        caloriesAreEstimated: true,
      ),
    ];
    const profile = UserProfile(
      displayName: 'Test User',
      weightKg: 70,
      heightCm: 170,
      fitnessGoal: 'General fitness',
      membershipLevel: 'Free',
      notificationsEnabled: false,
    );

    final snap = TrainingSnapshot(plans: plans, completions: completions, profile: profile, templates: templates);
    final decoded = TrainingSnapshot.decode(snap.encode());

    expect(decoded.plans.length, 1);
    expect(decoded.plans.first.id, 'p1');
    expect(decoded.plans.first.scheduledTime.hour, 9);
    expect(decoded.plans.first.scheduledTime.minute, 5);
    expect(decoded.plans.first.exercises.first.defaultSets, 4);
    expect(decoded.templates.length, 1);
    expect(decoded.templates.first.exercises.first.defaultReps, 5);
    expect(decoded.completions.first.calories, 300);
    expect(decoded.completions.first.exerciseLogs.length, 1);
    expect(decoded.completions.first.exerciseLogs.first.setsCompleted, 3);
    expect(decoded.completions.first.exerciseLogs.first.categoryKey, 'cardio');
    expect(decoded.profile.displayName, 'Test User');
    expect(decoded.profile.notificationsEnabled, false);
  });
}
