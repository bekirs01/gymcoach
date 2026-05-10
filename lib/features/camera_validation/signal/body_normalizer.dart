import 'dart:math' as math;

import '../domain/pose_frame.dart';

abstract final class BodyNormalizer {
  static double? torsoLength(Map<PoseLandmark, PosePoint> landmarks) {
    final ls = landmarks[PoseLandmark.leftShoulder];
    final rs = landmarks[PoseLandmark.rightShoulder];
    final lh = landmarks[PoseLandmark.leftHip];
    final rh = landmarks[PoseLandmark.rightHip];
    if (ls == null || rs == null || lh == null || rh == null) return null;
    if (!ls.isReliable || !rs.isReliable || !lh.isReliable || !rh.isReliable) {
      return null;
    }
    final sx = (ls.x + rs.x) / 2;
    final sy = (ls.y + rs.y) / 2;
    final hx = (lh.x + rh.x) / 2;
    final hy = (lh.y + rh.y) / 2;
    return math.sqrt((sx - hx) * (sx - hx) + (sy - hy) * (sy - hy));
  }

  /// Translate to hip midpoint, scale by torso length. Y+ is down (image space).
  static Map<PoseLandmark, PosePoint> normalize(Map<PoseLandmark, PosePoint> landmarks) {
    final scale = torsoLength(landmarks);
    if (scale == null || scale < 1e-4) return const {};

    final lh = landmarks[PoseLandmark.leftHip]!;
    final rh = landmarks[PoseLandmark.rightHip]!;
    final ox = (lh.x + rh.x) / 2;
    final oy = (lh.y + rh.y) / 2;

    final out = <PoseLandmark, PosePoint>{};
    for (final entry in landmarks.entries) {
      final p = entry.value;
      out[entry.key] = PosePoint(
        x: (p.x - ox) / scale,
        y: (p.y - oy) / scale,
        visibility: p.visibility,
      );
    }
    return out;
  }

  static double framingScore(
    Map<PoseLandmark, PosePoint> landmarks,
    Iterable<PoseLandmark> critical,
  ) {
    var present = 0;
    var inBounds = 0;
    for (final j in critical) {
      final p = landmarks[j];
      if (p == null || !p.isReliable) continue;
      present++;
      if (p.x > 0.05 && p.x < 0.95 && p.y > 0.05 && p.y < 0.95) {
        inBounds++;
      }
    }
    if (present == 0) return 0;
    return (inBounds / present).clamp(0.0, 1.0);
  }
}
