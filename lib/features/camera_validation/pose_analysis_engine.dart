import 'domain/pose_frame.dart';
import 'domain/smoothed_pose_observation.dart';
import 'domain/tracking_session_state.dart';
import 'domain/tracking_update.dart';
import 'signal/pose_signal_processor.dart';
import 'tracking/exercise_tracker.dart';

class PoseAnalysisEngine {
  PoseAnalysisEngine(this.tracker)
      : _signal = PoseSignalProcessor(criticalJoints: tracker.profile.criticalJoints);

  final ExerciseTracker tracker;
  final PoseSignalProcessor _signal;
  TrackingSessionState _state = const TrackingSessionState();

  TrackingSessionState get state => _state;
  SmoothedPoseObservation? get lastObservation => _lastObservation;

  SmoothedPoseObservation? _lastObservation;

  TrackingUpdate process(PoseFrame rawFrame) {
    final observation = _signal.process(rawFrame);
    _lastObservation = observation;
    final update = tracker.process(observation, _state);
    _state = update.state;
    return update;
  }

  void reset() {
    tracker.reset();
    _signal.reset();
    _state = const TrackingSessionState();
    _lastObservation = null;
  }
}
