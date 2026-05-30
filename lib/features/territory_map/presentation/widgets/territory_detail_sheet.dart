import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../../../app/widgets/floating_tab_bar.dart';
import '../../domain/territory.dart';
import '../territory_formatters.dart';

class TerritoryDetailSheet extends StatelessWidget {
  const TerritoryDetailSheet({
    super.key,
    required this.territory,
    required this.onClose,
    required this.onZoom,
  });

  final Territory territory;
  final VoidCallback onClose;
  final VoidCallback onZoom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomOffset = FloatingTabBar.reservedBottomSpace(context) + 12;

    return Positioned(
      left: 16,
      right: 16,
      bottom: bottomOffset,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 12, 18),
          decoration: BoxDecoration(
            color: PremiumColors.surfaceRaised.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(PremiumRadii.xl),
            border: Border.all(
              color: territory.isOwnedByCurrentUser
                  ? PremiumColors.accentBlue.withValues(alpha: 0.45)
                  : PremiumColors.glassBorder,
              width: territory.isOwnedByCurrentUser ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.32),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OwnerAvatar(territory: territory),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          territory.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          territory.ownerDisplayName,
                          style: const TextStyle(
                            color: PremiumColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded, color: PremiumColors.textSecondary),
                  ),
                ],
              ),
              if (territory.isOwnedByCurrentUser) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: PremiumColors.accentBlue.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(PremiumRadii.pill),
                    border: Border.all(color: PremiumColors.accentBlue.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    l10n.mapMyTerritory,
                    style: const TextStyle(
                      color: PremiumColors.accentBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  _StatChip(
                    label: l10n.mapArea,
                    value: TerritoryFormatters.area(territory.areaSquareMeters),
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: l10n.mapCapturedOn,
                    value: TerritoryFormatters.date(territory.capturedAt),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onZoom,
                  style: FilledButton.styleFrom(
                    backgroundColor: PremiumColors.accentBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(PremiumRadii.md),
                    ),
                  ),
                  child: Text(l10n.mapZoomToTerritory),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerAvatar extends StatelessWidget {
  const _OwnerAvatar({required this.territory});

  final Territory territory;

  @override
  Widget build(BuildContext context) {
    final url = territory.ownerAvatarUrl.trim();
    if (url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _InitialsBadge(name: territory.ownerDisplayName),
        ),
      );
    }
    return _InitialsBadge(name: territory.ownerDisplayName);
  }
}

class _InitialsBadge extends StatelessWidget {
  const _InitialsBadge({required this.name});

  final String name;

  static String _initials(String raw) {
    final parts = raw.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return p.length >= 2 ? p.substring(0, 2).toUpperCase() : p.toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PremiumColors.accentBlue, PremiumColors.accentBlueSoft],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        _initials(name),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

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
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
