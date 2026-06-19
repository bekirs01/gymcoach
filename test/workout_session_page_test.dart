import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym/features/plans/domain/workout_plan.dart';
import 'package:gym/features/profile/domain/user_profile.dart';
import 'package:gym/features/workout/domain/workout_completion.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:gym/features/workout/presentation/workout_session_page.dart';

void main() {
  late WorkoutPlan plan;
  const profile = UserProfile(
    displayName: 'Alex Morgan',
    weightKg: 78.5,
    heightCm: 178,
    fitnessGoal: 'Strength',
    membershipLevel: 'Premium',
    notificationsEnabled: true,
  );

  setUp(() {
    final today = WorkoutPlan.dateOnly(DateTime.now());
    plan = WorkoutPlan(
      id: 'plan1',
      name: 'Push Day',
      scheduledDate: today,
      scheduledTime: const TimeOfDay(hour: 18, minute: 30),
      durationMinutes: 45,
      difficulty: PlanDifficulty.intermediate,
      exerciseNames: const ['Push-up', 'Pull-up'],
      status: PlanStatus.planned,
    );
  });

  testWidgets('Active session shows metric steppers with default values', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: WorkoutSessionPage(
          plan: plan,
          profile: profile,
          onFinished: (_) {},
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Exercise 1 of 2'), findsOneWidget);
    expect(find.text('Complete exercise'), findsOneWidget);
    expect(find.text('End workout'), findsOneWidget);
  });

  testWidgets('Active session completes exercise and finishes workout', (WidgetTester tester) async {
    WorkoutCompletion? saved;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: WorkoutSessionPage(
          plan: plan,
          profile: profile,
          onFinished: (c) => saved = c,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Complete exercise'));
    await tester.pump();
    expect(find.text('Next exercise'), findsOneWidget);

    await tester.tap(find.text('Next exercise'));
    await tester.pump();
    expect(find.text('Exercise 2 of 2'), findsOneWidget);

    await tester.tap(find.text('Complete exercise'));
    await tester.pump();
    expect(find.text('Finish workout'), findsWidgets);

    await tester.tap(find.text('Finish workout').first);
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pump();

    expect(saved, isNotNull);
    expect(saved!.durationMinutes, greaterThanOrEqualTo(1));
    expect(saved!.calories, greaterThan(0));
    expect(saved!.exerciseLogs.length, 2);
    expect(saved!.exerciseLogs.first.setsCompleted, 3);
    expect(saved!.exerciseLogs.first.repsCompleted, 10);
  });
}
