import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../../app/theme/app_colors.dart';
import '../territory_map_controller.dart';

class MapFloatingControls extends StatelessWidget {
  const MapFloatingControls({
    super.key,
    required this.controller,
    required this.onLocateMe,
    required this.onLeaderboard,
    required this.onStartCapture,
    required this.onSatelliteUnavailable,
    this.isLocating = false,
  });

  final TerritoryMapController controller;
  final VoidCallback onLocateMe;
  final VoidCallback onLeaderboard;
  final VoidCallback onStartCapture;
  final VoidCallback onSatelliteUnavailable;
  final bool isLocating;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCapturing = controller.capturePhase == CapturePhase.capturing;
    if (isCapturing) return const SizedBox.shrink();

    return Positioned(
      right: 16,
      bottom: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _RoundMapButton(
            icon: isLocating ? Icons.gps_fixed_rounded : Icons.my_location_rounded,
            tooltip: l10n.mapLocateMe,
            onPressed: isLocating ? null : onLocateMe,
            highlighted: true,
          ),
          const SizedBox(height: 10),
          _RoundMapButton(
            icon: Icons.satellite_alt_rounded,
            tooltip: l10n.mapModeSatellite,
            onPressed: onSatelliteUnavailable,
            muted: true,
          ),
          const SizedBox(height: 10),
          _RoundMapButton(
            icon: Icons.leaderboard_rounded,
            tooltip: l10n.mapLeaderboard,
            onPressed: onLeaderboard,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onStartCapture,
            icon: const Icon(Icons.route_rounded),
            label: Text(l10n.mapStartCapture),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundMapButton extends StatelessWidget {
  const _RoundMapButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.muted = false,
    this.highlighted = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool muted;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surface,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: muted
              ? AppColors.textMuted
              : highlighted
                  ? AppColors.primaryDark
                  : AppColors.primary,
        ),
      ),
    );
  }
}
