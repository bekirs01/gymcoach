import '../features/plans/domain/workout_plan.dart';
import '../features/workout/domain/completed_exercise_log.dart';

abstract class SessionCalorieEstimator {
  static String categoryKeyForName(String exerciseName) {
    final n = exerciseName.toLowerCase();
    if (RegExp(
      r'run|jumping|jump rope|row|cycle|sprint|hiit|cardio|tempo|rowing',
    ).hasMatch(n)) {
      return 'cardio';
    }
    if (RegExp(
      r'plank|crunch|core|dead bug|pallof|leg raise|abs|bicycle|russian',
    ).hasMatch(n)) {
      return 'core';
    }
    if (RegExp(
      r'mobility|stretch|rotation|foam|breath|walk|recovery|ankle|hip cars',
    ).hasMatch(n)) {
      return 'mobility';
    }
    if (RegExp(
      r'squat|press|deadlift|pull-up|pull up|push-up|push up|lunge|bench',
    ).hasMatch(n)) {
      return 'strength';
    }
    return 'general';
  }

  static double _metForCategory(String categoryKey) {
    return switch (categoryKey) {
      'cardio' => 9.0,
      'strength' => 5.0,
      'core' => 3.8,
      'mobility' => 3.0,
      _ => 4.5,
    };
  }

  static double _secondsPerRep(String categoryKey) {
    return switch (categoryKey) {
      'cardio' => 1.8,
      'strength' => 4.0,
      'core' => 3.2,
      'mobility' => 5.0,
      _ => 3.8,
    };
  }

  static int kcalForExercise({
    required double weightKg,
    required String categoryKey,
    required int sets,
    required int reps,
  }) {
    if (sets <= 0 || reps <= 0 || weightKg <= 0) return 0;
    final met = _metForCategory(categoryKey);
    final sec = _secondsPerRep(categoryKey);
    final minutesMoving = (sets * reps * sec / 60.0).clamp(0.5, 45.0);
    final raw = 0.0175 * met * weightKg * minutesMoving;
    return raw.round().clamp(1, 2000);
  }

  static int sessionKcalFromLogs({
    required double weightKg,
    required PlanDifficulty difficulty,
    required int durationMinutes,
    required int exerciseCount,
    required List<CompletedExerciseLog> logs,
  }) {
    if (logs.isEmpty) {
      return fallbackSessionKcal(
        weightKg: weightKg,
        difficulty: difficulty,
        durationMinutes: durationMinutes,
        exerciseCount: exerciseCount,
      );
    }
    var totalVolume = 0;
    var weightedMet = 0.0;
    for (final log in logs) {
      final volume = (log.setsCompleted * log.repsCompleted).clamp(1, 10000);
      totalVolume += volume;
      weightedMet += _metForCategory(log.categoryKey) * volume;
    }
    final averageMet = weightedMet / totalVolume;
    final raw = averageMet * 3.5 * weightKg / 200 * durationMinutes;
    return raw.round().clamp(1, 20000);
  }

  static int fallbackSessionKcal({
    required double weightKg,
    required PlanDifficulty difficulty,
    required int durationMinutes,
    required int exerciseCount,
  }) {
    if (weightKg <= 0 || durationMinutes <= 0) return 1;
    final met = switch (difficulty) {
      PlanDifficulty.beginner => 4.6,
      PlanDifficulty.intermediate => 5.6,
      PlanDifficulty.advanced => 6.4,
    };
    final density = (exerciseCount / 6.0).clamp(0.65, 1.35);
    final raw = 0.0175 * met * weightKg * durationMinutes * density;
    return raw.round().clamp(1, 8000);
  }

  static int fallbackAdHocLog({
    required double weightKg,
    required int durationMinutes,
  }) {
    if (weightKg <= 0 || durationMinutes <= 0) return 1;
    final raw = 0.0175 * 5.2 * weightKg * durationMinutes;
    return raw.round().clamp(1, 8000);
  }
}
