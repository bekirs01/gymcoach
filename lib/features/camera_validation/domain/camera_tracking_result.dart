import 'exercise_tracking_mode.dart';

class CameraTrackingResult {
  const CameraTrackingResult({
    required this.validReps,
    required this.invalidAttempts,
    required this.mode,
    required this.usedCamera,
    this.holdSeconds = 0,
  });

  final int validReps;
  final int invalidAttempts;
  final ExerciseTrackingMode mode;
  final bool usedCamera;
  final int holdSeconds;

  int get primaryCount => mode == ExerciseTrackingMode.holdBased ? holdSeconds : validReps;
}
