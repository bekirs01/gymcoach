import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../plans/domain/workout_plan.dart';
import '../../plans/presentation/create_plan_sheet.dart';
import '../../plans/presentation/plans_widgets.dart';
import '../../workout/domain/workout_completion.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({
    super.key,
    required this.plans,
    required this.completions,
    required this.onAddPlan,
    required this.onOpenPlan,
  });

  final List<WorkoutPlan> plans;
  final List<WorkoutCompletion> completions;
  final ValueChanged<WorkoutPlan> onAddPlan;
  final ValueChanged<WorkoutPlan> onOpenPlan;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _month;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selected = WorkoutPlan.dateOnly(now);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  Set<DateTime> _completedDays() {
    final out = <DateTime>{};
    for (final p in widget.plans) {
      if (p.status == PlanStatus.completed) {
        out.add(WorkoutPlan.dateOnly(p.scheduledDate));
      }
    }
    for (final c in widget.completions) {
      out.add(WorkoutPlan.dateOnly(c.completedAt));
    }
    return out;
  }

  Set<DateTime> _plannedDays() {
    final out = <DateTime>{};
    for (final p in widget.plans) {
      if (p.status == PlanStatus.planned) {
        out.add(WorkoutPlan.dateOnly(p.scheduledDate));
      }
    }
    return out;
  }

  List<WorkoutPlan> _plansForDay(DateTime day) {
    return widget.plans.where((p) => WorkoutPlan.isSameDay(p.scheduledDate, day)).toList()
      ..sort((a, b) {
        final ta = a.scheduledTime.hour * 60 + a.scheduledTime.minute;
        final tb = b.scheduledTime.hour * 60 + b.scheduledTime.minute;
        return ta.compareTo(tb);
      });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;
    final completedDays = _completedDays();
    final plannedDays = _plannedDays();
    final selectedPlans = _plansForDay(_selected);
    final selectedDateStr =
        '${_selected.year}-${_selected.month.toString().padLeft(2, '0')}-${_selected.day.toString().padLeft(2, '0')}';

    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leadingBlanks = firstWeekday - 1;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.calendarTitle,
                    style: theme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _shiftMonth(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Text(
                  '${_month.year}-${_month.month.toString().padLeft(2, '0')}',
                  style: theme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                IconButton(
                  onPressed: () => _shiftMonth(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _WeekLabel(l10n.calendarDow1),
                        _WeekLabel(l10n.calendarDow2),
                        _WeekLabel(l10n.calendarDow3),
                        _WeekLabel(l10n.calendarDow4),
                        _WeekLabel(l10n.calendarDow5),
                        _WeekLabel(l10n.calendarDow6),
                        _WeekLabel(l10n.calendarDow7),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: leadingBlanks + daysInMonth,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        if (index < leadingBlanks) {
                          return const SizedBox.shrink();
                        }
                        final day = index - leadingBlanks + 1;
                        final date = DateTime(_month.year, _month.month, day);
                        final key = WorkoutPlan.dateOnly(date);
                        final selected = WorkoutPlan.isSameDay(_selected, date);
                        final completed = completedDays.contains(key);
                        final planned = plannedDays.contains(key);

                        return _DayCell(
                          label: '$day',
                          selected: selected,
                          completed: completed,
                          planned: planned,
                          onTap: () => setState(() => _selected = key),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.calendarWorkoutsOn(selectedDateStr),
                    style: theme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    showCreatePlanSheet(
                      context: context,
                      initialDate: _selected,
                      onSaved: widget.onAddPlan,
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(l10n.add),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (selectedPlans.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.borderSubtle),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    l10n.calendarEmptyDay,
                    style: theme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            sliver: SliverList.separated(
              itemCount: selectedPlans.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final plan = selectedPlans[i];
                return Material(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  child: InkWell(
                    onTap: () => widget.onOpenPlan(plan),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.name,
                                  style: theme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${plan.formattedTime} · ${l10n.minutesShort(plan.durationMinutes)}',
                                  style: theme.bodySmall?.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: plan.status),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ),
      ],
    );
  }
}

class _WeekLabel extends StatelessWidget {
  const _WeekLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.label,
    required this.selected,
    required this.completed,
    required this.planned,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool completed;
  final bool planned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    var bg = AppColors.background;
    if (completed) {
      bg = const Color(0xFFDCFCE7);
    } else if (selected) {
      bg = AppColors.successTint.withValues(alpha: 0.85);
    }

    var borderColor = AppColors.borderSubtle;
    var borderWidth = 1.0;
    if (selected) {
      borderColor = AppColors.primary;
      borderWidth = 1.4;
    } else if (planned && !completed) {
      borderColor = AppColors.primary.withValues(alpha: 0.45);
      borderWidth = 1.2;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
      ),
    );
  }
}
