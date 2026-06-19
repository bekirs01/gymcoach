import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/premium_tokens.dart';
import '../../../core/device_user_id.dart';
import '../../profile/domain/user_profile.dart';
import '../../profile/presentation/public_profile_page.dart';
import '../../social/data/social_api_client.dart';
import '../../social/domain/social_profile.dart';
import '../data/territory_api_factory.dart';
import '../domain/territory.dart';
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
    required this.profile,
  });

  final UserProfile profile;

  String get displayName => profile.displayName;

  @override
  State<TerritoryMapPage> createState() => _TerritoryMapPageState();
}

class _TerritoryMapPageState extends State<TerritoryMapPage> {
  final _mapViewKey = GlobalKey<TerritoryMapViewState>();
  TerritoryMapController? _controller;
  SocialApiClient? _socialClient;
  var _leaderboardLoading = false;
  var _namingDialogScheduled = false;
  var _isLocatingUser = false;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    _socialClient = SocialApiClient(prefs: prefs);
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
      return;
    }
    if (started && mounted) {
      await _mapViewKey.currentState?.locateUser(zoom: 17);
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

  Future<void> _locateUserWithFeedback() async {
    final controller = _controller;
    if (controller == null) return;

    if (controller.permissionState != LocationPermissionState.granted) {
      final proceed = await _showPermissionExplanation();
      if (!proceed || !mounted) return;
      final state = await controller.requestLocationPermission();
      if (!mounted) return;
      if (state != LocationPermissionState.granted) {
        setState(() {});
        return;
      }
      setState(() {});
    }

    await _mapViewKey.currentState?.locateUser();
  }

  void _openOwnerProfile(Territory territory) {
    final client = _socialClient;
    if (client == null || territory.isOwnedByCurrentUser) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PublicProfilePage(
          userId: territory.ownerId,
          client: client,
          currentProfile: widget.profile,
          initialProfile: SocialProfile(
            userId: territory.ownerId,
            displayName: territory.ownerDisplayName,
            bio: '',
            privateNotes: '',
            avatarUrl: territory.ownerAvatarUrl,
            coverUrl: '',
            isPublic: true,
          ),
        ),
      ),
    );
  }

  Future<void> _openLeaderboard() async {
    final controller = _controller;
    if (controller == null || _leaderboardLoading) return;
    setState(() => _leaderboardLoading = true);
    await controller.refreshLeaderboard();
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final userId = await DeviceUserId.resolve(prefs);
    if (!mounted) return;
    setState(() => _leaderboardLoading = false);
    await showTerritoryLeaderboardSheet(
      context: context,
      entries: controller.leaderboard,
      currentUserId: userId,
      onRefresh: controller.refreshLeaderboard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;

    if (controller == null) {
      return const ColoredBox(
        color: PremiumColors.midnightMid,
        child: Center(child: CircularProgressIndicator(color: PremiumColors.accentBlue)),
      );
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

        return ColoredBox(
          color: PremiumColors.midnightMid,
          child: Stack(
          fit: StackFit.expand,
          children: [
            TerritoryMapView(
              key: _mapViewKey,
              controller: controller,
              onTerritoryTap: controller.selectTerritory,
              onLocatingChanged: (isLocating) {
                if (_isLocatingUser != isLocating) {
                  setState(() => _isLocatingUser = isLocating);
                }
              },
            ),
            if (!permissionGranted)
              MapPermissionCard(
                state: controller.permissionState ?? LocationPermissionState.denied,
                onRequestPermission: () async {
                  final proceed = await _showPermissionExplanation();
                  if (!proceed || !mounted) return;
                  final state = await controller.requestLocationPermission();
                  if (!mounted) return;
                  if (state == LocationPermissionState.granted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      unawaited(_locateUserWithFeedback());
                    });
                  }
                },
                onOpenSettings: controller.openSystemSettings,
              ),
            if (permissionGranted &&
                controller.territories.where((t) {
                  if (t.id.startsWith('demo-')) return false;
                  if (t.ownerId.startsWith('demo-')) return false;
                  if (t.name.trim().toLowerCase().startsWith('demo ')) return false;
                  return true;
                }).isEmpty &&
                !controller.isLoadingTerritories &&
                controller.capturePhase == CapturePhase.idle)
              Padding(
                padding: EdgeInsets.only(top: topPadding + 8),
                child: const MapEmptyTerritoriesCard(),
              ),
            if (controller.permissionState == LocationPermissionState.granted)
              MapFloatingControls(
                controller: controller,
                isLocating: _isLocatingUser,
                onLocateMe: _locateUserWithFeedback,
                onLeaderboard: _openLeaderboard,
                onStartCapture: _startCapture,
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
                onViewOwnerProfile: controller.selectedTerritory!.isOwnedByCurrentUser
                    ? null
                    : () => _openOwnerProfile(controller.selectedTerritory!),
              ),
            Positioned(
              left: 16,
              top: topPadding + 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(PremiumRadii.lg),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Text(
                    l10n.mapTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: PremiumColors.midnightMid,
                          letterSpacing: -0.3,
                        ),
                  ),
                ),
              ),
            ),
          ],
          ),
        );
      },
    );
  }
}