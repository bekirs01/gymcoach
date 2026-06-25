import 'package:gym/l10n/app_localizations.dart';

abstract final class ProfileFieldL10n {
  static const _goalKeys = [
    'build_muscle',
    'lose_fat',
    'improve_strength',
    'improve_endurance',
    'stay_consistent',
    'mobility_recovery',
    'strength_conditioning',
  ];

  static const _goalEnglish = {
    'build_muscle': 'Build muscle',
    'lose_fat': 'Lose fat',
    'improve_strength': 'Improve strength',
    'improve_endurance': 'Improve endurance',
    'stay_consistent': 'Stay consistent',
    'mobility_recovery': 'Mobility and recovery',
    'strength_conditioning': 'Strength and conditioning',
  };

  static String fitnessGoalLabel(AppLocalizations l10n, String stored) {
    final key = _goalKeyForStored(stored);
    if (key == null) return stored;
    return _fitnessGoalLabelForKey(l10n, key);
  }

  static List<String> fitnessGoalOptions(AppLocalizations l10n) =>
      _goalKeys.map((key) => _fitnessGoalLabelForKey(l10n, key)).toList();

  static String fitnessGoalCanonical(AppLocalizations l10n, String localizedLabel) {
    for (final key in _goalKeys) {
      if (_fitnessGoalLabelForKey(l10n, key) == localizedLabel) {
        return _goalEnglish[key]!;
      }
    }
    return localizedLabel;
  }

  static String? _goalKeyForStored(String stored) {
    for (final entry in _goalEnglish.entries) {
      if (entry.value == stored) return entry.key;
    }
    final ru = _ruGoals;
    for (final entry in ru.entries) {
      if (entry.value == stored) return entry.key;
    }
    return null;
  }

  static String _fitnessGoalLabelForKey(AppLocalizations l10n, String key) {
    return switch (key) {
      'build_muscle' => l10n.goalBuildMuscle,
      'lose_fat' => l10n.goalLoseFat,
      'improve_strength' => l10n.goalImproveStrength,
      'improve_endurance' => l10n.goalImproveEndurance,
      'stay_consistent' => l10n.goalStayConsistent,
      'mobility_recovery' => l10n.goalMobilityRecovery,
      _ => l10n.profileDefaultGoal,
    };
  }

  static const _ruGoals = {
    'build_muscle': 'Набрать мышечную массу',
    'lose_fat': 'Снизить жир',
    'improve_strength': 'Улучшить силу',
    'improve_endurance': 'Улучшить выносливость',
    'stay_consistent': 'Сохранять регулярность',
    'mobility_recovery': 'Мобильность и восстановление',
    'strength_conditioning': 'Сила и общая подготовка',
  };

  static String experienceLabel(AppLocalizations l10n, String value) {
    return switch (value) {
      'beginner' => l10n.difficultyBeginner,
      'advanced' => l10n.difficultyAdvanced,
      _ => l10n.difficultyIntermediate,
    };
  }

  static List<String> experienceOptions(AppLocalizations l10n) => [
        l10n.difficultyBeginner,
        l10n.difficultyIntermediate,
        l10n.difficultyAdvanced,
      ];

  static String experienceValue(AppLocalizations l10n, String label) {
    if (label == l10n.difficultyBeginner) return 'beginner';
    if (label == l10n.difficultyAdvanced) return 'advanced';
    return 'intermediate';
  }

  static String activityLabel(AppLocalizations l10n, String value) {
    return switch (value) {
      'low' => l10n.activityLow,
      'high' => l10n.activityHigh,
      'athlete' => l10n.activityAthlete,
      _ => l10n.activityModerate,
    };
  }

  static List<String> activityOptions(AppLocalizations l10n) => [
        l10n.activityLow,
        l10n.activityModerate,
        l10n.activityHigh,
        l10n.activityAthlete,
      ];

  static String activityValue(AppLocalizations l10n, String label) {
    if (label == l10n.activityLow) return 'low';
    if (label == l10n.activityHigh) return 'high';
    if (label == l10n.activityAthlete) return 'athlete';
    return 'moderate';
  }

  static String weeklyTargetLabel(AppLocalizations l10n, int value) {
    if (value < 1 || value > 7) return l10n.weeklyTargetN(4);
    return l10n.weeklyTargetN(value);
  }

  static List<String> weeklyTargetOptions(AppLocalizations l10n) =>
      List.generate(7, (i) => l10n.weeklyTargetN(i + 1));

  static int weeklyTargetValue(AppLocalizations l10n, String label) {
    for (var i = 1; i <= 7; i++) {
      if (l10n.weeklyTargetN(i) == label) return i;
    }
    return 4;
  }
}
