import 'package:flutter_test/flutter_test.dart';

import 'package:gym/app/gymcoach_app.dart';

void main() {
  testWidgets('Home dashboard renders welcome section', (WidgetTester tester) async {
    await tester.pumpWidget(const GymCoachApp());
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Bekir'), findsOneWidget);
    expect(find.text("Today's Focus"), findsOneWidget);
  });
}
