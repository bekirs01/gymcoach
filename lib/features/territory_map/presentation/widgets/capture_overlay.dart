import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../../../app/widgets/floating_tab_bar.dart';
import '../../config/territory_config.dart';
import '../territory_formatters.dart';
import '../territory_map_controller.dart';

class CaptureOverlay extends StatelessWidget {
  const CaptureOverlay({
    super.key,
    required this.controller,
    required this.onFinish,
    required this.onCancel,
  });

  final TerritoryMapController controller;
  final VoidCallback onFinish;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomOffset = FloatingTabBar.reservedBottomSpace(context) + 12;
    final points = controller.capturePoints.length;
    final minPoints = TerritoryConfig.minCapturePoints;
    final minArea = TerritoryConfig.minAreaSquareMeters;
    final areaProgress = (controller.estimatedAreaSquareMeters / minArea).clamp(0.0, 1.0);

    return Positioned(
      left: 16,
      right: 16,
      bottom: bottomOffset,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (controller.poorGpsWarning)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3D2A14),
                borderRadius: BorderRadius.circular(PremiumRadii.md),
                border: Border.all(color: const Color(0xFFB87333).withValues(alpha: 0.45)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gps_off_rounded, color: Color(0xFFFFB74D), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.mapGpsAccuracyWarning,
                      style: const TextStyle(color: Color(0xFFFFE0B2), fontSize: 13, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PremiumColors.surfaceRaised.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(PremiumRadii.xl),
              border: Border.all(color: PremiumColors.accentBlue.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _RecordingDot(isActive: true),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.mapCaptureActive,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      TerritoryFormatters.duration(controller.elapsed),
                      style: const TextStyle(
                        color: PremiumColors.accentBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _StatTile(
                      label: l10n.mapDistance,
                      value: TerritoryFormatters.distance(controller.routeDistanceMeters),
                    ),
                    const SizedBox(width: 8),
                    _StatTile(
                      label: l10n.mapEstimatedArea,
                      value: TerritoryFormatters.area(controller.estimatedAreaSquareMeters),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatTile(
                      label: l10n.mapLabelGps,
                      value: '${controller.latestAccuracyMeters.round()} m',
                    ),
                    const SizedBox(width: 8),
                    _StatTile(
                      label: l10n.mapLabelPoints,
                      value: '$points / $minPoints',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(PremiumRadii.pill),
                  child: LinearProgressIndicator(
                    value: areaProgress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    color: PremiumColors.accentBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  controller.isLoopClosed
                      ? l10n.mapLoopClosed
                      : 'Close the loop to capture at least ${TerritoryFormatters.area(minArea)}.',
                  style: TextStyle(
                    color: controller.isLoopClosed ? const Color(0xFF86EFAC) : PremiumColors.textMuted,
                    fontSize: 11,
                    height: 1.35,
                    fontWeight: controller.isLoopClosed ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PremiumColors.textSecondary,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(PremiumRadii.md),
                          ),
                        ),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: onFinish,
                        style: FilledButton.styleFrom(
                          backgroundColor: PremiumColors.accentBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(PremiumRadii.md),
                          ),
                        ),
                        child: Text(l10n.mapFinishCapture),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: PremiumColors.surface,
          borderRadius: BorderRadius.circular(PremiumRadii.md),
          border: Border.all(color: PremiumColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: PremiumColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordingDot extends StatefulWidget {
  const _RecordingDot({required this.isActive});

  final bool isActive;

  @override
  State<_RecordingDot> createState() => _RecordingDotState();
}

class _RecordingDotState extends State<_RecordingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox(width: 12, height: 12);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: PremiumColors.accentBlue.withValues(alpha: 0.55 + (_controller.value * 0.45)),
            boxShadow: [
              BoxShadow(
                color: PremiumColors.accentBlue.withValues(alpha: 0.25 + (_controller.value * 0.35)),
                blurRadius: 8 + (_controller.value * 6),
              ),
            ],
          ),
        );
      },
    );
  }
}
