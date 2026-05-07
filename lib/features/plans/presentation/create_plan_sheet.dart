import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/workout_plan.dart';

const List<String> kSelectableExercises = [
  'Push-ups',
  'Squats',
  'Plank',
  'Lunges',
  'Jumping Jacks',
  'Pull-ups',
  'Shoulder Press',
  'Running',
];

Future<void> showCreatePlanSheet({
  required BuildContext context,
  required ValueChanged<WorkoutPlan> onSaved,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: CreatePlanSheet(onSaved: onSaved),
      );
    },
  );
}

class CreatePlanSheet extends StatefulWidget {
  const CreatePlanSheet({
    super.key,
    required this.onSaved,
  });

  final ValueChanged<WorkoutPlan> onSaved;

  @override
  State<CreatePlanSheet> createState() => _CreatePlanSheetState();
}

class _CreatePlanSheetState extends State<CreatePlanSheet> {
  final TextEditingController _nameController = TextEditingController();
  DateTime _selectedDate = WorkoutPlan.dateOnly(DateTime.now());
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 30);
  int _durationMinutes = 45;
  PlanDifficulty _difficulty = PlanDifficulty.intermediate;
  final Set<String> _selectedExercises = {};
  String? _validationMessage;

  static const List<int> _durationOptions = [30, 45, 60, 90];

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
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _validationMessage = 'Please enter a workout name.');
      return;
    }
    if (_selectedExercises.isEmpty) {
      setState(() => _validationMessage = 'Select at least one exercise.');
      return;
    }

    final plan = WorkoutPlan(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      scheduledDate: _selectedDate,
      scheduledTime: _selectedTime,
      durationMinutes: _durationMinutes,
      difficulty: _difficulty,
      exerciseNames: _selectedExercises.toList()..sort(),
      status: PlanStatus.planned,
    );

    Navigator.of(context).pop();
    widget.onSaved(plan);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Create Plan',
                style: theme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Workout name',
                  hintText: 'e.g. Upper Body Power',
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
                'Date',
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
                'Time',
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
                'Duration',
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
                    label: Text('$m min'),
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
                'Difficulty',
                style: theme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<PlanDifficulty>(
                segments: const [
                  ButtonSegment(value: PlanDifficulty.beginner, label: Text('Beginner')),
                  ButtonSegment(value: PlanDifficulty.intermediate, label: Text('Intermediate')),
                  ButtonSegment(value: PlanDifficulty.advanced, label: Text('Advanced')),
                ],
                selected: {_difficulty},
                onSelectionChanged: (s) => setState(() => _difficulty = s.first),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Exercises',
                    style: theme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_selectedExercises.length} selected',
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
                children: kSelectableExercises.map((name) {
                  final selected = _selectedExercises.contains(name);
                  return FilterChip(
                    label: Text(name),
                    selected: selected,
                    onSelected: (_) => _toggleExercise(name),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
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
                  child: const Text(
                    'Save Plan',
                    style: TextStyle(fontWeight: FontWeight.w700),
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
