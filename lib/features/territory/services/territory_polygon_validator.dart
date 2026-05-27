import 'dart:math' as math;

abstract final class TerritoryPolygonValidator {
  static const minAreaM2 = 25.0;
  static const maxAreaM2 = 5000000.0;

  static bool isValidGeoJsonPolygon(Map<String, dynamic> polygonGeoJson) {
    if (polygonGeoJson['type'] != 'Polygon') return false;

    final coordinates = polygonGeoJson['coordinates'];
    if (coordinates is! List || coordinates.isEmpty) return false;

    final ring = coordinates.first;
    if (ring is! List || ring.length < 4) return false;

    for (final point in ring) {
      if (point is! List || point.length < 2) return false;
      final lng = point[0];
      final lat = point[1];
      if (lng is! num || lat is! num) return false;
      if (lng < -180 || lng > 180 || lat < -90 || lat > 90) return false;
    }

    final first = ring.first as List;
    final last = ring.last as List;
    if (first[0] != last[0] || first[1] != last[1]) return false;

    return true;
  }

  static double estimateAreaM2(Map<String, dynamic> polygonGeoJson) {
    if (!isValidGeoJsonPolygon(polygonGeoJson)) return 0;

    final ring = (polygonGeoJson['coordinates'] as List).first as List;
    final originLat = (ring.first as List)[1] as num;
    final metersPerDegLat = 111320.0;
    final metersPerDegLng = 111320.0 * math.cos(originLat * math.pi / 180.0);

    var area = 0.0;
    for (var i = 0; i < ring.length - 1; i++) {
      final p1 = ring[i] as List;
      final p2 = ring[i + 1] as List;
      final x1 = (p1[0] as num).toDouble() * metersPerDegLng;
      final y1 = (p1[1] as num).toDouble() * metersPerDegLat;
      final x2 = (p2[0] as num).toDouble() * metersPerDegLng;
      final y2 = (p2[1] as num).toDouble() * metersPerDegLat;
      area += x1 * y2 - x2 * y1;
    }

    return area.abs() / 2.0;
  }

  static bool isAreaWithinLimits(Map<String, dynamic> polygonGeoJson) {
    final area = estimateAreaM2(polygonGeoJson);
    return area >= minAreaM2 && area <= maxAreaM2;
  }
}
