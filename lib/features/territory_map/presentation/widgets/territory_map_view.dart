import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:gym/l10n/app_localizations.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../config/territory_config.dart';
import '../../domain/territory.dart';
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
  StreamSubscription<geo.Position>? _positionSubscription;
  var _styleReady = false;
  var _autoLocateAttempted = false;
  var _isLocating = false;
  String? _loadedStyleUrl;
  Circle? _userCircle;
  LatLng? _resolvedInitialTarget;
  geo.Position? _pendingCenterPosition;
  double? _pendingCenterZoom;
  var _pendingCenterAnimate = false;
  var _hasCenteredOnUser = false;

  @override
  void initState() {
    super.initState();
    unawaited(_resolveInitialTarget());
  }

  @override
  void didUpdateWidget(covariant TerritoryMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_syncMap());
  }

  @override
  void dispose() {
    unawaited(_positionSubscription?.cancel());
    super.dispose();
  }

  Future<void> _resolveInitialTarget() async {
    final result = await _locationService.resolveCurrentPosition(forceFresh: true);
    if (!mounted || !result.isSuccess) return;
    final position = result.position!;
    setState(() {
      _resolvedInitialTarget = LatLng(position.latitude, position.longitude);
    });
    await _centerOnPosition(position, zoom: 15, animate: false);
  }

  Future<void> _onMapCreated(MapLibreMapController controller) async {
    _mapController = controller;
    controller.onFillTapped.add((fill) {
      final territoryId = fill.data?['territoryId'] as String?;
      if (territoryId == null) return;
      final territory = widget.controller.territories.where((t) => t.id == territoryId).firstOrNull;
      if (territory != null) widget.onTerritoryTap?.call(territory);
    });
    _startWatchingPosition();
  }

  void _startWatchingPosition() {
    unawaited(_positionSubscription?.cancel());
    _positionSubscription = _locationService.watchPosition().listen(
      (position) {
        unawaited(_updateUserMarker(position));
      },
      onError: (_) {},
    );
  }

  Future<void> _onStyleLoaded() async {
    _styleReady = true;
    await _syncMap();
    await _applyPendingCenter();
    if (!_autoLocateAttempted) {
      _autoLocateAttempted = true;
      await locateUser();
    }
  }

  Future<void> _syncMap() async {
    final controller = _mapController;
    if (controller == null || !_styleReady) return;

    final styleUrl = MapStyleConfig.styleUrlFor(widget.controller.mapMode);
    if (_loadedStyleUrl != styleUrl) {
      _styleReady = false;
      _userCircle = null;
      await controller.setStyle(styleUrl);
      _loadedStyleUrl = styleUrl;
      return;
    }

    await controller.clearFills();
    await controller.clearLines();

    for (final territory in widget.controller.territories) {
      final ring = _ringFromTerritory(territory);
      if (ring == null) continue;
      await controller.addFill(
        FillOptions(
          geometry: [ring],
          fillColor: territory.isOwnedByCurrentUser
              ? _colorHex(AppColors.primary)
              : _mutedColorHex(territory.ownerId),
          fillOpacity: territory.isOwnedByCurrentUser ? 0.35 : 0.28,
          fillOutlineColor: territory.isOwnedByCurrentUser
              ? _colorHex(AppColors.primaryDark)
              : _colorHex(AppColors.textSecondary),
        ),
        {'territoryId': territory.id},
      );
    }

    if (widget.controller.capturePoints.length >= 2) {
      await controller.addLine(
        LineOptions(
          geometry: widget.controller.capturePoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList(growable: false),
          lineColor: _colorHex(AppColors.accent),
          lineWidth: 4,
        ),
      );
    }
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
      points.add(LatLng(
        (vertex[1] as num).toDouble(),
        (vertex[0] as num).toDouble(),
      ));
    }
    return points.isEmpty ? null : points;
  }

  String _colorHex(Color color) {
    final value = color.toARGB32();
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }

  String _mutedColorHex(String ownerId) {
    const palette = [
      AppColors.textMuted,
      AppColors.textSecondary,
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
      Color(0xFF0EA5E9),
    ];
    return _colorHex(palette[ownerId.hashCode.abs() % palette.length]);
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

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2),
        15.5,
      ),
    );
  }

  Future<UserLocationResult?> locateUser() async {
    if (_isLocating) return null;
    _setLocating(true);

    try {
      final result = await _locationService.resolveCurrentPosition(forceFresh: true);
      if (!result.isSuccess) {
        return result;
      }

      final position = result.position!;
      _hasCenteredOnUser = true;
      await _centerOnPosition(position, zoom: 16, animate: true);
      await _updateUserMarker(position);
      await _mapController?.updateMyLocationTrackingMode(MyLocationTrackingMode.tracking);
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
    final controller = _mapController;
    if (controller == null || !_styleReady) {
      _pendingCenterPosition = position;
      _pendingCenterZoom = zoom;
      _pendingCenterAnimate = animate;
      return;
    }

    final target = LatLng(position.latitude, position.longitude);
    final update = CameraUpdate.newLatLngZoom(target, zoom);
    if (animate) {
      await controller.animateCamera(update);
    } else {
      await controller.moveCamera(update);
    }
    _hasCenteredOnUser = true;
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

  Future<void> _updateUserMarker(geo.Position position) async {
    await _updateUserMarkerAt(LatLng(position.latitude, position.longitude));
  }

  Future<void> _updateUserMarkerAt(LatLng target) async {
    final controller = _mapController;
    if (controller == null || !_styleReady) return;

    final circle = _userCircle;
    if (circle == null) {
      _userCircle = await controller.addCircle(
        CircleOptions(
          geometry: target,
          circleRadius: 12,
          circleColor: _colorHex(AppColors.primary),
          circleOpacity: 0.25,
          circleStrokeWidth: 3,
          circleStrokeColor: '#FFFFFF',
        ),
      );
      return;
    }

    await controller.updateCircle(
      circle,
      CircleOptions(
        geometry: target,
        circleRadius: 12,
        circleColor: _colorHex(AppColors.primary),
        circleOpacity: 0.25,
        circleStrokeWidth: 3,
        circleStrokeColor: '#FFFFFF',
      ),
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

    return Stack(
      fit: StackFit.expand,
      children: [
        MapLibreMap(
          key: ValueKey(MapStyleConfig.styleUrlFor(widget.controller.mapMode)),
          styleString: MapStyleConfig.styleUrlFor(widget.controller.mapMode),
          initialCameraPosition: CameraPosition(
            target: initialTarget,
            zoom: _resolvedInitialTarget == null ? 4 : 15,
          ),
          myLocationEnabled: true,
          myLocationRenderMode:
              Platform.isIOS ? MyLocationRenderMode.compass : MyLocationRenderMode.normal,
          myLocationTrackingMode: MyLocationTrackingMode.tracking,
          compassEnabled: true,
          onMapCreated: _onMapCreated,
          onStyleLoadedCallback: _onStyleLoaded,
          onUserLocationUpdated: (location) {
            unawaited(_updateUserMarkerAt(location.position));
            if (!_hasCenteredOnUser && _mapController != null) {
              _hasCenteredOnUser = true;
              unawaited(
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(location.position, 16),
                ),
              );
            }
          },
        ),
        if (_isLocating)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 56),
              child: _LocatingBanner(isLocating: _isLocating),
            ),
          ),
      ],
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
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.mapLocating,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
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
