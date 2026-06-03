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
    final totalSessions = TrainingStats.totalCompletedSessions(plans, completions);
    final weeklyMinutes = TrainingStats.weeklyTrainingMinutes(plans, completions, now);
    final weeklyCalories = TrainingStats.weeklyCalories(plans, completions, now);
    final dailyCalories = TrainingStats.weeklyCaloriesByDay(plans, completions, now);
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);
    var monthSessions = 0;
    for (final d in days) {
      if (!d.isBefore(monthStart) && d.isBefore(monthEnd)) monthSessions++;
    }
    final upcoming = plans.where((p) => p.status == PlanStatus.planned).length;
    final bottomPad = FloatingTabBar.reservedBottomSpace(context) + AppSpacing.xl;
    final topPad = MediaQuery.viewPaddingOf(context).top;

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
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.local_fire_department_rounded,
                      label: l10n.progressActiveStreak,
                      value: l10n.progressStreakDays(streak),
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
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PremiumColors.surface,
                  borderRadius: BorderRadius.circular(PremiumRadii.lg),
                  border: Border.all(color: PremiumColors.glassBorder),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: (monthPct / 100).clamp(0.0, 1.0),
                            strokeWidth: 7,
                            backgroundColor: PremiumColors.surfaceRaised,
                            color: PremiumColors.accentBlue,
                          ),
                          Center(
                            child: Text(
                              '${monthPct.round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.progressMonthlyConsistency,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.progressMonthlyHint,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12, height: 1.3),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _MiniStat(
                                  label: l10n.progressMonthSessions,
                                  value: '$monthSessions',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _MiniStat(
                                  label: l10n.progressPlannedUpcoming,
                                  value: '$upcoming',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
            sliver: SliverToBoxAdapter(
              child: _WeeklyCaloriesCard(daily: dailyCalories, l10n: l10n, total: weeklyCalories),
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
              child: _BadgesRow(
                l10n: l10n,
                completedWorkouts: totalSessions,
                streak: streak,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.progressSessionHighlights,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 10, AppSpacing.md, 0),
            sliver: SliverToBoxAdapter(
              child: _SessionHighlightsSection(completions: completions, l10n: l10n),
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
              child: _HistoryList(completions: completions, plans: plans),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
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
          Icon(icon, color: PremiumColors.accentBlue, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
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

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
        ),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: PremiumColors.textMuted, fontSize: 11, height: 1.2),
        ),
      ],
    );
  }
}

class _WeeklyCaloriesCard extends StatelessWidget {
  const _WeeklyCaloriesCard({required this.daily, required this.l10n, required this.total});

  final List<int> daily;
  final AppLocalizations l10n;
  final int total;

  @override
  Widget build(BuildContext context) {
    final labels = [
      l10n.progressWeeklyBarsDow1,
      l10n.progressWeeklyBarsDow2,
      l10n.progressWeeklyBarsDow3,
      l10n.progressWeeklyBarsDow4,
      l10n.progressWeeklyBarsDow5,
      l10n.progressWeeklyBarsDow6,
      l10n.progressWeeklyBarsDow7,
    ];
    final maxV = daily.fold<int>(0, (a, b) => a > b ? a : b);
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
                  l10n.progressWeekActivity,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              Text(
                l10n.sessionCaloriesUnit(total),
                style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(l10n.progressWeekActivityHint, style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12)),
          const SizedBox(height: 14),
          SizedBox(
            height: 132,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (daily[i] > 0)
                          Text(
                            '${daily[i]}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: PremiumColors.accentBlue,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: 8 + (daily[i] / norm) * 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: daily[i] > 0
                                ? PremiumColors.accentBlue
                                : PremiumColors.surfaceRaised,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labels[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: PremiumColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

class _SessionHighlightsSection extends StatelessWidget {
  const _SessionHighlightsSection({required this.completions, required this.l10n});

  final List<WorkoutCompletion> completions;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (completions.isEmpty) {
      return _PanelText(l10n.progressHighlightsEmpty);
    }

    WorkoutCompletion? longest;
    WorkoutCompletion? peakCal;
    WorkoutCompletion? mostMoves;
    for (final c in completions) {
      if (longest == null || c.durationMinutes > longest.durationMinutes) longest = c;
      if (peakCal == null || c.calories > peakCal.calories) peakCal = c;
      if (mostMoves == null || c.exerciseNames.length > mostMoves.exerciseNames.length) mostMoves = c;
    }

    final fmt = DateFormat.yMMMd(l10n.localeName);
    return Column(
      children: [
        _RecordTile(
          lift: l10n.progressHighlightLongest,
          value: l10n.minutesShort(longest!.durationMinutes),
          dateLabel: fmt.format(longest.completedAt),
        ),
        const SizedBox(height: 8),
        _RecordTile(
          lift: l10n.progressHighlightCalories,
          value: l10n.sessionCaloriesUnit(peakCal!.calories),
          dateLabel: fmt.format(peakCal.completedAt),
        ),
        const SizedBox(height: 8),
        _RecordTile(
          lift: l10n.progressHighlightMoves,
          value: l10n.exercisesCount(mostMoves!.exerciseNames.length),
          dateLabel: fmt.format(mostMoves.completedAt),
        ),
      ],
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.lift, required this.value, required this.dateLabel});

  final String lift;
  final String value;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lift,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: PremiumColors.accentBlue, fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _BadgesRow extends StatelessWidget {
  const _BadgesRow({required this.l10n, required this.completedWorkouts, required this.streak});

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
      spacing: 8,
      runSpacing: 8,
      children: items.map((e) {
        final unlocked = e.$2;
        return Opacity(
          opacity: unlocked ? 1 : 0.45,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: PremiumColors.surface,
              borderRadius: BorderRadius.circular(PremiumRadii.pill),
              border: Border.all(color: unlocked ? PremiumColors.accentBlue.withValues(alpha: 0.4) : PremiumColors.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(e.$3, color: unlocked ? PremiumColors.accentBlue : PremiumColors.textMuted, size: 18),
                const SizedBox(width: 6),
                Text(
                  e.$1,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: unlocked ? Colors.white : PremiumColors.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.completions, required this.plans});

  final List<WorkoutCompletion> completions;
  final List<WorkoutPlan> plans;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final relevant = completions.where((c) => TrainingStats.completionMatchesPlans(c, plans)).toList();
    if (relevant.isEmpty) {
      return _PanelText(l10n.progressHistoryEmpty);
    }

    final sorted = List<WorkoutCompletion>.from(relevant)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return Container(
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < sorted.length && i < 8; i++) ...[
            ListTile(
              title: Text(
                sorted[i].title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: Text(
                '${sorted[i].workoutType} · ${l10n.minutesShort(sorted[i].durationMinutes)} · ${l10n.sessionCaloriesUnit(sorted[i].calories)}',
                style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: PremiumColors.textMuted),
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => CompletedWorkoutDetailPage(completion: sorted[i]),
                  ),
                );
              },
            ),
            if (i < sorted.length - 1 && i < 7)
              Divider(height: 1, color: PremiumColors.glassBorder, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _PanelText extends StatelessWidget {
  const _PanelText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Text(text, style: const TextStyle(color: PremiumColors.textSecondary, height: 1.35)),
    );
  }
}
