import '../../domain/exercise_profile.dart';
import '../../domain/exercise_profiles_data.dart';
import '../../domain/exercise_tracking_mode.dart';
import '../../domain/pose_frame.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../../domain/tracking_session_state.dart';
import '../../domain/tracking_update.dart';
import '../biomechanics/metric_extractors.dart';
import '../exercise_tracker.dart';

/// Counts reps when each knee drives clearly toward the chest (alternating).
class MountainClimberTracker extends ExerciseTracker {
  @override
  String get canonicalId => 'mountain_climber';

  @override
  ExerciseTrackingMode get mode => profile.mode;

  @override
  ExerciseProfile get profile => ExerciseProfilesData.byId['mountain_climber']!;

  var _lastSide = '';
  var _armed = true;
  DateTime? _cooldownUntil;

  @override
  void reset() {
    _lastSide = '';
    _armed = true;
    _cooldownUntil = null;
  }

  @override
  TrackingUpdate process(SmoothedPoseObservation obs, TrackingSessionState state) {
    if (!obs.quality.isTrackingReady ||
        !obs.hasAllReliable([
          PoseLandmark.leftShoulder,
          PoseLandmark.rightShoulder,
          PoseLandmark.leftKnee,
          PoseLandmark.rightKnee,
        ])) {
      return TrackingUpdate(
        state: state.copyWith(bodyDetected: false, phaseLabel: 'no_body'),
        event: state.bodyDetected ? TrackingEventKind.bodyLost : TrackingEventKind.none,
      );
    }

    if (_cooldownUntil != null && obs.timestamp.isBefore(_cooldownUntil!)) {
      return TrackingUpdate(state: state.copyWith(bodyDetected: true, phaseLabel: 'drive'));
    }

    final frame = PoseFrame(timestamp: obs.timestamp, landmarks: obs.landmarks);
    final ls = frame[PoseLandmark.leftShoulder]!;
    final rs = frame[PoseLandmark.rightShoulder]!;
    final lk = frame[PoseLandmark.leftKnee]!;
    final rk = frame[PoseLandmark.rightKnee]!;
    final midY = (ls.y + rs.y) / 2;
    final scale = obs.bodyScale;
    final leftDrive = (midY - lk.y) / scale;
    final rightDrive = (midY - rk.y) / scale;
    const threshold = 0.12;

    var next = state.copyWith(bodyDetected: true, phaseLabel: 'drive');
    String activeSide;
    if (leftDrive >= rightDrive && leftDrive > threshold) {
      activeSide = 'left';
    } else if (rightDrive > threshold) {
      activeSide = 'right';
    } else {
      _armed = true;
      return TrackingUpdate(state: next);
    }

    if (_armed && activeSide != _lastSide) {
      _lastSide = activeSide;
      _armed = false;
      _cooldownUntil = obs.timestamp.add(const Duration(milliseconds: 280));
      next = next.copyWith(repCount: state.repCount + 1, clearFeedback: true);
      return TrackingUpdate(state: next, event: TrackingEventKind.repCompleted);
    }

    if (leftDrive < threshold * 0.6 && rightDrive < threshold * 0.6) {
      _armed = true;
    }
    return TrackingUpdate(state: next);
  }
}
