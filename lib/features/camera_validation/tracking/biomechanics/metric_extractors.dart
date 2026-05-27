import '../../domain/pose_frame.dart';
import '../../domain/smoothed_pose_observation.dart';
import '../pose_geometry.dart';

/// Per-exercise biomechanics metrics. Higher composite = extended/top, lower = flexed/bottom
/// (except where noted for hold exercises).
abstract final class MetricExtractors {
  // ── Squat: knee flexion + hip-to-knee distance + hip flexion ──────────────

  static double? squatMetric(SmoothedPoseObservation obs) {
    final frame = _asFrame(obs);
    final scale = obs.bodyScale;
    final knee = _avgLegKneeAngle(frame);
    final hipGap = _avgHipKneeVerticalGap(frame, scale);
    final hipFlex = PoseGeometry.averageAngle(
      frame,
      PoseLandmark.leftShoulder,
      PoseLandmark.leftHip,
      PoseLandmark.leftKnee,
      PoseLandmark.rightShoulder,
      PoseLandmark.rightHip,
      PoseLandmark.rightKnee,
    );
    final gapScore = hipGap != null ? (hipGap * 380).clamp(35.0, 170.0) : null;
    return _blend([
      (knee, 0.45),
      (gapScore, 0.35),
      (hipFlex, 0.20),
    ]);
  }

  // ── Push-up: elbow flexion angle ───────────────────────────────────────────

  static double? pushUpMetric(SmoothedPoseObservation obs) => elbowAngle(obs);

  // ── Lunge: front-leg knee angle + front hip-knee gap ─────────────────────

  static double? lungeMetric(SmoothedPoseObservation obs) {
    final frame = _asFrame(obs);
    final scale = obs.bodyScale;
    final leftKnee = PoseGeometry.legKneeAngle(frame, left: true);
    final rightKnee = PoseGeometry.legKneeAngle(frame, left: false);
    if (leftKnee == null && rightKnee == null) return null;

    final leftGap = PoseGeometry.hipKneeVerticalGapNorm(frame, scale, left: true);
    final rightGap = PoseGeometry.hipKneeVerticalGapNorm(frame, scale, left: false);

    double? legScore(double? knee, double? gap) {
      if (knee == null) return null;
      final g = gap != null ? (gap * 350).clamp(30.0, 170.0) : knee;
      return knee * 0.6 + g * 0.4;
    }

    final leftScore = legScore(leftKnee, leftGap);
    final rightScore = legScore(rightKnee, rightGap);

    final lk = leftKnee ?? 180;
    final rk = rightKnee ?? 180;
    final trailingExtended = (lk > 150 && rk > 150) || (lk - rk).abs() < 12;
    if (trailingExtended && lk > 140 && rk > 140) return 165;

    final scores = [leftScore, rightScore].whereType<double>();
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a < b ? a : b);
  }

  // ── Deadlift: hip hinge + shoulder-hip distance ─────────────────────────

  static double? deadliftMetric(SmoothedPoseObservation obs) {
    final frame = _asFrame(obs);
    final scale = obs.bodyScale;
    final hinge = hipHingeAngle(obs);
    final shoulderHip = PoseGeometry.bilateralVerticalGapNorm(
      frame,
      PoseLandmark.leftShoulder,
      PoseLandmark.rightShoulder,
      PoseLandmark.leftHip,
      PoseLandmark.rightHip,
      scale,
    );
    final reach = shoulderHip != null ? (shoulderHip * 320).clamp(40.0, 175.0) : null;
    return _blend([
      (hinge, 0.7),
      (reach, 0.3),
    ]);
  }

  // ── Shoulder press / lateral raise: arm elevation + elbow + wrist height ─

  static double? shoulderPressMetric(SmoothedPoseObservation obs) {
    final frame = _asFrame(obs);
    final elbow = elbowAngle(obs);
    if (elbow == null) return null;

    final leftAb = PoseGeometry.armElevationDeg(frame, true);
    final rightAb = PoseGeometry.armElevationDeg(frame, false);
    final abduction = leftAb != null && rightAb != null
        ? (leftAb + rightAb) / 2
        : (leftAb ?? rightAb);

    final wristsAbove = _wristsAboveShoulders(obs);
    final lateral = (abduction ?? 0) >= 55;
    return (wristsAbove ? elbow + 50 : elbow) + (lateral ? 15 : 0);
  }

  static bool validShoulderPressLockout(SmoothedPoseObservation obs) {
    final frame = _asFrame(obs);
    final elbow = elbowAngle(obs);
    if (elbow == null) return false;
    final leftAb = PoseGeometry.armElevationDeg(frame, true);
    final rightAb = PoseGeometry.armElevationDeg(frame, false);
    final abduction = leftAb != null && rightAb != null
        ? (leftAb + rightAb) / 2
        : (leftAb ?? rightAb ?? 0);
    final wristsAbove = _wristsAboveShoulders(obs);
    final lateral = abduction >= 68 && elbow >= 128;
    return (wristsAbove && elbow >= 142) || lateral;
  }

  // ── Pull-up: elbow flexion (low = pulled, high = hang) ──────────────────

  static double? pullUpMetric(SmoothedPoseObservation obs) {
    return elbowAngle(obs);
  }

  static bool chinAboveBar(SmoothedPoseObservation obs) => _chinAboveBar(obs);

  // ── Jumping jack: arm elevation + leg spread ─────────────────────────────

  static ({bool armsUp, bool legsOpen, bool armsDown, bool legsClosed}) jumpingJackState(
    SmoothedPoseObservation obs,
  ) {
    final frame = _asFrame(obs);
    final scale = obs.bodyScale.clamp(0.01, 1.0);
    final armTh = scale * 0.035;

    final leftArm = PoseGeometry.verticalOffset(
      frame,
      PoseLandmark.leftShoulder,
      PoseLandmark.leftWrist,
    );
    final rightArm = PoseGeometry.verticalOffset(
      frame,
      PoseLandmark.rightShoulder,
      PoseLandmark.rightWrist,
    );
    final spread = PoseGeometry.normalizedSpread(
          frame,
          PoseLandmark.leftAnkle,
          PoseLandmark.rightAnkle,
        ) ??
        0;

    final armsUp = (leftArm ?? -999) < -armTh && (rightArm ?? -999) < -armTh;
    final armsDown = (leftArm ?? 999) > -armTh * 0.25 && (rightArm ?? 999) > -armTh * 0.25;
    final legsOpen = spread > 1.32;
    final legsClosed = spread < 1.18;

    return (armsUp: armsUp, legsOpen: legsOpen, armsDown: armsDown, legsClosed: legsClosed);
  }

  // ── Plank: body line + hip sag ───────────────────────────────────────────

  static double? plankBodyLine(SmoothedPoseObservation obs) {
    return bodyLineAngle(obs);
  }

  static bool plankHipsSagging(SmoothedPoseObservation obs) {
    final line = plankBodyLine(obs);
    return line != null && line < 145;
  }

  // ── Shared primitives ────────────────────────────────────────────────────

  static double? kneeAngle(SmoothedPoseObservation obs) => _avgLegKneeAngle(_asFrame(obs));

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

  static double? _avgLegKneeAngle(PoseFrame frame) {
    return PoseGeometry.averageAngle(
      frame,
      PoseLandmark.leftHip,
      PoseLandmark.leftKnee,
      PoseLandmark.leftAnkle,
      PoseLandmark.rightHip,
      PoseLandmark.rightKnee,
      PoseLandmark.rightAnkle,
    );
  }

  static double? _avgHipKneeVerticalGap(PoseFrame frame, double scale) {
    final l = PoseGeometry.hipKneeVerticalGapNorm(frame, scale, left: true);
    final r = PoseGeometry.hipKneeVerticalGapNorm(frame, scale, left: false);
    if (l != null && r != null) return (l + r) / 2;
    return l ?? r;
  }

  static double? _blend(List<(double? value, double weight)> parts) {
    var sum = 0.0;
    var w = 0.0;
    for (final (value, weight) in parts) {
      if (value == null) continue;
      sum += value * weight;
      w += weight;
    }
    if (w == 0) return null;
    return sum / w;
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
