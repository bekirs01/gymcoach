enum PoseLandmark {
  nose,
  leftShoulder,
  rightShoulder,
  leftElbow,
  rightElbow,
  leftWrist,
  rightWrist,
  leftHip,
  rightHip,
  leftKnee,
  rightKnee,
  leftAnkle,
  rightAnkle,
}

class PosePoint {
  const PosePoint({
    required this.x,
    required this.y,
    this.visibility = 1,
  });

  final double x;
  final double y;
  final double visibility;

  bool get isReliable => visibility >= 0.5;
}

class PoseFrame {
  const PoseFrame({
    required this.timestamp,
    required this.landmarks,
  });

  final DateTime timestamp;
  final Map<PoseLandmark, PosePoint> landmarks;

  PosePoint? operator [](PoseLandmark landmark) => landmarks[landmark];

  bool hasReliable(PoseLandmark landmark) {
    final p = landmarks[landmark];
    return p != null && p.isReliable;
  }

  bool hasAllReliable(Iterable<PoseLandmark> required) {
    for (final l in required) {
      if (!hasReliable(l)) return false;
    }
    return true;
  }

  double? midpointY(PoseLandmark a, PoseLandmark b) {
    final pa = landmarks[a];
    final pb = landmarks[b];
    if (pa == null || pb == null) return null;
    if (!pa.isReliable || !pb.isReliable) return null;
    return (pa.y + pb.y) / 2;
  }

  double? midpointX(PoseLandmark a, PoseLandmark b) {
    final pa = landmarks[a];
    final pb = landmarks[b];
    if (pa == null || pb == null) return null;
    if (!pa.isReliable || !pb.isReliable) return null;
    return (pa.x + pb.x) / 2;
  }
}
