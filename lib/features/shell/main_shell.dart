import 'package:flutter/material.dart';

import '../home/presentation/home_page.dart';
import '../plans/presentation/plans_page.dart';
import '../plans/presentation/plan_detail_page.dart';
import '../plans/domain/workout_plan.dart';
import '../calendar/presentation/calendar_placeholder_page.dart';
import '../progress/presentation/progress_placeholder_page.dart';
import '../profile/presentation/profile_placeholder_page.dart';
import '../../app/theme/app_colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  int _plansCreateSignal = 0;
  late List<WorkoutPlan> _plans;

  @override
  void initState() {
    super.initState();
    _plans = WorkoutPlan.samplePlans();
  }

  void _addPlan(WorkoutPlan plan) {
    setState(() => _plans.insert(0, plan));
  }

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

  void _openPlanDetail(WorkoutPlan plan) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) => PlanDetailPage(
          plan: plan,
          onStartWorkout: () {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Workout session will open here in a future update.'),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(
            plans: _plans,
            onNavigateToPlans: () => _goToPlansTab(),
            onNavigateToPlansCreate: () => _goToPlansTab(openCreateSheet: true),
            onNavigateToProgress: _goToProgressTab,
            onOpenPlanDetail: _openPlanDetail,
          ),
          PlansPage(
            plans: _plans,
            onAddPlan: _addPlan,
            createSheetSignal: _plansCreateSignal,
            onOpenPlanDetail: _openPlanDetail,
          ),
          const CalendarPlaceholderPage(),
          const ProgressPlaceholderPage(),
          const ProfilePlaceholderPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center_rounded),
            label: 'Plans',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
