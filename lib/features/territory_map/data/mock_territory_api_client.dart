import 'package:uuid/uuid.dart';

import '../domain/capture_point.dart';
import '../domain/capture_session.dart';
import '../domain/leaderboard_entry.dart';
import '../domain/map_bounds.dart';
import '../domain/territory.dart';
import '../services/polygon_utils.dart';
import 'territory_api_client.dart';

class MockTerritoryApiClient implements TerritoryApiClient {
  MockTerritoryApiClient({
    required this.currentUserId,
    required this.currentUserDisplayName,
  });

  final String currentUserId;
  final String currentUserDisplayName;

  final _sessions = <String, _MockSession>{};
  final _territories = <Territory>[];

  @override
  Future<CaptureSession> createCaptureSession() async {
    final id = const Uuid().v4();
    final session = CaptureSession(id: id, startedAt: DateTime.now());
    _sessions[id] = _MockSession(session: session);
    return session;
  }

  @override
  Future<void> saveCapturePoint(String sessionId, CapturePoint point) async {
    final session = _sessions[sessionId];
    if (session == null) {
      throw StateError('Capture session not found: $sessionId');
    }
    session.points.add(point);
  }

  @override
  Future<Territory> finishCaptureSession(
    String sessionId,
    String territoryName,
    Map<String, dynamic> polygonGeojson,
  ) async {
    final session = _sessions.remove(sessionId);
    if (session == null) {
      throw StateError('Capture session not found: $sessionId');
    }
    final area = PolygonUtils.polygonAreaSquareMeters(session.points);
    final territory = Territory(
      id: const Uuid().v4(),
      name: territoryName,
      ownerId: currentUserId,
      ownerDisplayName: currentUserDisplayName,
      areaSquareMeters: area,
      capturedAt: DateTime.now(),
      polygonGeoJson: polygonGeojson,
      isOwnedByCurrentUser: true,
    );
    _territories.add(territory);
    _seedDemoTerritoriesIfEmpty();
    return territory;
  }

  @override
  Future<void> cancelCaptureSession(String sessionId) async {
    _sessions.remove(sessionId);
  }

  @override
  Future<List<Territory>> getTerritories({MapBounds? bounds}) async {
    _seedDemoTerritoriesIfEmpty();
    if (bounds == null) return List.unmodifiable(_territories);
    return _territories.where((t) => _intersectsBounds(t, bounds)).toList(growable: false);
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    await getTerritories();
    final totals = <String, ({String name, double area, int count})>{};
    for (final territory in _territories) {
      final existing = totals[territory.ownerId];
      totals[territory.ownerId] = (
        name: territory.ownerDisplayName,
        area: (existing?.area ?? 0) + territory.areaSquareMeters,
        count: (existing?.count ?? 0) + 1,
      );
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.area.compareTo(a.value.area));
    return List.generate(sorted.length, (index) {
      final entry = sorted[index];
      return LeaderboardEntry(
        rank: index + 1,
        displayName: entry.value.name,
        totalAreaSquareMeters: entry.value.area,
        territoryCount: entry.value.count,
        userId: entry.key,
      );
    });
  }

  @override
  Future<List<Territory>> getMyTerritories() async {
    await getTerritories();
    return _territories.where((t) => t.ownerId == currentUserId).toList(growable: false);
  }

  void _seedDemoTerritoriesIfEmpty() {
    if (_territories.isNotEmpty) return;
    _territories.addAll([
      _demoTerritory(
        id: 'demo-1',
        name: 'Riverside Loop',
        ownerId: 'demo-user-1',
        ownerDisplayName: 'Jordan Lee',
        centerLat: 41.015,
        centerLng: 28.979,
        radiusMeters: 90,
      ),
      _demoTerritory(
        id: 'demo-2',
        name: 'Park Circuit',
        ownerId: 'demo-user-2',
        ownerDisplayName: 'Maya Chen',
        centerLat: 41.018,
        centerLng: 28.985,
        radiusMeters: 70,
      ),
    ]);
  }

  Territory _demoTerritory({
    required String id,
    required String name,
    required String ownerId,
    required String ownerDisplayName,
    required double centerLat,
    required double centerLng,
    required double radiusMeters,
  }) {
    final points = _squarePoints(centerLat, centerLng, radiusMeters);
    return Territory(
      id: id,
      name: name,
      ownerId: ownerId,
      ownerDisplayName: ownerDisplayName,
      areaSquareMeters: PolygonUtils.polygonAreaSquareMeters(points),
      capturedAt: DateTime.now().subtract(const Duration(days: 2)),
      polygonGeoJson: PolygonUtils.buildPolygonGeoJson(points),
      isOwnedByCurrentUser: ownerId == currentUserId,
    );
  }

  List<CapturePoint> _squarePoints(double centerLat, double centerLng, double radiusMeters) {
    const earthRadius = 6371000.0;
    final latDelta = (radiusMeters / earthRadius) * (180 / 3.141592653589793);
    final lngDelta = latDelta / 0.75;
    final now = DateTime.now();
    CapturePoint p(double lat, double lng) => CapturePoint(
          latitude: lat,
          longitude: lng,
          accuracyMeters: 8,
          timestamp: now,
        );
    return [
      p(centerLat + latDelta, centerLng - lngDelta),
      p(centerLat + latDelta, centerLng + lngDelta),
      p(centerLat - latDelta, centerLng + lngDelta),
      p(centerLat - latDelta, centerLng - lngDelta),
    ];
  }

  bool _intersectsBounds(Territory territory, MapBounds bounds) {
    final coords = territory.polygonGeoJson['coordinates'];
    if (coords is! List || coords.isEmpty) return true;
    final ring = coords.first;
    if (ring is! List) return true;
    for (final vertex in ring) {
      if (vertex is! List || vertex.length < 2) continue;
      final lng = (vertex[0] as num).toDouble();
      final lat = (vertex[1] as num).toDouble();
      if (lat >= bounds.southWestLat &&
          lat <= bounds.northEastLat &&
          lng >= bounds.southWestLng &&
          lng <= bounds.northEastLng) {
        return true;
      }
    }
    return false;
  }
}

class _MockSession {
  _MockSession({required this.session});

  final CaptureSession session;
  final points = <CapturePoint>[];
}
