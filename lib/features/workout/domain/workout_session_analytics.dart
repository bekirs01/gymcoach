abstract interface class WorkoutSessionAnalytics {
  void onExerciseBecameActive(int index, String exerciseName);
  void onExerciseLogged({required int index, required int sets, required int reps});
  void onSessionFinished(Duration elapsed);
}

final class NoOpWorkoutSessionAnalytics implements WorkoutSessionAnalytics {
  const NoOpWorkoutSessionAnalytics();

  @override
  void onExerciseBecameActive(int index, String exerciseName) {}

  @override
  void onExerciseLogged({required int index, required int sets, required int reps}) {}

  @override
  void onSessionFinished(Duration elapsed) {}
}
