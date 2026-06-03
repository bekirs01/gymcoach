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
    this.placementHint = '',
    this.setupSteps = const [],
  });

  final CameraOrientationHint orientation;
  final String framingHint;
  final String safetyNote;
  final String placementHint;
  final List<String> setupSteps;
}
