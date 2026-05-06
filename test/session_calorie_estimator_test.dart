import 'package:flutter_test/flutter_test.dart';
import 'package:gym/core/session_calorie_estimator.dart';
import 'package:gym/features/plans/domain/workout_plan.dart';

void main() {
  test('kcalForExercise returns positive for strength work', () {
    final k = SessionCalorieEstimator.kcalForExercise(
      weightKg: 80,
      categoryKey: 'strength',
      sets: 4,
      reps: 8,
    );
    expect(k, greaterThan(5));
  });

  test('cardio category scores higher than mobility for same volume', () {
    final c = SessionCalorieEstimator.kcalForExercise(
      weightKg: 70,
      categoryKey: 'cardio',
      sets: 3,
      reps: 20,
    );
    final m = SessionCalorieEstimator.kcalForExercise(
      weightKg: 70,
      categoryKey: 'mobility',
      sets: 3,
      reps: 20,
    );
    expect(c, greaterThan(m));
  });

  test('categoryKeyForName classifies running as cardio', () {
    expect(SessionCalorieEstimator.categoryKeyForName('Morning Running'), 'cardio');
  });

  test('fallbackSessionKcal scales with duration', () {
    final a = SessionCalorieEstimator.fallbackSessionKcal(
      weightKg: 75,
      difficulty: PlanDifficulty.beginner,
      durationMinutes: 20,
      exerciseCount: 4,
    );
    final b = SessionCalorieEstimator.fallbackSessionKcal(
      weightKg: 75,
      difficulty: PlanDifficulty.beginner,
      durationMinutes: 40,
      exerciseCount: 4,
    );
    expect(b, greaterThan(a));
  });
}
