import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/exercise_catalog.dart';
import '../../../core/session_calorie_estimator.dart';
import '../../profile/domain/user_profile.dart';
import '../domain/completed_exercise_log.dart';
import '../domain/workout_completion.dart';
import '../../plans/domain/workout_plan.dart';

Future<void> showQuickLogSheet({
  required BuildContext context,
  required UserProfile profile,
  required ValueChanged<WorkoutCompletion> onSaved,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    barrierColor: Colors.black45,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: _QuickLogSheet(profile: profile, onSaved: onSaved),
      );
    },
  );
}

class _QuickLogEntry {
  _QuickLogEntry({required this.name}) : sets = 3, reps = 10;

  final String name;
  int sets;
  int reps;
}

class _QuickLogSheet extends StatefulWidget {
  const _QuickLogSheet({required this.profile, required this.onSaved});

  final UserProfile profile;
  final ValueChanged<WorkoutCompletion> onSaved;

  @override
  State<_QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends State<_QuickLogSheet> {
  final TextEditingController _nameController = TextEditingController();
  late DateTime _workoutDate;
  final List<_QuickLogEntry> _entries = [];
  final Set<String> _selectedCatalog = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _workoutDate = WorkoutPlan.dateOnly(DateTime.now());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _setRelativeDate(int daysAgo) {
    setState(() => _workoutDate = WorkoutPlan.dateOnly(DateTime.now().subtract(Duration(days: daysAgo))));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _workoutDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: WorkoutPlan.dateOnly(DateTime.now()),
    );
    if (picked != null) {
      setState(() => _workoutDate = WorkoutPlan.dateOnly(picked));
    }
  }

  void _toggleFromCatalog(String canonical) {
    final l10n = AppLocalizations.of(context)!;
    final label = ExerciseCatalog.label(l10n, canonical);
    setState(() {
      if (_selectedCatalog.contains(canonical)) {
        _selectedCatalog.remove(canonical);
        _entries.removeWhere((e) => e.name == label);
      } else {
        _selectedCatalog.add(canonical);
        _entries.add(_QuickLogEntry(name: label));
      }
      _error = null;
    });
  }

  Future<void> _addCustom() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.quickLogAddExercise),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l10n.exercisesLabel),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
    if (name == null || name.isEmpty) return;
    if (_entries.any((e) => e.name == name)) return;
    setState(() {
      _entries.add(_QuickLogEntry(name: name));
      _error = null;
    });
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final title = _nameController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = l10n.validationLogName);
      return;
    }
    if (_entries.isEmpty) {
      setState(() => _error = l10n.validationPickExercise);
      return;
    }

    final completedAt = DateTime(
      _workoutDate.year,
      _workoutDate.month,
      _workoutDate.day,
      12,
    );
    final logs = <CompletedExerciseLog>[];
    for (var i = 0; i < _entries.length; i++) {
      final e = _entries[i];
      if (e.sets <= 0 || e.reps <= 0) continue;
      final cat = SessionCalorieEstimator.categoryKeyForName(e.name);
      logs.add(
        CompletedExerciseLog(
          exerciseId: 'quick_${completedAt.microsecondsSinceEpoch}_$i',
          exerciseName: e.name,
          setsCompleted: e.sets,
          repsCompleted: e.reps,
          estimatedCalories: SessionCalorieEstimator.kcalForExercise(
            weightKg: widget.profile.weightKg,
            heightCm: widget.profile.heightCm,
            categoryKey: cat,
            sets: e.sets,
            reps: e.reps,
          ),
          completedAt: completedAt,
          categoryKey: cat,
        ),
      );
    }
    if (logs.isEmpty) {
      setState(() => _error = l10n.sessionValidationSetsReps);
      return;
    }

    final duration = (logs.length * 8).clamp(10, 180);
    final calories = SessionCalorieEstimator.sessionKcalFromLogs(
      weightKg: widget.profile.weightKg,
      heightCm: widget.profile.heightCm,
      difficulty: PlanDifficulty.intermediate,
      durationMinutes: duration,
      exerciseCount: logs.length,
      logs: logs,
    );

    final completion = WorkoutCompletion(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      workoutType: l10n.logWorkoutTypeDefault,
      completedAt: completedAt,
      durationMinutes: duration,
      calories: calories,
      exerciseNames: logs.map((l) => l.exerciseName).toList(),
      exerciseLogs: logs,
      caloriesAreEstimated: true,
    );
    Navigator.of(context).pop();
    widget.onSaved(completion);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    final maxH = MediaQuery.sizeOf(context).height * 0.92;
    final dateLabel =
        '${_workoutDate.year}-${_workoutDate.month.toString().padLeft(2, '0')}-${_workoutDate.day.toString().padLeft(2, '0')}';

    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.borderSubtle,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: l10n.closeTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                l10n.quickLogTitle,
                style: theme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.logWorkoutName,
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (_) => setState(() => _error = null),
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.quickLogDate, style: theme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(l10n.quickLogYesterday),
                          selected: WorkoutPlan.isSameDay(_workoutDate, DateTime.now().subtract(const Duration(days: 1))),
                          onSelected: (_) => _setRelativeDate(1),
                        ),
                        ChoiceChip(
                          label: Text(l10n.quickLogDayBefore),
                          selected: WorkoutPlan.isSameDay(_workoutDate, DateTime.now().subtract(const Duration(days: 2))),
                          onSelected: (_) => _setRelativeDate(2),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.calendar_month_rounded, size: 18),
                          label: Text(dateLabel),
                          onPressed: _pickDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.exercisesLabel, style: theme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ExerciseCatalog.canonicalNames.map((c) {
                        final selected = _selectedCatalog.contains(c);
                        return FilterChip(
                          label: Text(ExerciseCatalog.label(l10n, c)),
                          selected: selected,
                          showCheckmark: true,
                          checkmarkColor: AppColors.primaryDark,
                          selectedColor: AppColors.successTint,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selected ? AppColors.primaryDark : AppColors.textSecondary,
                          ),
                          side: BorderSide(
                            color: selected ? AppColors.primary : AppColors.borderSubtle,
                          ),
                          onSelected: (_) => _toggleFromCatalog(c),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _addCustom,
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.quickLogAddExercise),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < _entries.length; i++) ...[
                      _EntryRow(
                        entry: _entries[i],
                        onChanged: () => setState(() {}),
                        onRemove: () {
                          final removed = _entries[i].name;
                          setState(() {
                            _entries.removeAt(i);
                            for (final c in ExerciseCatalog.canonicalNames) {
                              if (ExerciseCatalog.label(l10n, c) == removed) {
                                _selectedCatalog.remove(c);
                              }
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (_error != null)
                      Text(
                        _error!,
                        style: theme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l10n.logSave, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryRow extends StatefulWidget {
  const _EntryRow({required this.entry, required this.onChanged, required this.onRemove});

  final _QuickLogEntry entry;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  State<_EntryRow> createState() => _EntryRowState();
}

class _EntryRowState extends State<_EntryRow> {
  late final TextEditingController _setsController;
  late final TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController(text: '${widget.entry.sets}');
    _repsController = TextEditingController(text: '${widget.entry.reps}');
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.entry.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(onPressed: widget.onRemove, icon: const Icon(Icons.close_rounded, size: 20)),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: l10n.labelSets, isDense: true),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: _setsController,
                    onChanged: (v) {
                      widget.entry.sets = int.tryParse(v) ?? widget.entry.sets;
                      widget.onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: l10n.labelReps, isDense: true),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: _repsController,
                    onChanged: (v) {
                      widget.entry.reps = int.tryParse(v) ?? widget.entry.reps;
                      widget.onChanged();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
