import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/premium_background.dart';
import '../../../app/widgets/workout_image.dart';
import '../../../core/workout_exercise_l10n.dart';
import '../../../core/workout_image_resolver.dart';
import '../domain/workout_plan.dart';
import 'delete_workout_sheet.dart';

class PlanDetailPage extends StatelessWidget {
  const PlanDetailPage({
    super.key,
    required this.plan,
    required this.onBeginSession,
    required this.onEdit,
    required this.onDelete,
    this.onRepeatWorkout,
    this.onCustomizeRepeat,
  });

  final WorkoutPlan plan;
  final VoidCallback onBeginSession;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;
  final VoidCallback? onRepeatWorkout;
  final VoidCallback? onCustomizeRepeat;

  Future<void> _confirmDelete(BuildContext context) async {
    await confirmDeleteWorkout(
      context: context,
      plan: plan,
      onDelete: onDelete,
      popOnSuccess: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final heroImage = WorkoutImageResolver.resolveAssetPath(
      exerciseNames: plan.exerciseNames,
      workoutName: plan.name,
    );
    final isCompleted = plan.status == PlanStatus.completed;

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
            WorkoutDeleteIconButton(onPressed: () => _confirmDelete(context)),
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
                        _ExerciseRow(name: name, l10n: l10n),
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
                      if (isCompleted) ...[
                        Text(
                          l10n.planCompletedHint,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12, height: 1.35),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: onRepeatWorkout,
                          icon: const Icon(Icons.event_repeat_rounded),
                          label: Text(l10n.planRepeatWorkout),
                          style: FilledButton.styleFrom(
                            backgroundColor: PremiumColors.accentBlue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(PremiumRadii.md),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: onCustomizeRepeat,
                          icon: const Icon(Icons.tune_rounded),
                          label: Text(l10n.planCustomizeRepeat),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: PremiumColors.accentBlue,
                            side: BorderSide(color: PremiumColors.accentBlue.withValues(alpha: 0.7)),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(PremiumRadii.md),
                            ),
                          ),
                        ),
                      ] else ...[
                        FilledButton(
                          onPressed: plan.exerciseNames.isNotEmpty ? onBeginSession : null,
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
  final String imageAsset;
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
          WorkoutImage(
            localImageAsset: imageAsset,
            exerciseNames: plan.exerciseNames,
            workoutName: plan.name,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
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
  const _ExerciseRow({required this.name, required this.l10n});

  final String name;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final displayName = WorkoutExerciseL10n.name(l10n, name);

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
              child: WorkoutImage(
                exerciseNames: [name],
                workoutName: name,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayName,
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
