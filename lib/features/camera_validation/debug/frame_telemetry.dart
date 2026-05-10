import '../domain/pose_quality.dart';
import '../engine/adaptive_rep_engine.dart';

class FrameTelemetry {
  FrameTelemetry({this.enabled = false});

  final bool enabled;
  final List<TelemetrySample> _samples = [];

  List<TelemetrySample> get samples => List.unmodifiable(_samples);

  void record({
    required DateTime timestamp,
    required double metric,
    required double velocity,
    required PoseQualityScore quality,
    required RepEnginePhase phase,
    required RepEngineEvent event,
  }) {
    if (!enabled) return;
    _samples.add(TelemetrySample(
      timestamp: timestamp,
      metric: metric,
      velocity: velocity,
      quality: quality.overall,
      phase: phase,
      event: event,
    ));
    if (_samples.length > 5000) {
      _samples.removeRange(0, 1000);
    }
  }

  void clear() => _samples.clear();
}

class TelemetrySample {
  const TelemetrySample({
    required this.timestamp,
    required this.metric,
    required this.velocity,
    required this.quality,
    required this.phase,
    required this.event,
  });

  final DateTime timestamp;
  final double metric;
  final double velocity;
  final double quality;
  final RepEnginePhase phase;
  final RepEngineEvent event;
}
