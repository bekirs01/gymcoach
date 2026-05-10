import 'package:camera/camera.dart';

import '../../domain/exercise_profile.dart';
import '../../domain/exercise_tracking_mode.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../../domain/tracking_session_state.dart';
import '../../domain/tracking_update.dart';
import '../exercise_tracker.dart';

class UnsupportedExerciseTracker extends ExerciseTracker {
  UnsupportedExerciseTracker(this.reasonCode);

  final String reasonCode;

  @override
  String get canonicalId => 'unsupported';

  @override
  ExerciseProfile get profile => const ExerciseProfile(
        id: 'unsupported',
        mode: ExerciseTrackingMode.unsupported,
        preferredLens: CameraLensDirection.front,
        orientationHint: CameraOrientationHint.any,
        framingHint: 'Camera tracking is not available for this exercise.',
        safetyNote: 'Use manual rep counting instead.',
        criticalJoints: [],
      );

  @override
  ExerciseTrackingMode get mode => ExerciseTrackingMode.unsupported;

  @override
  void reset() {}

  @override
  TrackingUpdate process(SmoothedPoseObservation observation, TrackingSessionState state) {
    return TrackingUpdate(state: state.copyWith(bodyDetected: false, phaseLabel: 'unsupported'));
  }
}
