import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:gym/l10n/app_localizations.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../config/territory_config.dart';
import '../../domain/capture_point.dart';
import '../../domain/territory.dart';
import '../../services/polygon_utils.dart';
import '../../services/user_location_service.dart';
import '../territory_map_controller.dart';

class TerritoryMapView extends StatefulWidget {
  const TerritoryMapView({
    super.key,
    required this.controller,
    this.onTerritoryTap,
    this.onLocatingChanged,
  });

  final TerritoryMapController controller;
  final ValueChanged<Territory>? onTerritoryTap;
  final ValueChanged<bool>? onLocatingChanged;

  @override
  State<TerritoryMapView> createState() => TerritoryMapViewState();
}

class TerritoryMapViewState extends State<TerritoryMapView> {
  final _locationService = UserLocationService();

  MapLibreMapController? _mapController;
  var _styleReady = false;
  var _isLocating = false;
  String? _loadedStyleUrl;
  LatLng? _resolvedInitialTarget;
  geo.Position? _pendingCenterPosition;
  double? _pendingCenterZoom;
  var _pendingCenterAnimate = false;
  _MapSyncSnapshot? _lastSyncedSnapshot;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    unawaited(_resolveInitialTarget());
  }

  @override
  void didUpdateWidget(covariant TerritoryMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _lastSyncedSnapshot = null;
    }
    unawaited(_syncMap());
  }

  void _onControllerChanged() {
    final snapshot = _MapSyncSnapshot.from(widget.controller);
    if (_lastSyncedSnapshot == snapshot) return;
    unawaited(_syncMap());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  bool _isValidLatLng(LatLng target) {
    if (!target.latitude.isFinite || !target.longitude.isFinite) return false;
    if (target.latitude.abs() > 90 || target.longitude.abs() > 180) return false;
    if (target.latitude == 0 && target.longitude == 0) return false;
    return true;
  }

  double _clampZoom(double zoom) => zoom.clamp(3.0, 18.0);

  Future<void> _safeCameraUpdate(CameraUpdate update, {required bool animate}) async {
    final controller = _mapController;
    if (controller == null || !_styleReady) return;

    try {
      // animated camera moves crash MapLibre on some iOS simulator builds.
      if (animate && !Platform.isAndroid) {
        await controller.moveCamera(update);
      } else if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
    } catch (error, stackTrace) {
      debugPrint('Map camera update failed: $error\n$stackTrace');
    }
  }

  Future<void> _resolveInitialTarget() async {
    final result = await _locationService.resolveCurrentPosition();
    if (!mounted || !result.isSuccess) return;
    final position = result.position!;
    final target = LatLng(position.latitude, position.longitude);
    if (!_isValidLatLng(target)) return;
    setState(() => _resolvedInitialTarget = target);
  }

  Future<void> _onMapCreated(MapLibreMapController controller) async {
    _mapController = controller;
    controller.onFillTapped.add((fill) {
      _handleTerritoryTap(fill.data?['territoryId'] as String?);
    });
    controller.onCircleTapped.add((circle) {
      _handleTerritoryTap(circle.data?['territoryId'] as String?);
    });
    controller.onSymbolTapped.add((symbol) {
      _handleTerritoryTap(symbol.data?['territoryId'] as String?);
    });
  }

  void _handleTerritoryTap(String? territoryId) {
    if (territoryId == null) return;
    final territory = widget.controller.territories.where((t) => t.id == territoryId).firstOrNull;
    if (territory != null) widget.onTerritoryTap?.call(territory);
  }

  Future<void> _onStyleLoaded() async {
    _styleReady = true;
    await _syncMap();
    await _applyPendingCenter();
  }

  Future<void> _syncMap() async {
    final controller = _mapController;
    if (controller == null || !_styleReady) return;

    final styleUrl = MapStyleConfig.styleUrlFor(widget.controller.mapMode);
    if (_loadedStyleUrl != styleUrl) {
      _styleReady = false;
      _lastSyncedSnapshot = null;
      await controller.setStyle(styleUrl);
      _loadedStyleUrl = styleUrl;
      return;
    }

    final snapshot = _MapSyncSnapshot.from(widget.controller);
    if (_lastSyncedSnapshot == snapshot) return;
    _lastSyncedSnapshot = snapshot;

    await controller.clearFills();
    await controller.clearLines();
    await controller.clearCircles();
    await controller.clearSymbols();

    for (final territory in widget.controller.territories) {
      final ring = _ringFromTerritory(territory);
      if (ring == null) continue;
      final fillColor = territory.isOwnedByCurrentUser
          ? PremiumColors.accentBlue
          : _ownerColor(territory.ownerId);
      await controller.addFill(
        FillOptions(
          geometry: [ring],
          fillColor: _colorHex(fillColor),
          fillOpacity: territory.isOwnedByCurrentUser ? 0.42 : 0.36,
          fillOutlineColor: _colorHex(fillColor),
        ),
        {'territoryId': territory.id},
      );

      final centroid = _centroidFromRing(ring);
      if (centroid == null) continue;

      await controller.addCircle(
        CircleOptions(
          geometry: centroid,
          circleRadius: 16,
          circleColor: _colorHex(fillColor),
          circleOpacity: 0.95,
          circleStrokeWidth: 2.5,
          circleStrokeColor: '#FFFFFF',
        ),
        {'territoryId': territory.id},
      );

      await controller.addSymbol(
        SymbolOptions(
          geometry: centroid,
          textField: _initials(territory.ownerDisplayName),
          textSize: 11,
          textColor: '#FFFFFF',
          textHaloColor: '#000000',
          textHaloWidth: 0.8,
          fontNames: const ['Noto Sans Regular'],
        ),
        {'territoryId': territory.id},
      );

      await controller.addSymbol(
        SymbolOptions(
          geometry: centroid,
          textField: territory.name,
          textSize: 12,
          textColor: '#1A1A2E',
          textHaloColor: '#FFFFFF',
          textHaloWidth: 1.6,
          textOffset: const Offset(0, 2.8),
          fontNames: const ['Noto Sans Regular'],
        ),
        {'territoryId': territory.id},
      );
    }

    if (widget.controller.isCapturingRouteVisible) {
      await _drawActiveCapture(controller);
    }
  }

  Future<void> _drawActiveCapture(MapLibreMapController controller) async {
    final points = widget.controller.capturePoints;
    if (points.isEmpty) return;

    final route = points.map((point) => LatLng(point.latitude, point.longitude)).toList(growable: false);
    final loopClosed = widget.controller.isLoopClosed;

    if (loopClosed && points.length >= 3) {
      final ring = _ringFromCapturePoints(points, closeLoop: true);
      if (ring != null) {
        await controller.addFill(
          FillOptions(
            geometry: [ring],
            fillColor: _colorHex(PremiumColors.accentBlue),
            fillOpacity: 0.38,
            fillOutlineColor: _colorHex(PremiumColors.accentBlue),
          ),
        );
      }
    }

    if (route.length >= 2) {
      await controller.addLine(
        LineOptions(
          geometry: route,
          lineColor: '#FFFFFF',
          lineWidth: 7,
          lineOpacity: 0.85,
        ),
      );
      await controller.addLine(
        LineOptions(
          geometry: route,
          lineColor: _colorHex(PremiumColors.accentBlue),
          lineWidth: 4.5,
        ),
      );
    }

    final start = route.first;
    await controller.addCircle(
      CircleOptions(
        geometry: start,
        circleRadius: loopClosed ? 10 : 8,
        circleColor: loopClosed ? '#22C55E' : _colorHex(PremiumColors.accentBlue),
        circleOpacity: 1,
        circleStrokeWidth: 2.5,
        circleStrokeColor: '#FFFFFF',
      ),
    );
  }

  List<LatLng>? _ringFromCapturePoints(
    List<CapturePoint> points, {
    required bool closeLoop,
  }) {
    if (points.length < 3) return null;
    final List<List<dynamic>> ringData;
    if (closeLoop) {
      final geoJson = PolygonUtils.buildPolygonGeoJson(points);
      final coords = geoJson['coordinates'];
      if (coords is! List || coords.isEmpty) return null;
      ringData = (coords.first as List).cast<List<dynamic>>();
    } else {
      ringData = [
        points.map((p) => [p.longitude, p.latitude]).toList(growable: false),
      ];
    }
    final result = <LatLng>[];
    for (final vertex in ringData.first) {
      if (vertex is! List || vertex.length < 2) continue;
      result.add(LatLng((vertex[1] as num).toDouble(), (vertex[0] as num).toDouble()));
    }
    return result.length >= 3 ? result : null;
  }

  List<LatLng>? _ringFromTerritory(Territory territory) {
    final geoJson = territory.polygonGeoJson;
    if (geoJson.isEmpty) return null;
    final type = geoJson['type'] as String?;
    final coords = geoJson['coordinates'];
    if (coords is! List || coords.isEmpty) return null;

    List<dynamic> ringData;
    if (type == 'MultiPolygon') {
      final firstPolygon = coords.first;
      if (firstPolygon is! List || firstPolygon.isEmpty) return null;
      ringData = firstPolygon.first as List<dynamic>;
    } else {
      ringData = coords.first as List<dynamic>;
    }

    final points = <LatLng>[];
    for (final vertex in ringData) {
      if (vertex is! List || vertex.length < 2) continue;
      final lat = (vertex[1] as num).toDouble();
      final lng = (vertex[0] as num).toDouble();
      if (!lat.isFinite || !lng.isFinite) continue;
      if (lat.abs() > 90 || lng.abs() > 180) continue;
      points.add(LatLng(lat, lng));
    }
    return points.isEmpty ? null : points;
  }

  String _colorHex(Color color) {
    final value = color.toARGB32();
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }

  Color _ownerColor(String ownerId) {
    const palette = <Color>[
      Color(0xFF2563EB),
      Color(0xFF7C3AED),
      Color(0xFF059669),
      Color(0xFFDC2626),
      Color(0xFFEA580C),
      Color(0xFF0891B2),
    ];
    return palette[ownerId.hashCode.abs() % palette.length];
  }

  LatLng? _centroidFromRing(List<LatLng> ring) {
    if (ring.isEmpty) return null;
    var sumLat = 0.0;
    var sumLng = 0.0;
    for (final point in ring) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }
    return LatLng(sumLat / ring.length, sumLng / ring.length);
  }

  String _initials(String raw) {
    final parts = raw.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return p.length >= 2 ? p.substring(0, 2).toUpperCase() : p.toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> zoomToTerritory(Territory territory) async {
    final controller = _mapController;
    final ring = _ringFromTerritory(territory);
    if (controller == null || ring == null || ring.isEmpty) return;

    var minLat = ring.first.latitude;
    var maxLat = minLat;
    var minLng = ring.first.longitude;
    var maxLng = minLng;
    for (final point in ring) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    await _safeCameraUpdate(
      CameraUpdate.newLatLngZoom(
        LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2),
        _clampZoom(15.5),
      ),
      animate: false,
    );
  }

  Future<UserLocationResult?> locateUser({double zoom = 16}) async {
    if (_isLocating) return null;
    _setLocating(true);

    try {
      final result = await _locationService.resolveCurrentPosition(forceFresh: true);
      if (!result.isSuccess) {
        return result;
      }

      final position = result.position!;
      await _centerOnPosition(position, zoom: zoom, animate: true);
      return result;
    } finally {
      _setLocating(false);
    }
  }

  Future<void> _centerOnPosition(
    geo.Position position, {
    required double zoom,
    required bool animate,
  }) async {
    final target = LatLng(position.latitude, position.longitude);
    if (!_isValidLatLng(target)) return;

    final controller = _mapController;
    if (controller == null || !_styleReady) {
      _pendingCenterPosition = position;
      _pendingCenterZoom = _clampZoom(zoom);
      _pendingCenterAnimate = animate;
      return;
    }

    await _safeCameraUpdate(
      CameraUpdate.newLatLngZoom(target, _clampZoom(zoom)),
      animate: animate,
    );
    _pendingCenterPosition = null;
    _pendingCenterZoom = null;
    _pendingCenterAnimate = false;
  }

  Future<void> _applyPendingCenter() async {
    final position = _pendingCenterPosition;
    final zoom = _pendingCenterZoom;
    if (position == null || zoom == null) return;
    await _centerOnPosition(
      position,
      zoom: zoom,
      animate: _pendingCenterAnimate,
    );
  }

  void _setLocating(bool value) {
    if (_isLocating == value) return;
    _isLocating = value;
    widget.onLocatingChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final initialTarget = _resolvedInitialTarget ?? const LatLng(41.015, 28.979);

    return ColoredBox(
      color: const Color(0xFFE8EDF2),
      child: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MapLibreMap(
              key: ValueKey(MapStyleConfig.styleUrlFor(widget.controller.mapMode)),
              styleString: MapStyleConfig.styleUrlFor(widget.controller.mapMode),
              initialCameraPosition: CameraPosition(
                target: initialTarget,
                zoom: _resolvedInitialTarget == null ? 4 : 16,
              ),
              myLocationEnabled: true,
              myLocationRenderMode:
                  Platform.isIOS ? MyLocationRenderMode.compass : MyLocationRenderMode.normal,
              myLocationTrackingMode: widget.controller.capturePhase == CapturePhase.capturing
                  ? MyLocationTrackingMode.tracking
                  : MyLocationTrackingMode.none,
              compassEnabled: false,
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onStyleLoaded,
            ),
            if (_isLocating)
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 56),
                  child: _LocatingBanner(isLocating: _isLocating),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 96,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        PremiumColors.midnightMid.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocatingBanner extends StatelessWidget {
  const _LocatingBanner({required this.isLocating});

  final bool isLocating;

  @override
  Widget build(BuildContext context) {
    if (!isLocating) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: PremiumColors.surfaceRaised.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.28), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: PremiumColors.accentBlue),
            ),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.mapLocating,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PremiumColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}

final class _MapSyncSnapshot {
  const _MapSyncSnapshot({
    required this.capturePointCount,
    required this.capturePhase,
    required this.territorySignature,
    required this.mapMode,
    required this.loopClosed,
  });

  final int capturePointCount;
  final CapturePhase capturePhase;
  final String territorySignature;
  final String mapMode;
  final bool loopClosed;

  factory _MapSyncSnapshot.from(TerritoryMapController controller) {
    return _MapSyncSnapshot(
      capturePointCount: controller.capturePoints.length,
      capturePhase: controller.capturePhase,
      territorySignature: controller.territories
          .map((t) => '${t.id}:${t.ownerId}:${t.areaSquareMeters.toStringAsFixed(1)}')
          .join('|'),
      mapMode: controller.mapMode.name,
      loopClosed: controller.isLoopClosed,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _MapSyncSnapshot &&
        other.capturePointCount == capturePointCount &&
        other.capturePhase == capturePhase &&
        other.territorySignature == territorySignature &&
        other.mapMode == mapMode &&
        other.loopClosed == loopClosed;
  }

  @override
  int get hashCode => Object.hash(
        capturePointCount,
        capturePhase,
        territorySignature,
        mapMode,
        loopClosed,
      );
}
