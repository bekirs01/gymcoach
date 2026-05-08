import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../plans/domain/workout_plan.dart';
import '../../plans/presentation/plans_widgets.dart';
import '../domain/workout_completion.dart';

class WorkoutSessionPage extends StatefulWidget {
  const WorkoutSessionPage({
    super.key,
    required this.plan,
    required this.onFinished,
  });

  final WorkoutPlan plan;
  final ValueChanged<WorkoutCompletion> onFinished;

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  late DateTime _startedAt;
  var _index = 0;
  final _done = <int>{};
  var _showSummary = false;
  late WorkoutCompletion _summary;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
  }

  void _completeCurrent() {
    setState(() {
      _done.add(_index);
      if (_index < widget.plan.exerciseNames.length - 1) {
        _index++;
      }
    });
  }

  void _finishWorkout() {
    final l10n = AppLocalizations.of(context)!;
    final elapsed = DateTime.now().difference(_startedAt).inMinutes.clamp(1, 999);
    final calories = (elapsed * 9 + widget.plan.exerciseNames.length * 12).round();
    _summary = WorkoutCompletion(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: widget.plan.name,
      workoutType: l10n.workoutTypePlannedSession,
      completedAt: DateTime.now(),
      durationMinutes: elapsed,
      calories: calories,
      exerciseNames: List<String>.from(widget.plan.exerciseNames),
    );
    setState(() => _showSummary = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_showSummary) {
      return _SessionSummaryView(
        completion: _summary,
        onClose: () {
          widget.onFinished(_summary);
          Navigator.of(context).pop();
        },
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    final names = widget.plan.exerciseNames;
    final current = names[_index];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.sessionActiveTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.plan.name,
                style: theme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  DifficultyBadge(difficulty: widget.plan.difficulty),
                  _ChipMeta(
                    icon: Icons.timer_outlined,
                    label: l10n.minutesPlanShort(widget.plan.durationMinutes),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l10n.sessionCurrentExercise,
                style: theme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.borderSubtle),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current,
                        style: theme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: l10n.labelSets,
                                hintText: '0',
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              enabled: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: l10n.labelReps,
                                hintText: '0',
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              enabled: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.sessionAllExercises,
                style: theme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: names.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final done = _done.contains(i);
                    final active = i == _index;
                    return Material(
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: active ? AppColors.primary : AppColors.borderSubtle,
                          width: active ? 1.4 : 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          names[i],
                          style: theme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: Icon(
                          done || i < _index ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: done || i < _index ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _completeCurrent,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _index >= names.length - 1 ? l10n.sessionCompleteFinal : l10n.sessionCompleteExercise,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _finishWorkout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.sessionFinishWorkout,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipMeta extends StatelessWidget {
  const _ChipMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.successTint.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
          ),
        ],
      ),
    );
  }
}

class _SessionSummaryView extends StatelessWidget {
  const _SessionSummaryView({
    required this.completion,
    required this.onClose,
  });

  final WorkoutCompletion completion;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.sessionSummaryTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
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
                        completion.title,
                        style: theme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryTile(
                              label: l10n.sessionSummaryDuration,
                              value: l10n.minutesShort(completion.durationMinutes),
                              icon: Icons.schedule_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryTile(
                              label: l10n.sessionSummaryCalories,
                              value: l10n.sessionCaloriesUnit(completion.calories),
                              icon: Icons.local_fire_department_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.sessionCompletedExercises,
                        style: theme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...completion.exerciseNames.map(
                        (n) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  n,
                                  style: theme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onClose,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.sessionDone,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(label, style: theme.labelSmall?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
