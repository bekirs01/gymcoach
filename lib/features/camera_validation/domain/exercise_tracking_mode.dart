enum ExerciseTrackingMode {
  repBased,
  holdBased,
  unsupported,
}

enum CameraOrientationHint {
  front,
  side,
  any,
}

class CameraGuidance {
  const CameraGuidance({
    required this.orientation,
    required this.framingHint,
    required this.safetyNote,
  });

  final CameraOrientationHint orientation;
  final String framingHint;
  final String safetyNote;
}
