import 'package:latlong2/latlong.dart';

import '../domain/territory_models.dart';
import 'polygon_utils.dart';

/// Çakışma / ele geçirme kuralları — parametreleştirilebilir (A/B test, backend).
class OverlapRules {
  const OverlapRules({
    this.partialTakeoverOverlapRatio = 0.60,
  });

  /// Savunmacı alanı içinde kalan örneklerin bu oranından fazlası saldırganda ise ele geçirme.
  final double partialTakeoverOverlapRatio;
}

/// Yeni poligon ile mevcut bölgeler için sahiplik güncellemesi (demo mantığı).
class OverlapEngine {
  OverlapEngine({OverlapRules? rules}) : rules = rules ?? const OverlapRules();

  final OverlapRules rules;

  /// Saldırgan [attackerRing], savunmacı [defender] için ele geçirme var mı?
  bool shouldTransferOwnership({
    required List<LatLng> attackerRing,
    required TerritoryZone defender,
  }) {
    final dRing = defender.closedRing;
    if (PolygonUtils.polygonFullyContains(attackerRing, dRing)) {
      return true;
    }
    final ratio =
        PolygonUtils.overlapRatioOverDefender(attackerRing, dRing);
    return ratio >= rules.partialTakeoverOverlapRatio;
  }
}
