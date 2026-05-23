import '../domain/pose_frame.dart';
import '../domain/pose_quality.dart';
import '../domain/smoothed_pose_observation.dart';
import 'body_normalizer.dart';
import 'confidence_stabilizer.dart';
import 'one_euro_filter.dart';

class PoseSignalProcessor {
  PoseSignalProcessor({
    this.criticalJoints = const [
      PoseLandmark.leftShoulder,
      PoseLandmark.rightShoulder,
      PoseLandmark.leftHip,
      PoseLandmark.rightHip,
      PoseLandmark.leftKnee,
      PoseLandmark.rightKnee,
    ],
  });

  final Iterable<PoseLandmark> criticalJoints;

  final ConfidenceStabilizer _confidence = ConfidenceStabilizer();
  final Map<PoseLandmark, OneEuroFilter2D> _filters = {};
  DateTime? _lastTimestamp;
  double _lastStability = 1.0;
  double _lastBodyScale = 1.0;

  void reset() {
    _confidence.reset();
    _filters.clear();
    _lastTimestamp = null;
    _lastStability = 1.0;
  }

  void setCriticalJoints(Iterable<PoseLandmark> joints) {
    // Caller should reset when joints change between exercises.
  }

  SmoothedPoseObservation process(PoseFrame raw) {
    final stabilized = _confidence.stabilize(raw);
    final dt = _computeDt(raw.timestamp);
    final smoothed = _smoothLandmarks(stabilized, dt);
    final normalized = BodyNormalizer.normalize(smoothed);
    final bodyScale = BodyNormalizer.torsoLength(smoothed) ?? _lastBodyScale;
    _lastBodyScale = bodyScale;

    final velocities = _computeVelocities(smoothed, dt);
    final stability = _estimateStability(velocities);
    _lastStability = stability;

    final quality = _scoreQuality(smoothed, normalized, stability);

    return SmoothedPoseObservation(
      timestamp: raw.timestamp,
      landmarks: smoothed,
      normalizedLandmarks: normalized,
      velocities: velocities,
      quality: quality,
      bodyScale: bodyScale,
      dtSeconds: dt,
      raw: raw,
    );
  }

  double _computeDt(DateTime now) {
    final prev = _lastTimestamp;
    _lastTimestamp = now;
    if (prev == null) return 1 / 15;
    final dt = now.difference(prev).inMicroseconds / 1e6;
    return dt.clamp(1 / 60, 0.5);
  }

  Map<PoseLandmark, PosePoint> _smoothLandmarks(
    Map<PoseLandmark, PosePoint> input,
    double dt,
  ) {
    final out = <PoseLandmark, PosePoint>{};
    for (final entry in input.entries) {
      final filter = _filters.putIfAbsent(entry.key, OneEuroFilter2D.new);
      final p = entry.value;
      final f = filter.filter(p.x, p.y, dt);
      out[entry.key] = PosePoint(x: f.x, y: f.y, visibility: p.visibility);
    }
    return out;
  }

  Map<PoseLandmark, ({double x, double y})> _computeVelocities(
    Map<PoseLandmark, PosePoint> landmarks,
    double dt,
  ) {
    final out = <PoseLandmark, ({double x, double y})>{};
    if (dt <= 0) return out;
    for (final entry in landmarks.entries) {
      final prev = _prevLandmarks[entry.key];
      if (prev != null) {
        out[entry.key] = (
          x: (entry.value.x - prev.x) / dt,
          y: (entry.value.y - prev.y) / dt,
        );
      }
      _prevLandmarks[entry.key] = entry.value;
    }
    return out;
  }

  final Map<PoseLandmark, PosePoint> _prevLandmarks = {};

  double _estimateStability(Map<PoseLandmark, ({double x, double y})> velocities) {
    if (velocities.isEmpty) return _lastStability;
    var jerkSum = 0.0;
    var count = 0;
    for (final entry in velocities.entries) {
      final prev = _prevVelocities[entry.key];
      if (prev != null) {
        final jx = (entry.value.x - prev.x).abs();
        final jy = (entry.value.y - prev.y).abs();
        jerkSum += jx + jy;
        count++;
      }
      _prevVelocities[entry.key] = entry.value;
    }
    if (count == 0) return _lastStability;
    final avgJerk = jerkSum / count;
    return (1 / (1 + avgJerk * 0.02)).clamp(0.0, 1.0);
  }

  final Map<PoseLandmark, ({double x, double y})> _prevVelocities = {};

  PoseQualityScore _scoreQuality(
    Map<PoseLandmark, PosePoint> landmarks,
    Map<PoseLandmark, PosePoint> normalized,
    double stability,
  ) {
    final critical = criticalJoints.toList();
    var visSum = 0.0;
    var visCount = 0;
    var present = 0;
    for (final j in critical) {
      final p = landmarks[j];
      if (p == null) continue;
      present++;
      visSum += p.visibility;
      visCount++;
    }
    final visibility = visCount == 0 ? 0.0 : visSum / visCount;
    final bodyCompleteness = critical.isEmpty ? 0.0 : present / critical.length;
    final occlusion = bodyCompleteness;
    final framing = BodyNormalizer.framingScore(landmarks, critical);
    return PoseQualityScore(
      visibility: visibility,
      framing: framing,
      occlusion: occlusion,
      stability: stability,
      bodyCompleteness: bodyCompleteness,
    );
  }
}
