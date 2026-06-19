import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../../../app/widgets/premium_background.dart';

class SettingsInfoPage extends StatelessWidget {
  const SettingsInfoPage({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final List<String> body;

  static Future<void> open(
    BuildContext context, {
    required String title,
    required List<String> body,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SettingsInfoPage(title: title, body: body),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumColors.midnightMid,
      appBar: AppBar(
        backgroundColor: PremiumColors.midnightMid,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: PremiumBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: PremiumColors.surface,
                borderRadius: BorderRadius.circular(PremiumRadii.lg),
                border: Border.all(color: PremiumColors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < body.length; i++) ...[
                    Text(
                      body[i],
                      style: const TextStyle(
                        color: PremiumColors.textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    if (i < body.length - 1) const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

abstract final class SettingsInfoContent {
  static const privacyPolicy = [
    'GymCoach respects your privacy and processes only the data needed to deliver training, social, and map features.',
    'Workout history, profile details, and preferences are stored securely and tied to your account.',
    'We do not sell personal data. You can review permissions and notification preferences at any time in Settings.',
  ];

  static const termsOfService = [
    'By using GymCoach you agree to train responsibly and use the app in compliance with local laws.',
    'Shared workouts, stories, and messages must follow community standards and must not include harmful content.',
    'GymCoach may update these terms as features evolve. Continued use means acceptance of the latest version.',
  ];

  static const contactSupport = [
    'Need help with workouts, account access, or permissions?',
    'Our support team can help with onboarding, profile issues, reminders, and technical troubleshooting.',
    'Email: support@gymcoach.app',
    'Typical response time: within one business day.',
  ];

  static const aboutApp = [
    'GymCoach helps you plan workouts, track progress, share results, and explore territory capture on the map.',
    'Version 1.0.0',
    'Built for focused training with a premium dark experience on iPhone.',
  ];

  static const dataAndPermissions = [
    'Notifications power workout reminders and important account updates.',
    'Camera and microphone are used for exercise capture, stories, and voice messages.',
    'Photos access lets you upload posts, stories, and profile media.',
    'Location is used for map positioning and live territory capture while the app is open.',
    'You can review or change any permission in Settings or iOS system settings.',
  ];
}
