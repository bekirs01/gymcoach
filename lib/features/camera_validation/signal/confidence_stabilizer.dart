import '../domain/pose_frame.dart';

/// Temporal voting + grace for missing joints.
class ConfidenceStabilizer {
  ConfidenceStabilizer({
    this.windowSize = 5,
    this.graceFrames = 8,
    this.reliableThreshold = 0.5,
  });

  final int windowSize;
  final int graceFrames;
  final double reliableThreshold;

  final Map<PoseLandmark, List<double>> _history = {};
  final Map<PoseLandmark, int> _missingStreak = {};

  void reset() {
    _history.clear();
    _missingStreak.clear();
  }

  Map<PoseLandmark, PosePoint> stabilize(PoseFrame frame) {
    final out = <PoseLandmark, PosePoint>{};

    for (final landmark in PoseLandmark.values) {
      final raw = frame[landmark];
      if (raw == null) {
        final streak = (_missingStreak[landmark] ?? 0) + 1;
        _missingStreak[landmark] = streak;
        final last = _lastStable[landmark];
        if (last != null && streak <= graceFrames) {
          out[landmark] = last.copyWith(visibility: last.visibility * 0.85);
        }
        continue;
      }

      _missingStreak[landmark] = 0;
      final hist = _history.putIfAbsent(landmark, () => []);
      hist.add(raw.visibility);
      while (hist.length > windowSize) {
        hist.removeAt(0);
      }
      final voted = hist.reduce((a, b) => a + b) / hist.length;
      final point = PosePoint(
        x: raw.x,
        y: raw.y,
        visibility: voted.clamp(0.0, 1.0),
      );
      out[landmark] = point;
      if (point.visibility >= reliableThreshold) {
        _lastStable[landmark] = point;
      }
    }

    return out;
  }

  final Map<PoseLandmark, PosePoint> _lastStable = {};
}

extension on PosePoint {
  PosePoint copyWith({double? visibility}) {
    return PosePoint(x: x, y: y, visibility: visibility ?? this.visibility);
  }
}
