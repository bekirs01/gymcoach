import '../../domain/exercise_profile.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../../engine/adaptive_rep_engine.dart';
import '../biomechanics/metric_extractors.dart';
import '../rep_exercise_tracker.dart';

class SquatTracker extends RepExerciseTracker {
  @override
  String get canonicalId => 'squats';

  @override
  ExerciseProfile get profile => ExerciseProfiles.squats;

  @override
  final AdaptiveRepEngine engine = AdaptiveRepEngine(ExerciseProfiles.squats.repConfig!);

  @override
  double? extractMetric(SmoothedPoseObservation obs) => MetricExtractors.squatMetric(obs);
}
