import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/floating_tab_bar.dart';
import '../../../app/widgets/premium_background.dart';
import '../../../core/training_stats.dart';
import '../../nutrition/presentation/nutrition_tab.dart';
import '../../plans/domain/workout_plan.dart';
import '../../profile/domain/user_profile.dart';
import '../../workout/domain/workout_completion.dart';
import 'widgets/articles_section.dart';
import 'widgets/home_widgets.dart';

WorkoutPlan? pickFeaturedPlan(List<WorkoutPlan> plans) {
  final next = plans.where((p) => p.status == PlanStatus.planned).toList();
  if (next.isEmpty) {
    if (plans.isEmpty) return null;
    return plans.first;
  }
  next.sort((a, b) {
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
  return next.first;
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.plans,
    required this.completions,
    required this.profile,
    required this.weekCompleted,
    required this.onAddPlan,
    required this.onNavigateToProgress,
    required this.onOpenProfile,
    required this.onOpenPlanDetail,
    required this.onStartSession,
    required this.onDeletePlan,
    required this.onSharePlan,
    required this.onOpenCompletion,
    required this.onOpenStreak,
    required this.onLogWorkout,
  });

  final List<WorkoutPlan> plans;
  final List<WorkoutCompletion> completions;
  final UserProfile profile;
  final List<bool> weekCompleted;
  final ValueChanged<WorkoutPlan> onAddPlan;
  final VoidCallback onNavigateToProgress;
  final VoidCallback onOpenProfile;
  final ValueChanged<WorkoutPlan> onOpenPlanDetail;
  final ValueChanged<WorkoutPlan> onStartSession;
  final Future<void> Function(WorkoutPlan plan) onDeletePlan;
  final ValueChanged<WorkoutPlan> onSharePlan;
  final ValueChanged<WorkoutCompletion> onOpenCompletion;
  final VoidCallback onOpenStreak;
  final VoidCallback onLogWorkout;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _topTab = 0;
  late DateTime _month;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selectedDay = WorkoutPlan.dateOnly(now);
  }

  Set<DateTime> get _plannedDays => widget.plans
      .where((p) => p.status == PlanStatus.planned)
      .map((p) => WorkoutPlan.dateOnly(p.scheduledDate))
      .toSet();

  Set<DateTime> get _completedDays =>
      TrainingStats.completedDays(widget.plans, widget.completions);

  void _shiftMonth(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // viewPadding is stable and not removed by Scaffold, so reliable for safe area top
    final topPad = MediaQuery.viewPaddingOf(context).top;
    final bottomPad =
        FloatingTabBar.reservedBottomSpace(context) + AppSpacing.md;
    final featured = pickFeaturedPlan(widget.plans);
    final sessionCount = widget.completions.length;

    return PremiumBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              topPad + 4,
              AppSpacing.md,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeReferenceHeader(
                  greeting: l10n.homeWelcomeBack,
                  displayName: widget.profile.displayName,
                  avatarUrl: widget.profile.avatarUrl,
                  onStreakTap: widget.onOpenStreak,
                  onProfileTap: widget.onOpenProfile,
                ),
                const SizedBox(height: AppSpacing.sm),
                HomeTopTabs(
                  labels: [
                    l10n.homeTabDashboard,
                    l10n.homeTabWorkouts,
                    NutritionTab.tabLabel(context),
                  ],
                  selectedIndex: _topTab,
                  onSelected: (i) => setState(() => _topTab = i),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _topTab == 2
                  ? NutritionTab(profile: widget.profile)
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: bottomPad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_topTab == 1) ...[
                            HomeFeaturedTrainingCard(
                              eyebrow: l10n.homeMyTraining,
                              title:
                                  featured?.name ?? l10n.homeFeaturedEmptyTitle,
                              subtitle: featured != null
                                  ? l10n.homeCompletedSessions(sessionCount)
                                  : l10n.homeFeaturedEmptySubtitle,
                              onTap: () {
                                if (featured != null) {
                                  widget.onOpenPlanDetail(featured);
                                }
                              },
                              onShare: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                      featured?.name ??
                                          l10n.homeFeaturedEmptyTitle,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            HomeWorkoutBuilderPanel(
                              plans: widget.plans,
                              onAddPlan: widget.onAddPlan,
                              onOpenPlan: widget.onOpenPlanDetail,
                              onStartPlan: widget.onStartSession,
                              onDeletePlan: widget.onDeletePlan,
                              onSharePlan: widget.onSharePlan,
                            ),
                          ] else ...[
                            // ── My Training card ─────────────────────────────────
                            HomeFeaturedTrainingCard(
                              eyebrow: l10n.homeMyTraining,
                              title:
                                  featured?.name ?? l10n.homeFeaturedEmptyTitle,
                              subtitle: featured != null
                                  ? l10n.homeCompletedSessions(sessionCount)
                                  : l10n.homeFeaturedEmptySubtitle,
                              onTap: () {
                                if (featured != null) {
                                  widget.onOpenPlanDetail(featured);
                                } else {
                                  setState(() => _topTab = 1);
                                }
                              },
                              onShare: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                      featured?.name ??
                                          l10n.homeFeaturedEmptyTitle,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // ── Training Schedule header ─────────────────────────
                            HomeSectionHeader(
                              title: l10n.homeTrainingSchedule,
                              actionLabel: l10n.homeMore,
                              onAction: () => setState(() => _topTab = 1),
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // ── Monthly calendar ─────────────────────────────────
                            HomeMonthlyCalendar(
                              month: _month,
                              selectedDay: _selectedDay,
                              plans: widget.plans,
                              plannedDays: _plannedDays,
                              completedDays: _completedDays,
                              l10n: l10n,
                              onMonthChanged: _shiftMonth,
                              onDaySelected: (d) =>
                                  setState(() => _selectedDay = d),
                            ),
                            const ArticlesSection(),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
