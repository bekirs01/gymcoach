import '../../domain/pose_frame.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../pose_geometry.dart';

abstract final class MetricExtractors {
  static double? kneeAngle(SmoothedPoseObservation obs) {
    return PoseGeometry.averageAngle(
      _asFrame(obs),
      PoseLandmark.leftHip,
      PoseLandmark.leftKnee,
      PoseLandmark.leftAnkle,
      PoseLandmark.rightHip,
      PoseLandmark.rightKnee,
      PoseLandmark.rightAnkle,
    );
  }

  /// Front-view fallback: normalized hip drop (0=standing, higher=deeper squat).
  static double? squatMetric(SmoothedPoseObservation obs) {
    final angle = kneeAngle(obs);
    final hipDrop = _normalizedHipDrop(obs);
    if (angle != null && hipDrop != null) {
      return angle * 0.7 + (180 - hipDrop * 120) * 0.3;
    }
    return angle ?? (hipDrop != null ? 180 - hipDrop * 120 : null);
  }

  static double? elbowAngle(SmoothedPoseObservation obs) {
    return PoseGeometry.averageAngle(
      _asFrame(obs),
      PoseLandmark.leftShoulder,
      PoseLandmark.leftElbow,
      PoseLandmark.leftWrist,
      PoseLandmark.rightShoulder,
      PoseLandmark.rightElbow,
      PoseLandmark.rightWrist,
    );
  }

  static double? hipHingeAngle(SmoothedPoseObservation obs) {
    return PoseGeometry.averageAngle(
      _asFrame(obs),
      PoseLandmark.leftShoulder,
      PoseLandmark.leftHip,
      PoseLandmark.leftKnee,
      PoseLandmark.rightShoulder,
      PoseLandmark.rightHip,
      PoseLandmark.rightKnee,
    );
  }

  static double? bodyLineAngle(SmoothedPoseObservation obs) {
    return PoseGeometry.averageAngle(
      _asFrame(obs),
      PoseLandmark.leftShoulder,
      PoseLandmark.leftHip,
      PoseLandmark.leftAnkle,
      PoseLandmark.rightShoulder,
      PoseLandmark.rightHip,
      PoseLandmark.rightAnkle,
    );
  }

  /// Deepest front knee during lunge; standing resets via trailing leg extension.
  static double? lungeMetric(SmoothedPoseObservation obs) {
    final left = PoseGeometry.angleAt(
      _asFrame(obs),
      PoseLandmark.leftHip,
      PoseLandmark.leftKnee,
      PoseLandmark.leftAnkle,
    );
    final right = PoseGeometry.angleAt(
      _asFrame(obs),
      PoseLandmark.rightHip,
      PoseLandmark.rightKnee,
      PoseLandmark.rightAnkle,
    );
    if (left == null && right == null) return null;

    final angles = [left, right].whereType<double>().toList();
    final deepest = angles.reduce((a, b) => a < b ? a : b);
    final trailing = angles.reduce((a, b) => a > b ? a : b);

    // Standing: trailing leg extended (>155°), metric stays high.
    if (trailing >= 155 && deepest >= 140) return 165;
    return deepest;
  }

  static double? pullUpMetric(SmoothedPoseObservation obs) {
    final elbow = elbowAngle(obs);
    if (elbow == null) return null;
    final chinClear = _chinAboveBar(obs);
    return chinClear ? elbow + 40 : elbow;
  }

  static bool chinAboveBar(SmoothedPoseObservation obs) => _chinAboveBar(obs);

  static double? shoulderPressMetric(SmoothedPoseObservation obs) {
    final elbow = elbowAngle(obs);
    if (elbow == null) return null;

    final leftAb = PoseGeometry.armElevationDeg(_asFrame(obs), true);
    final rightAb = PoseGeometry.armElevationDeg(_asFrame(obs), false);
    final abduction = leftAb != null && rightAb != null
        ? (leftAb + rightAb) / 2
        : (leftAb ?? rightAb ?? 0);

    final wristsAbove = _wristsAboveShoulders(obs);
    final lateral = abduction >= 55;
    return (wristsAbove ? elbow + 50 : elbow) + (lateral ? 15 : 0);
  }

  static bool validShoulderPressLockout(SmoothedPoseObservation obs) {
    final elbow = elbowAngle(obs);
    if (elbow == null) return false;
    final leftAb = PoseGeometry.armElevationDeg(_asFrame(obs), true);
    final rightAb = PoseGeometry.armElevationDeg(_asFrame(obs), false);
    final abduction = leftAb != null && rightAb != null
        ? (leftAb + rightAb) / 2
        : (leftAb ?? rightAb ?? 0);
    final wristsAbove = _wristsAboveShoulders(obs);
    final lateral = abduction >= 70 && elbow >= 130;
    return (wristsAbove && elbow >= 145) || lateral;
  }

  static double? _normalizedHipDrop(SmoothedPoseObservation obs) {
    final lh = obs.normalized(PoseLandmark.leftHip);
    final rh = obs.normalized(PoseLandmark.rightHip);
    final ls = obs.normalized(PoseLandmark.leftShoulder);
    final rs = obs.normalized(PoseLandmark.rightShoulder);
    if (lh == null || rh == null || ls == null || rs == null) return null;
    final hipY = (lh.y + rh.y) / 2;
    final shoulderY = (ls.y + rs.y) / 2;
    return (hipY - shoulderY).clamp(0.0, 2.0);
  }

  static bool _chinAboveBar(SmoothedPoseObservation obs) {
    final nose = obs[PoseLandmark.nose];
    final lw = obs[PoseLandmark.leftWrist];
    final rw = obs[PoseLandmark.rightWrist];
    if (nose == null || !nose.isReliable) return false;
    final refY = lw != null && rw != null ? (lw.y + rw.y) / 2 : (lw?.y ?? rw?.y);
    if (refY == null) return false;
    return nose.y < refY - obs.bodyScale * 0.02;
  }

  static bool _wristsAboveShoulders(SmoothedPoseObservation obs) {
    final ls = obs[PoseLandmark.leftShoulder];
    final rs = obs[PoseLandmark.rightShoulder];
    final lw = obs[PoseLandmark.leftWrist];
    final rw = obs[PoseLandmark.rightWrist];
    if (ls == null || rs == null || lw == null || rw == null) return false;
    return lw.y < ls.y - obs.bodyScale * 0.02 && rw.y < rs.y - obs.bodyScale * 0.02;
  }

  static PoseFrame _asFrame(SmoothedPoseObservation obs) {
    return PoseFrame(timestamp: obs.timestamp, landmarks: obs.landmarks);
  }
}
