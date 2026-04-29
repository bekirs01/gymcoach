import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../plans/domain/workout_plan.dart';
import '../../plans/presentation/plans_widgets.dart';

String scheduleSummaryForHome(WorkoutPlan plan) {
  final today = WorkoutPlan.dateOnly(DateTime.now());
  final pd = WorkoutPlan.dateOnly(plan.scheduledDate);
  final diff = pd.difference(today).inDays;
  final t = plan.formattedTime;
  if (diff == 0) return 'Today · $t';
  if (diff == 1) return 'Tomorrow · $t';
  return '${plan.formattedDate} · $t';
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

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.plans,
    required this.onNavigateToPlans,
    required this.onNavigateToPlansCreate,
    required this.onNavigateToProgress,
    required this.onOpenPlanDetail,
  });

  final List<WorkoutPlan> plans;
  final VoidCallback onNavigateToPlans;
  final VoidCallback onNavigateToPlansCreate;
  final VoidCallback onNavigateToProgress;
  final ValueChanged<WorkoutPlan> onOpenPlanDetail;

  static const List<_WeekDay> _weekDays = [
    _WeekDay('Mon', true),
    _WeekDay('Tue', true),
    _WeekDay('Wed', true),
    _WeekDay('Thu', false),
    _WeekDay('Fri', true),
    _WeekDay('Sat', false),
    _WeekDay('Sun', false),
  ];

  static const List<_CategoryItem> _categories = [
    _CategoryItem('Strength', '24 exercises', Icons.fitness_center_rounded),
    _CategoryItem('Cardio', '12 exercises', Icons.directions_run_rounded),
    _CategoryItem('Mobility', '9 exercises', Icons.self_improvement_rounded),
    _CategoryItem('Core', '14 exercises', Icons.accessibility_new_rounded),
    _CategoryItem('Recovery', '7 exercises', Icons.spa_rounded),
  ];

  static const List<_RecentItem> _recent = [
    _RecentItem('Leg Day completed', 'Yesterday', 'Lower body · 52 min'),
    _RecentItem('Core Session completed', '2 days ago', 'Abs · 28 min'),
    _RecentItem('Morning Run completed', '3 days ago', 'Outdoor · 35 min'),
  ];

  @override
  Widget build(BuildContext context) {
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
    final heroTitle =
        plannedToday.isNotEmpty ? plannedToday.first.name : 'Training Focus';
    final heroSubtitle = plannedToday.isEmpty
        ? 'Schedule a plan to stay consistent.'
        : plannedToday.length == 1
            ? '1 workout planned for today'
            : '${plannedToday.length} workouts planned for today';
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

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, topPadding + 8, 20, 0),
          sliver: SliverToBoxAdapter(
            child: const _WelcomeHeader(),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _HeroCard(
              focusTitle: heroTitle,
              focusSubtitle: heroSubtitle,
              onStartWorkout: () {
                if (nextPlan != null) {
                  onOpenPlanDetail(nextPlan);
                } else {
                  onNavigateToPlansCreate();
                }
              },
              onViewPlan: onNavigateToPlans,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _DashboardMetricRow(
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
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 28, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _SectionTitle('Quick Actions'),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _QuickActionsGrid(
              onCreatePlan: onNavigateToPlansCreate,
              onViewPlan: onNavigateToPlans,
              onViewStatistics: onNavigateToProgress,
            ),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 28, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _SectionTitle('Weekly Activity'),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _WeeklyActivityRow(days: _weekDays),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 28, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _SectionTitle('Exercise Categories'),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _CategoryStrip(items: _categories),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 28, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _SectionTitle('Recent Activity'),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _RecentActivityList(items: _recent),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _MotivationFooter(),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ),
      ],
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();
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
                'Welcome back',
                style: theme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bekir',
                style: theme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stay consistent and keep moving.',
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
              onTap: () {},
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
    required this.focusTitle,
    required this.focusSubtitle,
    required this.onStartWorkout,
    required this.onViewPlan,
  });

  final String focusTitle;
  final String focusSubtitle;
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
            "Today's Focus",
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
                  child: const Text(
                    'Start Workout',
                    style: TextStyle(fontWeight: FontWeight.w700),
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
              child: const Text(
                'View Plan',
                style: TextStyle(
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
    required this.plannedCount,
    required this.completedCount,
    required this.weekCount,
  });

  final String plannedCount;
  final String completedCount;
  final String weekCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PlansMetricTile(
            label: 'Planned workouts',
            value: plannedCount,
            icon: Icons.event_note_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PlansMetricTile(
            label: 'Completed workouts',
            value: completedCount,
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PlansMetricTile(
            label: 'This week',
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
    required this.onOpenDetails,
  });

  final WorkoutPlan? plan;
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
                    'Next Workout',
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
                      'None scheduled',
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
              p?.name ?? 'Add a workout plan',
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
                    text: scheduleSummaryForHome(p),
                  ),
                  _MetaChip(
                    icon: Icons.timer_outlined,
                    text: '${p.durationMinutes} min',
                  ),
                  DifficultyBadge(difficulty: p.difficulty),
                ],
              )
            else
              Text(
                'Create a plan to see your next session here.',
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
                  p != null ? 'Open Details' : 'View Plans',
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
    required this.onCreatePlan,
    required this.onViewPlan,
    required this.onViewStatistics,
  });

  final VoidCallback onCreatePlan;
  final VoidCallback onViewPlan;
  final VoidCallback onViewStatistics;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.15,
      children: [
        _QuickActionTile(
          label: 'Create Plan',
          icon: Icons.add_chart_rounded,
          onTap: onCreatePlan,
        ),
        _QuickActionTile(
          label: 'View Plan',
          icon: Icons.list_alt_rounded,
          onTap: onViewPlan,
        ),
        _QuickActionTile(
          label: 'Log Workout',
          icon: Icons.edit_calendar_rounded,
          onTap: () {},
        ),
        _QuickActionTile(
          label: 'View Statistics',
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

class _WeekDay {
  const _WeekDay(this.label, this.completed);

  final String label;
  final bool completed;
}

class _WeeklyActivityRow extends StatelessWidget {
  const _WeeklyActivityRow({required this.days});

  final List<_WeekDay> days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          for (var i = 0; i < days.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: _DayColumn(day: days[i], theme: theme),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.theme,
  });

  final _WeekDay day;
  final TextTheme theme;

  @override
  Widget build(BuildContext context) {
    final active = day.completed;

    return Column(
      children: [
        Text(
          day.label,
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
  const _CategoryItem(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final IconData icon;
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.items});

  final List<_CategoryItem> items;

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
              onTap: () {},
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

class _RecentItem {
  const _RecentItem(this.title, this.time, this.detail);

  final String title;
  final String time;
  final String detail;
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList({required this.items});

  final List<_RecentItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
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
                items[i].title,
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
                      items[i].time,
                      style: theme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      items[i].detail,
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
              onTap: () {},
            ),
            if (i < items.length - 1)
              const Divider(height: 1, indent: 72, color: AppColors.borderSubtle),
          ],
        ],
      ),
    );
  }
}

class _MotivationFooter extends StatelessWidget {
  const _MotivationFooter();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
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
                'Keep your streak alive',
                style: theme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Complete one workout today to stay on track.',
            style: theme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
