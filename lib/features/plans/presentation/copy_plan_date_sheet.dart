import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/workout_plan.dart';

Future<DateTime?> showCopyPlanDateSheet({
  required BuildContext context,
  required WorkoutPlan plan,
  DateTime? initialDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _CopyPlanDateSheet(plan: plan, initialDate: initialDate),
  );
}

class _CopyPlanDateSheet extends StatefulWidget {
  const _CopyPlanDateSheet({required this.plan, this.initialDate});

  final WorkoutPlan plan;
  final DateTime? initialDate;

  @override
  State<_CopyPlanDateSheet> createState() => _CopyPlanDateSheetState();
}

class _CopyPlanDateSheetState extends State<_CopyPlanDateSheet> {
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = WorkoutPlan.dateOnly(widget.initialDate ?? DateTime.now());
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _date = WorkoutPlan.dateOnly(picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    final dateStr =
        '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.copyPlanTitle,
                style: theme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.plan.name,
                style: theme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(dateStr, style: theme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                trailing: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context, _date),
                child: Text(l10n.copyPlanConfirm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
