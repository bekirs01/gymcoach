import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../presentation/social_avatar.dart';
import 'network_image_with_fallback.dart';

class StoryAvatar extends StatelessWidget {
  const StoryAvatar({
    super.key,
    required this.label,
    required this.avatarUrl,
    this.fallbackName = '',
    this.isOwnStory = false,
    this.hasUnseenStory = true,
    this.onTap,
  });

  static const double itemWidth = 88;
  static const double itemHeight = 112;
  static const double avatarSize = 68;

  final String label;
  final String avatarUrl;
  final String fallbackName;
  final bool isOwnStory;
  final bool hasUnseenStory;
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

  static const _seenRingColor = PremiumColors.textMuted;

  @override
  Widget build(BuildContext context) {
    final innerSize = avatarSize - 8;
    final name = fallbackName.isNotEmpty ? fallbackName : label;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: itemWidth,
        height: itemHeight,
        child: Column(
          children: [
            SizedBox(
              width: avatarSize,
              height: avatarSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: hasUnseenStory ? _ringGradient : null,
                      color: hasUnseenStory ? null : _seenRingColor.withValues(alpha: 0.35),
                      border: hasUnseenStory
                          ? null
                          : Border.all(color: _seenRingColor.withValues(alpha: 0.5), width: 2),
                      boxShadow: hasUnseenStory
                          ? const [
                              BoxShadow(
                                color: Color(0x336B8FC7),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: PremiumColors.midnightTop,
                      ),
                      child: ClipOval(
                        child: avatarUrl.trim().isNotEmpty
                            ? NetworkImageWithFallback(
                                url: avatarUrl,
                                width: innerSize,
                                height: innerSize,
                                fit: BoxFit.cover,
                                placeholderIcon: Icons.person_outline_rounded,
                              )
                            : SocialAvatar(name: name, imageUrl: '', size: innerSize),
                      ),
                    ),
                  ),
                  if (isOwnStory)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 20,
                        height: 20,
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
                        child: const Icon(Icons.add_rounded, size: 13, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: itemWidth,
              height: 14,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: PremiumColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
