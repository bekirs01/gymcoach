import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/floating_tab_bar.dart';
import '../../../app/widgets/premium_background.dart';
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
    final weeklySessions = TrainingStats.weeklySessionsCompleted(plans, completions, now);
    final monthPct = TrainingStats.monthlyConsistencyPercent(plans, completions, now);
    final monthTotals = TrainingStats.monthlyCompletedVsPlanned(plans, completions, now);
    final monthSessions = TrainingStats.monthlyCompletedSessions(plans, completions, now);
    final upcoming = TrainingStats.upcomingPlannedWorkouts(plans, now);
    final totalSessions = TrainingStats.totalCompletedSessions(plans, completions);
    final weeklyMinutes = TrainingStats.weeklyTrainingMinutes(plans, completions, now);
    final weeklyCalories = TrainingStats.weeklyCalories(plans, completions, now);
    final dailyCalories = TrainingStats.weeklyCaloriesByDay(plans, completions, now);
    final dailySessions = TrainingStats.weeklySessionCounts(plans, completions, now);
    final strengthVolume = TrainingStats.weeklyStrengthVolume(plans, completions, now);
    final muscleShares = TrainingStats.muscleGroupDistribution(plans, completions);
    final relevant = TrainingStats.relevantCompletions(plans, completions);
    final bottomPad = FloatingTabBar.reservedBottomSpace(context) + AppSpacing.xl;
    final topPad = MediaQuery.viewPaddingOf(context).top;
    final dayLabels = _weekdayLabels(l10n);

    return PremiumBackground(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(AppSpacing.md, topPad + AppSpacing.sm, AppSpacing.md, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.progressTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.progressSubtitle,
                    style: const TextStyle(color: PremiumColors.textSecondary, height: 1.35),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.fitness_center_rounded,
                      label: l10n.progressWeeklySessions,
                      value: '$weeklySessions',
                      statusLabel: weeklySessions >= 4 ? l10n.progressStatusStrong : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.local_fire_department_rounded,
                      label: l10n.progressActiveStreak,
                      value: l10n.progressStreakDays(streak),
                      statusLabel: streak >= 3 ? l10n.progressStatusHot : null,
                      onTap: onOpenStreak,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 10, AppSpacing.md, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.emoji_events_outlined,
                      label: l10n.progressTotalSessions,
                      value: '$totalSessions',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.timer_outlined,
                      label: l10n.progressWeeklyMinutes,
                      value: l10n.minutesShort(weeklyMinutes),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
            sliver: SliverToBoxAdapter(
              child: _MonthlyConsistencyCard(
                l10n: l10n,
                percent: monthPct.round(),
                monthSessions: monthSessions,
                upcoming: upcoming,
                completed: monthTotals.completed,
                planned: monthTotals.planned,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
            sliver: SliverToBoxAdapter(
              child: _WeeklyBarChartCard(
                title: l10n.progressWeekActivity,
                subtitle: l10n.progressWeekActivityHint,
                trailing: l10n.sessionCaloriesUnit(weeklyCalories),
                values: dailyCalories,
                labels: dayLabels,
                barColor: PremiumColors.accentBlue,
                valueColor: PremiumColors.accentBlue,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
            sliver: SliverToBoxAdapter(
              child: _WeeklyBarChartCard(
                title: l10n.progressSessionsByDay,
                subtitle: l10n.progressSessionsByDayHint,
                trailing: '$weeklySessions',
                values: dailySessions,
                labels: dayLabels,
                barColor: const Color(0xFF5BBFB8),
                valueColor: Colors.white,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
            sliver: SliverToBoxAdapter(
              child: _PerformanceInsightsCard(
                l10n: l10n,
                mostTrained: TrainingStats.mostTrainedMuscleGroup(plans, completions),
                avgDuration: TrainingStats.averageWorkoutDuration(plans, completions),
                avgCalories: TrainingStats.averageSessionCalories(plans, completions),
                completionRate: monthPct.round(),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
            sliver: SliverToBoxAdapter(
              child: _StrengthVolumeCard(l10n: l10n, stats: strengthVolume),
            ),
          ),
          if (muscleShares.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
              sliver: SliverToBoxAdapter(
                child: _MuscleDistributionCard(l10n: l10n, shares: muscleShares),
              ),
            ),
          if (relevant.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.progressSessionHighlights,
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    _SessionHighlightsSection(completions: relevant, l10n: l10n),
                  ],
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.progressAchievements,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 10, AppSpacing.md, 0),
            sliver: SliverToBoxAdapter(
              child: _AchievementsGrid(
                l10n: l10n,
                completedWorkouts: totalSessions,
                streak: streak,
                monthSessions: monthSessions,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.progressWorkoutHistory,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(AppSpacing.md, 10, AppSpacing.md, bottomPad),
            sliver: SliverToBoxAdapter(
              child: _HistoryList(completions: relevant, plans: plans),
            ),
          ),
        ],
      ),
    );
  }

  static List<String> _weekdayLabels(AppLocalizations l10n) {
    return [
      l10n.progressWeeklyBarsDow1,
      l10n.progressWeeklyBarsDow2,
      l10n.progressWeeklyBarsDow3,
      l10n.progressWeeklyBarsDow4,
      l10n.progressWeeklyBarsDow5,
      l10n.progressWeeklyBarsDow6,
      l10n.progressWeeklyBarsDow7,
    ];
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    this.statusLabel,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? statusLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(14),
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: PremiumColors.accentBlue.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: PremiumColors.accentBlue, size: 18),
              ),
              const Spacer(),
              if (statusLabel != null) _StatusPill(label: statusLabel!),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: PremiumColors.textMuted, fontSize: 11, height: 1.25),
          ),
        ],
      ),
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PremiumColors.successGreen.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(PremiumRadii.pill),
        border: Border.all(color: PremiumColors.successGreen.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_upward_rounded, size: 11, color: PremiumColors.successGreen),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              color: PremiumColors.successGreen,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyConsistencyCard extends StatelessWidget {
  const _MonthlyConsistencyCard({
    required this.l10n,
    required this.percent,
    required this.monthSessions,
    required this.upcoming,
    required this.completed,
    required this.planned,
  });

  final AppLocalizations l10n;
  final int percent;
  final int monthSessions;
  final int upcoming;
  final int completed;
  final int planned;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.progressMonthlyConsistency,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.progressMonthlyHint,
            style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: (percent / 100).clamp(0.0, 1.0),
                      strokeWidth: 8,
                      backgroundColor: PremiumColors.surfaceRaised,
                      color: PremiumColors.accentBlue,
                    ),
                    Center(
                      child: Text(
                        '$percent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryBlock(
                            value: '$monthSessions',
                            label: l10n.progressMonthSessions,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryBlock(
                            value: '$upcoming',
                            label: l10n.progressPlannedUpcoming,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _SummaryBlock(
                      value: l10n.progressCompletedVsPlanned(completed, planned),
                      label: '',
                      compact: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({
    required this.value,
    required this.label,
    this.compact = false,
  });

  final String value;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 10 : 12),
      decoration: BoxDecoration(
        color: PremiumColors.surfaceRaised,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 13 : 16,
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: PremiumColors.textMuted, fontSize: 11, height: 1.2),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeeklyBarChartCard extends StatelessWidget {
  const _WeeklyBarChartCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.values,
    required this.labels,
    required this.barColor,
    required this.valueColor,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final List<int> values;
  final List<String> labels;
  final Color barColor;
  final Color valueColor;

  static const _chartHeight = 152.0;
  static const _valueBand = 18.0;
  static const _labelBand = 16.0;
  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    final maxV = values.fold<int>(0, (a, b) => a > b ? a : b);
    final norm = maxV <= 0 ? 1.0 : maxV.toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              Text(
                trailing,
                style: const TextStyle(
                  color: PremiumColors.accentBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12)),
          const SizedBox(height: 14),
          SizedBox(
            height: _chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final barMax = constraints.maxHeight - _valueBand - _labelBand - (_gap * 2);
                        final barHeight = values[i] <= 0 ? 6.0 : math.max(10.0, (values[i] / norm) * barMax);
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: _valueBand,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: values[i] > 0
                                    ? Text(
                                        '${values[i]}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: valueColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                            SizedBox(height: _gap),
                            Container(
                              height: barHeight.clamp(6.0, barMax),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: values[i] > 0 ? barColor : PremiumColors.surfaceRaised,
                              ),
                            ),
                            SizedBox(height: _gap),
                            SizedBox(
                              height: _labelBand,
                              child: Center(
                                child: Text(
                                  labels[i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: PremiumColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceInsightsCard extends StatelessWidget {
  const _PerformanceInsightsCard({
    required this.l10n,
    required this.mostTrained,
    required this.avgDuration,
    required this.avgCalories,
    required this.completionRate,
  });

  final AppLocalizations l10n;
  final String mostTrained;
  final int avgDuration;
  final int avgCalories;
  final int completionRate;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (Icons.fitness_center_rounded, l10n.progressMostTrainedGroup, mostTrained),
      (Icons.schedule_rounded, l10n.progressAvgDuration, l10n.minutesShort(avgDuration)),
      (Icons.local_fire_department_outlined, l10n.progressAvgCalories, l10n.sessionCaloriesUnit(avgCalories)),
      (Icons.check_circle_outline_rounded, l10n.progressCompletionRate, '$completionRate%'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.progressPerformanceInsights,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.progressPerformanceInsightsHint,
            style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < rows.length; i++) ...[
            _InsightRow(icon: rows[i].$1, label: rows[i].$2, value: rows[i].$3),
            if (i < rows.length - 1)
              Divider(height: 1, color: PremiumColors.glassBorder, indent: 36),
          ],
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: PremiumColors.accentBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: PremiumColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _StrengthVolumeCard extends StatelessWidget {
  const _StrengthVolumeCard({required this.l10n, required this.stats});

  final AppLocalizations l10n;
  final StrengthVolumeStats stats;

  @override
  Widget build(BuildContext context) {
    final volumeLabel = stats.estimatedVolume >= 1000
        ? l10n.progressVolumeK((stats.estimatedVolume / 1000).toStringAsFixed(1))
        : '${stats.estimatedVolume}';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.progressStrengthVolume,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _VolumeTile(label: l10n.progressSetsThisWeek, value: '${stats.sets}')),
              const SizedBox(width: 8),
              Expanded(child: _VolumeTile(label: l10n.progressRepsThisWeek, value: '${stats.reps}')),
              const SizedBox(width: 8),
              Expanded(child: _VolumeTile(label: l10n.progressEstVolume, value: volumeLabel)),
            ],
          ),
        ],
      ),
    );
  }
}

class _VolumeTile extends StatelessWidget {
  const _VolumeTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: PremiumColors.surfaceRaised,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: PremiumColors.textMuted, fontSize: 10, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _MuscleDistributionCard extends StatelessWidget {
  const _MuscleDistributionCard({required this.l10n, required this.shares});

  final AppLocalizations l10n;
  final List<MuscleGroupShare> shares;

  static const _palette = [
    Color(0xFF6BBF8A),
    Color(0xFFB8733A),
    Color(0xFF9B7FD4),
    Color(0xFFD48AA8),
    Color(0xFF6B8FC7),
    Color(0xFF5BBFB8),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.progressMuscleDistribution,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.progressMuscleDistributionHint,
            style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 92,
                height: 92,
                child: CustomPaint(
                  painter: _SegmentedDonutPainter(
                    segments: shares,
                    colors: _palette,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < shares.length; i++)
                      Padding(
                        padding: EdgeInsets.only(bottom: i == shares.length - 1 ? 0 : 8),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _palette[i % _palette.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                shares[i].label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: PremiumColors.textSecondary, fontSize: 12),
                              ),
                            ),
                            Text(
                              '${shares[i].percent}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentedDonutPainter extends CustomPainter {
  _SegmentedDonutPainter({required this.segments, required this.colors});

  final List<MuscleGroupShare> segments;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = 10.0;
    var start = -math.pi / 2;
    for (var i = 0; i < segments.length; i++) {
      final sweep = (segments[i].percent / 100) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect.deflate(stroke / 2), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentedDonutPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}

class _SessionHighlightsSection extends StatelessWidget {
  const _SessionHighlightsSection({required this.completions, required this.l10n});

  final List<WorkoutCompletion> completions;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    WorkoutCompletion longest = completions.first;
    WorkoutCompletion peakCal = completions.first;
    WorkoutCompletion mostIntense = completions.first;
    WorkoutCompletion latest = completions.first;

    for (final c in completions) {
      if (c.durationMinutes > longest.durationMinutes) longest = c;
      if (c.calories > peakCal.calories) peakCal = c;
      if (_intensityScore(c) > _intensityScore(mostIntense)) mostIntense = c;
      if (c.completedAt.isAfter(latest.completedAt)) latest = c;
    }

    final fmt = DateFormat.yMMMd(l10n.localeName);
    final items = [
      (l10n.progressHighlightLongest, longest.title, l10n.minutesShort(longest.durationMinutes)),
      (l10n.progressHighlightCalories, peakCal.title, l10n.sessionCaloriesUnit(peakCal.calories)),
      (l10n.progressHighlightIntense, mostIntense.title, mostIntense.workoutType),
      (l10n.progressHighlightLatest, latest.title, fmt.format(latest.completedAt)),
    ];

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _HighlightCard(label: items[i].$1, title: items[i].$2, value: items[i].$3),
          if (i < items.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  static int _intensityScore(WorkoutCompletion completion) {
    return completion.exerciseLogs.fold<int>(
      0,
      (sum, log) => sum + (log.setsCompleted * log.repsCompleted),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.label,
    required this.title,
    required this.value,
  });

  final String label;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: PremiumColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: PremiumColors.accentBlue, fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  const _AchievementsGrid({
    required this.l10n,
    required this.completedWorkouts,
    required this.streak,
    required this.monthSessions,
  });

  final AppLocalizations l10n;
  final int completedWorkouts;
  final int streak;
  final int monthSessions;

  @override
  Widget build(BuildContext context) {
    final items = [
      (l10n.badgeFirstSession, completedWorkouts >= 1, Icons.flag_rounded),
      (l10n.badgeThreeDayStreak, streak >= 3, Icons.bolt_rounded),
      (l10n.badgeFiveSessions, completedWorkouts >= 5, Icons.star_rounded),
      (l10n.badgeWeeklyWarrior, completedWorkouts >= 5, Icons.military_tech_rounded),
      (l10n.badgeConsistencyBadge, streak >= 7, Icons.emoji_events_outlined),
      (l10n.badgeMonthlyGrind, monthSessions >= 10, Icons.calendar_month_rounded),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.55,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final unlocked = item.$2;
        return Opacity(
          opacity: unlocked ? 1 : 0.42,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: unlocked
                  ? PremiumColors.accentBlue.withValues(alpha: 0.12)
                  : PremiumColors.surface,
              borderRadius: BorderRadius.circular(PremiumRadii.md),
              border: Border.all(
                color: unlocked
                    ? PremiumColors.accentBlue.withValues(alpha: 0.35)
                    : PremiumColors.glassBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  item.$3,
                  color: unlocked ? PremiumColors.accentBlue : PremiumColors.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.$1,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unlocked ? Colors.white : PremiumColors.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.completions, required this.plans});

  final List<WorkoutCompletion> completions;
  final List<WorkoutPlan> plans;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (completions.isEmpty) {
      return const SizedBox.shrink();
    }

    final sorted = List<WorkoutCompletion>.from(completions)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    final dateFmt = DateFormat.MMMd(l10n.localeName);

    return Container(
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < sorted.length && i < 12; i++) ...[
            InkWell(
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => CompletedWorkoutDetailPage(completion: sorted[i]),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sorted[i].title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _CategoryPill(label: sorted[i].workoutType),
                              Text(
                                '${dateFmt.format(sorted[i].completedAt)} · ${l10n.minutesShort(sorted[i].durationMinutes)} · ${l10n.sessionCaloriesUnit(sorted[i].calories)}',
                                style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: PremiumColors.successGreen.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(PremiumRadii.pill),
                        border: Border.all(color: PremiumColors.successGreen.withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        l10n.progressCompleted,
                        style: const TextStyle(
                          color: PremiumColors.successGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i < sorted.length - 1 && i < 11)
              Divider(height: 1, color: PremiumColors.glassBorder, indent: 14, endIndent: 14),
          ],
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _focusColor(label).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(PremiumRadii.pill),
        border: Border.all(color: _focusColor(label).withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _focusColor(label),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static Color _focusColor(String focus) {
    switch (focus) {
      case 'Chest':
        return PremiumColors.accentBlue;
      case 'Back':
        return PremiumColors.successGreen;
      case 'Legs':
        return PremiumColors.bannerOrange;
      case 'Shoulders':
        return const Color(0xFF9B7FD4);
      case 'Biceps':
        return const Color(0xFFD48AA8);
      case 'Core':
        return const Color(0xFF5BBFB8);
      default:
        return PremiumColors.accentBlueSoft;
    }
  }
}
