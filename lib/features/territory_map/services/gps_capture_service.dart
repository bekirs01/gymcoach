import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../config/territory_config.dart';
import '../domain/capture_point.dart';
import '../services/polygon_utils.dart';

class GpsCaptureService {
  StreamSubscription<Position>? _subscription;
  final _points = <CapturePoint>[];

  List<CapturePoint> get points => List.unmodifiable(_points);

  Stream<CapturePoint> start() {
    _points.clear();
    final controller = StreamController<CapturePoint>();
    final settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: TerritoryConfig.minPointDistanceMeters.round(),
    );
    _subscription = Geolocator.getPositionStream(locationSettings: settings).listen(
      (position) {
        final point = CapturePoint(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracyMeters: position.accuracy,
          timestamp: position.timestamp,
          speedMps: position.speed >= 0 ? position.speed : null,
          headingDegrees: position.heading >= 0 ? position.heading : null,
        );
        if (!_shouldAcceptPoint(point)) return;
        _points.add(point);
        controller.add(point);
      },
      onError: controller.addError,
    );
    return controller.stream;
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  bool _shouldAcceptPoint(CapturePoint point) {
    if (point.accuracyMeters > TerritoryConfig.maxAccuracyMeters) return false;
    if (_points.isEmpty) return true;

    final previous = _points.last;
    final distance = PolygonUtils.haversineMeters(
      previous.latitude,
      previous.longitude,
      point.latitude,
      point.longitude,
    );
    if (distance < TerritoryConfig.minPointDistanceMeters) return false;

    final elapsedSeconds = point.timestamp.difference(previous.timestamp).inMilliseconds / 1000;
    if (elapsedSeconds > 0) {
      final speed = distance / elapsedSeconds;
      if (speed > TerritoryConfig.maxSpeedMps) return false;
    }
    return true;
  }
}
