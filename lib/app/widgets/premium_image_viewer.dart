import 'package:flutter/material.dart';

/// Full-screen pinch-to-zoom image viewer with fade transition.
Future<void> showPremiumImageViewer(
  BuildContext context, {
  required String imageUrl,
  String? heroTag,
}) {
  if (imageUrl.trim().isEmpty) return Future.value();
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.94),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _PremiumImageViewer(imageUrl: imageUrl, heroTag: heroTag);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _PremiumImageViewer extends StatelessWidget {
  const _PremiumImageViewer({required this.imageUrl, this.heroTag});

  final String imageUrl;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      imageUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 56);
      },
    );

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.6,
                  maxScale: 4.5,
                  child: heroTag == null
                      ? image
                      : Hero(tag: heroTag!, child: image),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
