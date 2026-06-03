import '../../domain/exercise_profile.dart';
import '../../domain/exercise_profiles_data.dart';
import '../../domain/exercise_tracking_mode.dart';
import '../../domain/pose_frame.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../../domain/tracking_session_state.dart';
import '../../domain/tracking_update.dart';
import '../exercise_tracker.dart';

/// Counts each visible hop when hip midpoint rises then falls.
class JumpRopeTracker extends ExerciseTracker {
  @override
  String get canonicalId => 'jump_rope';

  @override
  ExerciseTrackingMode get mode => profile.mode;

  @override
  ExerciseProfile get profile => ExerciseProfilesData.byId['jump_rope']!;

  var _phase = _HopPhase.down;
  double? _baselineHipY;
  DateTime? _cooldownUntil;

  @override
  void reset() {
    _phase = _HopPhase.down;
    _baselineHipY = null;
    _cooldownUntil = null;
  }

  @override
  TrackingUpdate process(SmoothedPoseObservation obs, TrackingSessionState state) {
    if (!obs.quality.isTrackingReady) {
      return TrackingUpdate(
        state: state.copyWith(bodyDetected: false, phaseLabel: 'no_body'),
        event: state.bodyDetected ? TrackingEventKind.bodyLost : TrackingEventKind.none,
      );
    }

    final frame = PoseFrame(timestamp: obs.timestamp, landmarks: obs.landmarks);
    final hipY = frame.midpointY(PoseLandmark.leftHip, PoseLandmark.rightHip);
    if (hipY == null) {
      return TrackingUpdate(
        state: state.copyWith(bodyDetected: false, phaseLabel: 'no_body'),
        event: state.bodyDetected ? TrackingEventKind.bodyLost : TrackingEventKind.none,
      );
    }

    _baselineHipY ??= hipY;
    _baselineHipY = _baselineHipY! * 0.98 + hipY * 0.02;
    final lift = (_baselineHipY! - hipY) / obs.bodyScale;

    var next = state.copyWith(bodyDetected: true, phaseLabel: _phase.name);

    if (_cooldownUntil != null && obs.timestamp.isBefore(_cooldownUntil!)) {
      return TrackingUpdate(state: next);
    }

    switch (_phase) {
      case _HopPhase.down:
        if (lift > 0.05) _phase = _HopPhase.up;
      case _HopPhase.up:
        if (lift < 0.02) {
          _phase = _HopPhase.down;
          _cooldownUntil = obs.timestamp.add(const Duration(milliseconds: 220));
          next = next.copyWith(repCount: state.repCount + 1, clearFeedback: true);
          return TrackingUpdate(state: next, event: TrackingEventKind.repCompleted);
        }
    }
    return TrackingUpdate(state: next);
  }
}

enum _HopPhase { down, up }
