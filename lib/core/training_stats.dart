import '../features/plans/domain/workout_plan.dart';
import '../features/workout/domain/workout_completion.dart';

class MuscleGroupShare {
  const MuscleGroupShare({required this.label, required this.percent});

  final String label;
  final int percent;
}

class StrengthVolumeStats {
  const StrengthVolumeStats({
    required this.sets,
    required this.reps,
    required this.estimatedVolume,
  });

  final int sets;
  final int reps;
  final int estimatedVolume;
}

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

  static int sessionsOnDay(
    DateTime day,
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
  ) {
    final d = WorkoutPlan.dateOnly(day);
    var count = 0;
    for (final c in completions) {
      if (!completionMatchesPlans(c, plans)) continue;
      if (WorkoutPlan.dateOnly(c.completedAt) == d) count++;
    }
    for (final p in plans) {
      if (p.status != PlanStatus.completed) continue;
      if (WorkoutPlan.dateOnly(p.scheduledDate) != d) continue;
      final hasLog = completions.any(
        (c) =>
            completionMatchesPlans(c, plans) &&
            c.title == p.name &&
            WorkoutPlan.isSameDay(c.completedAt, d),
      );
      if (!hasLog) count++;
    }
    return count;
  }

  static List<int> weeklySessionCounts(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
    DateTime reference,
  ) {
    final mon = WorkoutPlan.mondayContaining(reference);
    return List.generate(7, (i) => sessionsOnDay(mon.add(Duration(days: i)), plans, completions));
  }

  static int weeklyTrainingMinutes(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
    DateTime reference,
  ) {
    final mon = WorkoutPlan.mondayContaining(reference);
    final end = mon.add(const Duration(days: 7));
    var total = 0;
    for (final c in completions) {
      if (!completionMatchesPlans(c, plans)) continue;
      final d = WorkoutPlan.dateOnly(c.completedAt);
      if (d.isBefore(mon) || !d.isBefore(end)) continue;
      total += c.durationMinutes;
    }
    return total;
  }

  static int weeklyCalories(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
    DateTime reference,
  ) {
    return weeklyCaloriesByDay(plans, completions, reference).fold<int>(0, (a, b) => a + b);
  }

  static List<int> weeklyCaloriesByDay(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
    DateTime reference,
  ) {
    final mon = WorkoutPlan.mondayContaining(reference);
    return List.generate(7, (i) {
      final day = WorkoutPlan.dateOnly(mon.add(Duration(days: i)));
      var total = 0;
      for (final c in completions) {
        if (!completionMatchesPlans(c, plans)) continue;
        if (WorkoutPlan.dateOnly(c.completedAt) == day) total += c.calories;
      }
      return total;
    });
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
    final totals = monthlyCompletedVsPlanned(plans, completions, now);
    if (totals.planned == 0) return 0;
    return (totals.completed / totals.planned * 100).clamp(0, 100);
  }

  static ({int completed, int planned}) monthlyCompletedVsPlanned(
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

    final completionDaysInMonth = <DateTime>{};
    var completionCount = 0;
    for (final c in completions) {
      if (!completionMatchesPlans(c, plans)) continue;
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
    return (completed: completionCount + extraPlanHits, planned: planned);
  }

  static int monthlyCompletedSessions(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
    DateTime now,
  ) {
    return monthlyCompletedVsPlanned(plans, completions, now).completed;
  }

  static int upcomingPlannedWorkouts(List<WorkoutPlan> plans, DateTime now) {
    final today = WorkoutPlan.dateOnly(now);
    return plans.where((p) {
      if (p.status != PlanStatus.planned) return false;
      return !WorkoutPlan.dateOnly(p.scheduledDate).isBefore(today);
    }).length;
  }

  static List<WorkoutCompletion> relevantCompletions(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
  ) {
    return completions.where((c) => completionMatchesPlans(c, plans)).toList();
  }

  static String mostTrainedMuscleGroup(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
  ) {
    final counts = <String, int>{};
    for (final c in relevantCompletions(plans, completions)) {
      counts[c.workoutType] = (counts[c.workoutType] ?? 0) + 1;
    }
    if (counts.isEmpty) return '—';
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  static int averageWorkoutDuration(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
  ) {
    final relevant = relevantCompletions(plans, completions);
    if (relevant.isEmpty) return 0;
    final total = relevant.fold<int>(0, (sum, c) => sum + c.durationMinutes);
    return (total / relevant.length).round();
  }

  static int averageSessionCalories(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
  ) {
    final relevant = relevantCompletions(plans, completions);
    if (relevant.isEmpty) return 0;
    final total = relevant.fold<int>(0, (sum, c) => sum + c.calories);
    return (total / relevant.length).round();
  }

  static StrengthVolumeStats weeklyStrengthVolume(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
    DateTime reference,
  ) {
    final mon = WorkoutPlan.mondayContaining(reference);
    final end = mon.add(const Duration(days: 7));
    var sets = 0;
    var reps = 0;
    for (final c in relevantCompletions(plans, completions)) {
      final d = WorkoutPlan.dateOnly(c.completedAt);
      if (d.isBefore(mon) || !d.isBefore(end)) continue;
      for (final log in c.exerciseLogs) {
        sets += log.setsCompleted;
        reps += log.setsCompleted * log.repsCompleted;
      }
    }
    return StrengthVolumeStats(
      sets: sets,
      reps: reps,
      estimatedVolume: reps * 38,
    );
  }

  static List<MuscleGroupShare> muscleGroupDistribution(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
  ) {
    final counts = <String, int>{};
    for (final c in relevantCompletions(plans, completions)) {
      counts[c.workoutType] = (counts[c.workoutType] ?? 0) + 1;
    }
    if (counts.isEmpty) return const [];

    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    var assigned = 0;
    final shares = <MuscleGroupShare>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final percent = i == entries.length - 1
          ? (100 - assigned).clamp(0, 100)
          : ((entry.value / total) * 100).round();
      assigned += percent;
      shares.add(MuscleGroupShare(label: entry.key, percent: percent));
    }
    return shares;
  }
}
