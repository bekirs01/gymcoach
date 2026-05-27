import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../history/presentation/completed_workout_detail_page.dart';
import '../../workout/domain/workout_completion.dart';

class ProgressHistoryPage extends StatelessWidget {
  const ProgressHistoryPage({super.key, required this.completions});

  final List<WorkoutCompletion> completions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sorted = List<WorkoutCompletion>.from(completions)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.progressWorkoutHistory)),
      body: sorted.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.progressHistoryEmpty,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderSubtle),
              itemBuilder: (context, i) {
                final c = sorted[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    c.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${c.workoutType} · ${l10n.minutesShort(c.durationMinutes)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  onTap: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => CompletedWorkoutDetailPage(completion: c),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
