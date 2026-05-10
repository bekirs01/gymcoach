import '../../domain/exercise_profile.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../../engine/adaptive_rep_engine.dart';
import '../biomechanics/metric_extractors.dart';
import '../rep_exercise_tracker.dart';

class PullUpTracker extends RepExerciseTracker {
  @override
  String get canonicalId => 'pull_ups';

  @override
  ExerciseProfile get profile => ExerciseProfiles.pullUps;

  @override
  final AdaptiveRepEngine engine = AdaptiveRepEngine(ExerciseProfiles.pullUps.repConfig!);

  @override
  double? extractMetric(SmoothedPoseObservation obs) => MetricExtractors.pullUpMetric(obs);

  @override
  String? validateRep(SmoothedPoseObservation obs) {
    if (!MetricExtractors.chinAboveBar(obs)) return 'pull_higher';
    return null;
  }
}
