import '../../domain/exercise_profile.dart';
import '../../domain/exercise_profiles_data.dart';
import '../../domain/exercise_tracking_mode.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../../domain/tracking_session_state.dart';
import '../../domain/tracking_update.dart';
import '../../engine/adaptive_rep_engine.dart';
import '../biomechanics/metric_extractors.dart';
import '../rep_exercise_tracker.dart';

/// Full burpee cycle using squat depth (down → plank proxy → stand).
class BurpeeTracker extends RepExerciseTracker {
  @override
  String get canonicalId => 'burpee';

  @override
  ExerciseProfile get profile => ExerciseProfilesData.byId['burpee']!;

  @override
  final AdaptiveRepEngine engine = AdaptiveRepEngine(
    ExerciseProfilesData.byId['burpee']!.repConfig!,
  );

  @override
  double? extractMetric(SmoothedPoseObservation obs) => MetricExtractors.squatMetric(obs);

  @override
  String? validateRep(SmoothedPoseObservation obs) {
    final metric = MetricExtractors.squatMetric(obs);
    if (metric == null || metric > 130) return 'partial_rep';
    return null;
  }
}
