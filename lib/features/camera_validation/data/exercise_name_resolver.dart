import 'package:gym/l10n/app_localizations.dart';

import '../../../core/exercise_catalog.dart';

abstract final class ExerciseNameResolver {
  static String? canonicalIdForName(String displayName, [AppLocalizations? l10n]) {
    final normalized = _normalize(displayName);
    if (l10n != null) {
      for (final canonical in ExerciseCatalog.canonicalNames) {
        if (_normalize(ExerciseCatalog.label(l10n, canonical)) == normalized) {
          return _canonicalKey(canonical);
        }
      }
    }
    for (final canonical in ExerciseCatalog.canonicalNames) {
      if (_normalize(canonical) == normalized) {
        return _canonicalKey(canonical);
      }
    }
    return _aliasMap[normalized];
  }

  static String _canonicalKey(String canonical) => switch (canonical) {
        'Push-ups' => 'push_ups',
        'Squats' => 'squats',
        'Plank' => 'plank',
        'Lunges' => 'lunges',
        'Jumping Jacks' => 'jumping_jacks',
        'Pull-ups' => 'pull_ups',
        'Shoulder Press' => 'shoulder_press',
        'Running' => 'running',
        _ => _normalize(canonical).replaceAll(' ', '_'),
      };

  static String _normalize(String value) =>
      value.toLowerCase().replaceAll('-', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

  static final Map<String, String> _aliasMap = {
    'back squat': 'squats',
    'bench press': 'unsupported',
    'romanian deadlift': 'deadlift',
    'deadlift': 'deadlift',
    'plank variations': 'plank',
    'bicycle crunches': 'unsupported',
    'russian twists': 'unsupported',
    'dead bug': 'unsupported',
    'leg press': 'squats',
    'calf raises': 'unsupported',
    'dynamic warm up': 'unsupported',
    'dynamic warm-up': 'unsupported',
    'tempo run': 'running',
    'cycle intervals': 'running',
    'rowing sprint': 'running',
    'jump rope': 'jumping_jacks',
    'light walk': 'running',
    'breathwork': 'unsupported',
    'foam rolling': 'unsupported',
    'thoracic rotation': 'unsupported',
    'hip cars': 'unsupported',
    'ankle mobility': 'unsupported',
    'shoulder dislocates': 'shoulder_press',
    'pallof press': 'shoulder_press',
    'hanging leg raise': 'unsupported',
  };
}
