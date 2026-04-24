import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/territory_models.dart';
import '../../utils/geo_utils.dart';
import '../../utils/polygon_utils.dart';

/// Örnek veri — Firebase / Supabase ile değiştirilecek.
///
/// Harita merkezi: Kadıköy çevresi (demo).
final LatLng kDefaultTerritoryCenter = LatLng(40.9903, 29.0265);

/// Simülasyon karesi bu noktadan çizilir — yakındaki mock rakip alanının içinde kalır (ele geçirme demosu).
LatLng simulationAnchorInsideRival() =>
    GeoUtils.offsetMeters(kDefaultTerritoryCenter, 95, 42);

Map<String, TerritoryProfile> mockTerritoryUsers() {
  return {
    TerritoryModels.currentUserId: TerritoryProfile(
      id: TerritoryModels.currentUserId,
      displayName: 'Вы',
      avatarLabel: 'S',
      themeColor: const Color(0xFF14B8A6),
      totalCaptures: 2,
    ),
    'u_rival_1': TerritoryModels.colorForUser('u_rival_1', 'Алекс Бег', 'А'),
    'u_rival_2': TerritoryModels.colorForUser('u_rival_2', 'Ринат Ран', 'Р'),
    'u_rival_3': TerritoryModels.colorForUser('u_rival_3', 'Денис Шаг', 'Д'),
    'u_rival_4': TerritoryModels.colorForUser('u_rival_4', 'Елена Сила', 'Е'),
  };
}

/// 5–10 örnek bölge — sahip, isim, tarih mock.
List<TerritoryZone> mockTerritoryZones() {
  final o = kDefaultTerritoryCenter;
  final t = DateTime.now().subtract(const Duration(days: 2));

  TerritoryZone zone(
    String id,
    String name,
      String ownerId,
    List<LatLng> openCorners,
    DateTime claimed,
    int captures,
  ) {
    final closed = [...openCorners, openCorners.first];
    final area = PolygonUtils.polygonAreaSqM(closed);
    return TerritoryZone(
      id: id,
      name: name,
      ownerId: ownerId,
      ring: closed,
      claimedAt: claimed,
      areaSqM: area,
      routeLengthM: GeoUtils.pathLengthMeters(closed),
      captureCount: captures,
      lastCapturerId: captures > 0 ? ownerId : null,
    );
  }

  return [
    zone(
      'z1',
      'Набережная «Мода»',
      'u_rival_1',
      _rectAround(o, eastM: 80, northM: 40, w: 100, h: 70),
      t.subtract(const Duration(hours: 5)),
      1,
    ),
    zone(
      'z2',
      'Спринт Бахарие',
      'u_rival_2',
      _rectAround(GeoUtils.offsetMeters(o, 120, -30), eastM: 0, northM: 0, w: 90, h: 90),
      t.subtract(const Duration(days: 1)),
      0,
    ),
    zone(
      'z3',
      'Парк Йогуртчу',
      TerritoryModels.currentUserId,
      _rectAround(GeoUtils.offsetMeters(o, -140, 50), eastM: 0, northM: 0, w: 75, h: 60),
      t.subtract(const Duration(hours: 20)),
      2,
    ),
    zone(
      'z4',
      'Кольцо Фенербахче',
      'u_rival_3',
      _rectAround(GeoUtils.offsetMeters(o, 40, -120), eastM: 0, northM: 0, w: 110, h: 55),
      t.subtract(const Duration(hours: 48)),
      3,
    ),
    zone(
      'z5',
      'Интервалы Сёгютлючешме',
      'u_rival_4',
      _rectAround(GeoUtils.offsetMeters(o, -60, -90), eastM: 0, northM: 0, w: 65, h: 95),
      t.subtract(const Duration(hours: 12)),
      1,
    ),
    zone(
      'z6',
      'Разминка Джаферага',
      'u_rival_1',
      _rectAround(GeoUtils.offsetMeters(o, 200, 20), eastM: 0, northM: 0, w: 50, h: 50),
      t.subtract(const Duration(hours: 3)),
      0,
    ),
    zone(
      'z7',
      'Набережный круг',
      'u_rival_2',
      _rectAround(GeoUtils.offsetMeters(o, -200, -40), eastM: 0, northM: 0, w: 85, h: 45),
      t.subtract(const Duration(minutes: 90)),
      1,
    ),
  ];
}

/// Dikdörtgen köşeler (CCW) — open ring (ilk nokta sonda tekrarlanmaz).
List<LatLng> _rectAround(
  LatLng base, {
  required double eastM,
  required double northM,
  required double w,
  required double h,
}) {
  final p0 = GeoUtils.offsetMeters(base, eastM, northM);
  final p1 = GeoUtils.offsetMeters(p0, w, 0);
  final p2 = GeoUtils.offsetMeters(p1, 0, h);
  final p3 = GeoUtils.offsetMeters(p2, -w, 0);
  return [p0, p1, p2, p3];
}
