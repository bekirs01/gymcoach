import '../domain/territory_models.dart';

abstract final class TerritoryRowMapper {
  static TerritoryCaptureResult captureResultFromRow(Map<String, dynamic> row) {
    return TerritoryCaptureResult(
      territoryId: row['territory_id'] as String,
      ownerUserId: row['owner_user_id'] as String,
      areaM2: (row['area_m2'] as num).toDouble(),
    );
  }

  static CapturedTerritory territoryFromRow(Map<String, dynamic> row) {
    return CapturedTerritory(
      id: row['id'] as String,
      ownerUserId: row['owner_user_id'] as String,
      name: row['name'] as String,
      areaM2: (row['area_m2'] as num).toDouble(),
      geometry: Map<String, dynamic>.from(row['geometry'] as Map),
      capturedAt: DateTime.parse(row['captured_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      sourceSessionId: row['source_session_id'] as String?,
      ownerDisplayName: row['owner_display_name'] as String?,
    );
  }

  static TerritoryLeaderboardEntry leaderboardEntryFromRow(Map<String, dynamic> row) {
    return TerritoryLeaderboardEntry(
      userId: row['user_id'] as String,
      displayName: row['display_name'] as String? ?? '',
      totalAreaM2: (row['total_area_m2'] as num).toDouble(),
      territoryCount: (row['territory_count'] as num).toInt(),
      rank: (row['rank'] as num).toInt(),
      lastCaptureAt: row['last_capture_at'] == null
          ? null
          : DateTime.parse(row['last_capture_at'] as String),
    );
  }
}
