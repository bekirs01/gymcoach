import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/workout_plan.dart';
import 'plans_widgets.dart';

class PlanDetailPage extends StatelessWidget {
  const PlanDetailPage({
    super.key,
    required this.plan,
    required this.onBeginSession,
    required this.onEdit,
    required this.onDeleted,
  });

  final WorkoutPlan plan;
  final VoidCallback onBeginSession;
  final VoidCallback onEdit;
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
    final theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.planDetailTitle),
        actions: [
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.name,
                style: theme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  StatusBadge(status: plan.status),
                  DifficultyBadge(difficulty: plan.difficulty),
                ],
              ),
              const SizedBox(height: 24),
              PlansSectionHeader(title: l10n.planDetailSchedule),
              const SizedBox(height: 12),
              _DetailRow(icon: Icons.calendar_today_outlined, label: l10n.labelDate, value: plan.formattedDate),
              _DetailRow(icon: Icons.schedule_rounded, label: l10n.labelTime, value: plan.formattedTime),
              _DetailRow(
                icon: Icons.timer_outlined,
                label: l10n.labelDuration,
                value: l10n.durationMinutesLabel(plan.durationMinutes),
              ),
              const SizedBox(height: 24),
              PlansSectionHeader(title: l10n.planDetailExercises),
              const SizedBox(height: 12),
              ...plan.exerciseNames.map(
                (name) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.check_circle_outline_rounded, color: AppColors.primary),
                      title: Text(
                        name,
                        style: theme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: plan.status == PlanStatus.planned ? onBeginSession : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.beginSession,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (plan.status != PlanStatus.planned) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.planSessionOnlyPlanned,
                  style: theme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.editPlan,
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.labelSmall?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
