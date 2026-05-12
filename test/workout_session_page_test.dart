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
      exerciseNames: const ['Push-ups', 'Pull-ups'],
      status: PlanStatus.planned,
    );
  });

  testWidgets('Active session exposes enabled sets and reps fields', (WidgetTester tester) async {
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
    await tester.pumpAndSettle();

    final textFields = tester.widgetList<TextField>(find.byType(TextField));
    expect(textFields.length, 2);
    expect(textFields.every((f) => f.enabled != false), true);
  });

  testWidgets('Active session starts timer and saves logged exercise', (WidgetTester tester) async {
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
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start session'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '3');
    await tester.enterText(fields.at(1), '10');
    await tester.tap(find.text('Complete exercise'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.durationMinutes, greaterThanOrEqualTo(1));
    expect(saved!.calories, greaterThan(0));
    expect(saved!.exerciseLogs.single.setsCompleted, 3);
    expect(saved!.exerciseLogs.single.repsCompleted, 10);
  });
}
