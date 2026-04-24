import 'package:latlong2/latlong.dart';

import 'geo_utils.dart';
import 'polygon_utils.dart';

/// Rota kapanış kuralları — backend’de aynı parametreler API ile hizalanabilir.
class RouteCaptureRules {
  const RouteCaptureRules({
    this.closeToleranceM = 18,
    this.minPathLengthM = 120,
    this.minAreaSqM = 800,
    this.minRoutePoints = 5,
  });

  /// Başlangıç noktasına “yeterince yakın” eşik (metre).
  final double closeToleranceM;

  /// Minimum yürüyüş mesafesi (son kapanış segmenti hariç toplam polyline).
  final double minPathLengthM;

  /// Çok küçük alanları reddet (m²).
  final double minAreaSqM;

  /// En az GPS / simülasyon örneği sayısı.
  final int minRoutePoints;
}

class RouteCaptureOutcome {
  const RouteCaptureOutcome.success({
    required this.verticesOpen,
    required this.closedRing,
    required this.areaSqM,
    required this.pathLengthM,
  }) : isSuccess = true, message = null;

  const RouteCaptureOutcome.failure(this.message)
      : isSuccess = false,
        verticesOpen = const [],
        closedRing = const [],
        areaSqM = 0,
        pathLengthM = 0;

  final bool isSuccess;
  final String? message;
  final List<LatLng> verticesOpen;
  final List<LatLng> closedRing;
  final double areaSqM;
  final double pathLengthM;
}

/// Başlangıca dönüş + geçerli poligon üretimi.
class RouteCaptureLogic {
  RouteCaptureLogic({RouteCaptureRules? rules})
      : rules = rules ?? const RouteCaptureRules();

  final RouteCaptureRules rules;

  /// [route] sıralı noktalar; son nokta başlangıca yakın olmalı.
  RouteCaptureOutcome evaluate(List<LatLng> route) {
    if (route.length < rules.minRoutePoints) {
      return RouteCaptureOutcome.failure(
        'Нужно больше точек маршрута (мин. ${rules.minRoutePoints}).',
      );
    }

    final first = route.first;
    final last = route.last;
    final gap = GeoUtils.distanceMeters(first, last);
    if (gap > rules.closeToleranceM) {
      return RouteCaptureOutcome.failure(
        'Вернитесь ближе к старту (сейчас ${gap.toStringAsFixed(0)} м, нужно ≤ ${rules.closeToleranceM.toStringAsFixed(0)} м).',
      );
    }

    final pathLen = GeoUtils.pathLengthMeters(route);
    if (pathLen < rules.minPathLengthM) {
      return RouteCaptureOutcome.failure(
        'Маршрут короткий (нужно ≥ ${rules.minPathLengthM.toStringAsFixed(0)} м).',
      );
    }

    // Son nokta başa yakınsa kapalı şekil köşeleri = son hariç (veya tümü unique)
    List<LatLng> vertices = route.sublist(0, route.length - 1).toList();
    if (vertices.length < 3) {
      return RouteCaptureOutcome.failure('Недостаточно углов полигона.');
    }

    if (!PolygonUtils.isSimplePolygon(vertices)) {
      return RouteCaptureOutcome.failure(
        'Маршрут пересекается. Нарисуйте более простой контур.',
      );
    }

    final area = PolygonUtils.polygonAreaSqM(vertices);
    if (area < rules.minAreaSqM) {
      return RouteCaptureOutcome.failure(
        'Площадь мала (нужно ≥ ${rules.minAreaSqM.toStringAsFixed(0)} м²).',
      );
    }

    final closed = [...vertices, vertices.first];
    return RouteCaptureOutcome.success(
      verticesOpen: vertices,
      closedRing: closed,
      areaSqM: area,
      pathLengthM: pathLen + gap,
    );
  }
}
