import '../../domain/exercise_profile.dart';
import '../../domain/exercise_profiles_data.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../../engine/adaptive_rep_engine.dart';
import '../biomechanics/metric_extractors.dart';
import '../rep_exercise_tracker.dart';

class PullUpTracker extends RepExerciseTracker {
  @override
  String get canonicalId => 'pull_ups';

  @override
  ExerciseProfile get profile => ExerciseProfilesData.byId['pull_ups']!;

  @override
  late final AdaptiveRepEngine engine = AdaptiveRepEngine(profile.repConfig!);

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
    final elbowOk = _minElbowThisRep <= 105;
    final chinOk = MetricExtractors.chinAboveBar(obs);
    _minElbowThisRep = 180;
    if (!elbowOk || !chinOk) return 'pull_higher';
    return null;
  }
}
