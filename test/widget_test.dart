import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym/app/gymcoach_app.dart';
import 'package:gym/features/profile/domain/user_profile.dart';
import 'package:gym/features/profile/presentation/profile_page.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Home dashboard renders welcome section', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const GymCoachApp());
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text("Today's Focus"), findsOneWidget);
  });

  testWidgets('Home dashboard renders Russian locale from preferences', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'app_locale_code': 'ru'});
    await tester.pumpWidget(const GymCoachApp());
    await tester.pumpAndSettle();
    expect(find.text('С возвращением'), findsOneWidget);
    expect(find.text('Фокус на сегодня'), findsOneWidget);
  });

  testWidgets('Profile edit accepts comma decimals and closes without crash', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    UserProfile? saved;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: ProfilePage(
            profile: const UserProfile(
              displayName: 'Alex Morgan',
              weightKg: 78.5,
              heightCm: 178,
              fitnessGoal: 'Strength and conditioning',
              membershipLevel: 'Premium',
              notificationsEnabled: true,
            ),
            onProfileChanged: (p) => saved = p,
            onLocaleChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Edit'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(6));
    await tester.enterText(fields.at(1), '82,3');
    await tester.enterText(fields.at(2), '181,5');
    final save = find.widgetWithText(FilledButton, 'Save');
    await tester.scrollUntilVisible(save, 80, scrollable: find.byType(Scrollable).last);
    await tester.tap(save);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AlertDialog), findsNothing);
    expect(saved, isNotNull);
    expect(saved!.weightKg, 82.3);
    expect(saved!.heightCm, 181.5);
  });
}
