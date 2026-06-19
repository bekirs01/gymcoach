import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../app/theme/premium_tokens.dart';

class ChatImageViewerScreen extends StatelessWidget {
  const ChatImageViewerScreen({
    super.key,
    this.imageUrl,
    this.imageBytes,
  });

  final String? imageUrl;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 3,
                child: _ImageContent(imageUrl: imageUrl, imageBytes: imageBytes),
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: Material(
                color: Colors.black.withValues(alpha: 0.45),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(Icons.close_rounded, color: Colors.white),
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

class _ImageContent extends StatelessWidget {
  const _ImageContent({
    required this.imageUrl,
    required this.imageBytes,
  });

  final String? imageUrl;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null) {
      return Image.memory(imageBytes!, fit: BoxFit.contain);
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(strokeWidth: 2, color: PremiumColors.accentBlue),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image_outlined, color: PremiumColors.textMuted, size: 48);
        },
      );
    }

    return const Icon(Icons.image_not_supported_outlined, color: PremiumColors.textMuted, size: 48);
  }
}
