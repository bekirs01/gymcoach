import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../plans/domain/workout_plan.dart';
import '../../plans/presentation/plans_widgets.dart';

class CategoryExercise {
  const CategoryExercise(this.name, this.difficulty);

  final String name;
  final PlanDifficulty difficulty;
}

class CategoryDetailPage extends StatelessWidget {
  const CategoryDetailPage._({
    required this.title,
    required this.description,
    required this.icon,
    required this.exercises,
    required this.examplePlanNames,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<CategoryExercise> exercises;
  final List<String> examplePlanNames;

  factory CategoryDetailPage.forCatalogKey(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    return switch (key) {
      'Strength' => CategoryDetailPage._(
          title: l10n.catStrengthTitle,
          description: l10n.catStrengthDesc,
          icon: Icons.fitness_center_rounded,
          exercises: [
            CategoryExercise(l10n.exBackSquat, PlanDifficulty.intermediate),
            CategoryExercise(l10n.exBenchPress, PlanDifficulty.intermediate),
            CategoryExercise(l10n.exDeadlift, PlanDifficulty.advanced),
            CategoryExercise(l10n.exRomanianDeadlift, PlanDifficulty.intermediate),
            CategoryExercise(l10n.exPullUps, PlanDifficulty.beginner),
          ],
          examplePlanNames: [l10n.planUpperPower, l10n.planLowerStrength, l10n.planFullBodyA],
        ),
      'Cardio' => CategoryDetailPage._(
          title: l10n.catCardioTitle,
          description: l10n.catCardioDesc,
          icon: Icons.directions_run_rounded,
          exercises: [
            CategoryExercise(l10n.exTempoRun, PlanDifficulty.intermediate),
            CategoryExercise(l10n.exCycleIntervals, PlanDifficulty.beginner),
            CategoryExercise(l10n.exRowingSprint, PlanDifficulty.advanced),
            CategoryExercise(l10n.exJumpRope, PlanDifficulty.beginner),
          ],
          examplePlanNames: [l10n.planHiit20, l10n.planSteadyZone2, l10n.planSprintLadder],
        ),
      'Mobility' => CategoryDetailPage._(
          title: l10n.catMobilityTitle,
          description: l10n.catMobilityDesc,
          icon: Icons.self_improvement_rounded,
          exercises: [
            CategoryExercise(l10n.exThoracicRotation, PlanDifficulty.beginner),
            CategoryExercise(l10n.exHipCars, PlanDifficulty.intermediate),
            CategoryExercise(l10n.exAnkleMobility, PlanDifficulty.beginner),
            CategoryExercise(l10n.exShoulderDislocates, PlanDifficulty.beginner),
          ],
          examplePlanNames: [l10n.planMorningReset, l10n.planPreTrainingPrep],
        ),
      'Core' => CategoryDetailPage._(
          title: l10n.catCoreTitle,
          description: l10n.catCoreDesc,
          icon: Icons.accessibility_new_rounded,
          exercises: [
            CategoryExercise(l10n.exPlankVariations, PlanDifficulty.beginner),
            CategoryExercise(l10n.exPallofPress, PlanDifficulty.intermediate),
            CategoryExercise(l10n.exHangingLegRaise, PlanDifficulty.advanced),
            CategoryExercise(l10n.exDeadBug, PlanDifficulty.beginner),
          ],
          examplePlanNames: [l10n.planAbsFinishers, l10n.planAntiRotation],
        ),
      'Recovery' => CategoryDetailPage._(
          title: l10n.catRecoveryTitle,
          description: l10n.catRecoveryDesc,
          icon: Icons.spa_rounded,
          exercises: [
            CategoryExercise(l10n.exLightWalk, PlanDifficulty.beginner),
            CategoryExercise(l10n.exBreathwork, PlanDifficulty.beginner),
            CategoryExercise(l10n.exFoamRolling, PlanDifficulty.beginner),
          ],
          examplePlanNames: [l10n.planDeloadWeek, l10n.planSundayReset],
        ),
      _ => CategoryDetailPage._(
          title: key,
          description: '',
          icon: Icons.category_rounded,
          exercises: const [],
          examplePlanNames: const [],
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [AppColors.heroGradientStart, AppColors.heroGradientEnd],
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      description,
                      style: theme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.catSectionExercises,
              style: theme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...exercises.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  child: ListTile(
                    title: Text(
                      e.name,
                      style: theme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: DifficultyBadge(difficulty: e.difficulty),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.catSectionExamplePlans,
              style: theme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...examplePlanNames.map(
              (n) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.list_alt_rounded, color: AppColors.primary),
                    title: Text(
                      n,
                      style: theme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
