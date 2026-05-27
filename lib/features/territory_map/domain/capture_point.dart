class CapturePoint {
  const CapturePoint({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.timestamp,
    this.speedMps,
    this.headingDegrees,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime timestamp;
  final double? speedMps;
  final double? headingDegrees;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracyMeters,
        'speed': speedMps,
        'heading': headingDegrees,
        'timestamp': timestamp.toUtc().toIso8601String(),
      };
}
