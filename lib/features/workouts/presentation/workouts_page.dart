import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../calendar/presentation/calendar_page.dart';
import '../../plans/domain/workout_plan.dart';
import '../../plans/presentation/plans_page.dart';
import '../../workout/domain/workout_completion.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({
    super.key,
    required this.plans,
    required this.completions,
    required this.onAddPlan,
    required this.createSheetSignal,
    required this.onPreviewPlan,
    required this.onStartSession,
    required this.onCalendarAddPlan,
    required this.onCalendarOpenPlan,
  });

  final List<WorkoutPlan> plans;
  final List<WorkoutCompletion> completions;
  final ValueChanged<WorkoutPlan> onAddPlan;
  final int createSheetSignal;
  final ValueChanged<WorkoutPlan> onPreviewPlan;
  final ValueChanged<WorkoutPlan> onStartSession;
  final ValueChanged<WorkoutPlan> onCalendarAddPlan;
  final ValueChanged<WorkoutPlan> onCalendarOpenPlan;

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  var _calendarView = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.navWorkouts,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(l10n.workoutsViewList)),
              ButtonSegment(value: true, label: Text(l10n.workoutsViewCalendar)),
            ],
            selected: {_calendarView},
            onSelectionChanged: (s) => setState(() => _calendarView = s.first),
          ),
        ),
        Expanded(
          child: _calendarView
              ? CalendarPage(
                  plans: widget.plans,
                  completions: widget.completions,
                  onAddPlan: widget.onCalendarAddPlan,
                  onOpenPlan: widget.onCalendarOpenPlan,
                  embedded: true,
                )
              : PlansPage(
                  plans: widget.plans,
                  onAddPlan: widget.onAddPlan,
                  createSheetSignal: widget.createSheetSignal,
                  onPreviewPlan: widget.onPreviewPlan,
                  onStartSession: widget.onStartSession,
                  embedded: true,
                ),
        ),
      ],
    );
  }
}
