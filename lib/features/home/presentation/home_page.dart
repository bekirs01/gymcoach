import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../plans/domain/workout_plan.dart';
import '../../plans/presentation/plans_widgets.dart';
import '../../profile/domain/user_profile.dart';
import '../../workout/domain/workout_completion.dart';

String scheduleSummaryForHome(WorkoutPlan plan, AppLocalizations l10n) {
  final today = WorkoutPlan.dateOnly(DateTime.now());
  final pd = WorkoutPlan.dateOnly(plan.scheduledDate);
  final diff = pd.difference(today).inDays;
  final t = plan.formattedTime;
  if (diff == 0) return l10n.scheduleToday(t);
  if (diff == 1) return l10n.scheduleTomorrow(t);
  return l10n.scheduleDateTime(plan.formattedDate, t);
}

WorkoutPlan? pickNextPlannedWorkout(List<WorkoutPlan> plans) {
  final planned = plans.where((p) => p.status == PlanStatus.planned).toList();
  planned.sort((a, b) {
    final da = DateTime(
      a.scheduledDate.year,
      a.scheduledDate.month,
      a.scheduledDate.day,
      a.scheduledTime.hour,
      a.scheduledTime.minute,
    );
    final db = DateTime(
      b.scheduledDate.year,
      b.scheduledDate.month,
      b.scheduledDate.day,
      b.scheduledTime.hour,
      b.scheduledTime.minute,
    );
    return da.compareTo(db);
  });
  if (planned.isEmpty) return null;
  final now = DateTime.now();
  for (final p in planned) {
    final dt = DateTime(
      p.scheduledDate.year,
      p.scheduledDate.month,
      p.scheduledDate.day,
      p.scheduledTime.hour,
      p.scheduledTime.minute,
    );
    if (!dt.isBefore(now)) return p;
  }
  return planned.first;
}

List<_CategoryItem> _homeCategoryItems(AppLocalizations l10n) => [
      _CategoryItem(
        l10n.catStrengthTitle,
        l10n.categorySubtitle(24),
        Icons.fitness_center_rounded,
        'Strength',
      ),
      _CategoryItem(
        l10n.catCardioTitle,
        l10n.categorySubtitle(12),
        Icons.directions_run_rounded,
        'Cardio',
      ),
      _CategoryItem(
        l10n.catMobilityTitle,
        l10n.categorySubtitle(9),
        Icons.self_improvement_rounded,
        'Mobility',
      ),
      _CategoryItem(
        l10n.catCoreTitle,
        l10n.categorySubtitle(14),
        Icons.accessibility_new_rounded,
        'Core',
      ),
      _CategoryItem(
        l10n.catRecoveryTitle,
        l10n.categorySubtitle(7),
        Icons.spa_rounded,
        'Recovery',
      ),
    ];

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.plans,
    required this.completions,
    required this.profile,
    required this.weekCompleted,
    required this.onNavigateToPlans,
    required this.onNavigateToPlansCreate,
    required this.onNavigateToProgress,
    required this.onNavigateToProfile,
    required this.onOpenPlanDetail,
    required this.onOpenCategory,
    required this.onOpenCompletion,
    required this.onOpenStreak,
    required this.onLogWorkout,
  });

  final List<WorkoutPlan> plans;
  final List<WorkoutCompletion> completions;
  final UserProfile profile;
  final List<bool> weekCompleted;
  final VoidCallback onNavigateToPlans;
  final VoidCallback onNavigateToPlansCreate;
  final VoidCallback onNavigateToProgress;
  final VoidCallback onNavigateToProfile;
  final ValueChanged<WorkoutPlan> onOpenPlanDetail;
  final ValueChanged<String> onOpenCategory;
  final ValueChanged<WorkoutCompletion> onOpenCompletion;
  final VoidCallback onOpenStreak;
  final VoidCallback onLogWorkout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;
    final today = WorkoutPlan.dateOnly(DateTime.now());
    final plannedToday = plans
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
    final heroTitle = plannedToday.isNotEmpty ? plannedToday.first.name : l10n.homeTrainingFocus;
    final heroSubtitle = plannedToday.isEmpty
        ? l10n.homeSchedulePlanPrompt
        : plannedToday.length == 1
            ? l10n.homeOneWorkoutToday
            : l10n.homeNWorkoutsToday(plannedToday.length);
    final plannedCount =
        plans.where((p) => p.status == PlanStatus.planned).length.toString();
    final completedCount =
        plans.where((p) => p.status == PlanStatus.completed).length.toString();
    final weekCount = plans
        .where(
          (p) => WorkoutPlan.isInSameCalendarWeek(p.scheduledDate, DateTime.now()),
        )
        .length
        .toString();
    final nextPlan = pickNextPlannedWorkout(plans);
    final categories = _homeCategoryItems(l10n);
    final weekLabels = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, topPadding + 8, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _WelcomeHeader(
              displayName: profile.displayName,
              onProfileTap: onNavigateToProfile,
              welcomeBack: l10n.homeWelcomeBack,
              tagline: l10n.homeStayConsistent,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _HeroCard(
              sectionTitle: l10n.homeTodaysFocus,
              focusTitle: heroTitle,
              focusSubtitle: heroSubtitle,
              startLabel: l10n.homeStartWorkout,
              viewPlanLabel: l10n.homeViewPlanLink,
              onStartWorkout: () {
                if (plannedToday.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(l10n.homeNoWorkoutToday),
                    ),
                  );
                  onNavigateToPlans();
                  return;
                }
                onOpenPlanDetail(plannedToday.first);
              },
              onViewPlan: onNavigateToPlans,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _DashboardMetricRow(
              plannedLabel: l10n.homeMetricPlanned,
              completedLabel: l10n.homeMetricCompleted,
              weekLabel: l10n.homeMetricThisWeek,
              plannedCount: plannedCount,
              completedCount: completedCount,
              weekCount: weekCount,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _NextWorkoutCard(
              plan: nextPlan,
              l10n: l10n,
              onOpenDetails: () {
                if (nextPlan != null) {
                  onOpenPlanDetail(nextPlan);
                } else {
                  onNavigateToPlans();
                }
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _SectionTitle(l10n.homeQuickActions),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _QuickActionsGrid(
              createPlanLabel: l10n.homeQuickCreatePlan,
              logWorkoutLabel: l10n.homeQuickLogWorkout,
              statisticsLabel: l10n.homeQuickStatistics,
              onCreatePlan: onNavigateToPlansCreate,
              onViewStatistics: onNavigateToProgress,
              onLogWorkout: onLogWorkout,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _SectionTitle(l10n.homeWeeklyActivity),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _WeeklyActivityRow(
              dayLabels: weekLabels,
              daysCompleted: weekCompleted,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _SectionTitle(l10n.homeExerciseCategories),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _CategoryStrip(
              items: categories,
              onCategory: onOpenCategory,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _SectionTitle(l10n.homeRecentActivity),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _RecentActivityList(
              completions: completions,
              l10n: l10n,
              onOpen: onOpenCompletion,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _MotivationFooter(
              title: l10n.homeStreakTitle,
              subtitle: l10n.homeStreakSubtitle,
              onTap: onOpenStreak,
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

String _relativeActivityLabel(DateTime past, AppLocalizations l10n) {
  final now = WorkoutPlan.dateOnly(DateTime.now());
  final d = WorkoutPlan.dateOnly(past);
  final diff = now.difference(d).inDays;
  if (diff <= 0) return l10n.activityToday;
  if (diff == 1) return l10n.activityYesterday;
  return l10n.activityDaysAgo(diff);
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({
    required this.displayName,
    required this.onProfileTap,
    required this.welcomeBack,
    required this.tagline,
  });

  final String displayName;
  final VoidCallback onProfileTap;
  final String welcomeBack;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                welcomeBack,
                style: theme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayName,
                style: theme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tagline,
                style: theme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                AppColors.heroGradientStart,
                AppColors.heroGradientEnd,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onProfileTap,
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.sectionTitle,
    required this.focusTitle,
    required this.focusSubtitle,
    required this.startLabel,
    required this.viewPlanLabel,
    required this.onStartWorkout,
    required this.onViewPlan,
  });

  final String sectionTitle;
  final String focusTitle;
  final String focusSubtitle;
  final String startLabel;
  final String viewPlanLabel;
  final VoidCallback onStartWorkout;
  final VoidCallback onViewPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.heroGradientStart,
            AppColors.heroGradientEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: theme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            focusTitle,
            style: theme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            focusSubtitle,
            style: theme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onStartWorkout,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    startLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: onViewPlan,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withValues(alpha: 0.92),
              ),
              child: Text(
                viewPlanLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetricRow extends StatelessWidget {
  const _DashboardMetricRow({
    required this.plannedLabel,
    required this.completedLabel,
    required this.weekLabel,
    required this.plannedCount,
    required this.completedCount,
    required this.weekCount,
  });

  final String plannedLabel;
  final String completedLabel;
  final String weekLabel;
  final String plannedCount;
  final String completedCount;
  final String weekCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PlansMetricTile(
            label: plannedLabel,
            value: plannedCount,
            icon: Icons.event_note_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PlansMetricTile(
            label: completedLabel,
            value: completedCount,
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PlansMetricTile(
            label: weekLabel,
            value: weekCount,
            icon: Icons.date_range_rounded,
          ),
        ),
      ],
    );
  }
}

class _NextWorkoutCard extends StatelessWidget {
  const _NextWorkoutCard({
    required this.plan,
    required this.l10n,
    required this.onOpenDetails,
  });

  final WorkoutPlan? plan;
  final AppLocalizations l10n;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final p = plan;

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.homeNextWorkout,
                    style: theme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (p != null)
                  StatusBadge(status: p.status)
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.homeNoneScheduled,
                      style: theme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              p?.name ?? l10n.homeAddWorkoutPlan,
              style: theme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (p != null)
              Wrap(
                spacing: 16,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _MetaChip(
                    icon: Icons.schedule_rounded,
                    text: scheduleSummaryForHome(p, l10n),
                  ),
                  _MetaChip(
                    icon: Icons.timer_outlined,
                    text: l10n.minutesShort(p.durationMinutes),
                  ),
                  DifficultyBadge(difficulty: p.difficulty),
                ],
              )
            else
              Text(
                l10n.homeNextWorkoutEmptyHint,
                style: theme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onOpenDetails,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                ),
                child: Text(
                  p != null ? l10n.homeOpenDetails : l10n.homeViewPlans,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
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
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({
    required this.createPlanLabel,
    required this.logWorkoutLabel,
    required this.statisticsLabel,
    required this.onCreatePlan,
    required this.onViewStatistics,
    required this.onLogWorkout,
  });

  final String createPlanLabel;
  final String logWorkoutLabel;
  final String statisticsLabel;
  final VoidCallback onCreatePlan;
  final VoidCallback onViewStatistics;
  final VoidCallback onLogWorkout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _QuickActionTile(
                label: createPlanLabel,
                icon: Icons.add_chart_rounded,
                onTap: onCreatePlan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionTile(
                label: logWorkoutLabel,
                icon: Icons.edit_calendar_rounded,
                onTap: onLogWorkout,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _QuickActionTile(
          label: statisticsLabel,
          icon: Icons.bar_chart_rounded,
          onTap: onViewStatistics,
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.successTint.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
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
    final flags = daysCompleted.length == 7
        ? daysCompleted
        : List<bool>.generate(7, (i) => i < daysCompleted.length ? daysCompleted[i] : false);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
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
              child: _DayColumn(
                label: dayLabels[i],
                completed: flags[i],
                theme: theme,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.label,
    required this.completed,
    required this.theme,
  });

  final String label;
  final bool completed;
  final TextTheme theme;

  @override
  Widget build(BuildContext context) {
    final active = completed;

    return Column(
      children: [
        Text(
          label,
          style: theme.labelSmall?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: active ? 52 : 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: active
                ? const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.heroGradientStart,
                      AppColors.heroGradientEnd,
                    ],
                  )
                : null,
            color: active ? null : AppColors.borderSubtle.withValues(alpha: 0.45),
          ),
          alignment: Alignment.center,
          child: Icon(
            active ? Icons.check_rounded : Icons.remove_rounded,
            color: active ? Colors.white : AppColors.textMuted,
            size: active ? 22 : 16,
          ),
        ),
      ],
    );
  }
}

class _CategoryItem {
  const _CategoryItem(this.title, this.subtitle, this.icon, this.catalogKey);

  final String title;
  final String subtitle;
  final IconData icon;
  final String catalogKey;
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.items, required this.onCategory});

  final List<_CategoryItem> items;
  final ValueChanged<String> onCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.borderSubtle),
            ),
            child: InkWell(
              onTap: () => onCategory(item.catalogKey),
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 132,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.icon, color: AppColors.primary, size: 26),
                      const Spacer(),
                      Text(
                        item.title,
                        style: theme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: theme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList({
    required this.completions,
    required this.l10n,
    required this.onOpen,
  });

  final List<WorkoutCompletion> completions;
  final AppLocalizations l10n;
  final ValueChanged<WorkoutCompletion> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final items = List<WorkoutCompletion>.from(completions)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    if (items.isEmpty) {
      return Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            l10n.homeRecentEmpty,
            style: theme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final top = items.length > 5 ? items.sublist(0, 5) : items;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          for (var i = 0; i < top.length; i++) ...[
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 6,
              ),
              leading: CircleAvatar(
                backgroundColor: AppColors.successTint.withValues(alpha: 0.85),
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              title: Text(
                top[i].title,
                style: theme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _relativeActivityLabel(top[i].completedAt, l10n),
                      style: theme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${top[i].workoutType} · ${l10n.minutesShort(top[i].durationMinutes)}',
                      style: theme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
              onTap: () => onOpen(top[i]),
            ),
            if (i < top.length - 1)
              const Divider(height: 1, indent: 72, color: AppColors.borderSubtle),
          ],
        ],
      ),
    );
  }
}

class _MotivationFooter extends StatelessWidget {
  const _MotivationFooter({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.primaryDark.withValues(alpha: 0.06),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: theme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
