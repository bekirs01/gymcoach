import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/premium_background.dart';
import '../../../core/training_stats.dart';
import '../../plans/domain/workout_plan.dart';
import '../../workout/domain/workout_completion.dart';

const _flameAccent = Color(0xFFFF8A50);
const _flameAccentSoft = Color(0x33FF8A50);

class StreakDetailPage extends StatelessWidget {
  const StreakDetailPage({
    super.key,
    required this.plans,
    required this.completions,
    this.onOpenProgress,
  });

  final List<WorkoutPlan> plans;
  final List<WorkoutCompletion> completions;
  final VoidCallback? onOpenProgress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final completedDays = TrainingStats.completedDays(plans, completions);
    final streak = TrainingStats.currentStreak(completedDays, now);
    final bestStreak = _StreakMetrics.bestStreak(completedDays);
    final weeklySessions = TrainingStats.weeklySessionsCompleted(plans, completions, now);
    final weeklyCompletion = _StreakMetrics.weeklyCompletionPercent(plans, completions, now);
    final activeDaysMonth = _StreakMetrics.activeDaysThisMonth(completedDays, now);
    final nextMilestone = _StreakMetrics.nextMilestone(streak);
    final recentEntries = _StreakMetrics.recentTrainingEntries(plans, completions);
    final lastWorkout = recentEntries.isEmpty ? null : recentEntries.first.date;
    final weekDays = _StreakMetrics.weekDayStates(completedDays, now);
    final dateFormat = DateFormat.MMMd(Localizations.localeOf(context).toString());
    final statusText = streak > 0 ? l10n.streakBuildingMomentum : l10n.streakTrainTodayStart;
    final thisWeekLabel = weeklySessions == 1
        ? l10n.streakWorkoutsThisWeek(weeklySessions)
        : l10n.streakWorkoutsThisWeekPlural(weeklySessions);

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: Text(
            l10n.streakDetailsTitle,
            style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.streakDetailsSubtitle,
                  style: const TextStyle(
                    color: PremiumColors.textSecondary,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _StreakHeroCard(
                  streak: streak,
                  statusText: statusText,
                  bestStreakLabel: l10n.streakBestStreak,
                  bestStreakValue: l10n.streakDaysShort(bestStreak),
                  thisWeekLabel: l10n.streakThisWeekSessions,
                  thisWeekValue: thisWeekLabel,
                  lastWorkoutLabel: l10n.streakLastWorkout,
                  lastWorkoutValue: lastWorkout == null
                      ? l10n.streakNoLastWorkout
                      : dateFormat.format(lastWorkout),
                  streakTitle: l10n.streakDayStreak(streak),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _StreakStatCard(
                        label: l10n.streakBestStreak,
                        value: l10n.streakDaysShort(bestStreak),
                        icon: Icons.emoji_events_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StreakStatCard(
                        label: l10n.streakActiveDays,
                        value: '$activeDaysMonth',
                        icon: Icons.calendar_today_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _StreakStatCard(
                        label: l10n.streakWeeklyCompletion,
                        value: l10n.streakCompletionPercent(weeklyCompletion),
                        icon: Icons.insights_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StreakStatCard(
                        label: l10n.streakNextMilestone,
                        value: l10n.streakMilestoneDays(nextMilestone),
                        icon: Icons.flag_rounded,
                        accentFlame: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.streakThisWeekSection,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                _WeeklyConsistencyRow(
                  dayLabels: [
                    l10n.progressWeeklyBarsDow1,
                    l10n.progressWeeklyBarsDow2,
                    l10n.progressWeeklyBarsDow3,
                    l10n.progressWeeklyBarsDow4,
                    l10n.progressWeeklyBarsDow5,
                    l10n.progressWeeklyBarsDow6,
                    l10n.progressWeeklyBarsDow7,
                  ],
                  weekDays: weekDays,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.streakRecentDays,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                _RecentTrainingList(
                  entries: recentEntries,
                  emptyTitle: l10n.streakEmpty,
                  emptyHint: l10n.streakEmptyHint,
                  dateFormat: dateFormat,
                  minutesLabel: (m) => l10n.minutesShort(m),
                ),
                const SizedBox(height: AppSpacing.lg),
                _StreakTipsCard(
                  title: l10n.homeStreakTitle,
                  tips: [
                    l10n.streakTipShortSession,
                    l10n.streakTipSchedule,
                    l10n.streakTipConsistency,
                  ],
                ),
                if (onOpenProgress != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onOpenProgress,
                      style: FilledButton.styleFrom(
                        backgroundColor: PremiumColors.accentBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(PremiumRadii.lg),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.streakViewProgress,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StreakHeroCard extends StatelessWidget {
  const _StreakHeroCard({
    required this.streak,
    required this.statusText,
    required this.bestStreakLabel,
    required this.bestStreakValue,
    required this.thisWeekLabel,
    required this.thisWeekValue,
    required this.lastWorkoutLabel,
    required this.lastWorkoutValue,
    required this.streakTitle,
  });

  final int streak;
  final String statusText;
  final String bestStreakLabel;
  final String bestStreakValue;
  final String thisWeekLabel;
  final String thisWeekValue;
  final String lastWorkoutLabel;
  final String lastWorkoutValue;
  final String streakTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PremiumRadii.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumColors.surfaceRaised,
            PremiumColors.surfaceRaised.withValues(alpha: 0.92),
            const Color(0xFF1E2430),
          ],
        ),
        border: Border.all(color: _flameAccent.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: _flameAccent.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _flameAccentSoft,
                  borderRadius: BorderRadius.circular(PremiumRadii.md),
                  border: Border.all(color: _flameAccent.withValues(alpha: 0.35)),
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: streak > 0 ? _flameAccent : PremiumColors.textMuted,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      streakTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      statusText,
                      style: const TextStyle(
                        color: PremiumColors.textSecondary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: PremiumColors.surface.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(PremiumRadii.lg),
              border: Border.all(color: PremiumColors.glassBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _HeroMetric(label: bestStreakLabel, value: bestStreakValue),
                ),
                _metricDivider(),
                Expanded(
                  child: _HeroMetric(label: thisWeekLabel, value: thisWeekValue),
                ),
                _metricDivider(),
                Expanded(
                  child: _HeroMetric(label: lastWorkoutLabel, value: lastWorkoutValue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricDivider() {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: PremiumColors.glassBorder,
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: PremiumColors.textMuted,
            fontSize: 11,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _StreakStatCard extends StatelessWidget {
  const _StreakStatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.accentFlame = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool accentFlame;

  @override
  Widget build(BuildContext context) {
    final iconColor = accentFlame ? _flameAccent : PremiumColors.accentBlue;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: PremiumColors.textMuted,
              fontSize: 12,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyConsistencyRow extends StatelessWidget {
  const _WeeklyConsistencyRow({
    required this.dayLabels,
    required this.weekDays,
  });

  final List<String> dayLabels;
  final List<_WeekDayState> weekDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Row(
        children: List.generate(7, (index) {
          final state = weekDays[index];
          return Expanded(
            child: _WeekDayPill(
              label: dayLabels[index],
              completed: state.completed,
              isToday: state.isToday,
            ),
          );
        }),
      ),
    );
  }
}

class _WeekDayPill extends StatelessWidget {
  const _WeekDayPill({
    required this.label,
    required this.completed,
    required this.isToday,
  });

  final String label;
  final bool completed;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final fillColor = completed
        ? _flameAccent.withValues(alpha: isToday ? 0.28 : 0.18)
        : PremiumColors.surfaceRaised.withValues(alpha: 0.5);
    final borderColor = isToday
        ? PremiumColors.accentBlue.withValues(alpha: 0.7)
        : completed
            ? _flameAccent.withValues(alpha: 0.4)
            : PremiumColors.glassBorder;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isToday ? PremiumColors.accentBlue : PremiumColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(PremiumRadii.sm),
            border: Border.all(color: borderColor, width: isToday ? 1.5 : 1),
          ),
          child: Icon(
            completed ? Icons.check_rounded : Icons.remove_rounded,
            size: completed ? 18 : 16,
            color: completed
                ? (isToday ? _flameAccent : PremiumColors.successGreen)
                : PremiumColors.textMuted.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

class _RecentTrainingList extends StatelessWidget {
  const _RecentTrainingList({
    required this.entries,
    required this.emptyTitle,
    required this.emptyHint,
    required this.dateFormat,
    required this.minutesLabel,
  });

  final List<_RecentTrainingEntry> entries;
  final String emptyTitle;
  final String emptyHint;
  final DateFormat dateFormat;
  final String Function(int minutes) minutesLabel;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: PremiumColors.surface,
          borderRadius: BorderRadius.circular(PremiumRadii.lg),
          border: Border.all(color: PremiumColors.glassBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _flameAccentSoft,
                borderRadius: BorderRadius.circular(PremiumRadii.sm),
              ),
              child: const Icon(Icons.local_fire_department_outlined, color: _flameAccent, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              emptyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              emptyHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: PremiumColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: PremiumColors.glassBorder.withValues(alpha: 0.8),
                indent: 56,
              ),
            _RecentTrainingRow(
              entry: entries[i],
              dateFormat: dateFormat,
              minutesLabel: minutesLabel,
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentTrainingRow extends StatelessWidget {
  const _RecentTrainingRow({
    required this.entry,
    required this.dateFormat,
    required this.minutesLabel,
  });

  final _RecentTrainingEntry entry;
  final DateFormat dateFormat;
  final String Function(int minutes) minutesLabel;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[entry.title];
    if (entry.durationMinutes > 0) {
      subtitleParts.add(minutesLabel(entry.durationMinutes));
    }
    if (entry.calories > 0) {
      subtitleParts.add('${entry.calories} kcal');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _flameAccentSoft,
              borderRadius: BorderRadius.circular(PremiumRadii.sm),
            ),
            child: const Icon(Icons.local_fire_department_rounded, color: _flameAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(entry.date),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitleParts.join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PremiumColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: PremiumColors.textMuted, size: 20),
        ],
      ),
    );
  }
}

class _StreakTipsCard extends StatelessWidget {
  const _StreakTipsCard({required this.title, required this.tips});

  final String title;
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: PremiumColors.accentBlue.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(PremiumRadii.sm),
                ),
                child: const Icon(Icons.lightbulb_outline_rounded, color: PremiumColors.accentBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final tip in tips) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 10),
                    decoration: const BoxDecoration(
                      color: PremiumColors.accentBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        color: PremiumColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeekDayState {
  const _WeekDayState({required this.completed, required this.isToday});

  final bool completed;
  final bool isToday;
}

class _RecentTrainingEntry {
  const _RecentTrainingEntry({
    required this.date,
    required this.title,
    required this.durationMinutes,
    required this.calories,
  });

  final DateTime date;
  final String title;
  final int durationMinutes;
  final int calories;
}

abstract final class _StreakMetrics {
  static int bestStreak(Set<DateTime> completedDays) {
    if (completedDays.isEmpty) return 0;
    final sorted = completedDays.toList()..sort();
    var best = 1;
    var current = 1;
    for (var i = 1; i < sorted.length; i++) {
      final gap = sorted[i].difference(sorted[i - 1]).inDays;
      if (gap == 1) {
        current++;
        if (current > best) best = current;
      } else if (gap > 1) {
        current = 1;
      }
    }
    return best;
  }

  static int nextMilestone(int currentStreak) {
    const milestones = [3, 7, 14, 30, 60, 100];
    for (final milestone in milestones) {
      if (currentStreak < milestone) return milestone;
    }
    return currentStreak + 10;
  }

  static int activeDaysThisMonth(Set<DateTime> completedDays, DateTime now) {
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    var count = 0;
    for (final day in completedDays) {
      if (!day.isBefore(start) && day.isBefore(end)) count++;
    }
    return count;
  }

  static int weeklyCompletionPercent(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
    DateTime now,
  ) {
    final completed = TrainingStats.weeklySessionsCompleted(plans, completions, now);
    final mon = WorkoutPlan.mondayContaining(now);
    final sun = mon.add(const Duration(days: 7));
    var planned = 0;
    for (final plan in plans) {
      final day = WorkoutPlan.dateOnly(plan.scheduledDate);
      if (day.isBefore(mon) || !day.isBefore(sun)) continue;
      planned++;
    }
    final target = planned > 0 ? planned : 4;
    return ((completed / target) * 100).round().clamp(0, 100);
  }

  static List<_WeekDayState> weekDayStates(Set<DateTime> completedDays, DateTime now) {
    final mon = WorkoutPlan.mondayContaining(now);
    final today = WorkoutPlan.dateOnly(now);
    return List.generate(7, (index) {
      final day = WorkoutPlan.dateOnly(mon.add(Duration(days: index)));
      return _WeekDayState(
        completed: completedDays.contains(day),
        isToday: day == today,
      );
    });
  }

  static List<_RecentTrainingEntry> recentTrainingEntries(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
  ) {
    final byDay = <DateTime, _RecentTrainingEntry>{};

    final sortedCompletions = completions
        .where((c) => TrainingStats.completionMatchesPlans(c, plans))
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    for (final completion in sortedCompletions) {
      final day = WorkoutPlan.dateOnly(completion.completedAt);
      byDay.putIfAbsent(
        day,
        () => _RecentTrainingEntry(
          date: day,
          title: completion.title,
          durationMinutes: completion.durationMinutes,
          calories: completion.calories,
        ),
      );
    }

    for (final plan in plans) {
      if (plan.status != PlanStatus.completed) continue;
      final day = WorkoutPlan.dateOnly(plan.scheduledDate);
      byDay.putIfAbsent(
        day,
        () => _RecentTrainingEntry(
          date: day,
          title: plan.name,
          durationMinutes: plan.durationMinutes,
          calories: 0,
        ),
      );
    }

    final sorted = byDay.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(14).toList();
  }
}
