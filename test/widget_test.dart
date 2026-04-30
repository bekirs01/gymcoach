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
            profile: UserProfile.initial(),
            onProfileChanged: (p) => saved = p,
            onLocaleChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(4));
    await tester.enterText(fields.at(1), '82,3');
    await tester.enterText(fields.at(2), '181,5');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(saved, isNotNull);
    expect(saved!.weightKg, 82.3);
    expect(saved!.heightCm, 181.5);
  });
}
