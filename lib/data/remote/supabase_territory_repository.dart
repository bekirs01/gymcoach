import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/device_user_id.dart';
import '../../features/territory/data/territory_row_mapper.dart';
import '../../features/territory/domain/territory_models.dart';
import '../../features/territory/services/territory_polygon_validator.dart';
import '../../shared/repositories/territory_repository.dart';

final class SupabaseTerritoryRepository implements TerritoryRepository {
  SupabaseTerritoryRepository({
    required SharedPreferences prefs,
    SupabaseClient? client,
  })  : _prefs = prefs,
        _client = client ?? Supabase.instance.client;

  final SharedPreferences _prefs;
  final SupabaseClient _client;
  String? _userId;

  Future<String> _deviceId() async {
    _userId ??= await DeviceUserId.resolve(_prefs);
    return _userId!;
  }

  @override
  Future<String> createCaptureSession() async {
    final uid = await _deviceId();
    final sessionId = await _client.rpc(
      'start_territory_capture_session',
      params: {'p_user_id': uid},
    );
    return sessionId as String;
  }

  @override
  Future<String> saveCapturePoint({
    required String sessionId,
    required TerritoryCapturePointInput point,
  }) async {
    final uid = await _deviceId();
    final pointId = await _client.rpc(
      'save_territory_capture_point',
      params: {
        'p_user_id': uid,
        'p_session_id': sessionId,
        'p_latitude': point.latitude,
        'p_longitude': point.longitude,
        'p_accuracy_m': point.accuracyM,
        'p_speed_mps': point.speedMps,
        'p_heading': point.heading,
      },
    );
    return pointId as String;
  }

  @override
  Future<TerritoryCaptureResult> finishCaptureSession({
    required String sessionId,
    required String territoryName,
    required Map<String, dynamic> polygonGeoJson,
  }) async {
    if (!TerritoryPolygonValidator.isValidGeoJsonPolygon(polygonGeoJson)) {
      throw ArgumentError('Invalid polygon GeoJSON');
    }

    final uid = await _deviceId();
    final rows = await _client.rpc(
      'finish_territory_capture_session',
      params: {
        'p_user_id': uid,
        'p_session_id': sessionId,
        'p_name': territoryName.trim(),
        'p_polygon_geojson': polygonGeoJson,
      },
    );

    final list = rows as List<dynamic>;
    if (list.isEmpty) {
      throw StateError('Territory capture returned no result');
    }

    return TerritoryRowMapper.captureResultFromRow(
      Map<String, dynamic>.from(list.first as Map),
    );
  }

  @override
  Future<void> cancelCaptureSession(String sessionId) async {
    final uid = await _deviceId();
    await _client.rpc(
      'cancel_territory_capture_session',
      params: {
        'p_user_id': uid,
        'p_session_id': sessionId,
      },
    );
  }

  @override
  Future<List<CapturedTerritory>> getTerritories({TerritoryMapBounds? bounds}) async {
    final uid = await _deviceId();
    final params = <String, dynamic>{'p_user_id': uid};
    if (bounds != null) {
      params
        ..['p_min_lng'] = bounds.minLng
        ..['p_min_lat'] = bounds.minLat
        ..['p_max_lng'] = bounds.maxLng
        ..['p_max_lat'] = bounds.maxLat;
    }

    final rows = await _client.rpc('get_territories', params: params);
    return _mapTerritories(rows);
  }

  @override
  Future<List<CapturedTerritory>> getMyTerritories() async {
    final uid = await _deviceId();
    final rows = await _client.rpc(
      'get_my_territories',
      params: {'p_user_id': uid},
    );
    return _mapTerritories(rows);
  }

  @override
  Future<CapturedTerritory?> getTerritoryDetail(String territoryId) async {
    final uid = await _deviceId();
    final rows = await _client.rpc(
      'get_territory_detail',
      params: {
        'p_user_id': uid,
        'p_territory_id': territoryId,
      },
    );

    final list = rows as List<dynamic>;
    if (list.isEmpty) return null;

    return TerritoryRowMapper.territoryFromRow(
      Map<String, dynamic>.from(list.first as Map),
    );
  }

  @override
  Future<List<TerritoryLeaderboardEntry>> getLeaderboard({int limit = 50}) async {
    final rows = await _client.rpc(
      'get_territory_leaderboard',
      params: {'p_limit': limit},
    );

    final list = rows as List<dynamic>? ?? const [];
    return list
        .map((row) => TerritoryRowMapper.leaderboardEntryFromRow(
              Map<String, dynamic>.from(row as Map),
            ))
        .toList(growable: false);
  }

  List<CapturedTerritory> _mapTerritories(dynamic rows) {
    final list = rows as List<dynamic>? ?? const [];
    return list
        .map((row) => TerritoryRowMapper.territoryFromRow(
              Map<String, dynamic>.from(row as Map),
            ))
        .toList(growable: false);
  }
}

final class TerritoryRepositoryFactory {
  static TerritoryRepository create(SharedPreferences prefs) {
    return SupabaseTerritoryRepository(prefs: prefs);
  }
}
