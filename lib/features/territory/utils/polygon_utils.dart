import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Poligon geçerliliği, alan, içerme — modüler; kurallar servis katmanında birleşir.
class PolygonUtils {
  PolygonUtils._();

  /// Referans ilk noktaya uzanan düzlemde shoelace ~m² (küçük alanlar için demo yeterli).
  static double polygonAreaSqM(List<LatLng> ringClosedOrOpen) {
    final verts = _uniqueVertices(ringClosedOrOpen);
    if (verts.length < 3) return 0;

    final ref = verts.first;
    final projected = verts.map((p) => _toLocalMeters(p, ref)).toList();

    var sum = 0.0;
    for (var i = 0; i < projected.length; i++) {
      final j = (i + 1) % projected.length;
      sum += projected[i].dx * projected[j].dy;
      sum -= projected[j].dx * projected[i].dy;
    }
    return sum.abs() / 2.0;
  }

  static _XY _toLocalMeters(LatLng p, LatLng ref) {
    const mPerDegLat = 111_320.0;
    final dx = (p.longitude - ref.longitude) *
        mPerDegLat *
        math.cos(ref.latitude * math.pi / 180.0);
    final dy = (p.latitude - ref.latitude) * mPerDegLat;
    return _XY(dx, dy);
  }

  /// Işık ışını — poligon içi mi (açık/kapalı ring).
  static bool pointInPolygon(LatLng p, List<LatLng> ring) {
    final verts = _uniqueVertices(ring);
    if (verts.length < 3) return false;

    var inside = false;
    for (var i = 0, j = verts.length - 1; i < verts.length; j = i++) {
      final pi = verts[i];
      final pj = verts[j];
      final intersect = ((pi.latitude > p.latitude) != (pj.latitude > p.latitude)) &&
          (p.longitude <
              (pj.longitude - pi.longitude) *
                      (p.latitude - pi.latitude) /
                      (pj.latitude - pi.latitude) +
                  pi.longitude);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  /// B’nin tüm köşeleri A içindeyse “A, B’yi tamamen kaplar”.
  static bool polygonFullyContains(List<LatLng> outerRing, List<LatLng> innerRing) {
    final inner = _uniqueVertices(innerRing);
    for (final p in inner) {
      if (!pointInPolygon(p, outerRing)) return false;
    }
    return inner.isNotEmpty;
  }

  /// Edge case: kendi kendini kesen basit olmayan poligon tespiti (O(n²)).
  static bool isSimplePolygon(List<LatLng> verticesOpen) {
    final n = verticesOpen.length;
    if (n < 3) return false;
    for (var i = 0; i < n; i++) {
      final i2 = (i + 1) % n;
      final a1 = verticesOpen[i];
      final a2 = verticesOpen[i2];
      for (var j = i + 1; j < n; j++) {
        final j2 = (j + 1) % n;
        if (i == j || i == j2 || i2 == j || i2 == j2) continue;
        final b1 = verticesOpen[j];
        final b2 = verticesOpen[j2];
        if (_segmentsIntersect(a1, a2, b1, b2)) return false;
      }
    }
    return true;
  }

  /// Savunmacı alanı içinde örneklenen noktalardan kaçının saldırgan içinde kaldığı (0–1).
  static double overlapRatioOverDefender(
    List<LatLng> attackerRing,
    List<LatLng> defenderRing, {
    int samples = 2000,
  }) {
    final defArea = polygonAreaSqM(defenderRing);
    if (defArea < 1) return 0;

    final verts = _uniqueVertices(defenderRing);
    final minLat = verts.map((e) => e.latitude).reduce(math.min);
    final maxLat = verts.map((e) => e.latitude).reduce(math.max);
    final minLon = verts.map((e) => e.longitude).reduce(math.min);
    final maxLon = verts.map((e) => e.longitude).reduce(math.max);

    var defHits = 0;
    var bothHits = 0;
    final rnd = math.Random(42);
    for (var k = 0; k < samples; k++) {
      final lat = minLat + rnd.nextDouble() * (maxLat - minLat);
      final lon = minLon + rnd.nextDouble() * (maxLon - minLon);
      final p = LatLng(lat, lon);
      if (!pointInPolygon(p, defenderRing)) continue;
      defHits++;
      if (pointInPolygon(p, attackerRing)) bothHits++;
    }
    if (defHits == 0) return 0;
    return (bothHits / defHits).clamp(0.0, 1.0);
  }

  static List<LatLng> _uniqueVertices(List<LatLng> ring) {
    if (ring.length < 2) return ring;
    final first = ring.first;
    final last = ring.last;
    if (first.latitude == last.latitude && first.longitude == last.longitude) {
      return ring.sublist(0, ring.length - 1);
    }
    return ring;
  }

  static bool _segmentsIntersect(LatLng p, LatLng p2, LatLng q, LatLng q2) {
    final o1 = _orientation(p, p2, q);
    final o2 = _orientation(p, p2, q2);
    final o3 = _orientation(q, q2, p);
    final o4 = _orientation(q, q2, p2);

    if (o1 != o2 && o3 != o4) return true;
    return false;
  }

  static int _orientation(LatLng a, LatLng b, LatLng c) {
    final v = (b.longitude - a.longitude) * (c.latitude - b.latitude) -
        (b.latitude - a.latitude) * (c.longitude - b.longitude);
    if (v.abs() < 1e-12) return 0;
    return v > 0 ? 1 : 2;
  }
}

class _XY {
  const _XY(this.dx, this.dy);
  final double dx;
  final double dy;
}
