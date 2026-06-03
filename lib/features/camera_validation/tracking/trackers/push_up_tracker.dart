import '../../domain/exercise_profile.dart';
import '../../domain/exercise_profiles_data.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../../engine/adaptive_rep_engine.dart';
import '../biomechanics/metric_extractors.dart';
import '../rep_exercise_tracker.dart';

class PushUpTracker extends RepExerciseTracker {
  @override
  String get canonicalId => 'push_ups';

  @override
  ExerciseProfile get profile => ExerciseProfilesData.byId['push_ups']!;

  @override
  late final AdaptiveRepEngine engine = AdaptiveRepEngine(profile.repConfig!);

  double _minElbow = double.infinity;

  @override
  void reset() {
    super.reset();
    _minElbow = double.infinity;
  }

  @override
  double? extractMetric(SmoothedPoseObservation obs) {
    final elbow = MetricExtractors.pushUpMetric(obs);
    if (elbow != null && elbow < _minElbow) {
      _minElbow = elbow;
    }
    return elbow;
  }

  @override
  String? validateRep(SmoothedPoseObservation obs) {
    final shallow = _minElbow > 105;
    _minElbow = double.infinity;
    if (shallow) return 'partial_rep';
    return null;
  }
}
