import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/workout_plan.dart';

class PlansSectionHeader extends StatelessWidget {
  const PlansSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}

class PlansMetricTile extends StatelessWidget {
  const PlansMetricTile({
    super.key,
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

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(
              value,
              style: theme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.labelSmall?.copyWith(
                color: AppColors.textMuted,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({super.key, required this.difficulty});

  final PlanDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    late final String label;
    late final Color bg;
    late final Color fg;

    switch (difficulty) {
      case PlanDifficulty.beginner:
        label = l10n.difficultyBeginner;
        bg = AppColors.successTint;
        fg = AppColors.successForeground;
      case PlanDifficulty.intermediate:
        label = l10n.difficultyIntermediate;
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0369A1);
      case PlanDifficulty.advanced:
        label = l10n.difficultyAdvanced;
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF7C3AED);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final PlanStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    late final String label;
    late final Color bg;
    late final Color fg;

    switch (status) {
      case PlanStatus.planned:
        label = l10n.statusPlanned;
        bg = AppColors.successTint;
        fg = AppColors.successForeground;
      case PlanStatus.completed:
        label = l10n.statusCompleted;
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
      case PlanStatus.missed:
        label = l10n.statusMissed;
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class WorkoutPlanCard extends StatelessWidget {
  const WorkoutPlanCard({
    super.key,
    required this.plan,
    required this.onOpen,
    required this.onStart,
  });

  final WorkoutPlan plan;
  final VoidCallback onOpen;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: theme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                StatusBadge(status: plan.status),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _PlanMeta(icon: Icons.calendar_today_outlined, text: plan.formattedDate),
                _PlanMeta(icon: Icons.schedule_rounded, text: plan.formattedTime),
                _PlanMeta(icon: Icons.timer_outlined, text: l10n.minutesShort(plan.durationMinutes)),
                _PlanMeta(
                  icon: Icons.list_alt_rounded,
                  text: l10n.exercisesCount(plan.exerciseNames.length),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DifficultyBadge(difficulty: plan.difficulty),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: onOpen,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.planCardDetails,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: plan.status == PlanStatus.planned ? onStart : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.planCardStart,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
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

class _PlanMeta extends StatelessWidget {
  const _PlanMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
