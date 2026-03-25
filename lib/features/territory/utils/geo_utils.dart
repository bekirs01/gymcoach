import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Basit coğrafi yardımcılar — ileride `turf_dart` veya backend hesaplarına taşınabilir.
class GeoUtils {
  GeoUtils._();

  static const Distance _distance = Distance();

  /// İki nokta arası mesafe (metre).
  static double distanceMeters(LatLng a, LatLng b) => _distance.as(LengthUnit.Meter, a, b);

  /// Rota toplam uzunluğu (ardışık noktalar, son segment dahil değil).
  static double pathLengthMeters(List<LatLng> path) {
    if (path.length < 2) return 0;
    var sum = 0.0;
    for (var i = 0; i < path.length - 1; i++) {
      sum += distanceMeters(path[i], path[i + 1]);
    }
    return sum;
  }

  /// Poligon merkezine yakın mock nokta (simülasyon adımı).
  static LatLng offsetMeters(LatLng origin, double eastM, double northM) {
    const mPerDegLat = 111_320.0;
    final lat = origin.latitude + northM / mPerDegLat;
    final mPerDegLon = mPerDegLat * math.cos(origin.latitude * math.pi / 180.0);
    final lon = origin.longitude + eastM / mPerDegLon;
    return LatLng(lat, lon);
  }
}
