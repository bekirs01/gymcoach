import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/lift_progress.dart';
import '../../../core/training_stats.dart';
import '../../history/presentation/completed_workout_detail_page.dart';
import '../../plans/domain/workout_plan.dart';
import '../../plans/presentation/plans_widgets.dart';
import '../../workout/domain/workout_completion.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({
    super.key,
    required this.plans,
    required this.completions,
    this.onOpenStreak,
    this.onSeeAllHistory,
  });

  final List<WorkoutPlan> plans;
  final List<WorkoutCompletion> completions;
  final VoidCallback? onOpenStreak;
  final VoidCallback? onSeeAllHistory;

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  var _weekExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final days = TrainingStats.completedDays(widget.plans, widget.completions);
    final streak = TrainingStats.currentStreak(days, now);
    final weekly = TrainingStats.weeklySessionsCompleted(widget.plans, widget.completions, now);
    final monthTotal = TrainingStats.monthlyConsistencyPercent(widget.plans, widget.completions, now);
    final theme = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;
    final lifts = computeLiftProgress(widget.completions);
    final recent = List<WorkoutCompletion>.from(widget.completions)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    final recentTop = recent.length > 3 ? recent.sublist(0, 3) : recent;

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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: PlansMetricTile(
                    label: l10n.progressWeeklySessions,
                    value: '$weekly',
                    icon: Icons.fitness_center_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onOpenStreak,
                      borderRadius: BorderRadius.circular(14),
                      child: PlansMetricTile(
                        label: l10n.progressActiveStreak,
                        value: l10n.progressStreakDays(streak),
                        icon: Icons.local_fire_department_rounded,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          sliver: SliverToBoxAdapter(
            child: PlansMetricTile(
              label: l10n.progressMonthlyConsistency,
              value: '${monthTotal.round()}%',
              icon: Icons.auto_graph_rounded,
            ),
          ),
        ),
        if (lifts.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.progressLiftProgress,
                style: theme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        if (lifts.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverList.separated(
              itemCount: lifts.length > 5 ? 5 : lifts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final e = lifts[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: Text(
                    e.exerciseName,
                    style: theme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  trailing: Text(
                    l10n.progressBestWeight(e.bestWeightKg),
                    style: theme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(
            child: InkWell(
              onTap: () => setState(() => _weekExpanded = !_weekExpanded),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      l10n.progressWeeklyVolume,
                      style: theme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _weekExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_weekExpanded)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _WeeklyBars(
                completions: widget.completions,
                plans: widget.plans,
                reference: now,
                l10n: l10n,
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Text(
                  l10n.progressRecentSessions,
                  style: theme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (widget.onSeeAllHistory != null && recent.isNotEmpty)
                  TextButton(
                    onPressed: widget.onSeeAllHistory,
                    child: Text(l10n.progressSeeAll),
                  ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          sliver: SliverToBoxAdapter(
            child: recentTop.isEmpty
                ? Text(
                    l10n.progressHistoryEmpty,
                    style: theme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < recentTop.length; i++) ...[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            recentTop[i].title,
                            style: theme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            DateFormat.MMMd(l10n.localeName).format(recentTop[i].completedAt),
                            style: theme.bodySmall?.copyWith(color: AppColors.textMuted),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                          onTap: () {
                            Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => CompletedWorkoutDetailPage(completion: recentTop[i]),
                              ),
                            );
                          },
                        ),
                        if (i < recentTop.length - 1)
                          const Divider(height: 1, color: AppColors.borderSubtle),
                      ],
                    ],
                  ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ),
      ],
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 24 + (values[i] / norm) * 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.primary.withValues(alpha: values[i] > 0 ? 1 : 0.2),
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
    );
  }
}
