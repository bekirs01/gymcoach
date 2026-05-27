import '../../features/territory/domain/territory_models.dart';

abstract class TerritoryRepository {
  Future<String> createCaptureSession();

  Future<String> saveCapturePoint({
    required String sessionId,
    required TerritoryCapturePointInput point,
  });

  Future<TerritoryCaptureResult> finishCaptureSession({
    required String sessionId,
    required String territoryName,
    required Map<String, dynamic> polygonGeoJson,
  });

  Future<void> cancelCaptureSession(String sessionId);

  Future<List<CapturedTerritory>> getTerritories({TerritoryMapBounds? bounds});

  Future<List<CapturedTerritory>> getMyTerritories();

  Future<CapturedTerritory?> getTerritoryDetail(String territoryId);

  Future<List<TerritoryLeaderboardEntry>> getLeaderboard({int limit = 50});
}
