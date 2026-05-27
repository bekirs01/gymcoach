import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../../app/theme/app_colors.dart';
import '../../services/location_permission_service.dart';

class MapPermissionCard extends StatelessWidget {
  const MapPermissionCard({
    super.key,
    required this.state,
    required this.onRequestPermission,
    required this.onOpenSettings,
  });

  final LocationPermissionState state;
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    final isDeniedForever = state == LocationPermissionState.deniedForever;
    final isServiceDisabled = state == LocationPermissionState.serviceDisabled;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off_rounded,
                size: 40,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.mapPermissionTitle,
                textAlign: TextAlign.center,
                style: theme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isServiceDisabled ? l10n.mapPermissionServiceDisabled : l10n.mapPermissionBody,
                textAlign: TextAlign.center,
                style: theme.bodyMedium?.copyWith(color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isDeniedForever || isServiceDisabled ? onOpenSettings : onRequestPermission,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(isDeniedForever || isServiceDisabled ? l10n.mapOpenSettings : l10n.mapAllowLocation),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapEmptyTerritoriesCard extends StatelessWidget {
  const MapEmptyTerritoriesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Text(
            l10n.mapEmptyTerritories,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
