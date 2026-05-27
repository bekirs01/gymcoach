import '../domain/leaderboard_entry.dart';
import '../domain/territory.dart';

abstract final class TerritoryMapRowMapper {
  static Territory territoryFromRow(
    Map<String, dynamic> row, {
    required String currentUserId,
    Map<String, String> displayNames = const {},
  }) {
    final ownerId = row['owner_user_id'] as String? ?? row['owner_id'] as String? ?? '';
    final geometry = row['geometry'] as Map?;
    final polygon = row['polygon_geojson'] as Map? ?? row['polygonGeoJson'] as Map?;
    return Territory(
      id: row['id'] as String,
      name: row['name'] as String? ?? 'Territory',
      ownerId: ownerId,
      ownerDisplayName: row['owner_display_name'] as String? ??
          displayNames[ownerId] ??
          _fallbackName(ownerId),
      areaSquareMeters:
          (row['area_m2'] as num? ?? row['area_square_meters'] as num? ?? row['areaSquareMeters'] as num? ?? 0)
              .toDouble(),
      capturedAt: DateTime.parse(
        row['captured_at'] as String? ?? row['capturedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      polygonGeoJson: Map<String, dynamic>.from(geometry ?? polygon ?? const {}),
      isOwnedByCurrentUser: ownerId == currentUserId,
    );
  }

  static LeaderboardEntry leaderboardFromRow(Map<String, dynamic> row) {
    return LeaderboardEntry(
      rank: (row['rank'] as num?)?.toInt() ?? 0,
      displayName: row['display_name'] as String? ?? row['displayName'] as String? ?? 'Unknown',
      totalAreaSquareMeters: (row['total_area_m2'] as num? ??
              row['total_area_square_meters'] as num? ??
              row['totalAreaSquareMeters'] as num? ??
              0)
          .toDouble(),
      territoryCount: (row['territory_count'] as num? ?? row['territoryCount'] as num? ?? 0).toInt(),
      userId: row['user_id'] as String? ?? row['userId'] as String? ?? '',
    );
  }

  static String _fallbackName(String ownerId) {
    if (ownerId.length <= 8) return ownerId;
    return '${ownerId.substring(0, 8)}…';
  }
}
