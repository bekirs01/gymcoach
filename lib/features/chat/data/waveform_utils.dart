import 'dart:math';

abstract final class WaveformUtils {
  static List<double> generateSamples({
    required int barCount,
    required int durationMs,
    String? seed,
  }) {
    final random = Random(_seedValue(seed ?? durationMs.toString()));
    final base = max(12, barCount);
    final samples = <double>[];
    for (var i = 0; i < base; i++) {
      final wave = sin(i / 2.8) * 0.18;
      final jitter = random.nextDouble() * 0.55;
      final value = (0.22 + jitter + wave).clamp(0.12, 1.0);
      samples.add(double.parse(value.toStringAsFixed(3)));
    }
    return samples;
  }

  static int _seedValue(String input) {
    var hash = 0;
    for (var i = 0; i < input.length; i++) {
      hash = 31 * hash + input.codeUnitAt(i);
    }
    return hash.abs();
  }

  static String formatDuration(int durationMs) {
    final totalSeconds = max(0, durationMs ~/ 1000);
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static double bubbleWidthFactor(int durationMs) {
    final seconds = max(1, durationMs ~/ 1000);
    return (0.42 + (seconds / 60) * 0.38).clamp(0.42, 0.72);
  }
}
