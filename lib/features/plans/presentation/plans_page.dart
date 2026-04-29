import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/workout_plan.dart';
import 'create_plan_sheet.dart';
import 'plans_widgets.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({
    super.key,
    required this.plans,
    required this.onAddPlan,
    required this.createSheetSignal,
    required this.onOpenPlanDetail,
  });

  final List<WorkoutPlan> plans;
  final ValueChanged<WorkoutPlan> onAddPlan;
  final int createSheetSignal;
  final ValueChanged<WorkoutPlan> onOpenPlanDetail;

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  int _lastCreateSignal = 0;

  @override
  void didUpdateWidget(PlansPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.createSheetSignal != _lastCreateSignal &&
        widget.createSheetSignal > 0) {
      _lastCreateSignal = widget.createSheetSignal;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openCreateSheet();
      });
    }
  }

  List<WorkoutPlan> get _sortedPlans {
    final copy = List<WorkoutPlan>.from(widget.plans);
    copy.sort((a, b) {
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
    return copy;
  }

  int get _plannedCount =>
      widget.plans.where((p) => p.status == PlanStatus.planned).length;

  int get _completedCount =>
      widget.plans.where((p) => p.status == PlanStatus.completed).length;

  int get _weekCount => widget.plans
      .where((p) => WorkoutPlan.isInSameCalendarWeek(p.scheduledDate, DateTime.now()))
      .length;

  void _openCreateSheet() {
    showCreatePlanSheet(
      context: context,
      onSaved: (plan) {
        widget.onAddPlan(plan);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Workout plan created'),
          ),
        );
      },
    );
  }

  void _openDetail(WorkoutPlan plan) {
    widget.onOpenPlanDetail(plan);
  }

  void _quickStart(WorkoutPlan plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Starting "${plan.name}" will be available soon.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final plans = _sortedPlans;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workout Plans',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Plan your training and stay consistent.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                              height: 1.35,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _openCreateSheet,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Create Plan'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: PlansMetricTile(
                    label: 'Planned workouts',
                    value: '$_plannedCount',
                    icon: Icons.event_note_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PlansMetricTile(
                    label: 'Completed workouts',
                    value: '$_completedCount',
                    icon: Icons.task_alt_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PlansMetricTile(
                    label: 'This week',
                    value: '$_weekCount',
                    icon: Icons.date_range_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
          sliver: SliverToBoxAdapter(
            child: PlansSectionHeader(
              title: 'Your plans',
              subtitle: plans.isEmpty ? null : '${plans.length} total',
            ),
          ),
        ),
        if (plans.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: SliverToBoxAdapter(
              child: _PlansEmptyState(onCreate: _openCreateSheet),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            sliver: SliverList.separated(
              itemBuilder: (context, index) {
                final plan = plans[index];
                return WorkoutPlanCard(
                  plan: plan,
                  onOpen: () => _openDetail(plan),
                  onStart: () => _quickStart(plan),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemCount: plans.length,
            ),
          ),
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ),
      ],
    );
  }
}

class _PlansEmptyState extends StatelessWidget {
  const _PlansEmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.successTint.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No workout plans yet',
              style: theme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Create your first plan and start building consistency.',
              style: theme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Plan'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
