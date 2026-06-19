import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';

class NetworkImageWithFallback extends StatelessWidget {
  const NetworkImageWithFallback({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholderIcon = Icons.image_outlined,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final child = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _Placeholder(
          width: width,
          height: height,
          icon: placeholderIcon,
          showSpinner: true,
          progress: loadingProgress.expectedTotalBytes == null
              ? null
              : loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!,
        );
      },
      errorBuilder: (context, error, stackTrace) => _Placeholder(
        width: width,
        height: height,
        icon: Icons.broken_image_outlined,
      ),
    );

    if (borderRadius == null) return child;

    return ClipRRect(
      borderRadius: borderRadius!,
      child: child,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.width,
    required this.height,
    required this.icon,
    this.showSpinner = false,
    this.progress,
  });

  final double? width;
  final double? height;
  final IconData icon;
  final bool showSpinner;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumColors.surfaceRaised,
            PremiumColors.midnightBottom,
          ],
        ),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      alignment: Alignment.center,
      child: showSpinner
          ? SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: PremiumColors.accentBlue.withValues(alpha: 0.7),
                value: progress,
              ),
            )
          : Icon(icon, color: PremiumColors.textMuted, size: 28),
    );
  }
}
