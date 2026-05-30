import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../../../app/widgets/floating_tab_bar.dart';
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

    final bottomOffset = FloatingTabBar.reservedBottomSpace(context) + 8;

    return Positioned(
      right: 16,
      bottom: bottomOffset,
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
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onStartCapture,
            icon: const Icon(Icons.route_rounded, size: 18),
            label: Text(l10n.mapStartCapture),
            style: FilledButton.styleFrom(
              backgroundColor: PremiumColors.accentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PremiumRadii.lg),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
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
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: PremiumColors.surfaceRaised.withValues(alpha: 0.94),
        border: Border.all(
          color: highlighted
              ? PremiumColors.accentBlue.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: muted
              ? PremiumColors.textMuted
              : highlighted
                  ? PremiumColors.accentBlue
                  : PremiumColors.textPrimary,
        ),
      ),
    );
  }
}
