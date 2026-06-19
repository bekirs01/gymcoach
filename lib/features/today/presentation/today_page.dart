import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../plans/domain/workout_plan.dart';
import '../../plans/presentation/plans_widgets.dart';
import '../../workout/domain/workout_completion.dart';
import '../../home/presentation/home_page.dart'
    show pickNextPlannedWorkout, scheduleSummaryForHome;

class TodayPage extends StatelessWidget {
  const TodayPage({
    super.key,
    required this.plans,
    required this.completions,
    required this.profileName,
    required this.weekCompleted,
    required this.streakDays,
    required this.onStartWorkout,
    required this.onPreviewWorkout,
    required this.onScheduleWorkout,
    required this.onOpenProfile,
    required this.onOpenProgress,
    required this.onOpenCompletion,
    required this.onNavigateToWorkouts,
  });

  final List<WorkoutPlan> plans;
  final List<WorkoutCompletion> completions;
  final String profileName;
  final List<bool> weekCompleted;
  final int streakDays;
  final ValueChanged<WorkoutPlan> onStartWorkout;
  final ValueChanged<WorkoutPlan> onPreviewWorkout;
  final VoidCallback onScheduleWorkout;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenProgress;
  final ValueChanged<WorkoutCompletion> onOpenCompletion;
  final VoidCallback onNavigateToWorkouts;

  List<WorkoutPlan> _plannedToday() {
    final today = WorkoutPlan.dateOnly(DateTime.now());
    return plans
        .where(
          (p) =>
              p.status == PlanStatus.planned &&
              WorkoutPlan.isSameDay(p.scheduledDate, today),
        )
        .toList()
      ..sort((a, b) {
        final ta = a.scheduledTime.hour * 60 + a.scheduledTime.minute;
        final tb = b.scheduledTime.hour * 60 + b.scheduledTime.minute;
        return ta.compareTo(tb);
      });
  }

  List<WorkoutPlan> _upNext(WorkoutPlan? hero) {
    final next = pickNextPlannedWorkout(plans);
    final out = <WorkoutPlan>[];
    if (next != null && (hero == null || next.id != hero.id)) out.add(next);
    final today = WorkoutPlan.dateOnly(DateTime.now());
    for (final p in plans) {
      if (p.status != PlanStatus.planned) continue;
      if (hero != null && p.id == hero.id) continue;
      if (out.any((x) => x.id == p.id)) continue;
      if (WorkoutPlan.isSameDay(p.scheduledDate, today) && hero != null) continue;
      out.add(p);
      if (out.length >= 2) break;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;
    final todayPlans = _plannedToday();
    final hero = todayPlans.isNotEmpty ? todayPlans.first : null;
    final nextPlan = pickNextPlannedWorkout(plans);
    final upNext = _upNext(hero);
    final dateLabel = DateFormat.yMMMEd(l10n.localeName).format(DateTime.now());

    final plannedCount = plans.where((p) => p.status == PlanStatus.planned).length;
    final completedCount = plans.where((p) => p.status == PlanStatus.completed).length;
    final weekCount = plans
        .where((p) => WorkoutPlan.isInSameCalendarWeek(p.scheduledDate, DateTime.now()))
        .length;

    final weekLabels = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];
    final flags = weekCompleted.length == 7
        ? weekCompleted
        : List<bool>.generate(7, (i) => i < weekCompleted.length ? weekCompleted[i] : false);

    final recent = List<WorkoutCompletion>.from(completions)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    final recentTop = recent.length > 3 ? recent.sublist(0, 3) : recent;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, topPadding + 8, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeWelcomeBack,
                        style: theme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profileName.isNotEmpty ? profileName : l10n.navToday,
                        style: theme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateLabel,
                        style: theme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                if (streakDays > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: TextButton(
                      onPressed: onOpenProgress,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            l10n.progressStreakDays(streakDays),
                            style: theme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Material(
                  color: AppColors.surface,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onOpenProfile,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        profileName.isNotEmpty ? profileName[0].toUpperCase() : '?',
                        style: theme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
                    label: l10n.homeMetricPlanned,
                    value: '$plannedCount',
                    icon: Icons.event_note_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PlansMetricTile(
                    label: l10n.homeMetricCompleted,
                    value: '$completedCount',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PlansMetricTile(
                    label: l10n.homeMetricThisWeek,
                    value: '$weekCount',
                    icon: Icons.date_range_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: hero != null
                ? _TodayHero(
                    plan: hero,
                    extraTodayCount: todayPlans.length > 1 ? todayPlans.length - 1 : 0,
                    l10n: l10n,
                    onStart: () => onStartWorkout(hero),
                    onPreview: () => onPreviewWorkout(hero),
                  )
                : _TodayNoWorkoutCard(
                    l10n: l10n,
                    onSchedule: onScheduleWorkout,
                  ),
          ),
        ),
        if (hero == null && nextPlan != null)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _NextWorkoutCard(
                plan: nextPlan,
                l10n: l10n,
                onPreview: () => onPreviewWorkout(nextPlan),
                onStart: nextPlan.status == PlanStatus.planned
                    ? () => onStartWorkout(nextPlan)
                    : null,
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.homeWeeklyActivity,
              style: theme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _WeeklyActivityRow(dayLabels: weekLabels, daysCompleted: flags),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onNavigateToWorkouts,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: Text(l10n.homeQuickCreatePlan),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenProgress,
                    icon: const Icon(Icons.bar_chart_rounded, size: 20),
                    label: Text(l10n.homeQuickStatistics),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (upNext.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.todayUpNext,
                style: theme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            sliver: SliverList.separated(
              itemCount: upNext.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = upNext[i];
                return Material(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  child: ListTile(
                    title: Text(
                      p.name,
                      style: theme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${scheduleSummaryForHome(p, l10n)} · ${l10n.exercisesCount(p.exerciseNames.length)}',
                      style: theme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow_rounded, color: AppColors.primary),
                      onPressed: p.status == PlanStatus.planned ? () => onStartWorkout(p) : null,
                    ),
                    onTap: () => onPreviewWorkout(p),
                  ),
                );
              },
            ),
          ),
        ],
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.homeRecentActivity,
              style: theme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          sliver: SliverToBoxAdapter(
            child: _RecentActivityList(
              completions: recentTop,
              allEmpty: recent.isEmpty,
              l10n: l10n,
              onOpen: onOpenCompletion,
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

class _TodayHero extends StatelessWidget {
  const _TodayHero({
    required this.plan,
    required this.extraTodayCount,
    required this.l10n,
    required this.onStart,
    required this.onPreview,
  });

  final WorkoutPlan plan;
  final int extraTodayCount;
  final AppLocalizations l10n;
  final VoidCallback onStart;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.heroGradientStart, AppColors.heroGradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeTodaysFocus,
            style: theme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plan.name,
            style: theme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.todayHeroMeta(plan.exerciseNames.length, plan.durationMinutes),
            style: theme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.88)),
          ),
          if (extraTodayCount > 0) ...[
            const SizedBox(height: 4),
            Text(
              l10n.todayMoreToday(extraTodayCount),
              style: theme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                l10n.homeStartWorkout,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: onPreview,
              style: TextButton.styleFrom(foregroundColor: Colors.white.withValues(alpha: 0.92)),
              child: Text(l10n.todayPreview, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayNoWorkoutCard extends StatelessWidget {
  const _TodayNoWorkoutCard({required this.l10n, required this.onSchedule});

  final AppLocalizations l10n;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todayEmptyTitle,
              style: theme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.todayEmptyBody,
              style: theme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.35),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSchedule,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(l10n.todayScheduleCta, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextWorkoutCard extends StatelessWidget {
  const _NextWorkoutCard({
    required this.plan,
    required this.l10n,
    required this.onPreview,
    this.onStart,
  });

  final WorkoutPlan plan;
  final AppLocalizations l10n;
  final VoidCallback onPreview;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.homeNextWorkout,
                    style: theme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                StatusBadge(status: plan.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              plan.name,
              style: theme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _MetaChip(icon: Icons.schedule_rounded, text: scheduleSummaryForHome(plan, l10n)),
                _MetaChip(icon: Icons.timer_outlined, text: l10n.minutesShort(plan.durationMinutes)),
                DifficultyBadge(difficulty: plan.difficulty),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (onStart != null) ...[
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: onStart,
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: Text(l10n.planCardStart),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPreview,
                    child: Text(l10n.todayPreview),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class _WeeklyActivityRow extends StatelessWidget {
  const _WeeklyActivityRow({required this.dayLabels, required this.daysCompleted});

  final List<String> dayLabels;
  final List<bool> daysCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Column(
                children: [
                  Text(
                    dayLabels[i],
                    style: theme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: daysCompleted[i] ? 48 : 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: daysCompleted[i]
                          ? const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [AppColors.heroGradientStart, AppColors.heroGradientEnd],
                            )
                          : null,
                      color: daysCompleted[i] ? null : AppColors.borderSubtle.withValues(alpha: 0.45),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      daysCompleted[i] ? Icons.check_rounded : Icons.remove_rounded,
                      color: daysCompleted[i] ? Colors.white : AppColors.textMuted,
                      size: daysCompleted[i] ? 20 : 14,
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

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList({
    required this.completions,
    required this.allEmpty,
    required this.l10n,
    required this.onOpen,
  });

  final List<WorkoutCompletion> completions;
  final bool allEmpty;
  final AppLocalizations l10n;
  final ValueChanged<WorkoutCompletion> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    if (allEmpty) {
      return Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            l10n.homeRecentEmpty,
            style: theme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          for (var i = 0; i < completions.length; i++) ...[
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.successTint.withValues(alpha: 0.85),
                child: const Icon(Icons.fitness_center_rounded, color: AppColors.primary, size: 22),
              ),
              title: Text(
                completions[i].title,
                style: theme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${_relativeLabel(completions[i].completedAt, l10n)} · ${l10n.minutesShort(completions[i].durationMinutes)}',
                style: theme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              onTap: () => onOpen(completions[i]),
            ),
            if (i < completions.length - 1)
              const Divider(height: 1, indent: 72, color: AppColors.borderSubtle),
          ],
        ],
      ),
    );
  }
}

String _relativeLabel(DateTime past, AppLocalizations l10n) {
  final now = WorkoutPlan.dateOnly(DateTime.now());
  final d = WorkoutPlan.dateOnly(past);
  final diff = now.difference(d).inDays;
  if (diff <= 0) return l10n.activityToday;
  if (diff == 1) return l10n.activityYesterday;
  return l10n.activityDaysAgo(diff);
}
