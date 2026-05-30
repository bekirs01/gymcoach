import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/premium_background.dart';
import '../../../core/workout_exercise_catalog.dart';
import '../domain/workout_plan.dart';

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
          backgroundColor: PremiumColors.surfaceRaised,
          title: Text(l10n.deletePlanTitle, style: const TextStyle(color: Colors.white)),
          content: Text(
            l10n.deletePlanConfirm(plan.name),
            style: const TextStyle(color: PremiumColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel, style: const TextStyle(color: PremiumColors.textSecondary)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF453A)),
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
    final heroImage = WorkoutExerciseCatalog.imageForName(
      plan.exerciseNames.isEmpty ? null : plan.exerciseNames.first,
    );

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: Text(
            l10n.planDetailTitle,
            style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
          ),
          actions: [
            IconButton(
              onPressed: () => _confirmDelete(context),
              icon: const Icon(Icons.delete_outline_rounded),
              color: PremiumColors.textSecondary,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroCard(
                        plan: plan,
                        imageAsset: heroImage,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 18),
                      _InfoCard(
                        title: l10n.planDetailSchedule,
                        children: [
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: l10n.labelDate,
                            value: plan.formattedDate,
                          ),
                          _DetailRow(
                            icon: Icons.schedule_rounded,
                            label: l10n.labelTime,
                            value: plan.formattedTime,
                          ),
                          _DetailRow(
                            icon: Icons.timer_outlined,
                            label: l10n.labelDuration,
                            value: l10n.durationMinutesLabel(plan.durationMinutes),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.planDetailExercises,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final name in plan.exerciseNames) ...[
                        _ExerciseRow(name: name),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton(
                        onPressed: plan.status == PlanStatus.planned ? onBeginSession : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: PremiumColors.accentBlue,
                          disabledBackgroundColor: PremiumColors.surfaceRaised,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(PremiumRadii.md),
                          ),
                        ),
                        child: Text(
                          l10n.beginSession,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ),
                      if (plan.status != PlanStatus.planned) ...[
                        const SizedBox(height: 8),
                        Text(
                          l10n.planSessionOnlyPlanned,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: onEdit,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PremiumColors.accentBlue,
                          side: BorderSide(color: PremiumColors.accentBlue.withValues(alpha: 0.7)),
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(PremiumRadii.md),
                          ),
                        ),
                        child: Text(
                          l10n.editPlan,
                          style: const TextStyle(fontWeight: FontWeight.w700),
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
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.plan,
    required this.imageAsset,
    required this.l10n,
  });

  final WorkoutPlan plan;
  final String? imageAsset;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageAsset != null)
            Image.asset(imageAsset!, fit: BoxFit.cover, filterQuality: FilterQuality.high)
          else
            Container(color: PremiumColors.surfaceRaised),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.78),
                  Colors.black.withValues(alpha: 0.34),
                  Colors.black.withValues(alpha: 0.12),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TagChip(
                      label: switch (plan.status) {
                        PlanStatus.planned => l10n.statusPlanned,
                        PlanStatus.completed => l10n.statusCompleted,
                        PlanStatus.missed => l10n.statusMissed,
                      },
                      color: switch (plan.status) {
                        PlanStatus.planned => PremiumColors.accentBlue,
                        PlanStatus.completed => PremiumColors.successGreen,
                        PlanStatus.missed => const Color(0xFFFF453A),
                      },
                    ),
                    _TagChip(
                      label: switch (plan.difficulty) {
                        PlanDifficulty.beginner => l10n.difficultyBeginner,
                        PlanDifficulty.intermediate => l10n.difficultyIntermediate,
                        PlanDifficulty.advanced => l10n.difficultyAdvanced,
                      },
                      color: PremiumColors.textSecondary,
                    ),
                    _TagChip(
                      label: l10n.exercisesCount(plan.exerciseNames.length),
                      color: PremiumColors.textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(PremiumRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: PremiumColors.accentBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: PremiumColors.textMuted, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final imageAsset = WorkoutExerciseCatalog.imageForName(name);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 56,
              child: imageAsset == null
                  ? Container(
                      color: PremiumColors.accentBlue.withValues(alpha: 0.16),
                      child: const Icon(Icons.fitness_center_rounded, color: PremiumColors.accentBlue),
                    )
                  : Image.asset(imageAsset, fit: BoxFit.cover, filterQuality: FilterQuality.high),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: PremiumColors.accentBlue, size: 20),
        ],
      ),
    );
  }
}
