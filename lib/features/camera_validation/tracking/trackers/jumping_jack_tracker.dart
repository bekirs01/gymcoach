import '../../domain/exercise_profile.dart';
import '../../domain/exercise_tracking_mode.dart';
import '../../domain/pose_frame.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../../domain/tracking_session_state.dart';
import '../../domain/tracking_update.dart';
import '../exercise_tracker.dart';
import '../pose_geometry.dart';

class JumpingJackTracker extends ExerciseTracker {
  @override
  String get canonicalId => 'jumping_jacks';

  @override
  ExerciseTrackingMode get mode => profile.mode;

  @override
  ExerciseProfile get profile => ExerciseProfiles.jumpingJacks;

  var _phase = _JackPhase.closed;
  DateTime? _phaseEntered;
  DateTime? _cooldownUntil;

  @override
  void reset() {
    _phase = _JackPhase.closed;
    _phaseEntered = null;
    _cooldownUntil = null;
  }

  @override
  TrackingUpdate process(SmoothedPoseObservation obs, TrackingSessionState state) {
    if (!obs.quality.isTrackingReady ||
        !obs.hasAllReliable([
          PoseLandmark.leftWrist,
          PoseLandmark.rightWrist,
          PoseLandmark.leftShoulder,
          PoseLandmark.rightShoulder,
          PoseLandmark.leftAnkle,
          PoseLandmark.rightAnkle,
        ])) {
      return TrackingUpdate(
        state: state.copyWith(bodyDetected: false, phaseLabel: 'no_body'),
        event: state.bodyDetected ? TrackingEventKind.bodyLost : TrackingEventKind.none,
      );
    }

    final frame = PoseFrame(timestamp: obs.timestamp, landmarks: obs.landmarks);
    final leftArmUp = PoseGeometry.verticalOffset(
          frame,
          PoseLandmark.leftShoulder,
          PoseLandmark.leftWrist,
        ) ??
        -999;
    final rightArmUp = PoseGeometry.verticalOffset(
          frame,
          PoseLandmark.rightShoulder,
          PoseLandmark.rightWrist,
        ) ??
        -999;
    final spread = PoseGeometry.normalizedSpread(
          frame,
          PoseLandmark.leftAnkle,
          PoseLandmark.rightAnkle,
        ) ??
        0;

    final scale = obs.bodyScale.clamp(0.01, 1.0);
    final armThreshold = scale * 0.04;

    final armsOpen = leftArmUp < -armThreshold && rightArmUp < -armThreshold;
    final legsOpen = spread > 1.35;
    final armsClosed = leftArmUp > -armThreshold * 0.3 && rightArmUp > -armThreshold * 0.3;
    final legsClosed = spread < 1.2;

    var next = state.copyWith(bodyDetected: true, phaseLabel: _phase.name);

    if (_cooldownUntil != null && obs.timestamp.isBefore(_cooldownUntil!)) {
      return TrackingUpdate(state: next);
    }

    switch (_phase) {
      case _JackPhase.closed:
        if (armsOpen && legsOpen) {
          _phase = _JackPhase.open;
          _phaseEntered = obs.timestamp;
        }
      case _JackPhase.open:
        if (_dwellMs(obs.timestamp) >= 100 && armsClosed && legsClosed) {
          _phase = _JackPhase.closed;
          _phaseEntered = obs.timestamp;
          _cooldownUntil = obs.timestamp.add(const Duration(milliseconds: 350));
          next = next.copyWith(repCount: state.repCount + 1, clearFeedback: true);
          return TrackingUpdate(state: next, event: TrackingEventKind.repCompleted);
        }
    }
    return TrackingUpdate(state: next);
  }

  int _dwellMs(DateTime now) {
    final entered = _phaseEntered;
    if (entered == null) return 0;
    return now.difference(entered).inMilliseconds;
  }
}

enum _JackPhase { closed, open }
