import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/exercise_catalog.dart';
import '../domain/workout_plan.dart';

String? _resolveExerciseCanonical(String stored, AppLocalizations l10n) {
  for (final c in ExerciseCatalog.canonicalNames) {
    if (stored == c || stored == ExerciseCatalog.label(l10n, c)) return c;
  }
  return null;
}

Future<void> showCreatePlanSheet({
  required BuildContext context,
  required ValueChanged<WorkoutPlan> onSaved,
  WorkoutPlan? existingPlan,
  DateTime? initialDate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    barrierColor: Colors.black45,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: CreatePlanSheet(
          onSaved: onSaved,
          existingPlan: existingPlan,
          initialDate: initialDate,
        ),
      );
    },
  );
}

class CreatePlanSheet extends StatefulWidget {
  const CreatePlanSheet({
    super.key,
    required this.onSaved,
    this.existingPlan,
    this.initialDate,
  });

  final ValueChanged<WorkoutPlan> onSaved;
  final WorkoutPlan? existingPlan;
  final DateTime? initialDate;

  @override
  State<CreatePlanSheet> createState() => _CreatePlanSheetState();
}

class _CreatePlanSheetState extends State<CreatePlanSheet> {
  final TextEditingController _nameController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _durationMinutes;
  late PlanDifficulty _difficulty;
  final Set<String> _selectedExercises = {};
  String? _validationMessage;
  var _hydratedExercises = false;

  static const List<int> _durationOptions = [30, 45, 60, 90];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingPlan;
    if (existing != null) {
      _nameController.text = existing.name;
      _selectedDate = WorkoutPlan.dateOnly(existing.scheduledDate);
      _selectedTime = existing.scheduledTime;
      _durationMinutes = existing.durationMinutes;
      _difficulty = existing.difficulty;
    } else {
      _selectedDate = WorkoutPlan.dateOnly(widget.initialDate ?? DateTime.now());
      _selectedTime = const TimeOfDay(hour: 18, minute: 30);
      _durationMinutes = 45;
      _difficulty = PlanDifficulty.intermediate;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydratedExercises) return;
    _hydratedExercises = true;
    final existing = widget.existingPlan;
    if (existing == null) return;
    final l10n = AppLocalizations.of(context)!;
    for (final n in existing.exerciseNames) {
      final c = _resolveExerciseCanonical(n, l10n);
      if (c != null) _selectedExercises.add(c);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _selectedDate = WorkoutPlan.dateOnly(picked));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _toggleExercise(String canonical) {
    setState(() {
      if (_selectedExercises.contains(canonical)) {
        _selectedExercises.remove(canonical);
      } else {
        _selectedExercises.add(canonical);
      }
      _validationMessage = null;
    });
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _validationMessage = l10n.validationWorkoutName);
      return;
    }
    if (_selectedExercises.isEmpty) {
      setState(() => _validationMessage = l10n.validationPickExercise);
      return;
    }

    final names = _selectedExercises.map((c) => ExerciseCatalog.label(l10n, c)).toList()..sort();

    final plan = WorkoutPlan(
      id: widget.existingPlan?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      scheduledDate: _selectedDate,
      scheduledTime: _selectedTime,
      durationMinutes: _durationMinutes,
      difficulty: _difficulty,
      exerciseNames: names,
      status: widget.existingPlan?.status ?? PlanStatus.planned,
    );

    Navigator.of(context).pop();
    widget.onSaved(plan);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final maxH = MediaQuery.sizeOf(context).height * 0.92;

    final title = widget.existingPlan == null ? l10n.createPlanTitle : l10n.editPlanSheetTitle;
    final saveLabel = widget.existingPlan == null ? l10n.savePlan : l10n.updatePlan;

    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.max,
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
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                title,
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
                        labelText: l10n.workoutNameLabel,
                        hintText: l10n.workoutNameHint,
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                      onChanged: (_) => setState(() => _validationMessage = null),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.dateLabel,
                      style: theme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      color: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.borderSubtle),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(
                          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                          style: theme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        trailing: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.timeLabel,
                      style: theme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      color: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.borderSubtle),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(
                          _selectedTime.format(context),
                          style: theme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        trailing: const Icon(Icons.schedule_rounded, color: AppColors.primary),
                        onTap: _pickTime,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.durationLabel,
                      style: theme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _durationOptions.map((m) {
                        final selected = _durationMinutes == m;
                        return ChoiceChip(
                          label: Text(l10n.chipMinutes(m)),
                          selected: selected,
                          onSelected: (_) => setState(() => _durationMinutes = m),
                          selectedColor: AppColors.successTint,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selected ? AppColors.primaryDark : AppColors.textSecondary,
                          ),
                          side: BorderSide(
                            color: selected ? AppColors.primary : AppColors.borderSubtle,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.difficultyLabel,
                      style: theme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<PlanDifficulty>(
                      segments: [
                        ButtonSegment(value: PlanDifficulty.beginner, label: Text(l10n.difficultyBeginner)),
                        ButtonSegment(value: PlanDifficulty.intermediate, label: Text(l10n.difficultyIntermediate)),
                        ButtonSegment(value: PlanDifficulty.advanced, label: Text(l10n.difficultyAdvanced)),
                      ],
                      selected: {_difficulty},
                      onSelectionChanged: (s) => setState(() => _difficulty = s.first),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          l10n.exercisesLabel,
                          style: theme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          l10n.exercisesSelected(_selectedExercises.length),
                          style: theme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ExerciseCatalog.canonicalNames.map((canonical) {
                        final selected = _selectedExercises.contains(canonical);
                        return FilterChip(
                          label: Text(ExerciseCatalog.label(l10n, canonical)),
                          selected: selected,
                          onSelected: (_) => _toggleExercise(canonical),
                          selectedColor: AppColors.successTint,
                          checkmarkColor: AppColors.primaryDark,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selected ? AppColors.primaryDark : AppColors.textSecondary,
                          ),
                          side: BorderSide(
                            color: selected ? AppColors.primary : AppColors.borderSubtle,
                          ),
                        );
                      }).toList(),
                    ),
                    if (_validationMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _validationMessage!,
                        style: theme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n.cancel, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          saveLabel,
                          style: const TextStyle(fontWeight: FontWeight.w700),
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
    );
  }
}
