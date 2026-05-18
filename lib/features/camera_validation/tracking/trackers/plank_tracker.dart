import '../../domain/exercise_profile.dart';
import '../../domain/exercise_tracking_mode.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../../domain/tracking_session_state.dart';
import '../../domain/tracking_update.dart';
import '../biomechanics/metric_extractors.dart';
import '../exercise_tracker.dart';

class PlankTracker extends ExerciseTracker {
  @override
  String get canonicalId => 'plank';

  @override
  ExerciseTrackingMode get mode => profile.mode;

  @override
  ExerciseProfile get profile => ExerciseProfiles.plank;

  DateTime? _lastTick;
  var _validHold = false;
  var _graceFrames = 0;

  @override
  void reset() {
    _lastTick = null;
    _validHold = false;
    _graceFrames = 0;
  }

  @override
  TrackingUpdate process(SmoothedPoseObservation obs, TrackingSessionState state) {
    if (!obs.quality.isTrackingReady) {
      _graceFrames++;
      if (_graceFrames > 12) {
        _validHold = false;
        _lastTick = null;
        return TrackingUpdate(
          state: state.copyWith(bodyDetected: false, phaseLabel: 'no_body'),
          event: state.bodyDetected ? TrackingEventKind.bodyLost : TrackingEventKind.none,
        );
      }
      return TrackingUpdate(state: state.copyWith(bodyDetected: state.bodyDetected));
    }
    _graceFrames = 0;

    final bodyLine = MetricExtractors.plankBodyLine(obs);
    if (bodyLine == null) {
      return TrackingUpdate(
        state: state.copyWith(bodyDetected: false, phaseLabel: 'no_body'),
        event: state.bodyDetected ? TrackingEventKind.bodyLost : TrackingEventKind.none,
      );
    }

    final isValid = bodyLine >= 155 && bodyLine <= 195;
    var holdSeconds = state.holdSeconds;
    var event = TrackingEventKind.none;
    String? feedback;

    if (isValid) {
      _validHold = true;
      final last = _lastTick;
      if (last != null) {
        final delta = obs.timestamp.difference(last).inMilliseconds;
        if (delta >= 900) {
          holdSeconds += 1;
          event = TrackingEventKind.holdTick;
          _lastTick = obs.timestamp;
        }
      } else {
        _lastTick = obs.timestamp;
      }
    } else {
      if (_validHold && MetricExtractors.plankHipsSagging(obs)) {
        event = TrackingEventKind.invalidAttempt;
        feedback = 'hips_sagging';
      }
      _validHold = false;
      _lastTick = null;
    }

    return TrackingUpdate(
      state: state.copyWith(
        bodyDetected: true,
        holdSeconds: holdSeconds,
        phaseLabel: isValid ? 'holding' : 'align',
        invalidAttempts: event == TrackingEventKind.invalidAttempt
            ? state.invalidAttempts + 1
            : state.invalidAttempts,
        lastFeedbackCode: feedback,
      ),
      event: event,
      feedbackCode: feedback,
    );
  }
}
