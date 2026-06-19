import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/workout_plan.dart';
import 'plans_widgets.dart';

Future<void> showPlanPreviewSheet({
  required BuildContext context,
  required WorkoutPlan plan,
  required VoidCallback onStart,
  required VoidCallback onEdit,
  required VoidCallback onDuplicate,
  required VoidCallback onDeleted,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return PlanPreviewSheet(
        plan: plan,
        onStart: () {
          Navigator.of(sheetContext).pop();
          onStart();
        },
        onEdit: () {
          Navigator.of(sheetContext).pop();
          onEdit();
        },
        onDuplicate: () {
          Navigator.of(sheetContext).pop();
          onDuplicate();
        },
        onDeleted: onDeleted,
      );
    },
  );
}

class PlanPreviewSheet extends StatelessWidget {
  const PlanPreviewSheet({
    super.key,
    required this.plan,
    required this.onStart,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDeleted,
  });

  final WorkoutPlan plan;
  final VoidCallback onStart;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDeleted;

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deletePlanTitle),
          content: Text(l10n.deletePlanConfirm(plan.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: Theme.of(dialogContext).colorScheme.error),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
    if (ok == true && context.mounted) {
      onDeleted();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    final canStart = plan.status == PlanStatus.planned;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              plan.name,
              style: theme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(status: plan.status),
                DifficultyBadge(difficulty: plan.difficulty),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${plan.formattedDate} · ${plan.formattedTime} · ${l10n.minutesShort(plan.durationMinutes)}',
              style: theme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.planDetailExercises,
              style: theme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.28,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: plan.exerciseNames.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, i) {
                  return Text(
                    '${i + 1}. ${plan.exerciseNames[i]}',
                    style: theme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: canStart ? onStart : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  l10n.homeStartWorkout,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onEdit,
                    child: Text(l10n.editPlan),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: onDuplicate,
                    child: Text(l10n.planDuplicate),
                  ),
                ),
                IconButton(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

WorkoutPlan duplicateWorkoutPlan(WorkoutPlan plan, {DateTime? scheduledDate}) {
  final date = scheduledDate ?? WorkoutPlan.dateOnly(DateTime.now());
  return WorkoutPlan(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    name: plan.name,
    scheduledDate: date,
    scheduledTime: plan.scheduledTime,
    durationMinutes: plan.durationMinutes,
    difficulty: plan.difficulty,
    exerciseNames: List<String>.from(plan.exerciseNames),
    status: PlanStatus.planned,
  );
}
