import '../domain/exercise_metric_kind.dart';
import '../domain/exercise_profile.dart';
import '../domain/exercise_tracking_mode.dart';
import '../domain/smoothed_pose_observation.dart';
import '../engine/adaptive_rep_engine.dart';
import 'biomechanics/metric_extractors.dart';
import 'rep_exercise_tracker.dart';

class ConfiguredRepTracker extends RepExerciseTracker {
  ConfiguredRepTracker({
    required this.canonicalId,
    required this.profile,
    required this.metricKind,
    this.validateRepFn,
  });

  @override
  final String canonicalId;

  @override
  final ExerciseProfile profile;

  final ExerciseMetricKind metricKind;
  final String? Function(SmoothedPoseObservation)? validateRepFn;

  @override
  late final AdaptiveRepEngine engine = AdaptiveRepEngine(
    profile.repConfig ??
        const AdaptiveRepEngineConfig(
          defaultBottom: 95,
          defaultTop: 155,
          hysteresisBand: 10,
        ),
  );

  @override
  double? extractMetric(SmoothedPoseObservation obs) => switch (metricKind) {
        ExerciseMetricKind.squat => MetricExtractors.squatMetric(obs),
        ExerciseMetricKind.pushUp => MetricExtractors.pushUpMetric(obs),
        ExerciseMetricKind.lunge => MetricExtractors.lungeMetric(obs),
        ExerciseMetricKind.deadlift => MetricExtractors.deadliftMetric(obs),
        ExerciseMetricKind.shoulderPress => MetricExtractors.shoulderPressMetric(obs),
        ExerciseMetricKind.pullUp => MetricExtractors.pullUpMetric(obs),
        ExerciseMetricKind.benchPress => MetricExtractors.benchPressMetric(obs),
        ExerciseMetricKind.chestFly => MetricExtractors.chestFlyMetric(obs),
        ExerciseMetricKind.latPulldown => MetricExtractors.latPulldownMetric(obs),
        ExerciseMetricKind.seatedRow => MetricExtractors.seatedRowMetric(obs),
        ExerciseMetricKind.legCurl => MetricExtractors.legCurlMetric(obs),
        ExerciseMetricKind.hipThrust => MetricExtractors.hipThrustMetric(obs),
        ExerciseMetricKind.gluteBridge => MetricExtractors.gluteBridgeMetric(obs),
        ExerciseMetricKind.stepUp => MetricExtractors.stepUpMetric(obs),
        ExerciseMetricKind.lateralRaise => MetricExtractors.lateralRaiseMetric(obs),
        ExerciseMetricKind.frontRaise => MetricExtractors.frontRaiseMetric(obs),
        ExerciseMetricKind.facePull => MetricExtractors.facePullMetric(obs),
        ExerciseMetricKind.bicepsCurl => MetricExtractors.bicepsCurlMetric(obs),
        ExerciseMetricKind.dips => MetricExtractors.dipsMetric(obs),
        ExerciseMetricKind.cableCrunch => MetricExtractors.cableCrunchMetric(obs),
        ExerciseMetricKind.legRaise => MetricExtractors.legRaiseMetric(obs),
      };

  @override
  String? validateRep(SmoothedPoseObservation obs) => validateRepFn?.call(obs);
}
