import '../../domain/exercise_profile.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../../engine/adaptive_rep_engine.dart';
import '../biomechanics/metric_extractors.dart';
import '../rep_exercise_tracker.dart';

class ShoulderPressTracker extends RepExerciseTracker {
  @override
  String get canonicalId => 'shoulder_press';

  @override
  ExerciseProfile get profile => ExerciseProfiles.shoulderPress;

  @override
  final AdaptiveRepEngine engine = AdaptiveRepEngine(ExerciseProfiles.shoulderPress.repConfig!);

  @override
  double? extractMetric(SmoothedPoseObservation obs) =>
      MetricExtractors.shoulderPressMetric(obs);

  @override
  String? validateRep(SmoothedPoseObservation obs) {
    if (MetricExtractors.validShoulderPressLockout(obs)) return null;
    return MetricExtractors.shoulderPressMetric(obs)! > 140 ? 'incomplete_press' : 'raise_higher';
  }
}
