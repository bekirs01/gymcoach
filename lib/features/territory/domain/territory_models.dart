class TerritoryCaptureSession {
  const TerritoryCaptureSession({
    required this.id,
    required this.userId,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.polygonGeoJson,
    this.pathGeoJson,
    this.distanceM = 0,
    this.areaM2 = 0,
  });

  final String id;
  final String userId;
  final String status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final Map<String, dynamic>? polygonGeoJson;
  final Map<String, dynamic>? pathGeoJson;
  final double distanceM;
  final double areaM2;
}

class TerritoryCapturePointInput {
  const TerritoryCapturePointInput({
    required this.latitude,
    required this.longitude,
    this.accuracyM,
    this.speedMps,
    this.heading,
  });

  final double latitude;
  final double longitude;
  final double? accuracyM;
  final double? speedMps;
  final double? heading;
}

class CapturedTerritory {
  const CapturedTerritory({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.areaM2,
    required this.geometry,
    required this.capturedAt,
    required this.updatedAt,
    this.sourceSessionId,
    this.ownerDisplayName,
  });

  final String id;
  final String ownerUserId;
  final String name;
  final double areaM2;
  final Map<String, dynamic> geometry;
  final DateTime capturedAt;
  final DateTime updatedAt;
  final String? sourceSessionId;
  final String? ownerDisplayName;
}

class TerritoryCaptureResult {
  const TerritoryCaptureResult({
    required this.territoryId,
    required this.ownerUserId,
    required this.areaM2,
  });

  final String territoryId;
  final String ownerUserId;
  final double areaM2;
}

class TerritoryLeaderboardEntry {
  const TerritoryLeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.totalAreaM2,
    required this.territoryCount,
    required this.rank,
    this.lastCaptureAt,
  });

  final String userId;
  final String displayName;
  final double totalAreaM2;
  final int territoryCount;
  final int rank;
  final DateTime? lastCaptureAt;
}

class TerritoryMapBounds {
  const TerritoryMapBounds({
    required this.minLng,
    required this.minLat,
    required this.maxLng,
    required this.maxLat,
  });

  final double minLng;
  final double minLat;
  final double maxLng;
  final double maxLat;
}
