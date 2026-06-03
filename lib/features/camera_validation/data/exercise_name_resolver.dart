import 'package:gym/l10n/app_localizations.dart';

import '../../../core/exercise_catalog.dart';
import 'exercise_tracking_catalog.dart';

abstract final class ExerciseNameResolver {
  static String? canonicalIdForName(String displayName, [AppLocalizations? l10n]) {
    final fromWorkoutCatalog = ExerciseTrackingCatalog.canonicalIdForDisplayName(displayName);
    if (fromWorkoutCatalog != null) return fromWorkoutCatalog;

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
    'push up': 'push_ups',
    'push ups': 'push_ups',
    'squat': 'squats',
    'squats': 'squats',
    'lunge': 'lunges',
    'lunges': 'lunges',
    'pull up': 'pull_ups',
    'pull ups': 'pull_ups',
    'back squat': 'squats',
    'bench press': 'bench_press',
    'barbell bench press': 'bench_press',
    'chest fly': 'chest_fly',
    'lat pulldown': 'lat_pulldown',
    'seated row': 'seated_row',
    'romanian deadlift': 'romanian_deadlift',
    'deadlift': 'deadlift',
    'leg curl': 'leg_curl',
    'hip thrust': 'hip_thrust',
    'glute bridge': 'glute_bridge',
    'step up': 'step_up',
    'lateral raise': 'lateral_raise',
    'front raise': 'front_raise',
    'face pull': 'face_pull',
    'biceps curl': 'biceps_curl',
    'hammer curl': 'hammer_curl',
    'cable crunch': 'cable_crunch',
    'leg raise': 'leg_raise',
    'bicycle crunch': 'bicycle_crunch',
    'mountain climber': 'mountain_climber',
    'jump rope': 'jump_rope',
    'stationary bike': 'stationary_bike',
    'burpee': 'burpee',
    'plank variations': 'plank',
    'leg press': 'squats',
    'jumping jacks': 'jumping_jacks',
    'tempo run': 'running',
    'cycle intervals': 'running',
    'rowing sprint': 'running',
    'light walk': 'running',
    'running': 'running',
  };
}
