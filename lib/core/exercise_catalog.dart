import 'package:gym/l10n/app_localizations.dart';

abstract final class ExerciseCatalog {
  static const List<String> canonicalNames = [
    'Push-ups',
    'Squats',
    'Plank',
    'Lunges',
    'Jumping Jacks',
    'Pull-ups',
    'Shoulder Press',
    'Running',
  ];

  static String label(AppLocalizations l10n, String canonical) {
    return switch (canonical) {
      'Push-ups' => l10n.exPushUps,
      'Squats' => l10n.exSquats,
      'Plank' => l10n.exPlank,
      'Lunges' => l10n.exLunges,
      'Jumping Jacks' => l10n.exJumpingJacks,
      'Pull-ups' => l10n.exPullUps,
      'Shoulder Press' => l10n.exShoulderPress,
      'Running' => l10n.exRunning,
      _ => canonical,
    };
  }
}
