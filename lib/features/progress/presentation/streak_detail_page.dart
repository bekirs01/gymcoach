import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/training_stats.dart';
import '../../plans/domain/workout_plan.dart';
import '../../workout/domain/workout_completion.dart';

class StreakDetailPage extends StatelessWidget {
  const StreakDetailPage({
    super.key,
    required this.plans,
    required this.completions,
    this.onOpenProgress,
  });

  final List<WorkoutPlan> plans;
  final List<WorkoutCompletion> completions;
  final VoidCallback? onOpenProgress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final days = TrainingStats.completedDays(plans, completions);
    final streak = TrainingStats.currentStreak(days, now);
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.streakDetailsTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [AppColors.heroGradientStart, AppColors.heroGradientEnd],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.streakDayStreak(streak),
                      style: theme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.streakMomentum,
                      style: theme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.streakRecentDays,
                style: theme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: days.isEmpty
                    ? Center(
                        child: Text(
                          l10n.streakEmpty,
                          style: theme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView(
                        children: () {
                          final sorted = days.toList()..sort((a, b) => b.compareTo(a));
                          return sorted.take(14).map(
                            (d) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Material(
                                  color: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: AppColors.borderSubtle),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(Icons.local_fire_department_rounded, color: AppColors.primary),
                                    title: Text(
                                      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
                                      style: theme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ).toList();
                        }(),
                      ),
              ),
              if (onOpenProgress != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onOpenProgress,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.streakOpenProgress, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
