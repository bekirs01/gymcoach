import 'package:camera/camera.dart';

import '../domain/exercise_tracking_mode.dart';
import '../domain/pose_frame.dart';
import '../engine/adaptive_rep_engine.dart';

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
  });

  final String id;
  final ExerciseTrackingMode mode;
  final CameraLensDirection preferredLens;
  final CameraOrientationHint orientationHint;
  final String framingHint;
  final String safetyNote;
  final List<PoseLandmark> criticalJoints;
  final AdaptiveRepEngineConfig? repConfig;
}

abstract final class ExerciseProfiles {
  static const _hipLeg = [
    PoseLandmark.leftHip,
    PoseLandmark.rightHip,
    PoseLandmark.leftKnee,
    PoseLandmark.rightKnee,
    PoseLandmark.leftAnkle,
    PoseLandmark.rightAnkle,
  ];

  static const _upperBody = [
    PoseLandmark.leftShoulder,
    PoseLandmark.rightShoulder,
    PoseLandmark.leftElbow,
    PoseLandmark.rightElbow,
    PoseLandmark.leftWrist,
    PoseLandmark.rightWrist,
  ];

  static const squats = ExerciseProfile(
    id: 'squats',
    mode: ExerciseTrackingMode.repBased,
    preferredLens: CameraLensDirection.front,
    orientationHint: CameraOrientationHint.front,
    framingHint: 'Face the camera. Keep hips, knees, and ankles in frame.',
    safetyNote: 'Chest up, knees track over toes.',
    criticalJoints: _hipLeg,
    repConfig: AdaptiveRepEngineConfig(
      defaultBottom: 95,
      defaultTop: 155,
      hysteresisBand: 10,
      minEccentricVelocity: 20,
      minRomSpan: 30,
    ),
  );

  static const pushUps = ExerciseProfile(
    id: 'push_ups',
    mode: ExerciseTrackingMode.repBased,
    preferredLens: CameraLensDirection.front,
    orientationHint: CameraOrientationHint.front,
    framingHint: 'Face the camera at an angle so shoulders, elbows, and wrists are visible.',
    safetyNote: 'Straight line shoulders to ankles.',
    criticalJoints: [..._upperBody, ..._hipLeg],
    repConfig: AdaptiveRepEngineConfig(
      defaultBottom: 90,
      defaultTop: 155,
      hysteresisBand: 8,
      minBottomDwellMs: 100,
    ),
  );

  static const lunges = ExerciseProfile(
    id: 'lunges',
    mode: ExerciseTrackingMode.repBased,
    preferredLens: CameraLensDirection.front,
    orientationHint: CameraOrientationHint.front,
    framingHint: 'Face the camera. Step forward so both legs are visible.',
    safetyNote: 'Front knee over ankle, torso upright.',
    criticalJoints: _hipLeg,
    repConfig: AdaptiveRepEngineConfig(
      defaultBottom: 95,
      defaultTop: 160,
      hysteresisBand: 10,
      minRomSpan: 28,
    ),
  );

  static const plank = ExerciseProfile(
    id: 'plank',
    mode: ExerciseTrackingMode.holdBased,
    preferredLens: CameraLensDirection.front,
    orientationHint: CameraOrientationHint.front,
    framingHint: 'Face the camera from the side so your body line is visible.',
    safetyNote: 'Stop if lower back discomfort.',
    criticalJoints: [
      PoseLandmark.leftShoulder,
      PoseLandmark.rightShoulder,
      PoseLandmark.leftHip,
      PoseLandmark.rightHip,
      PoseLandmark.leftAnkle,
      PoseLandmark.rightAnkle,
    ],
  );

  static const shoulderPress = ExerciseProfile(
    id: 'shoulder_press',
    mode: ExerciseTrackingMode.repBased,
    preferredLens: CameraLensDirection.front,
    orientationHint: CameraOrientationHint.front,
    framingHint: 'Front view: upper body and both arms in frame.',
    safetyNote: 'Press overhead with control.',
    criticalJoints: _upperBody,
    repConfig: AdaptiveRepEngineConfig(
      defaultBottom: 90,
      defaultTop: 155,
      hysteresisBand: 12,
      minEccentricVelocity: 18,
    ),
  );

  static const jumpingJacks = ExerciseProfile(
    id: 'jumping_jacks',
    mode: ExerciseTrackingMode.repBased,
    preferredLens: CameraLensDirection.front,
    orientationHint: CameraOrientationHint.front,
    framingHint: 'Full body: arms and feet visible.',
    safetyNote: 'Land softly, knees slightly bent.',
    criticalJoints: [
      ..._upperBody,
      PoseLandmark.leftAnkle,
      PoseLandmark.rightAnkle,
    ],
  );

  static const pullUps = ExerciseProfile(
    id: 'pull_ups',
    mode: ExerciseTrackingMode.repBased,
    preferredLens: CameraLensDirection.front,
    orientationHint: CameraOrientationHint.front,
    framingHint: 'Front view: shoulders, elbows, chin visible.',
    safetyNote: 'Controlled motion, no kipping.',
    criticalJoints: [..._upperBody, PoseLandmark.nose],
    repConfig: AdaptiveRepEngineConfig(
      defaultBottom: 95,
      defaultTop: 150,
      hysteresisBand: 10,
      minEccentricVelocity: 25,
    ),
  );

  static const deadlift = ExerciseProfile(
    id: 'deadlift',
    mode: ExerciseTrackingMode.repBased,
    preferredLens: CameraLensDirection.front,
    orientationHint: CameraOrientationHint.front,
    framingHint: 'Face the camera. Keep shoulders, hips, and knees in frame.',
    safetyNote: 'Neutral spine throughout hinge.',
    criticalJoints: [
      PoseLandmark.leftShoulder,
      PoseLandmark.rightShoulder,
      PoseLandmark.leftHip,
      PoseLandmark.rightHip,
      PoseLandmark.leftKnee,
      PoseLandmark.rightKnee,
    ],
    repConfig: AdaptiveRepEngineConfig(
      defaultBottom: 105,
      defaultTop: 165,
      hysteresisBand: 9,
      minRomSpan: 22,
    ),
  );

  static ExerciseProfile? forId(String id) => switch (id) {
        'squats' => squats,
        'push_ups' => pushUps,
        'lunges' => lunges,
        'plank' => plank,
        'shoulder_press' => shoulderPress,
        'jumping_jacks' => jumpingJacks,
        'pull_ups' => pullUps,
        'deadlift' => deadlift,
        _ => null,
      };
}
