import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym/core/training_stats.dart';
import 'package:gym/features/plans/domain/workout_plan.dart';
import 'package:gym/features/workout/domain/workout_completion.dart';

void main() {
  final weekMon = DateTime.utc(2026, 5, 4);

  test('weeklySessionsCompleted avoids double-count same day', () {
    final tue = weekMon.add(const Duration(days: 1));
    final plans = [
      WorkoutPlan(
        id: 'b',
        name: 'B',
        scheduledDate: tue,
        scheduledTime: const TimeOfDay(hour: 10, minute: 0),
        durationMinutes: 30,
        difficulty: PlanDifficulty.beginner,
        exerciseNames: const [],
        status: PlanStatus.completed,
      ),
    ];
    final completions = [
      WorkoutCompletion(
        id: 'l1',
        title: 'Log',
        workoutType: 'X',
        completedAt: tue,
        durationMinutes: 20,
        calories: 100,
        exerciseNames: const ['a'],
      ),
    ];
    expect(TrainingStats.weeklySessionsCompleted(plans, completions, tue), 1);
  });

  test('monthlyConsistencyPercent is zero when no plan in month', () {
    final plans = [
      WorkoutPlan(
        id: 'a',
        name: 'A',
        scheduledDate: weekMon,
        scheduledTime: const TimeOfDay(hour: 10, minute: 0),
        durationMinutes: 30,
        difficulty: PlanDifficulty.beginner,
        exerciseNames: const [],
        status: PlanStatus.planned,
      ),
    ];
    final ref = DateTime.utc(2026, 6, 15);
    expect(TrainingStats.monthlyConsistencyPercent(plans, [], ref), 0);
  });

  test('totalCompletedSessions counts plan without log on that day', () {
    final plans = [
      WorkoutPlan(
        id: 'a',
        name: "A",
        scheduledDate: weekMon,
        scheduledTime: const TimeOfDay(hour: 10, minute: 0),
        durationMinutes: 30,
        difficulty: PlanDifficulty.beginner,
        exerciseNames: const [],
        status: PlanStatus.planned,
      ),
      WorkoutPlan(
        id: 'b',
        name: 'B',
        scheduledDate: weekMon.add(const Duration(days: 1)),
        scheduledTime: const TimeOfDay(hour: 10, minute: 0),
        durationMinutes: 30,
        difficulty: PlanDifficulty.beginner,
        exerciseNames: const [],
        status: PlanStatus.completed,
      ),
    ];
    final completions = [
      WorkoutCompletion(
        id: 'l1',
        title: 'Log',
        workoutType: 'X',
        completedAt: weekMon,
        durationMinutes: 20,
        calories: 100,
        exerciseNames: const ['a'],
      ),
    ];
    expect(TrainingStats.totalCompletedSessions(plans, completions), 2);
  });
}
