import '../../domain/exercise_profile.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../../engine/adaptive_rep_engine.dart';
import '../biomechanics/metric_extractors.dart';
import '../rep_exercise_tracker.dart';

class PushUpTracker extends RepExerciseTracker {
  @override
  String get canonicalId => 'push_ups';

  @override
  ExerciseProfile get profile => ExerciseProfiles.pushUps;

  @override
  final AdaptiveRepEngine engine = AdaptiveRepEngine(ExerciseProfiles.pushUps.repConfig!);

  @override
  double? extractMetric(SmoothedPoseObservation obs) => MetricExtractors.elbowAngle(obs);

  @override
  String? validateRep(SmoothedPoseObservation obs) {
    final bodyLine = MetricExtractors.bodyLineAngle(obs);
    if (bodyLine != null && bodyLine < 140) return 'sagging_hips';
    return null;
  }
}
