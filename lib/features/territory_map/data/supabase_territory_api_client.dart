import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/capture_point.dart';
import '../domain/capture_session.dart';
import '../domain/leaderboard_entry.dart';
import '../domain/map_bounds.dart';
import '../domain/territory.dart';
import 'territory_api_client.dart';
import 'territory_map_row_mapper.dart';

class SupabaseTerritoryApiClient implements TerritoryApiClient {
  SupabaseTerritoryApiClient({
    SupabaseClient? client,
    required this.currentUserId,
    required this.currentUserDisplayName,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final String currentUserId;
  final String currentUserDisplayName;

  @override
  Future<CaptureSession> createCaptureSession() async {
    final sessionId = await _client.rpc<dynamic>(
      'start_territory_capture_session',
      params: {'p_user_id': currentUserId},
    );
    if (sessionId == null) {
      throw StateError('start_territory_capture_session returned empty session id.');
    }
    return CaptureSession(
      id: sessionId.toString(),
      startedAt: DateTime.now(),
    );
  }

  @override
  Future<void> saveCapturePoint(String sessionId, CapturePoint point) async {
    await _client.rpc<dynamic>(
      'save_territory_capture_point',
      params: {
        'p_user_id': currentUserId,
        'p_session_id': sessionId,
        'p_latitude': point.latitude,
        'p_longitude': point.longitude,
        'p_accuracy_m': point.accuracyMeters,
        'p_speed_mps': point.speedMps,
        'p_heading': point.headingDegrees,
      },
    );
  }

  @override
  Future<Territory> finishCaptureSession(
    String sessionId,
    String territoryName,
    Map<String, dynamic> polygonGeojson,
  ) async {
    final rows = await _client.rpc<List<dynamic>>(
      'finish_territory_capture_session',
      params: {
        'p_user_id': currentUserId,
        'p_session_id': sessionId,
        'p_name': territoryName.trim(),
        'p_polygon_geojson': polygonGeojson,
      },
    );
    if (rows.isEmpty) {
      throw StateError('finish_territory_capture_session returned no rows.');
    }
    final row = Map<String, dynamic>.from(rows.first as Map);
    return Territory(
      id: row['territory_id'] as String,
      name: territoryName.trim(),
      ownerId: row['owner_user_id'] as String? ?? currentUserId,
      ownerDisplayName: currentUserDisplayName,
      areaSquareMeters: (row['area_m2'] as num).toDouble(),
      capturedAt: DateTime.now(),
      polygonGeoJson: polygonGeojson,
      isOwnedByCurrentUser: true,
    );
  }

  @override
  Future<void> cancelCaptureSession(String sessionId) async {
    await _client.rpc<dynamic>(
      'cancel_territory_capture_session',
      params: {
        'p_user_id': currentUserId,
        'p_session_id': sessionId,
      },
    );
  }

  @override
  Future<List<Territory>> getTerritories({MapBounds? bounds}) async {
    final params = <String, dynamic>{'p_user_id': currentUserId};
    if (bounds != null) {
      params.addAll(bounds.toRpcParams());
    }
    final rows = await _client.rpc<List<dynamic>>(
      'get_territories',
      params: params,
    );
    return _mapTerritoryRows(rows);
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    final rows = await _client.rpc<List<dynamic>>(
      'get_territory_leaderboard',
      params: {'p_limit': 50},
    );
    if (rows.isEmpty) return const [];
    return rows
        .map((row) => TerritoryMapRowMapper.leaderboardFromRow(Map<String, dynamic>.from(row as Map)))
        .toList(growable: false);
  }

  @override
  Future<List<Territory>> getMyTerritories() async {
    final rows = await _client.rpc<List<dynamic>>(
      'get_my_territories',
      params: {'p_user_id': currentUserId},
    );
    return _mapTerritoryRows(rows, forceOwned: true);
  }

  Future<Territory?> getTerritoryDetail(String territoryId) async {
    final rows = await _client.rpc<List<dynamic>>(
      'get_territory_detail',
      params: {
        'p_user_id': currentUserId,
        'p_territory_id': territoryId,
      },
    );
    if (rows.isEmpty) return null;
    final territory = TerritoryMapRowMapper.territoryFromRow(
      Map<String, dynamic>.from(rows.first as Map),
      currentUserId: currentUserId,
    );
    final profiles = await _loadOwnerProfiles({territory.ownerId});
    return territory.copyWith(
      ownerDisplayName: profiles.names[territory.ownerId] ?? territory.ownerDisplayName,
      ownerAvatarUrl: profiles.avatars[territory.ownerId] ?? territory.ownerAvatarUrl,
    );
  }

  Future<List<Territory>> _mapTerritoryRows(
    List<dynamic>? rows, {
    bool forceOwned = false,
  }) async {
    if (rows == null || rows.isEmpty) return const [];
    final parsed = rows
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
    final ownerIds = parsed
        .map((row) => row['owner_user_id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    final displayNames = await _loadOwnerProfiles(ownerIds);
    return parsed
        .map((row) {
          final territory = TerritoryMapRowMapper.territoryFromRow(
            row,
            currentUserId: currentUserId,
            displayNames: displayNames.names,
            avatarUrls: displayNames.avatars,
          );
          return forceOwned ? territory.copyWith(isOwnedByCurrentUser: true) : territory;
        })
        .toList(growable: false);
  }

  Future<({Map<String, String> names, Map<String, String> avatars})> _loadOwnerProfiles(
    Set<String> ownerIds,
  ) async {
    if (ownerIds.isEmpty) {
      return (names: <String, String>{}, avatars: <String, String>{});
    }
    try {
      final rows = await _client
          .from('profiles')
          .select('id, display_name, avatar_url')
          .inFilter('id', ownerIds.toList(growable: false));
      final names = <String, String>{};
      final avatars = <String, String>{};
      for (final row in rows) {
        final map = Map<String, dynamic>.from(row);
        final id = map['id'] as String?;
        final name = map['display_name'] as String?;
        final avatar = map['avatar_url'] as String?;
        if (id == null) continue;
        if (name != null && name.isNotEmpty) names[id] = name;
        if (avatar != null && avatar.isNotEmpty) avatars[id] = avatar;
      }
      return (names: names, avatars: avatars);
    } catch (_) {
      return (names: <String, String>{}, avatars: <String, String>{});
    }
  }
}
