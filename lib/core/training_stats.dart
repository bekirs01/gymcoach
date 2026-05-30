import '../features/plans/domain/workout_plan.dart';
import '../features/workout/domain/workout_completion.dart';

abstract final class TrainingStats {
  static bool completionMatchesPlans(WorkoutCompletion completion, List<WorkoutPlan> plans) {
    for (final plan in plans) {
      if (plan.name == completion.title &&
          WorkoutPlan.isSameDay(plan.scheduledDate, completion.completedAt)) {
        return true;
      }
    }
    for (final log in completion.exerciseLogs) {
      final sep = log.exerciseId.indexOf('_');
      if (sep <= 0) continue;
      final planId = log.exerciseId.substring(0, sep);
      if (plans.any((p) => p.id == planId)) return true;
    }
    return false;
  }

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
      if (!completionMatchesPlans(c, plans)) continue;
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

  static int weeklySessionsCompleted(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
    DateTime reference,
  ) {
    final mon = WorkoutPlan.mondayContaining(reference);
    final sun = mon.add(const Duration(days: 7));
    final completionDays = <DateTime>{};
    var n = 0;
    for (final c in completions) {
      final d = WorkoutPlan.dateOnly(c.completedAt);
      if (d.isBefore(mon) || !d.isBefore(sun)) continue;
      n++;
      completionDays.add(d);
    }
    for (final p in plans) {
      if (p.status != PlanStatus.completed) continue;
      final d = WorkoutPlan.dateOnly(p.scheduledDate);
      if (d.isBefore(mon) || !d.isBefore(sun)) continue;
      if (!completionDays.contains(d)) n++;
    }
    return n;
  }

  static int totalCompletedSessions(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
  ) {
    final completionDays = <DateTime>{};
    for (final c in completions) {
      completionDays.add(WorkoutPlan.dateOnly(c.completedAt));
    }
    var n = completions.length;
    for (final p in plans) {
      if (p.status != PlanStatus.completed) continue;
      final d = WorkoutPlan.dateOnly(p.scheduledDate);
      if (!completionDays.contains(d)) n++;
    }
    return n;
  }

  static double monthlyConsistencyPercent(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
    DateTime now,
  ) {
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    var planned = 0;
    for (final p in plans) {
      final d = WorkoutPlan.dateOnly(p.scheduledDate);
      if (d.isBefore(start) || !d.isBefore(end)) continue;
      planned++;
    }
    if (planned == 0) return 0;

    final completionDaysInMonth = <DateTime>{};
    var completionCount = 0;
    for (final c in completions) {
      final d = WorkoutPlan.dateOnly(c.completedAt);
      if (d.isBefore(start) || !d.isBefore(end)) continue;
      completionCount++;
      completionDaysInMonth.add(d);
    }
    var extraPlanHits = 0;
    for (final p in plans) {
      if (p.status != PlanStatus.completed) continue;
      final d = WorkoutPlan.dateOnly(p.scheduledDate);
      if (d.isBefore(start) || !d.isBefore(end)) continue;
      if (!completionDaysInMonth.contains(d)) extraPlanHits++;
    }
    final done = completionCount + extraPlanHits;
    return (done / planned * 100).clamp(0, 100);
  }
}
