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

  double _minElbowThisRep = 180;

  @override
  void reset() {
    super.reset();
    _minElbowThisRep = 180;
  }

  @override
  double? extractMetric(SmoothedPoseObservation obs) {
    final elbow = MetricExtractors.pullUpMetric(obs);
    if (elbow != null && elbow < _minElbowThisRep) {
      _minElbowThisRep = elbow;
    }
    return elbow;
  }

  @override
  String? validateRep(SmoothedPoseObservation obs) {
    final ok = _minElbowThisRep <= 105;
    _minElbowThisRep = 180;
    if (!ok) return 'pull_higher';
    return null;
  }
}
