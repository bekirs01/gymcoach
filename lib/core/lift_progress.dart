import '../features/workout/domain/workout_completion.dart';

class LiftProgressEntry {
  const LiftProgressEntry({
    required this.exerciseName,
    required this.bestWeightKg,
    required this.lastDate,
  });

  final String exerciseName;
  final double bestWeightKg;
  final DateTime lastDate;
}

List<LiftProgressEntry> computeLiftProgress(List<WorkoutCompletion> completions) {
  final best = <String, ({double kg, DateTime date})>{};
  for (final c in completions) {
    for (final log in c.exerciseLogs) {
      final w = log.weightKg;
      if (w == null) continue;
      final prev = best[log.exerciseName];
      if (prev == null || w > prev.kg) {
        best[log.exerciseName] = (kg: w, date: log.completedAt);
      }
    }
  }
  final entries = best.entries
      .map(
        (e) => LiftProgressEntry(
          exerciseName: e.key,
          bestWeightKg: e.value.kg,
          lastDate: e.value.date,
        ),
      )
      .toList()
    ..sort((a, b) => b.bestWeightKg.compareTo(a.bestWeightKg));
  return entries;
}
