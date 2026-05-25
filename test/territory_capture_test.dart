import 'package:flutter_test/flutter_test.dart';
import 'package:gym/features/territory/data/territory_row_mapper.dart';
import 'package:gym/features/territory/services/territory_polygon_validator.dart';

void main() {
  final validPolygon = {
    'type': 'Polygon',
    'coordinates': [
      [
        [28.97840, 41.00820],
        [28.97940, 41.00820],
        [28.97940, 41.00920],
        [28.97840, 41.00920],
        [28.97840, 41.00820],
      ],
    ],
  };

  final tinyPolygon = {
    'type': 'Polygon',
    'coordinates': [
      [
        [28.97840, 41.00820],
        [28.9784001, 41.00820],
        [28.9784001, 41.0082001],
        [28.97840, 41.0082001],
        [28.97840, 41.00820],
      ],
    ],
  };

  test('accepts valid closed polygon geojson', () {
    expect(TerritoryPolygonValidator.isValidGeoJsonPolygon(validPolygon), isTrue);
  });

  test('rejects open polygon ring', () {
    final openPolygon = {
      'type': 'Polygon',
      'coordinates': [
        [
          [28.97840, 41.00820],
          [28.97940, 41.00820],
          [28.97940, 41.00920],
          [28.97840, 41.00920],
        ],
      ],
    };

    expect(TerritoryPolygonValidator.isValidGeoJsonPolygon(openPolygon), isFalse);
  });

  test('rejects too small polygon area estimate', () {
    expect(TerritoryPolygonValidator.isAreaWithinLimits(tinyPolygon), isFalse);
  });

  test('accepts realistic polygon area estimate', () {
    expect(TerritoryPolygonValidator.isAreaWithinLimits(validPolygon), isTrue);
  });

  test('maps capture result row', () {
    final result = TerritoryRowMapper.captureResultFromRow({
      'territory_id': '11111111-1111-1111-1111-111111111111',
      'owner_user_id': 'device-user-1',
      'area_m2': 1250.5,
    });

    expect(result.territoryId, '11111111-1111-1111-1111-111111111111');
    expect(result.ownerUserId, 'device-user-1');
    expect(result.areaM2, 1250.5);
  });

  test('maps leaderboard row with rank', () {
    final entry = TerritoryRowMapper.leaderboardEntryFromRow({
      'user_id': 'device-user-1',
      'display_name': 'Alex Morgan',
      'total_area_m2': 2500,
      'territory_count': 2,
      'last_capture_at': '2026-05-27T12:00:00Z',
      'rank': 1,
    });

    expect(entry.displayName, 'Alex Morgan');
    expect(entry.totalAreaM2, 2500);
    expect(entry.territoryCount, 2);
    expect(entry.rank, 1);
  });
}
