import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme/app_colors.dart';
import '../data/territory_api_factory.dart';
import '../services/location_permission_service.dart';
import 'territory_formatters.dart';
import 'territory_map_controller.dart';
import 'widgets/capture_overlay.dart';
import 'widgets/leaderboard_sheet.dart';
import 'widgets/map_floating_controls.dart';
import 'widgets/map_state_cards.dart';
import 'widgets/territory_detail_sheet.dart';
import 'widgets/territory_map_view.dart';

class TerritoryMapPage extends StatefulWidget {
  const TerritoryMapPage({
    super.key,
    required this.displayName,
  });

  final String displayName;

  @override
  State<TerritoryMapPage> createState() => _TerritoryMapPageState();
}

class _TerritoryMapPageState extends State<TerritoryMapPage> {
  final _mapViewKey = GlobalKey<TerritoryMapViewState>();
  TerritoryMapController? _controller;
  var _leaderboardLoading = false;
  var _namingDialogScheduled = false;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final apiClient = await createTerritoryApiClient(
      prefs: prefs,
      displayName: widget.displayName,
    );
    final controller = TerritoryMapController(
      apiClient: apiClient,
      displayName: widget.displayName,
    );
    setState(() => _controller = controller);
    await controller.initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<bool> _showPermissionExplanation() async {
    final l10n = AppLocalizations.of(context)!;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.mapPermissionDialogTitle),
        content: Text(l10n.mapPermissionDialogBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(l10n.mapContinue),
          ),
        ],
      ),
    );
    return proceed == true;
  }

  Future<void> _startCapture() async {
    final controller = _controller;
    if (controller == null) return;
    final started = await controller.startCapture(
      onExplainPermission: _showPermissionExplanation,
    );
    if (!started && mounted && controller.permissionState != LocationPermissionState.granted) {
      setState(() {});
    }
  }

  Future<void> _finishCapture() async {
    final controller = _controller;
    if (controller == null) return;
    final errorCode = await controller.finishCapture();
    if (!mounted || errorCode == null) return;
    final l10n = AppLocalizations.of(context)!;
    final message = switch (errorCode) {
      'min_points' => l10n.mapValidationMinPoints,
      'min_area' => l10n.mapValidationMinArea,
      _ => l10n.mapCaptureFailed,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  Future<void> _promptTerritoryName() async {
    final controller = _controller;
    if (controller == null || controller.capturePhase != CapturePhase.naming) return;
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: controller.defaultTerritoryName());
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.mapNameTerritoryTitle),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.mapTerritoryNameLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(nameController.text.trim()),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (!mounted || name == null || name.isEmpty) {
      await controller.cancelCapture();
      return;
    }
    final saved = await controller.submitCaptureName(name);
    if (!mounted) return;
    if (saved) {
      await _showCaptureSuccess();
    } else if (controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(controller.errorMessage!),
        ),
      );
    }
  }

  Future<void> _showCaptureSuccess() async {
    final controller = _controller;
    if (controller == null || controller.lastCapturedTerritory == null) return;
    final l10n = AppLocalizations.of(context)!;
    final territory = controller.lastCapturedTerritory!;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.mapCaptureSuccessTitle),
        content: Text(
          l10n.mapCaptureSuccessBody(
            territory.name,
            TerritoryFormatters.area(territory.areaSquareMeters),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(l10n.mapDone),
          ),
        ],
      ),
    );
    controller.dismissCaptureSuccess();
  }

  Future<void> _openLeaderboard() async {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _leaderboardLoading = true);
    unawaited(showTerritoryLeaderboardSheet(
      context: context,
      entries: controller.leaderboard,
      isLoading: true,
    ));
    await controller.refreshLeaderboard();
    if (!mounted) return;
    Navigator.of(context).pop();
    setState(() => _leaderboardLoading = false);
    await showTerritoryLeaderboardSheet(
      context: context,
      entries: controller.leaderboard,
      isLoading: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;

    if (controller == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.capturePhase == CapturePhase.naming && !_namingDialogScheduled) {
          _namingDialogScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await _promptTerritoryName();
            _namingDialogScheduled = false;
          });
        }

        final permissionGranted = controller.permissionState == LocationPermissionState.granted;

        return Stack(
          fit: StackFit.expand,
          children: [
            if (permissionGranted)
              TerritoryMapView(
                key: _mapViewKey,
                controller: controller,
                onTerritoryTap: controller.selectTerritory,
              )
            else
              const ColoredBox(color: AppColors.background),
            if (!permissionGranted)
              MapPermissionCard(
                state: controller.permissionState ?? LocationPermissionState.denied,
                onRequestPermission: () async {
                  await _showPermissionExplanation();
                  await controller.requestLocationPermission();
                },
                onOpenSettings: controller.openSystemSettings,
              ),
            if (permissionGranted &&
                controller.territories.isEmpty &&
                !controller.isLoadingTerritories &&
                controller.capturePhase == CapturePhase.idle)
              Padding(
                padding: EdgeInsets.only(top: topPadding + 8),
                child: const MapEmptyTerritoriesCard(),
              ),
            if (permissionGranted)
              MapFloatingControls(
                controller: controller,
                onLocateMe: () => _mapViewKey.currentState?.locateUser(),
                onLeaderboard: _leaderboardLoading ? () {} : _openLeaderboard,
                onStartCapture: _startCapture,
                onSatelliteUnavailable: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(l10n.mapSatelliteUnavailable),
                    ),
                  );
                },
              ),
            if (controller.capturePhase == CapturePhase.capturing)
              CaptureOverlay(
                controller: controller,
                onFinish: _finishCapture,
                onCancel: controller.cancelCapture,
              ),
            if (controller.selectedTerritory != null)
              TerritoryDetailSheet(
                territory: controller.selectedTerritory!,
                onClose: () => controller.selectTerritory(null),
                onZoom: () {
                  final territory = controller.selectedTerritory;
                  if (territory != null) {
                    _mapViewKey.currentState?.zoomToTerritory(territory);
                  }
                },
              ),
            Positioned(
              left: 20,
              top: topPadding + 12,
              child: Text(
                l10n.mapTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      shadows: permissionGranted
                          ? const [Shadow(color: Colors.white, blurRadius: 8)]
                          : null,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}