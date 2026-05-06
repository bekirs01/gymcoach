import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../workout/domain/completed_exercise_log.dart';
import '../../workout/domain/workout_completion.dart';

class CompletedWorkoutDetailPage extends StatelessWidget {
  const CompletedWorkoutDetailPage({super.key, required this.completion});

  final WorkoutCompletion completion;

  CompletedExerciseLog? _logForName(String name) {
    for (final log in completion.exerciseLogs) {
      if (log.exerciseName == name) return log;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    final d = completion.completedAt;
    final dateLabel = DateFormat.yMMMEd(Localizations.localeOf(context).toString()).format(d);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.historyWorkoutSummary),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              completion.title,
              style: theme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              completion.workoutType,
              style: theme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.schedule_rounded,
                    label: l10n.sessionSummaryDuration,
                    value: l10n.minutesShort(completion.durationMinutes),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.local_fire_department_outlined,
                    label: l10n.sessionSummaryCalories,
                    value: l10n.sessionCaloriesUnit(completion.calories),
                  ),
                ),
              ],
            ),
            if (completion.caloriesAreEstimated) ...[
              const SizedBox(height: 10),
              Text(
                l10n.historyCaloriesEstimateNote,
                style: theme.bodySmall?.copyWith(color: AppColors.textMuted, height: 1.35),
              ),
            ],
            const SizedBox(height: 16),
            _InfoCard(
              icon: Icons.event_rounded,
              label: l10n.historyCompletedOn,
              value: dateLabel,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.historyExercisesCompleted,
              style: theme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...completion.exerciseNames.map(
              (n) {
                final log = _logForName(n);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary),
                      title: Text(
                        n,
                        style: theme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: log != null
                          ? Text(
                              l10n.historySetsRepsDetail(log.setsCompleted, log.repsCompleted),
                              style: theme.bodySmall?.copyWith(color: AppColors.textMuted),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 10),
          Text(label, style: theme.labelSmall?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
