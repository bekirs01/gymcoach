import '../features/plans/domain/workout_plan.dart';
import '../features/workout/domain/completed_exercise_log.dart';

abstract class SessionCalorieEstimator {
  static String categoryKeyForName(String exerciseName) {
    final n = exerciseName.toLowerCase();
    if (RegExp(
      r'run|jumping jack|jump rope|burpee|mountain climber|row|cycle|bike|sprint|hiit|cardio|tempo|rowing|скакалк|бёрпи|бег',
    ).hasMatch(n)) {
      return 'cardio';
    }
    if (RegExp(
      r'plank|crunch|core|dead bug|pallof|leg raise|abs|bicycle|twist|планк|пресс|скручив',
    ).hasMatch(n)) {
      return 'core';
    }
    if (RegExp(
      r'mobility|stretch|rotation|foam|breath|walk|recovery|ankle|hip cars|растяж',
    ).hasMatch(n)) {
      return 'mobility';
    }
    if (RegExp(
      r'squat|press|deadlift|pull-up|pull up|push-up|push up|lunge|bench|fly|curl|thrust|bridge|dip|row|тяга|жим|присед|выпад|подтяг|отжим',
    ).hasMatch(n)) {
      return 'strength';
    }
    return 'general';
  }

  static double _metForCategory(String categoryKey) {
    return switch (categoryKey) {
      'cardio' => 9.5,
      'strength' => 6.0,
      'core' => 4.2,
      'mobility' => 3.2,
      _ => 5.0,
    };
  }

  static double _secondsPerRep(String categoryKey) {
    return switch (categoryKey) {
      'cardio' => 1.6,
      'strength' => 4.2,
      'core' => 3.4,
      'mobility' => 5.5,
      _ => 3.8,
    };
  }

  /// Mifflin–St Jeor (average), age 30 — kcal per minute at rest.
  static double bmrKcalPerMinute(double weightKg, double heightCm) {
    if (weightKg <= 0 || heightCm <= 0) return 1.0;
    final bmr = 10 * weightKg + 6.25 * heightCm - 5 * 30 - 78;
    return (bmr / 1440).clamp(0.9, 3.2);
  }

  static double heightFactor(double heightCm) {
    if (heightCm <= 0) return 1.0;
    return (heightCm / 175.0).clamp(0.9, 1.12);
  }

  static double activeMinutesForLog(CompletedExerciseLog log) {
    final sec = _secondsPerRep(log.categoryKey);
    final work = log.setsCompleted * log.repsCompleted * sec / 60.0;
    final rest = log.setsCompleted * 1.75;
    return (work + rest).clamp(0.5, 90.0);
  }

  static int kcalForExercise({
    required double weightKg,
    required double heightCm,
    required String categoryKey,
    required int sets,
    required int reps,
  }) {
    if (sets <= 0 || reps <= 0 || weightKg <= 0) return 0;
    final met = _metForCategory(categoryKey);
    final sec = _secondsPerRep(categoryKey);
    final workMinutes = (sets * reps * sec / 60.0).clamp(0.25, 40.0);
    final restMinutes = sets * 1.75;
    final minutes = workMinutes + restMinutes;
    final raw = 0.0175 * met * weightKg * minutes * heightFactor(heightCm);
    return raw.round().clamp(1, 2500);
  }

  static int sessionKcalFromLogs({
    required double weightKg,
    required double heightCm,
    required PlanDifficulty difficulty,
    required int durationMinutes,
    required int exerciseCount,
    required List<CompletedExerciseLog> logs,
  }) {
    if (logs.isEmpty) {
      return fallbackSessionKcal(
        weightKg: weightKg,
        heightCm: heightCm,
        difficulty: difficulty,
        durationMinutes: durationMinutes,
        exerciseCount: exerciseCount,
      );
    }

    var exerciseKcal = 0;
    var activeMinutes = 0.0;
    for (final log in logs) {
      exerciseKcal += kcalForExercise(
        weightKg: weightKg,
        heightCm: heightCm,
        categoryKey: log.categoryKey,
        sets: log.setsCompleted,
        reps: log.repsCompleted,
      );
      activeMinutes += activeMinutesForLog(log);
    }

    final sessionMinutes = durationMinutes.clamp(1, 999).toDouble();
    final transitionMinutes = (sessionMinutes - activeMinutes).clamp(0.0, sessionMinutes);
    final transitionKcal = (bmrKcalPerMinute(weightKg, heightCm) * transitionMinutes * 1.35).round();

    return (exerciseKcal + transitionKcal).clamp(1, 20000);
  }

  static int fallbackSessionKcal({
    required double weightKg,
    required double heightCm,
    required PlanDifficulty difficulty,
    required int durationMinutes,
    required int exerciseCount,
  }) {
    if (weightKg <= 0 || durationMinutes <= 0) return 1;
    final met = switch (difficulty) {
      PlanDifficulty.beginner => 4.8,
      PlanDifficulty.intermediate => 5.8,
      PlanDifficulty.advanced => 6.6,
    };
    final density = (exerciseCount / 6.0).clamp(0.65, 1.35);
    final raw = 0.0175 * met * weightKg * durationMinutes * density * heightFactor(heightCm);
    return raw.round().clamp(1, 8000);
  }

  static int fallbackAdHocLog({
    required double weightKg,
    required double heightCm,
    required int durationMinutes,
  }) {
    if (weightKg <= 0 || durationMinutes <= 0) return 1;
    final raw = 0.0175 * 5.2 * weightKg * durationMinutes * heightFactor(heightCm);
    return raw.round().clamp(1, 8000);
  }
}
