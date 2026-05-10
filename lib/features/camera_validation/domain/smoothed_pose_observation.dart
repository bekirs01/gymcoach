import 'pose_frame.dart';
import 'pose_quality.dart';

class SmoothedPoseObservation {
  const SmoothedPoseObservation({
    required this.timestamp,
    required this.landmarks,
    required this.normalizedLandmarks,
    required this.velocities,
    required this.quality,
    required this.bodyScale,
    required this.dtSeconds,
    required this.raw,
  });

  final DateTime timestamp;
  final Map<PoseLandmark, PosePoint> landmarks;
  final Map<PoseLandmark, PosePoint> normalizedLandmarks;
  final Map<PoseLandmark, ({double x, double y})> velocities;
  final PoseQualityScore quality;
  final double bodyScale;
  final double dtSeconds;
  final PoseFrame raw;

  PosePoint? operator [](PoseLandmark landmark) => landmarks[landmark];

  PosePoint? normalized(PoseLandmark landmark) => normalizedLandmarks[landmark];

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
