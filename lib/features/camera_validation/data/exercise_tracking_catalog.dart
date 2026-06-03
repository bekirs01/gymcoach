import '../../../core/workout_exercise_catalog.dart';
import '../domain/exercise_metric_kind.dart';
import '../domain/exercise_profile.dart';
import '../domain/exercise_profiles_data.dart';
import '../domain/exercise_tracking_mode.dart';
import '../tracking/configured_rep_tracker.dart';
import '../tracking/exercise_tracker.dart';
import '../tracking/trackers/bicycle_crunch_tracker.dart';
import '../tracking/trackers/burpee_tracker.dart';
import '../tracking/trackers/jumping_jack_tracker.dart';
import '../tracking/trackers/jump_rope_tracker.dart';
import '../tracking/trackers/mountain_climber_tracker.dart';
import '../tracking/trackers/plank_tracker.dart';
import '../tracking/trackers/pull_up_tracker.dart';
import '../tracking/trackers/push_up_tracker.dart';
import '../tracking/trackers/unsupported_tracker.dart';
/// Maps every app exercise name to a tracker profile and metric strategy.
abstract final class ExerciseTrackingCatalog {
  static final Map<String, String> _displayNameToId = {
    for (final exercise in WorkoutExerciseCatalog.allExercises)
      _norm(exercise.name): _catalogNameToId[exercise.name] ?? _norm(exercise.name).replaceAll(' ', '_'),
  };

  static const Map<String, String> _catalogNameToId = {
    'Barbell Bench Press': 'bench_press',
    'Chest Fly': 'chest_fly',
    'Push-up': 'push_ups',
    'Pull-up': 'pull_ups',
    'Lat Pulldown': 'lat_pulldown',
    'Seated Row': 'seated_row',
    'Deadlift': 'deadlift',
    'Squat': 'squats',
    'Lunge': 'lunges',
    'Leg Curl': 'leg_curl',
    'Hip Thrust': 'hip_thrust',
    'Glute Bridge': 'glute_bridge',
    'Romanian Deadlift': 'romanian_deadlift',
    'Step-up': 'step_up',
    'Shoulder Press': 'shoulder_press',
    'Lateral Raise': 'lateral_raise',
    'Front Raise': 'front_raise',
    'Face Pull': 'face_pull',
    'Biceps Curl': 'biceps_curl',
    'Hammer Curl': 'hammer_curl',
    'Dips': 'dips',
    'Plank': 'plank',
    'Cable Crunch': 'cable_crunch',
    'Leg Raise': 'leg_raise',
    'Bicycle Crunch': 'bicycle_crunch',
    'Burpee': 'burpee',
    'Mountain Climber': 'mountain_climber',
    'Jump Rope': 'jump_rope',
    'Stationary Bike': 'stationary_bike',
  };

  static String? canonicalIdForDisplayName(String displayName) =>
      _displayNameToId[_norm(displayName)];

  static ExerciseProfile? profileForId(String id) => ExerciseProfilesData.byId[id];

  static ExerciseTracker buildTracker(String canonicalId) {
    final profile = profileForId(canonicalId);
    if (profile == null) {
      return UnsupportedExerciseTracker('unknown_exercise');
    }
    if (profile.mode == ExerciseTrackingMode.unsupported) {
      return UnsupportedExerciseTracker(canonicalId);
    }

    return switch (canonicalId) {
      'plank' => PlankTracker(),
      'jumping_jacks' => JumpingJackTracker(),
      'mountain_climber' => MountainClimberTracker(),
      'bicycle_crunch' => BicycleCrunchTracker(),
      'burpee' => BurpeeTracker(),
      'jump_rope' => JumpRopeTracker(),
      'push_ups' => PushUpTracker(),
      'pull_ups' => PullUpTracker(),
      'squats' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.squat,
        ),
      'lunges' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.lunge,
        ),
      'deadlift' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.deadlift,
        ),
      'romanian_deadlift' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.deadlift,
        ),
      'shoulder_press' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.shoulderPress,
        ),
      'bench_press' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.benchPress,
        ),
      'chest_fly' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.chestFly,
        ),
      'lat_pulldown' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.latPulldown,
        ),
      'seated_row' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.seatedRow,
        ),
      'leg_curl' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.legCurl,
        ),
      'hip_thrust' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.hipThrust,
        ),
      'glute_bridge' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.gluteBridge,
        ),
      'step_up' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.stepUp,
        ),
      'lateral_raise' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.lateralRaise,
        ),
      'front_raise' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.frontRaise,
        ),
      'face_pull' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.facePull,
        ),
      'biceps_curl' || 'hammer_curl' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.bicepsCurl,
        ),
      'dips' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.dips,
        ),
      'cable_crunch' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.cableCrunch,
        ),
      'leg_raise' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.legRaise,
        ),
      'stationary_bike' => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.squat,
        ),
      _ => ConfiguredRepTracker(
          canonicalId: canonicalId,
          profile: profile,
          metricKind: ExerciseMetricKind.squat,
        ),
    };
  }

  static bool isCameraSupported(String canonicalId) {
    return profileForId(canonicalId) != null &&
        profileForId(canonicalId)!.mode != ExerciseTrackingMode.unsupported;
  }

  static String _norm(String value) =>
      value.toLowerCase().replaceAll('-', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}
