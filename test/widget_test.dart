import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym/app/gymcoach_app.dart';
import 'package:gym/features/profile/domain/profile_defaults.dart';
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
    expect(find.text(ProfileDefaults.displayName), findsOneWidget);
    expect(find.text("Today's Focus"), findsOneWidget);
  });

  testWidgets('Home dashboard renders Russian locale from preferences', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'app_locale_code': 'ru'});
    await tester.pumpWidget(const GymCoachApp());
    await tester.pumpAndSettle();
    expect(find.text('С возвращением'), findsOneWidget);
    expect(find.text('Фокус на сегодня'), findsOneWidget);
  });

  testWidgets('Profile edit saves updated display name', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    UserProfile? saved;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: ProfilePage(
            profile: UserProfile.withDefaults(membershipLevel: 'Premium'),
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
    expect(find.text('Edit profile'), findsOneWidget);
    final nameField = find.byType(TextField).first;
    await tester.enterText(nameField, ProfileDefaults.displayName);
    final save = find.widgetWithText(FilledButton, 'Save');
    await tester.scrollUntilVisible(save, 80, scrollable: find.byType(Scrollable).last);
    await tester.tap(save);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(AlertDialog), findsNothing);
    expect(saved, isNotNull);
    expect(saved!.displayName, ProfileDefaults.displayName);
  });
}
