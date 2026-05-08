import '../features/plans/domain/workout_plan.dart';
import '../features/workout/domain/workout_completion.dart';

abstract final class TrainingStats {
  static Set<DateTime> completedDays(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
  ) {
    final out = <DateTime>{};
    for (final p in plans) {
      if (p.status == PlanStatus.completed) {
        out.add(WorkoutPlan.dateOnly(p.scheduledDate));
      }
    }
    for (final c in completions) {
      out.add(WorkoutPlan.dateOnly(c.completedAt));
    }
    return out;
  }

  static int currentStreak(Set<DateTime> completedDays, DateTime reference) {
    var day = WorkoutPlan.dateOnly(reference);
    var streak = 0;
    while (completedDays.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static int weeklyWorkoutsCompleted(
    List<WorkoutCompletion> completions,
    DateTime reference,
  ) {
    final mon = WorkoutPlan.mondayContaining(reference);
    final sun = mon.add(const Duration(days: 7));
    var n = 0;
    for (final c in completions) {
      final d = WorkoutPlan.dateOnly(c.completedAt);
      if (!d.isBefore(mon) && d.isBefore(sun)) n++;
    }
    return n;
  }
}
