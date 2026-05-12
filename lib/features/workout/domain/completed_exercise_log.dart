class CompletedExerciseLog {
  const CompletedExerciseLog({
    required this.exerciseId,
    required this.exerciseName,
    required this.setsCompleted,
    required this.repsCompleted,
    required this.estimatedCalories,
    required this.completedAt,
    required this.categoryKey,
  });

  final String exerciseId;
  final String exerciseName;
  final int setsCompleted;
  final int repsCompleted;
  final int estimatedCalories;
  final DateTime completedAt;
  final String categoryKey;
}
