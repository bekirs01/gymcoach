import 'dart:math' as math;

import '../domain/pose_frame.dart';

abstract final class PoseGeometry {
  static double? angle(PosePoint a, PosePoint b, PosePoint c) {
    final abX = a.x - b.x;
    final abY = a.y - b.y;
    final cbX = c.x - b.x;
    final cbY = c.y - b.y;
    final dot = abX * cbX + abY * cbY;
    final magAb = math.sqrt(abX * abX + abY * abY);
    final magCb = math.sqrt(cbX * cbX + cbY * cbY);
    if (magAb == 0 || magCb == 0) return null;
    final cos = (dot / (magAb * magCb)).clamp(-1.0, 1.0);
    return math.acos(cos) * 180 / math.pi;
  }

  static double? angleAt(PoseFrame frame, PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final pa = frame[a];
    final pb = frame[b];
    final pc = frame[c];
    if (pa == null || pb == null || pc == null) return null;
    if (!pa.isReliable || !pb.isReliable || !pc.isReliable) return null;
    return angle(pa, pb, pc);
  }

  static double? averageAngle(
    PoseFrame frame,
    PoseLandmark a1,
    PoseLandmark b1,
    PoseLandmark c1,
    PoseLandmark a2,
    PoseLandmark b2,
    PoseLandmark c2,
  ) {
    final left = angleAt(frame, a1, b1, c1);
    final right = angleAt(frame, a2, b2, c2);
    if (left != null && right != null) return (left + right) / 2;
    return left ?? right;
  }

  static double? armElevationDeg(PoseFrame frame, bool leftSide) {
    final shoulder = leftSide ? PoseLandmark.leftShoulder : PoseLandmark.rightShoulder;
    final elbow = leftSide ? PoseLandmark.leftElbow : PoseLandmark.rightElbow;
    final hip = leftSide ? PoseLandmark.leftHip : PoseLandmark.rightHip;
    final ps = frame[shoulder];
    final pe = frame[elbow];
    final ph = frame[hip];
    if (ps == null || pe == null || ph == null) return null;
    if (!ps.isReliable || !pe.isReliable || !ph.isReliable) return null;
    final torsoX = ps.x - ph.x;
    final torsoY = ps.y - ph.y;
    final armX = pe.x - ps.x;
    final armY = pe.y - ps.y;
    final torsoMag = math.sqrt(torsoX * torsoX + torsoY * torsoY);
    final armMag = math.sqrt(armX * armX + armY * armY);
    if (torsoMag == 0 || armMag == 0) return null;
    final dot = torsoX * armX + torsoY * armY;
    final cos = (dot / (torsoMag * armMag)).clamp(-1.0, 1.0);
    return math.acos(cos) * 180 / math.pi;
  }

  static double? normalizedSpread(PoseFrame frame, PoseLandmark left, PoseLandmark right) {
    final pl = frame[left];
    final pr = frame[right];
    if (pl == null || pr == null || !pl.isReliable || !pr.isReliable) return null;
    final sw = (frame[PoseLandmark.leftShoulder]!.x - frame[PoseLandmark.rightShoulder]!.x).abs();
    if (sw < 0.01) return null;
    return (pl.x - pr.x).abs() / sw;
  }

  static double? verticalOffset(PoseFrame frame, PoseLandmark upper, PoseLandmark lower) {
    final pu = frame[upper];
    final pl = frame[lower];
    if (pu == null || pl == null || !pu.isReliable || !pl.isReliable) return null;
    return pl.y - pu.y;
  }

  /// Euclidean distance between two landmarks divided by [scale] (torso length).
  static double? normalizedDistance(
    PoseFrame frame,
    PoseLandmark a,
    PoseLandmark b,
    double scale,
  ) {
    if (scale < 1e-4) return null;
    final pa = frame[a];
    final pb = frame[b];
    if (pa == null || pb == null || !pa.isReliable || !pb.isReliable) return null;
    final dx = pa.x - pb.x;
    final dy = pa.y - pb.y;
    return math.sqrt(dx * dx + dy * dy) / scale;
  }

  /// Vertical gap (lower.y - upper.y) between bilateral midpoints, normalized.
  static double? bilateralVerticalGapNorm(
    PoseFrame frame,
    PoseLandmark upperLeft,
    PoseLandmark upperRight,
    PoseLandmark lowerLeft,
    PoseLandmark lowerRight,
    double scale,
  ) {
    if (scale < 1e-4) return null;
    final uy = frame.midpointY(upperLeft, upperRight);
    final ly = frame.midpointY(lowerLeft, lowerRight);
    if (uy == null || ly == null) return null;
    return (ly - uy) / scale;
  }

  static double? legKneeAngle(PoseFrame frame, {required bool left}) {
    if (left) {
      return angleAt(frame, PoseLandmark.leftHip, PoseLandmark.leftKnee, PoseLandmark.leftAnkle);
    }
    return angleAt(frame, PoseLandmark.rightHip, PoseLandmark.rightKnee, PoseLandmark.rightAnkle);
  }

  static double? hipKneeGapNorm(PoseFrame frame, double scale, {required bool left}) {
    if (left) {
      return normalizedDistance(frame, PoseLandmark.leftHip, PoseLandmark.leftKnee, scale);
    }
    return normalizedDistance(frame, PoseLandmark.rightHip, PoseLandmark.rightKnee, scale);
  }

  static double? hipKneeVerticalGapNorm(PoseFrame frame, double scale, {required bool left}) {
    if (scale < 1e-4) return null;
    final hip = left ? PoseLandmark.leftHip : PoseLandmark.rightHip;
    final knee = left ? PoseLandmark.leftKnee : PoseLandmark.rightKnee;
    final gap = verticalOffset(frame, hip, knee);
    if (gap == null) return null;
    return gap / scale;
  }
}
