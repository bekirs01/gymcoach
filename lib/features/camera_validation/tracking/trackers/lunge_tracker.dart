import '../../domain/exercise_profile.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../../engine/adaptive_rep_engine.dart';
import '../biomechanics/metric_extractors.dart';
import '../rep_exercise_tracker.dart';

class LungeTracker extends RepExerciseTracker {
  @override
  String get canonicalId => 'lunges';

  @override
  ExerciseProfile get profile => ExerciseProfiles.lunges;

  @override
  final AdaptiveRepEngine engine = AdaptiveRepEngine(ExerciseProfiles.lunges.repConfig!);

  @override
  double? extractMetric(SmoothedPoseObservation obs) => MetricExtractors.lungeMetric(obs);
}
