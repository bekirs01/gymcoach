import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/training_stats.dart';
import '../../history/presentation/completed_workout_detail_page.dart';
import '../../plans/domain/workout_plan.dart';
import '../../workout/domain/workout_completion.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({
    super.key,
    required this.plans,
    required this.completions,
    this.onOpenStreak,
  });

  final List<WorkoutPlan> plans;
  final List<WorkoutCompletion> completions;
  final VoidCallback? onOpenStreak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final days = TrainingStats.completedDays(plans, completions);
    final streak = TrainingStats.currentStreak(days, now);
    final weekly = TrainingStats.weeklyWorkoutsCompleted(completions, now);
    final monthTotal = _monthlyCompletionRatio(plans, completions, now);
    final theme = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.progressTitle,
              style: theme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.progressSubtitle,
              style: theme.bodyMedium?.copyWith(color: AppColors.textMuted, height: 1.35),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: l10n.progressWeeklySessions,
                    value: '$weekly',
                    icon: Icons.fitness_center_rounded,
                    onTap: null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: l10n.progressActiveStreak,
                    value: l10n.progressStreakDays(streak),
                    icon: Icons.local_fire_department_rounded,
                    onTap: onOpenStreak,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _StatCard(
              label: l10n.progressMonthlyConsistency,
              value: '${monthTotal.round()}%',
              subtitle: l10n.progressMonthlyHint,
              icon: Icons.auto_graph_rounded,
              onTap: null,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.progressWeeklyVolume,
              style: theme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _WeeklyBars(
              completions: completions,
              plans: plans,
              reference: now,
              l10n: l10n,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.progressAchievements,
              style: theme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _BadgesRow(
              l10n: l10n,
              completedWorkouts: plans.where((p) => p.status == PlanStatus.completed).length + completions.length,
              streak: streak,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.progressPersonalRecords,
              style: theme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                _PersonalRecordTile(lift: l10n.prBackSquat, value: l10n.prMockSquatValue, dateLabel: l10n.prMockSquatDate),
                const SizedBox(height: 10),
                _PersonalRecordTile(lift: l10n.pr5kRun, value: l10n.prMock5kValue, dateLabel: l10n.prMock5kDate),
                const SizedBox(height: 10),
                _PersonalRecordTile(lift: l10n.prPullUps, value: l10n.prMockPullValue, dateLabel: l10n.prMockPullDate),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.progressWorkoutHistory,
              style: theme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          sliver: SliverToBoxAdapter(
            child: _HistoryList(completions: completions),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ),
      ],
    );
  }

  static double _monthlyCompletionRatio(
    List<WorkoutPlan> plans,
    List<WorkoutCompletion> completions,
    DateTime now,
  ) {
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    var planned = 0;
    var done = 0;
    for (final p in plans) {
      final d = WorkoutPlan.dateOnly(p.scheduledDate);
      if (d.isBefore(start) || !d.isBefore(end)) continue;
      planned++;
      if (p.status == PlanStatus.completed) done++;
    }
    done += completions.where((c) {
      final d = WorkoutPlan.dateOnly(c.completedAt);
      return !d.isBefore(start) && d.isBefore(end);
    }).length;
    if (planned == 0) return 72;
    return (done / planned * 100).clamp(20, 100);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final card = Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(label, style: theme.labelSmall?.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: theme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: card,
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({
    required this.completions,
    required this.plans,
    required this.reference,
    required this.l10n,
  });

  final List<WorkoutCompletion> completions;
  final List<WorkoutPlan> plans;
  final DateTime reference;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final mon = WorkoutPlan.mondayContaining(reference);
    final theme = Theme.of(context).textTheme;
    final values = List<double>.generate(7, (i) {
      final day = mon.add(Duration(days: i));
      var score = 0.0;
      for (final c in completions) {
        if (WorkoutPlan.isSameDay(c.completedAt, day)) score += 1;
      }
      for (final p in plans) {
        if (p.status == PlanStatus.completed && WorkoutPlan.isSameDay(p.scheduledDate, day)) {
          score += 1;
        }
      }
      return score.clamp(0, 3).toDouble();
    });
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final norm = maxV <= 0 ? 1.0 : maxV;

    final labels = [
      l10n.progressWeeklyBarsDow1,
      l10n.progressWeeklyBarsDow2,
      l10n.progressWeeklyBarsDow3,
      l10n.progressWeeklyBarsDow4,
      l10n.progressWeeklyBarsDow5,
      l10n.progressWeeklyBarsDow6,
      l10n.progressWeeklyBarsDow7,
    ];

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < 7; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: 24 + (values[i] / norm) * 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppColors.heroGradientStart, AppColors.heroGradientEnd],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[i],
                      style: theme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BadgesRow extends StatelessWidget {
  const _BadgesRow({
    required this.l10n,
    required this.completedWorkouts,
    required this.streak,
  });

  final AppLocalizations l10n;
  final int completedWorkouts;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final items = [
      (l10n.badgeFirstSession, completedWorkouts >= 1, Icons.flag_rounded),
      (l10n.badgeWeekWarrior, completedWorkouts >= 5, Icons.military_tech_rounded),
      (l10n.badgeStreakStarter, streak >= 3, Icons.bolt_rounded),
      (l10n.badgeConsistency, streak >= 7, Icons.emoji_events_outlined),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((e) {
        final unlocked = e.$2;
        return Opacity(
          opacity: unlocked ? 1 : 0.45,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(e.$3, color: unlocked ? AppColors.primary : AppColors.textMuted, size: 20),
                const SizedBox(width: 8),
                Text(
                  e.$1,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PersonalRecordTile extends StatelessWidget {
  const _PersonalRecordTile({
    required this.lift,
    required this.value,
    required this.dateLabel,
  });

  final String lift;
  final String value;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: ListTile(
        title: Text(lift, style: theme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text(dateLabel, style: theme.bodySmall?.copyWith(color: AppColors.textMuted)),
        trailing: Text(
          value,
          style: theme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.completions});

  final List<WorkoutCompletion> completions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (completions.isEmpty) {
      return Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.progressHistoryEmpty,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final sorted = List<WorkoutCompletion>.from(completions)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          for (var i = 0; i < sorted.length; i++) ...[
            ListTile(
              title: Text(
                sorted[i].title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
              subtitle: Text(
                '${sorted[i].workoutType} · ${l10n.minutesShort(sorted[i].durationMinutes)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => CompletedWorkoutDetailPage(completion: sorted[i]),
                  ),
                );
              },
            ),
            if (i < sorted.length - 1) const Divider(height: 1, indent: 16, color: AppColors.borderSubtle),
          ],
        ],
      ),
    );
  }
}
