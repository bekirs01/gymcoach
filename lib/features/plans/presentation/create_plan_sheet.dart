import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../core/workout_exercise_catalog.dart';
import '../domain/workout_plan.dart';

Future<void> showCreatePlanSheet({
  required BuildContext context,
  required ValueChanged<WorkoutPlan> onSaved,
  WorkoutPlan? existingPlan,
  DateTime? initialDate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
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
  final TextEditingController _durationController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late PlanDifficulty _difficulty;
  final Set<String> _selectedExercises = {};
  String? _validationMessage;
  var _hydratedExercises = false;

  static const List<int> _durationPresets = [15, 30, 45, 60, 75, 90, 120];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingPlan;
    if (existing != null) {
      _nameController.text = existing.name;
      _selectedDate = WorkoutPlan.dateOnly(existing.scheduledDate);
      _selectedTime = existing.scheduledTime;
      _durationController.text = '${existing.durationMinutes}';
      _difficulty = existing.difficulty;
    } else {
      _selectedDate = WorkoutPlan.dateOnly(widget.initialDate ?? DateTime.now());
      _selectedTime = const TimeOfDay(hour: 18, minute: 30);
      _durationController.text = '45';
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
    _selectedExercises.addAll(existing.exerciseNames);
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  int? get _parsedDuration => int.tryParse(_durationController.text.trim());

  void _selectDurationPreset(int minutes) {
    setState(() => _durationController.text = '$minutes');
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

  void _toggleExercise(String name) {
    setState(() {
      if (_selectedExercises.contains(name)) {
        _selectedExercises.remove(name);
      } else {
        _selectedExercises.add(name);
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
    final duration = _parsedDuration;
    if (duration == null || duration < 5 || duration > 300) {
      setState(() => _validationMessage = 'Duration must be between 5 and 300 minutes.');
      return;
    }

    final names = _selectedExercises.toList()..sort();

    final plan = WorkoutPlan(
      id: widget.existingPlan?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      scheduledDate: _selectedDate,
      scheduledTime: _selectedTime,
      durationMinutes: duration,
      difficulty: _difficulty,
      exerciseNames: names,
      status: widget.existingPlan?.status ?? PlanStatus.planned,
    );

    Navigator.of(context).pop();
    widget.onSaved(plan);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maxH = MediaQuery.sizeOf(context).height * 0.92;
    final title = widget.existingPlan == null ? l10n.createPlanTitle : l10n.editPlanSheetTitle;
    final saveLabel = widget.existingPlan == null ? l10n.savePlan : l10n.updatePlan;

    return Container(
      height: maxH,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: PremiumColors.midnightMid,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
            child: Row(
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: PremiumColors.textSecondary,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      labelText: l10n.workoutNameLabel,
                      hintText: l10n.workoutNameHint,
                      labelStyle: const TextStyle(color: PremiumColors.textMuted),
                      hintStyle: TextStyle(color: PremiumColors.textMuted.withValues(alpha: 0.7)),
                      filled: true,
                      fillColor: PremiumColors.surface,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(PremiumRadii.md),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(PremiumRadii.md),
                        borderSide: const BorderSide(color: PremiumColors.accentBlue, width: 1.4),
                      ),
                    ),
                    onChanged: (_) => setState(() => _validationMessage = null),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel(l10n.dateLabel),
                            const SizedBox(height: 8),
                            _PickerTile(
                              value:
                                  '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                              icon: Icons.calendar_month_rounded,
                              onTap: _pickDate,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel(l10n.timeLabel),
                            const SizedBox(height: 8),
                            _PickerTile(
                              value: _selectedTime.format(context),
                              icon: Icons.schedule_rounded,
                              onTap: _pickTime,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SectionLabel(l10n.durationLabel),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '45',
                      suffixText: 'min',
                      suffixStyle: const TextStyle(color: PremiumColors.textMuted, fontWeight: FontWeight.w600),
                      filled: true,
                      fillColor: PremiumColors.surface,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(PremiumRadii.md),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(PremiumRadii.md),
                        borderSide: const BorderSide(color: PremiumColors.accentBlue, width: 1.4),
                      ),
                    ),
                    onChanged: (_) => setState(() => _validationMessage = null),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _durationPresets.map((m) {
                      final selected = _parsedDuration == m;
                      return ChoiceChip(
                        label: Text(l10n.chipMinutes(m)),
                        selected: selected,
                        onSelected: (_) => _selectDurationPreset(m),
                        backgroundColor: PremiumColors.surface,
                        selectedColor: PremiumColors.accentBlue.withValues(alpha: 0.24),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : PremiumColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: selected
                              ? PremiumColors.accentBlue
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _SectionLabel(l10n.exercisesLabel),
                      const Spacer(),
                      Text(
                        l10n.exercisesSelected(_selectedExercises.length),
                        style: const TextStyle(
                          color: PremiumColors.accentBlue,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final category in WorkoutExerciseCatalog.categories) ...[
                    Text(
                      category.title,
                      style: const TextStyle(
                        color: PremiumColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final exercise in category.exercises) ...[
                      _EditExerciseRow(
                        exercise: exercise,
                        selected: _selectedExercises.contains(exercise.name),
                        onTap: () => _toggleExercise(exercise.name),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 6),
                  ],
                  if (_validationMessage != null) ...[
                    Text(
                      _validationMessage!,
                      style: const TextStyle(
                        color: Color(0xFFFF453A),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PremiumColors.textSecondary,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(PremiumRadii.md),
                        ),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: PremiumColors.accentBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(PremiumRadii.md),
                        ),
                      ),
                      child: Text(saveLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PremiumColors.surface,
      borderRadius: BorderRadius.circular(PremiumRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PremiumRadii.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(icon, color: PremiumColors.accentBlue),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditExerciseRow extends StatelessWidget {
  const _EditExerciseRow({
    required this.exercise,
    required this.selected,
    required this.onTap,
  });

  final WorkoutExerciseEntry exercise;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PremiumColors.surface,
      borderRadius: BorderRadius.circular(PremiumRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PremiumRadii.md),
            border: Border.all(
              color: selected
                  ? PremiumColors.accentBlue.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.1),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.asset(
                    exercise.imageAsset,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? PremiumColors.accentBlue : PremiumColors.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
