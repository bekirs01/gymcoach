import 'package:flutter/material.dart';

import '../../social/data/social_seed_data.dart';
import '../../social/domain/feed_media.dart';
import 'profile_image_assets.dart';
import 'profile_media_filter.dart';
import 'user_profile.dart';

abstract final class ProfileImagePrecache {
  static Future<void> warm({
    required BuildContext context,
    required UserProfile profile,
    Iterable<FeedMedia> extraMedia = const [],
  }) async {
    if (!context.mounted) return;

    final urls = <String>{};

    void addUrl(String? raw) {
      final trimmed = raw?.trim() ?? '';
      if (ProfileMediaFilter.isValidMediaUrl(trimmed)) {
        urls.add(trimmed);
      }
    }

    addUrl(ProfileMediaFilter.resolveImageUrl(primary: profile.coverUrl, fallback: ''));
    addUrl(ProfileMediaFilter.resolveImageUrl(primary: profile.avatarUrl, fallback: ''));

    final seedPhotos = SocialSeedRepository.photosForUser(
      SocialSeedRepository.currentUserId,
      currentProfile: profile,
    );
    for (final media in seedPhotos) {
      addUrl(media.url);
    }
    for (final media in extraMedia) {
      addUrl(media.url);
    }

    final futures = <Future<void>>[
      for (final url in urls)
        precacheImage(NetworkImage(url), context).catchError((_) {}),
      precacheImage(const AssetImage(ProfileImageAssets.defaultMaleAvatar), context).catchError((_) {}),
      precacheImage(const AssetImage(ProfileImageAssets.defaultProfileCover), context).catchError((_) {}),
    ];

    await Future.wait(futures);
  }
}
