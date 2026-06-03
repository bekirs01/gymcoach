import 'package:camera/camera.dart';

import 'exercise_tracking_mode.dart';
import 'pose_frame.dart';
import '../engine/adaptive_rep_engine.dart';
import 'exercise_profiles_data.dart';

class ExerciseProfile {
  const ExerciseProfile({
    required this.id,
    required this.mode,
    required this.preferredLens,
    required this.orientationHint,
    required this.framingHint,
    required this.safetyNote,
    required this.criticalJoints,
    this.repConfig,
    this.placementHint = '',
    this.setupSteps = const [],
  });

  final String id;
  final ExerciseTrackingMode mode;
  final CameraLensDirection preferredLens;
  final CameraOrientationHint orientationHint;
  final String framingHint;
  final String safetyNote;
  final String placementHint;
  final List<String> setupSteps;
  final List<PoseLandmark> criticalJoints;
  final AdaptiveRepEngineConfig? repConfig;
}

/// Back-compat accessors for tests and legacy imports.
abstract final class ExerciseProfiles {
  static ExerciseProfile get squats => ExerciseProfilesData.byId['squats']!;
  static ExerciseProfile get pushUps => ExerciseProfilesData.byId['push_ups']!;
  static ExerciseProfile get lunges => ExerciseProfilesData.byId['lunges']!;
  static ExerciseProfile get plank => ExerciseProfilesData.byId['plank']!;
  static ExerciseProfile get shoulderPress => ExerciseProfilesData.byId['shoulder_press']!;
  static ExerciseProfile get jumpingJacks => ExerciseProfilesData.byId['jumping_jacks']!;
  static ExerciseProfile get pullUps => ExerciseProfilesData.byId['pull_ups']!;
  static ExerciseProfile get deadlift => ExerciseProfilesData.byId['deadlift']!;

  static ExerciseProfile? forId(String id) => ExerciseProfilesData.byId[id];
}
