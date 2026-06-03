import 'package:camera/camera.dart';

import '../domain/exercise_profile.dart';
import '../domain/exercise_tracking_mode.dart';
import '../domain/smoothed_pose_observation.dart';
import '../domain/tracking_session_state.dart';
import '../domain/tracking_update.dart';

abstract class ExerciseTracker {
  String get canonicalId;
  ExerciseTrackingMode get mode;
  ExerciseProfile get profile;
  CameraLensDirection get preferredLens => profile.preferredLens;
  CameraGuidance get guidance => profile.guidance;

  void reset();

  TrackingUpdate process(SmoothedPoseObservation observation, TrackingSessionState state);
}

extension ExerciseProfileGuidance on ExerciseProfile {
  CameraGuidance get guidance => CameraGuidance(
        orientation: orientationHint,
        framingHint: framingHint,
        safetyNote: safetyNote,
        placementHint: placementHint,
        setupSteps: setupSteps,
      );
}
