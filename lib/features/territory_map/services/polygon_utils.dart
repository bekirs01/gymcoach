import 'dart:math' as math;

import '../config/territory_config.dart';
import '../domain/capture_point.dart';

abstract final class PolygonUtils {
  static double haversineMeters(double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double routeDistanceMeters(List<CapturePoint> points) {
    if (points.length < 2) return 0;
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += haversineMeters(
        points[i - 1].latitude,
        points[i - 1].longitude,
        points[i].latitude,
        points[i].longitude,
      );
    }
    return total;
  }

  static double polygonAreaSquareMeters(List<CapturePoint> points) {
    if (points.length < 3) return 0;
    final ring = _closedRing(points);
    final originLat = ring.first.latitude;
    final originLng = ring.first.longitude;
    final projected = ring
        .map((p) => _projectToMeters(p.latitude, p.longitude, originLat, originLng))
        .toList(growable: false);
    var area = 0.0;
    for (var i = 0; i < projected.length - 1; i++) {
      area += projected[i].dx * projected[i + 1].dy - projected[i + 1].dx * projected[i].dy;
    }
    return area.abs() / 2;
  }

  static bool isClosureWithinTolerance(List<CapturePoint> points, {double maxMeters = TerritoryConfig.maxClosureDistanceMeters}) {
    if (points.length < 2) return false;
    final first = points.first;
    final last = points.last;
    return haversineMeters(first.latitude, first.longitude, last.latitude, last.longitude) <= maxMeters;
  }

  static Map<String, dynamic> buildPolygonGeoJson(List<CapturePoint> points) {
    final ring = _closedRing(points);
    return {
      'type': 'Polygon',
      'coordinates': [
        ring.map((p) => [p.longitude, p.latitude]).toList(growable: false),
      ],
    };
  }

  static List<CapturePoint> _closedRing(List<CapturePoint> points) {
    if (points.isEmpty) return const [];
    final ring = List<CapturePoint>.from(points);
    final first = ring.first;
    final last = ring.last;
    if (first.latitude != last.latitude || first.longitude != last.longitude) {
      ring.add(first);
    }
    return ring;
  }

  static _Point2 _projectToMeters(double lat, double lng, double originLat, double originLng) {
    const metersPerDegreeLat = 111320.0;
    final metersPerDegreeLng = metersPerDegreeLat * math.cos(_toRadians(originLat));
    final x = (lng - originLng) * metersPerDegreeLng;
    final y = (lat - originLat) * metersPerDegreeLat;
    return _Point2(x, y);
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}

final class _Point2 {
  const _Point2(this.dx, this.dy);
  final double dx;
  final double dy;
}
