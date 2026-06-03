import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/territory_config.dart';
import '../data/supabase_territory_api_client.dart';
import '../data/territory_api_client.dart';
import '../domain/capture_point.dart';
import '../domain/capture_session.dart';
import '../domain/leaderboard_entry.dart';
import '../domain/territory.dart';
import '../services/gps_capture_service.dart';
import '../services/location_permission_service.dart';
import '../services/polygon_utils.dart';

enum CapturePhase { idle, capturing, naming, success }

class TerritoryMapController extends ChangeNotifier {
  TerritoryMapController({
    required this.apiClient,
    required this.displayName,
    LocationPermissionService? permissionService,
    GpsCaptureService? captureService,
  })  : _permissionService = permissionService ?? LocationPermissionService(),
        _captureService = captureService ?? GpsCaptureService();

  final TerritoryApiClient apiClient;
  final String displayName;
  final LocationPermissionService _permissionService;
  final GpsCaptureService _captureService;

  LocationPermissionState? permissionState;
  TerritoryMapVisualMode mapMode = TerritoryMapVisualMode.standard;
  CapturePhase capturePhase = CapturePhase.idle;
  List<Territory> territories = const [];
  List<LeaderboardEntry> leaderboard = const [];
  Territory? selectedTerritory;
  CaptureSession? activeSession;
  List<CapturePoint> capturePoints = const [];
  Duration elapsed = Duration.zero;
  double routeDistanceMeters = 0;
  double estimatedAreaSquareMeters = 0;
  double latestAccuracyMeters = 0;
  bool poorGpsWarning = false;
  String? errorMessage;
  Territory? lastCapturedTerritory;
  bool isLoadingTerritories = false;
  bool isSubmittingCapture = false;

  StreamSubscription<CapturePoint>? _captureSubscription;
  Timer? _refreshTimer;
  Timer? _elapsedTimer;
  DateTime? _captureStartedAt;

  bool get isLoopClosed => PolygonUtils.isClosureWithinTolerance(capturePoints);

  bool get isCapturingRouteVisible =>
      capturePhase == CapturePhase.capturing || capturePhase == CapturePhase.naming;

  Future<void> initialize() async {
    permissionState = await _permissionService.checkPermission();
    await refreshTerritories();
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (capturePhase == CapturePhase.idle) {
        unawaited(refreshTerritories());
      }
    });
    notifyListeners();
  }

  Future<void> refreshTerritories() async {
    isLoadingTerritories = true;
    notifyListeners();
    try {
      territories = await apiClient.getTerritories();
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoadingTerritories = false;
      notifyListeners();
    }
  }

  Future<List<LeaderboardEntry>> refreshLeaderboard() async {
    try {
      leaderboard = await apiClient.getLeaderboard();
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    }
    notifyListeners();
    return leaderboard;
  }

  Future<LocationPermissionState> requestLocationPermission() async {
    permissionState = await _permissionService.requestPermission();
    notifyListeners();
    return permissionState!;
  }

  Future<void> openSystemSettings() async {
    await _permissionService.openSystemSettings();
  }

  void setStandardMapMode() {
    if (mapMode == TerritoryMapVisualMode.standard) return;
    mapMode = TerritoryMapVisualMode.standard;
    notifyListeners();
  }

  void selectTerritory(Territory? territory) {
    selectedTerritory = territory;
    notifyListeners();
    if (territory != null) {
      unawaited(_loadTerritoryDetail(territory.id));
    }
  }

  Future<void> _loadTerritoryDetail(String territoryId) async {
    final client = apiClient;
    if (client is! SupabaseTerritoryApiClient) return;
    try {
      final detail = await client.getTerritoryDetail(territoryId);
      if (detail == null || selectedTerritory?.id != territoryId) return;
      selectedTerritory = detail;
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> startCapture({required Future<bool> Function() onExplainPermission}) async {
    if (capturePhase != CapturePhase.idle) return false;

    final current = permissionState ?? await _permissionService.checkPermission();
    if (current != LocationPermissionState.granted) {
      final explained = await onExplainPermission();
      if (!explained) return false;
      permissionState = await _permissionService.requestPermission();
      if (permissionState != LocationPermissionState.granted) {
        notifyListeners();
        return false;
      }
    }

    try {
      activeSession = await apiClient.createCaptureSession();
      capturePoints = const [];
      routeDistanceMeters = 0;
      estimatedAreaSquareMeters = 0;
      latestAccuracyMeters = 0;
      poorGpsWarning = false;
      lastCapturedTerritory = null;
      errorMessage = null;
      capturePhase = CapturePhase.capturing;
      _captureStartedAt = DateTime.now();
      _elapsedTimer?.cancel();
      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_captureStartedAt == null) return;
        elapsed = DateTime.now().difference(_captureStartedAt!);
        notifyListeners();
      });
      await _captureSubscription?.cancel();
      _captureSubscription = _captureService.start().listen(
        _onCapturePoint,
        onError: (Object error) {
          errorMessage = error.toString();
          notifyListeners();
        },
      );
      notifyListeners();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      capturePhase = CapturePhase.idle;
      notifyListeners();
      return false;
    }
  }

  void _onCapturePoint(CapturePoint point) {
    capturePoints = [...capturePoints, point];
    routeDistanceMeters = PolygonUtils.routeDistanceMeters(capturePoints);
    estimatedAreaSquareMeters = PolygonUtils.polygonAreaSquareMeters(capturePoints);
    latestAccuracyMeters = point.accuracyMeters;
    poorGpsWarning = point.accuracyMeters > TerritoryConfig.warnAccuracyMeters;
    unawaited(_persistCapturePoint(point));
    notifyListeners();
  }

  Future<void> _persistCapturePoint(CapturePoint point) async {
    final session = activeSession;
    if (session == null) return;
    try {
      await apiClient.saveCapturePoint(session.id, point);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('saveCapturePoint failed: $error');
      }
    }
  }

  Future<String?> finishCapture() async {
    if (capturePhase != CapturePhase.capturing) return null;
    await _captureSubscription?.cancel();
    _captureSubscription = null;
    _elapsedTimer?.cancel();
    await _captureService.stop();

    if (capturePoints.length < TerritoryConfig.minCapturePoints) {
      await _cancelCaptureInternal();
      return 'min_points';
    }

    if (estimatedAreaSquareMeters < TerritoryConfig.minAreaSquareMeters) {
      await _cancelCaptureInternal();
      return 'min_area';
    }

    if (!PolygonUtils.isClosureWithinTolerance(capturePoints)) {
      capturePoints = [...capturePoints, capturePoints.first];
      estimatedAreaSquareMeters = PolygonUtils.polygonAreaSquareMeters(capturePoints);
    }

    capturePhase = CapturePhase.naming;
    notifyListeners();
    return null;
  }

  Future<void> cancelCapture() async {
    await _cancelCaptureInternal();
    notifyListeners();
  }

  Future<void> _cancelCaptureInternal() async {
    await _captureSubscription?.cancel();
    _captureSubscription = null;
    _elapsedTimer?.cancel();
    await _captureService.stop();
    final session = activeSession;
    activeSession = null;
    capturePoints = const [];
    capturePhase = CapturePhase.idle;
    elapsed = Duration.zero;
    routeDistanceMeters = 0;
    estimatedAreaSquareMeters = 0;
    if (session != null) {
      try {
        await apiClient.cancelCaptureSession(session.id);
      } catch (_) {}
    }
  }

  Future<bool> submitCaptureName(String name) async {
    final session = activeSession;
    if (session == null || capturePhase != CapturePhase.naming) return false;
    isSubmittingCapture = true;
    notifyListeners();
    try {
      final geoJson = PolygonUtils.buildPolygonGeoJson(capturePoints);
      final territory = await apiClient.finishCaptureSession(session.id, name.trim(), geoJson);
      lastCapturedTerritory = territory;
      activeSession = null;
      capturePhase = CapturePhase.success;
      await refreshTerritories();
      await refreshLeaderboard();
      errorMessage = null;
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmittingCapture = false;
      notifyListeners();
    }
  }

  void dismissCaptureSuccess() {
    capturePhase = CapturePhase.idle;
    capturePoints = const [];
    elapsed = Duration.zero;
    routeDistanceMeters = 0;
    estimatedAreaSquareMeters = 0;
    notifyListeners();
  }

  String defaultTerritoryName() => "$displayName's area";

  @override
  void dispose() {
    _captureSubscription?.cancel();
    _refreshTimer?.cancel();
    _elapsedTimer?.cancel();
    unawaited(_captureService.stop());
    super.dispose();
  }
}
