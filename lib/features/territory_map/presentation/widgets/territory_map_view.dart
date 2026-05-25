import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../config/territory_config.dart';
import '../../domain/territory.dart';
import '../territory_map_controller.dart';

class TerritoryMapView extends StatefulWidget {
  const TerritoryMapView({
    super.key,
    required this.controller,
    this.onTerritoryTap,
  });

  final TerritoryMapController controller;
  final ValueChanged<Territory>? onTerritoryTap;

  @override
  State<TerritoryMapView> createState() => TerritoryMapViewState();
}

class TerritoryMapViewState extends State<TerritoryMapView> {
  MapLibreMapController? _mapController;
  var _styleReady = false;
  String? _loadedStyleUrl;

  @override
  void didUpdateWidget(covariant TerritoryMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_syncMap());
  }

  Future<void> _onMapCreated(MapLibreMapController controller) async {
    _mapController = controller;
    controller.onFillTapped.add((fill) {
      final territoryId = fill.data?['territoryId'] as String?;
      if (territoryId == null) return;
      final territory = widget.controller.territories.where((t) => t.id == territoryId).firstOrNull;
      if (territory != null) widget.onTerritoryTap?.call(territory);
    });
  }

  Future<void> _onStyleLoaded() async {
    _styleReady = true;
    await _syncMap();
  }

  Future<void> _syncMap() async {
    final controller = _mapController;
    if (controller == null || !_styleReady) return;

    final styleUrl = MapStyleConfig.styleUrlFor(widget.controller.mapMode);
    if (_loadedStyleUrl != styleUrl) {
      _styleReady = false;
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

  Future<void> locateUser() async {
    final controller = _mapController;
    if (controller == null) return;
    final position = await geo.Geolocator.getCurrentPosition(
      locationSettings: const geo.LocationSettings(accuracy: geo.LocationAccuracy.best),
    );
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      key: ValueKey(MapStyleConfig.styleUrlFor(widget.controller.mapMode)),
      styleString: MapStyleConfig.styleUrlFor(widget.controller.mapMode),
      initialCameraPosition: const CameraPosition(
        target: LatLng(41.015, 28.979),
        zoom: 12,
      ),
      myLocationEnabled: true,
      myLocationRenderMode: MyLocationRenderMode.normal,
      myLocationTrackingMode: MyLocationTrackingMode.tracking,
      compassEnabled: true,
      onMapCreated: _onMapCreated,
      onStyleLoadedCallback: _onStyleLoaded,
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
