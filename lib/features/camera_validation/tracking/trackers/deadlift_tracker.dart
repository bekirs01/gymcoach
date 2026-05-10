import '../../domain/exercise_profile.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../../engine/adaptive_rep_engine.dart';
import '../biomechanics/metric_extractors.dart';
import '../rep_exercise_tracker.dart';

class DeadliftTracker extends RepExerciseTracker {
  @override
  String get canonicalId => 'deadlift';

  @override
  ExerciseProfile get profile => ExerciseProfiles.deadlift;

  @override
  final AdaptiveRepEngine engine = AdaptiveRepEngine(ExerciseProfiles.deadlift.repConfig!);

  @override
  double? extractMetric(SmoothedPoseObservation obs) => MetricExtractors.hipHingeAngle(obs);
}
