import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../domain/profile_image_assets.dart';
import '../../domain/profile_media_filter.dart';

class ProfileCoverImage extends StatelessWidget {
  const ProfileCoverImage({
    super.key,
    required this.coverUrl,
    this.height = 132,
    this.darkenAlpha = 0.25,
    this.networkFallbackUrl,
  });

  final String coverUrl;
  final double height;
  final double darkenAlpha;
  final String? networkFallbackUrl;

  @override
  Widget build(BuildContext context) {
    final networkUrl = ProfileMediaFilter.resolveImageUrl(
      primary: coverUrl,
      fallback: networkFallbackUrl ?? '',
    );

    return SizedBox(
      height: height,
      width: double.infinity,
      child: networkUrl.isNotEmpty
          ? Image.network(
              networkUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: height,
              gaplessPlayback: true,
              color: Colors.black.withValues(alpha: darkenAlpha),
              colorBlendMode: BlendMode.darken,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) return child;
                return _assetCover();
              },
              errorBuilder: (context, error, stackTrace) => _assetCover(),
            )
          : _assetCover(),
    );
  }

  Widget _assetCover() {
    return Image.asset(
      ProfileImageAssets.defaultProfileCover,
      fit: BoxFit.cover,
      width: double.infinity,
      height: height,
      color: Colors.black.withValues(alpha: darkenAlpha),
      colorBlendMode: BlendMode.darken,
      errorBuilder: (context, error, stackTrace) {
        return ColoredBox(
          color: PremiumColors.surface,
          child: SizedBox(height: height, width: double.infinity),
        );
      },
    );
  }
}
