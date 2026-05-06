import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../app/theme/app_colors.dart';
import '../../app/training_app_state.dart';
import '../../core/training_stats.dart';
import '../calendar/presentation/calendar_page.dart';
import '../categories/presentation/category_detail_page.dart';
import '../history/presentation/completed_workout_detail_page.dart';
import '../home/presentation/home_page.dart';
import '../plans/domain/workout_plan.dart';
import '../plans/presentation/create_plan_sheet.dart';
import '../plans/presentation/plan_detail_page.dart';
import '../plans/presentation/plans_page.dart';
import '../profile/presentation/profile_page.dart';
import '../progress/presentation/progress_page.dart';
import '../progress/presentation/streak_detail_page.dart';
import '../workout/domain/workout_completion.dart';
import '../workout/presentation/workout_log_sheet.dart';
import '../workout/presentation/workout_session_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.training,
    required this.onLocaleChanged,
  });

  final TrainingAppState training;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  var _selectedIndex = 0;
  var _plansCreateSignal = 0;

  TrainingAppState get _t => widget.training;

  Future<void> _addPlan(WorkoutPlan plan) => _t.addPlan(plan);

  Future<void> _upsertPlan(WorkoutPlan plan) => _t.upsertPlan(plan);

  Future<void> _removePlan(WorkoutPlan plan) => _t.removePlan(plan);

  void _goToPlansTab({bool openCreateSheet = false}) {
    setState(() {
      _selectedIndex = 1;
      if (openCreateSheet) {
        _plansCreateSignal++;
      }
    });
  }

  void _goToProgressTab() {
    setState(() => _selectedIndex = 3);
  }

  void _goToProfileTab() {
    setState(() => _selectedIndex = 4);
  }

  Future<void> _handleSessionComplete(WorkoutPlan plan, WorkoutCompletion completion) =>
      _t.completePlanSession(plan, completion);

  void _pushSession(BuildContext messengerContext, WorkoutPlan plan) {
    final messenger = ScaffoldMessenger.of(messengerContext);
    final l10n = AppLocalizations.of(messengerContext)!;
    Navigator.of(messengerContext).push<void>(
      MaterialPageRoute<void>(
        builder: (sctx) => WorkoutSessionPage(
          plan: plan,
          profile: _t.profile,
          onFinished: (c) {
            unawaited(_handleSessionComplete(plan, c));
            messenger.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(l10n.snackbarWorkoutSavedHistory),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openPlanDetail(BuildContext messengerContext, WorkoutPlan plan) {
    final messenger = ScaffoldMessenger.of(messengerContext);
    final l10n = AppLocalizations.of(messengerContext)!;
    Navigator.of(messengerContext).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) => PlanDetailPage(
          plan: plan,
          onBeginSession: () => _pushSession(ctx, plan),
          onEdit: () {
            showCreatePlanSheet(
              context: ctx,
              existingPlan: plan,
              onSaved: (updated) {
                unawaited(_upsertPlan(updated));
                Navigator.of(ctx).pop();
                messenger.showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(l10n.snackbarPlanUpdated),
                  ),
                );
              },
            );
          },
          onDeleted: () {
            unawaited(_removePlan(plan));
            messenger.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(l10n.snackbarPlanDeleted),
              ),
            );
          },
        ),
      ),
    );
  }

  Set<DateTime> get _completedDays => TrainingStats.completedDays(_t.plans, _t.completions);

  List<bool> _weekFlags() {
    final mon = WorkoutPlan.mondayContaining(DateTime.now());
    final days = _completedDays;
    return List.generate(7, (i) => days.contains(WorkoutPlan.dateOnly(mon.add(Duration(days: i)))));
  }

  void _openCategory(BuildContext navContext, String key) {
    Navigator.of(navContext).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CategoryDetailPage.forCatalogKey(navContext, key),
      ),
    );
  }

  void _openCompletion(BuildContext navContext, WorkoutCompletion c) {
    Navigator.of(navContext).push<void>(
      MaterialPageRoute<void>(builder: (_) => CompletedWorkoutDetailPage(completion: c)),
    );
  }

  void _openStreak(BuildContext navContext) {
    Navigator.of(navContext).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) => StreakDetailPage(
          plans: _t.plans,
          completions: _t.completions,
          onOpenProgress: () {
            Navigator.of(ctx).pop();
            _goToProgressTab();
          },
        ),
      ),
    );
  }

  void _logWorkout(BuildContext messengerContext) {
    final l10n = AppLocalizations.of(messengerContext)!;
    showWorkoutLogSheet(
      context: messengerContext,
      profile: _t.profile,
      onSaved: (c) {
        unawaited(_t.insertCompletionOnly(c));
        ScaffoldMessenger.of(messengerContext).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(l10n.snackbarWorkoutLogged),
          ),
        );
      },
    );
  }

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final weekFlags = _weekFlags();
    final l10n = AppLocalizations.of(context)!;
    final plans = _t.plans;
    final completions = _t.completions;
    final profile = _t.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(
            plans: plans,
            completions: completions,
            profile: profile,
            weekCompleted: weekFlags,
            onNavigateToPlans: () => setState(() => _selectedIndex = 1),
            onNavigateToPlansCreate: () => _goToPlansTab(openCreateSheet: true),
            onNavigateToProgress: _goToProgressTab,
            onNavigateToProfile: _goToProfileTab,
            onOpenPlanDetail: (p) => _openPlanDetail(context, p),
            onOpenCategory: (key) => _openCategory(context, key),
            onOpenCompletion: (c) => _openCompletion(context, c),
            onOpenStreak: () => _openStreak(context),
            onLogWorkout: () => _logWorkout(context),
          ),
          PlansPage(
            plans: plans,
            onAddPlan: (p) {
              unawaited(_addPlan(p));
            },
            createSheetSignal: _plansCreateSignal,
            onOpenPlanDetail: (p) => _openPlanDetail(context, p),
            onStartSession: (p) => _pushSession(context, p),
          ),
          CalendarPage(
            plans: plans,
            completions: completions,
            onAddPlan: (plan) {
              unawaited(_addPlan(plan));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(l10n.snackbarCalendarAdded),
                ),
              );
            },
            onOpenPlan: (p) => _openPlanDetail(context, p),
          ),
          ProgressPage(
            plans: plans,
            completions: completions,
            onOpenStreak: () => _openStreak(context),
          ),
          ProfilePage(
            profile: profile,
            onProfileChanged: (p) {
              unawaited(_t.updateProfile(p));
            },
            onLocaleChanged: widget.onLocaleChanged,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center_outlined),
            selectedIcon: const Icon(Icons.fitness_center_rounded),
            label: l10n.navPlans,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded),
            label: l10n.navCalendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights_rounded),
            label: l10n.navProgress,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
