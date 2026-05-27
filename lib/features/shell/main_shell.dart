import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../app/theme/app_colors.dart';
import '../../app/training_app_state.dart';
import '../../core/training_stats.dart';
import '../history/presentation/completed_workout_detail_page.dart';
import '../plans/domain/workout_plan.dart';
import '../plans/presentation/create_plan_sheet.dart';
import '../plans/presentation/plan_preview_sheet.dart';
import '../profile/presentation/profile_page.dart';
import '../progress/presentation/progress_history_page.dart';
import '../progress/presentation/progress_page.dart';
import '../progress/presentation/streak_detail_page.dart';
import '../territory_map/presentation/territory_map_page.dart';
import '../today/presentation/today_page.dart';
import '../workout/domain/workout_completion.dart';
import '../workout/presentation/workout_log_sheet.dart';
import '../workout/presentation/workout_session_page.dart';
import '../workouts/presentation/workouts_page.dart';

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

  void _goToWorkoutsTab({bool openCreateSheet = false}) {
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

  Map<String, double> _lastWeightByExercise() {
    final out = <String, double>{};
    final sorted = List<WorkoutCompletion>.from(_t.completions)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    for (final c in sorted) {
      for (final log in c.exerciseLogs) {
        final w = log.weightKg;
        if (w != null && !out.containsKey(log.exerciseName)) {
          out[log.exerciseName] = w;
        }
      }
    }
    return out;
  }

  void _pushSession(BuildContext messengerContext, WorkoutPlan plan) {
    final messenger = ScaffoldMessenger.of(messengerContext);
    final l10n = AppLocalizations.of(messengerContext)!;
    Navigator.of(messengerContext).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (sctx) => WorkoutSessionPage(
          plan: plan,
          profile: _t.profile,
          autoStart: true,
          lastWeightKgByExercise: _lastWeightByExercise(),
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

  void _openPlanPreview(BuildContext context, WorkoutPlan plan) {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    unawaited(
      showPlanPreviewSheet(
        context: context,
        plan: plan,
        onStart: () => _pushSession(context, plan),
        onEdit: () {
          showCreatePlanSheet(
            context: context,
            existingPlan: plan,
            onSaved: (updated) {
              unawaited(_upsertPlan(updated));
              messenger.showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(l10n.snackbarPlanUpdated),
                ),
              );
            },
          );
        },
        onDuplicate: () {
          final copy = duplicateWorkoutPlan(plan);
          unawaited(_addPlan(copy));
          messenger.showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(l10n.snackbarPlanDuplicated),
            ),
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
    );
  }

  Set<DateTime> get _completedDays => TrainingStats.completedDays(_t.plans, _t.completions);

  List<bool> _weekFlags() {
    final mon = WorkoutPlan.mondayContaining(DateTime.now());
    final days = _completedDays;
    return List.generate(7, (i) => days.contains(WorkoutPlan.dateOnly(mon.add(Duration(days: i)))));
  }

  int _streakDays() {
    final now = DateTime.now();
    return TrainingStats.currentStreak(_completedDays, now);
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

  void _openHistory(BuildContext navContext) {
    Navigator.of(navContext).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ProgressHistoryPage(completions: _t.completions),
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
    final streak = _streakDays();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          TodayPage(
            plans: plans,
            completions: completions,
            profileName: profile.displayName,
            weekCompleted: weekFlags,
            streakDays: streak,
            onStartWorkout: (p) => _pushSession(context, p),
            onPreviewWorkout: (p) => _openPlanPreview(context, p),
            onScheduleWorkout: () => _goToWorkoutsTab(openCreateSheet: true),
            onOpenProfile: _goToProfileTab,
            onOpenProgress: _goToProgressTab,
            onNavigateToWorkouts: () => _goToWorkoutsTab(openCreateSheet: true),
            onOpenCompletion: (c) {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => CompletedWorkoutDetailPage(completion: c),
                ),
              );
            },
          ),
          WorkoutsPage(
            plans: plans,
            completions: completions,
            onAddPlan: (p) {
              unawaited(_addPlan(p));
            },
            createSheetSignal: _plansCreateSignal,
            onPreviewPlan: (p) => _openPlanPreview(context, p),
            onStartSession: (p) => _pushSession(context, p),
            onCalendarAddPlan: (plan) {
              unawaited(_addPlan(plan));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(l10n.snackbarCalendarAdded),
                ),
              );
            },
            onCalendarOpenPlan: (p) => _openPlanPreview(context, p),
          ),
          TerritoryMapPage(displayName: profile.displayName),
          ProgressPage(
            plans: plans,
            completions: completions,
            onOpenStreak: () => _openStreak(context),
            onSeeAllHistory: () => _openHistory(context),
          ),
          ProfilePage(
            profile: profile,
            onProfileChanged: (p) {
              unawaited(_t.updateProfile(p));
            },
            onLocaleChanged: widget.onLocaleChanged,
            onLogWorkout: () => _logWorkout(context),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today_rounded),
            label: l10n.navToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center_outlined),
            selectedIcon: const Icon(Icons.fitness_center_rounded),
            label: l10n.navWorkouts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map_rounded),
            label: l10n.navMap,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights_rounded),
            label: l10n.navProgress,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: l10n.navYou,
          ),
        ],
      ),
    );
  }
}
