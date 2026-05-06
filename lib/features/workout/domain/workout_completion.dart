import 'completed_exercise_log.dart';

class WorkoutCompletion {
  const WorkoutCompletion({
    required this.id,
    required this.title,
    required this.workoutType,
    required this.completedAt,
    required this.durationMinutes,
    required this.calories,
    required this.exerciseNames,
    this.exerciseLogs = const [],
    this.caloriesAreEstimated = true,
  });

  final String id;
  final String title;
  final String workoutType;
  final DateTime completedAt;
  final int durationMinutes;
  final int calories;
  final List<String> exerciseNames;
  final List<CompletedExerciseLog> exerciseLogs;
  final bool caloriesAreEstimated;
}
