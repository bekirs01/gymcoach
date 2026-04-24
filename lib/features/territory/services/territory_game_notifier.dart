import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../domain/territory_models.dart';
import '../utils/geo_utils.dart';
import '../utils/overlap_engine.dart';
import '../utils/route_capture_logic.dart';
import 'location_permission_service.dart';
import '../data/mock/mock_territory_seed.dart';
import 'mock_territory_store.dart';

final territoryGameProvider =
    StateNotifierProvider<TerritoryGameNotifier, TerritoryGameState>((ref) {
  return TerritoryGameNotifier(MockTerritoryStore().initialState);
});

class TerritoryGameNotifier extends StateNotifier<TerritoryGameState> {
  TerritoryGameNotifier(super.state);

  final RouteCaptureLogic _routeLogic = RouteCaptureLogic();
  final OverlapEngine _overlap = OverlapEngine();

  StreamSubscription<Position>? _posSub;
  Timer? _simTimer;

  @override
  void dispose() {
    _posSub?.cancel();
    _simTimer?.cancel();
    super.dispose();
  }

  void setBanner(String? m) =>
      state = state.copyWith(statusMessage: m, clearStatus: m == null);

  Future<void> useDeviceMode() async {
    _simTimer?.cancel();
    final err = await LocationPermissionService.ensureReady();
    if (err != null) {
      state = state.copyWith(permissionDenied: true, statusMessage: err);
      return;
    }
    state = state.copyWith(
      mode: TerritoryRouteMode.device,
      permissionDenied: false,
      statusMessage: 'GPS: маршрут рисуется по ходьбе.',
    );
    await _posSub?.cancel();
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 6,
      ),
    ).listen((p) {
      final ll = LatLng(p.latitude, p.longitude);
      state = state.copyWith(liveUserPosition: ll);
      if (state.isRecording) _appendIfMoved(ll);
    });

    final pos = await Geolocator.getCurrentPosition();
    state = state.copyWith(
      liveUserPosition: LatLng(pos.latitude, pos.longitude),
    );
  }

  void useSimulationMode() {
    _posSub?.cancel();
    _posSub = null;
    _simTimer?.cancel();
    state = state.copyWith(
      mode: TerritoryRouteMode.simulation,
      permissionDenied: false,
      liveUserPosition: state.mapCenter,
      statusMessage: 'Симуляция: доступен демо-маршрут.',
    );
  }

  /// Haritayı kullanıcı konumuna kaydır (ekran MapController ile dinler).
  void recenterMapOnUser() {
    final p = state.liveUserPosition ?? state.mapCenter;
    state = state.copyWith(mapCenter: p);
  }

  void startRecording() {
    final start = state.liveUserPosition ?? state.mapCenter;
    state = state.copyWith(
      isRecording: true,
      activeRoute: [start],
      clearStatus: true,
    );
  }

  void stopRecording() {
    _simTimer?.cancel();
    state = state.copyWith(
      isRecording: false,
      statusMessage: 'Запись остановлена. Нажмите «Старт» снова.',
    );
  }

  void clearRoute() {
    _simTimer?.cancel();
    state = state.copyWith(clearRoute: true, isRecording: false);
  }

  void appendPoint(LatLng p) {
    if (!state.isRecording) return;
    state = state.copyWith(activeRoute: [...state.activeRoute, p]);
  }

  void _appendIfMoved(LatLng p) {
    final r = state.activeRoute;
    if (r.isEmpty) {
      state = state.copyWith(activeRoute: [p]);
      return;
    }
    if (GeoUtils.distanceMeters(r.last, p) >= 5) {
      appendPoint(p);
    }
  }

  void startSimulationRun() {
    useSimulationMode();
    final anchor = simulationAnchorInsideRival();
    state = state.copyWith(liveUserPosition: anchor, mapCenter: anchor);
    startRecording();
    final full = _demoSquareRoute(anchor);
    var i = 0;
    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (!state.isRecording || state.mode != TerritoryRouteMode.simulation) {
        _simTimer?.cancel();
        return;
      }
      if (i >= full.length) {
        _simTimer?.cancel();
        state = state.copyWith(
          statusMessage: 'Симуляция готова — нажмите «Завершить».',
        );
        return;
      }
      state = state.copyWith(
        activeRoute: full.sublist(0, i + 1),
        liveUserPosition: full[i],
      );
      i++;
    });
  }

  List<LatLng> _demoSquareRoute(LatLng o) {
    final p0 = o;
    final p1 = GeoUtils.offsetMeters(p0, 0, 48);
    final p2 = GeoUtils.offsetMeters(p1, 55, 0);
    final p3 = GeoUtils.offsetMeters(p2, 0, -48);
    final p4 = GeoUtils.offsetMeters(p3, -55, 0);
    final p5 = p0;
    return [p0, p1, p2, p3, p4, p5];
  }

  RouteCaptureOutcome tryCloseRoute() => _routeLogic.evaluate(state.activeRoute);

  void saveCompletedTerritory({
    required String name,
    required List<LatLng> closedRing,
    required double areaSqM,
    required double pathLengthM,
  }) {
    final id = 'z_${DateTime.now().millisecondsSinceEpoch}';
    final incoming = TerritoryZone(
      id: id,
      name: name.trim().isEmpty ? 'Без названия' : name.trim(),
      ownerId: state.currentUserId,
      ring: closedRing,
      claimedAt: DateTime.now(),
      areaSqM: areaSqM,
      routeLengthM: pathLengthM,
      captureCount: 0,
    );

    final updated = List<TerritoryZone>.from(state.territories);
    final users = Map<String, TerritoryProfile>.from(state.users);
    final me = users[state.currentUserId]!;
    var newCaptures = me.totalCaptures;

    for (var i = 0; i < updated.length; i++) {
      final t = updated[i];
      if (t.ownerId == state.currentUserId) continue;
      if (_overlap.shouldTransferOwnership(
        attackerRing: incoming.ring,
        defender: t,
      )) {
        updated[i] = t.copyWith(
          ownerId: state.currentUserId,
          captureCount: t.captureCount + 1,
          lastCapturerId: state.currentUserId,
          claimedAt: DateTime.now(),
        );
        newCaptures += 1;
      }
    }

    updated.add(incoming);
    users[state.currentUserId] = me.copyWith(totalCaptures: newCaptures);

    final tookRival = newCaptures > me.totalCaptures;
    state = state.copyWith(
      territories: updated,
      users: users,
      clearRoute: true,
      isRecording: false,
      statusMessage: tookRival
          ? 'Захвачены зоны соперников — очки обновлены!'
          : 'Территория сохранена. Ещё круг?',
    );
  }
}
