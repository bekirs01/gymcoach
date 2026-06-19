import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';
import 'network_image_with_fallback.dart';

class StoryAvatar extends StatelessWidget {
  const StoryAvatar({
    super.key,
    required this.label,
    required this.avatarUrl,
    this.isOwnStory = false,
    this.size = 68,
    this.onTap,
  });

  final String label;
  final String avatarUrl;
  final bool isOwnStory;
  final double size;
  final VoidCallback? onTap;

  static const _ringGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7BA4E0),
      PremiumColors.accentBlue,
      Color(0xFF4A6FA5),
      Color(0xFF8CB4F0),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final innerSize = size - 6;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size + 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: size,
                  height: size,
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _ringGradient,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x336B8FC7),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: PremiumColors.midnightTop,
                    ),
                    child: ClipOval(
                      child: NetworkImageWithFallback(
                        url: avatarUrl,
                        width: innerSize,
                        height: innerSize,
                        fit: BoxFit.cover,
                        placeholderIcon: Icons.person_outline_rounded,
                      ),
                    ),
                  ),
                ),
                if (isOwnStory)
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: PremiumColors.accentBlue,
                        border: Border.all(color: PremiumColors.midnightTop, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: PremiumColors.accentBlue.withValues(alpha: 0.45),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: PremiumColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
