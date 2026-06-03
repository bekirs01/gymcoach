import '../../domain/exercise_profile.dart';
import '../../domain/exercise_profiles_data.dart';
import '../../domain/exercise_tracking_mode.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../../domain/tracking_session_state.dart';
import '../../domain/tracking_update.dart';
import '../biomechanics/metric_extractors.dart';
import '../exercise_tracker.dart';

/// Rep when opposite elbow and knee meet (alternating sides).
class BicycleCrunchTracker extends ExerciseTracker {
  @override
  String get canonicalId => 'bicycle_crunch';

  @override
  ExerciseTrackingMode get mode => profile.mode;

  @override
  ExerciseProfile get profile => ExerciseProfilesData.byId['bicycle_crunch']!;

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
    if (!obs.quality.isTrackingReady) {
      return TrackingUpdate(
        state: state.copyWith(bodyDetected: false, phaseLabel: 'no_body'),
        event: state.bodyDetected ? TrackingEventKind.bodyLost : TrackingEventKind.none,
      );
    }

    if (_cooldownUntil != null && obs.timestamp.isBefore(_cooldownUntil!)) {
      return TrackingUpdate(state: state.copyWith(bodyDetected: true, phaseLabel: 'twist'));
    }

    final scores = MetricExtractors.bicycleCrunchScores(obs);
    const hitThreshold = 95.0;
    var next = state.copyWith(bodyDetected: true, phaseLabel: 'twist');

    String? active;
    if (scores.leftScore >= hitThreshold) active = 'left';
    if (scores.rightScore >= hitThreshold && scores.rightScore >= scores.leftScore) {
      active = 'right';
    }

    if (active == null) {
      _armed = true;
      return TrackingUpdate(state: next);
    }

    if (_armed && active != _lastSide) {
      _lastSide = active;
      _armed = false;
      _cooldownUntil = obs.timestamp.add(const Duration(milliseconds: 320));
      next = next.copyWith(repCount: state.repCount + 1, clearFeedback: true);
      return TrackingUpdate(state: next, event: TrackingEventKind.repCompleted);
    }

    return TrackingUpdate(state: next);
  }
}
