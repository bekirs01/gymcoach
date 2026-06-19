import 'package:flutter_test/flutter_test.dart';
import 'package:gym/core/progress_demo_seed.dart';
import 'package:gym/features/profile/domain/user_profile.dart';
import 'package:gym/features/workout/domain/workout_completion.dart';

void main() {
  final profile = UserProfile.withDefaults(membershipLevel: 'Premium');
  final now = DateTime(2026, 6, 20, 12);

  test('ProgressDemoSeed adds sessions when history is empty', () {
    final result = ProgressDemoSeed.applyIfNeeded(
      plans: const [],
      completions: const [],
      profile: profile,
      now: now,
    );
    expect(result, isNotNull);
    expect(result!.addedSessions, 15);
    expect(result.plans.length, 15);
    expect(result.completions.length, 12);
  });

  test('ProgressDemoSeed is idempotent after first run', () {
    final first = ProgressDemoSeed.applyIfNeeded(
      plans: const [],
      completions: const [],
      profile: profile,
      now: now,
    );
    expect(first, isNotNull);

    final second = ProgressDemoSeed.applyIfNeeded(
      plans: first!.plans,
      completions: first.completions,
      profile: profile,
      now: now,
    );
    expect(second, isNull);
  });

  test('ProgressDemoSeed skips when user has enough real completions', () {
    final realCompletions = List.generate(
      3,
      (i) => WorkoutCompletion(
        id: 'real_$i',
        title: 'User Workout $i',
        workoutType: 'Strength',
        completedAt: DateTime(2026, 6, 5 + i, 10),
        durationMinutes: 45,
        calories: 300,
        exerciseNames: const ['Squats'],
      ),
    );

    final result = ProgressDemoSeed.applyIfNeeded(
      plans: const [],
      completions: realCompletions,
      profile: profile,
      now: now,
    );
    expect(result, isNull);
  });
}
