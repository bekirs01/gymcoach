import '../domain/exercise_tracking_mode.dart';
import '../domain/exercise_profile.dart';
import '../domain/smoothed_pose_observation.dart';
import '../domain/tracking_session_state.dart';
import '../domain/tracking_update.dart';
import '../engine/adaptive_rep_engine.dart';
import 'exercise_tracker.dart';

abstract class RepExerciseTracker extends ExerciseTracker {
  @override
  ExerciseTrackingMode get mode => profile.mode;

  @override
  @override
  ExerciseProfile get profile;
  AdaptiveRepEngine get engine;

  double? extractMetric(SmoothedPoseObservation obs);

  String? validateRep(SmoothedPoseObservation obs) => null;

  @override
  void reset() => engine.reset();

  @override
  TrackingUpdate process(SmoothedPoseObservation obs, TrackingSessionState state) {
    final critical = profile.criticalJoints;
    final bodyPresent = obs.quality.isTrackingReady && obs.hasAllReliable(critical);

    if (!bodyPresent) {
      engine.update(
        metric: 0,
        now: obs.timestamp,
        quality: obs.quality,
        bodyPresent: false,
      );
      return TrackingUpdate(
        state: state.copyWith(
          bodyDetected: false,
          phaseLabel: engine.phaseLabel,
        ),
        event: state.bodyDetected ? TrackingEventKind.bodyLost : TrackingEventKind.none,
      );
    }

    final metric = extractMetric(obs);
    if (metric == null) {
      return TrackingUpdate(
        state: state.copyWith(bodyDetected: false, phaseLabel: 'no_body'),
        event: state.bodyDetected ? TrackingEventKind.bodyLost : TrackingEventKind.none,
      );
    }

    final result = engine.update(
      metric: metric,
      now: obs.timestamp,
      quality: obs.quality,
      bodyPresent: true,
    );

    var next = state.copyWith(
      bodyDetected: true,
      phaseLabel: engine.phaseLabel,
    );

    switch (result.event) {
      case RepEngineEvent.repCompleted:
        final feedback = validateRep(obs);
        if (feedback != null) {
          next = next.copyWith(
            invalidAttempts: state.invalidAttempts + 1,
            lastFeedbackCode: feedback,
          );
          return TrackingUpdate(
            state: next,
            event: TrackingEventKind.invalidAttempt,
            feedbackCode: feedback,
          );
        }
        next = next.copyWith(repCount: state.repCount + 1, clearFeedback: true);
        return TrackingUpdate(state: next, event: TrackingEventKind.repCompleted);
      case RepEngineEvent.invalidPartial:
        next = next.copyWith(
          invalidAttempts: state.invalidAttempts + 1,
          lastFeedbackCode: 'partial_rep',
        );
        return TrackingUpdate(
          state: next,
          event: TrackingEventKind.invalidAttempt,
          feedbackCode: 'partial_rep',
        );
      case RepEngineEvent.invalidCheating:
      case RepEngineEvent.none:
        return TrackingUpdate(state: next);
    }
  }
}
