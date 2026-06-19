import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';

class ExerciseHeroCard extends StatelessWidget {
  const ExerciseHeroCard({
    super.key,
    required this.imageAsset,
    required this.label,
    this.onExpand,
  });

  final String? imageAsset;
  final String label;
  final VoidCallback? onExpand;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: PremiumColors.accentBlue.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageAsset == null)
              _FallbackContent(label: label)
            else
              _HeroImage(asset: imageAsset!, label: label),
            if (onExpand != null)
              Positioned(
                right: 10,
                bottom: 10,
                child: Material(
                  color: PremiumColors.surfaceRaised.withValues(alpha: 0.92),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onExpand,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.open_in_full_rounded,
                        color: PremiumColors.accentBlue,
                        size: 18,
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

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) => _FallbackContent(label: label),
      ),
    );
  }
}

class _FallbackContent extends StatelessWidget {
  const _FallbackContent({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_rounded,
            color: PremiumColors.accentBlue.withValues(alpha: 0.9),
            size: 48,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: PremiumColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
