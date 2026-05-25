import '../domain/capture_point.dart';
import '../domain/capture_session.dart';
import '../domain/leaderboard_entry.dart';
import '../domain/map_bounds.dart';
import '../domain/territory.dart';

abstract class TerritoryApiClient {
  Future<CaptureSession> createCaptureSession();

  Future<void> saveCapturePoint(String sessionId, CapturePoint point);

  Future<Territory> finishCaptureSession(
    String sessionId,
    String territoryName,
    Map<String, dynamic> polygonGeojson,
  );

  Future<void> cancelCaptureSession(String sessionId);

  Future<List<Territory>> getTerritories({MapBounds? bounds});

  Future<List<LeaderboardEntry>> getLeaderboard();

  Future<List<Territory>> getMyTerritories();
}
