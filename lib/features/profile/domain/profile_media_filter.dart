import '../../social/domain/feed_media.dart';
import '../../social/domain/feed_post.dart';
import 'profile_defaults.dart';

abstract final class ProfileMediaFilter {
  static bool isValidMediaUrl(String? url) {
    final trimmed = url?.trim() ?? '';
    if (trimmed.isEmpty) return false;
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return false;
    }
    return true;
  }

  static bool isDeletedPost(FeedPost post) => post.deletedAt != null;

  static bool isLegacySavedAuthor(FeedPost post) {
    final name = post.author.displayName.trim();
    return name == ProfileDefaults.legacyDisplayName;
  }

  static bool isVisiblePost(FeedPost post) {
    if (isDeletedPost(post)) return false;
    if (post.id.trim().isEmpty) return false;
    if (post.isWorkoutShare && post.sharedWorkoutSnapshot != null) return true;

    final media = visibleMedia(post.media);
    final hasCaption = post.caption.trim().isNotEmpty;
    if (media.isNotEmpty) return true;
    if (post.media.isNotEmpty) return false;
    return hasCaption;
  }

  static List<FeedMedia> visibleMedia(Iterable<FeedMedia> media) {
    final seen = <String>{};
    final result = <FeedMedia>[];
    for (final item in media) {
      final url = item.url.trim();
      if (!isValidMediaUrl(url) || seen.contains(url)) continue;
      seen.add(url);
      result.add(item);
    }
    return result;
  }

  static List<FeedPost> visiblePosts(Iterable<FeedPost> posts) {
    return posts
        .map(
          (post) => post.copyWith(
            media: visibleMedia(post.media),
          ),
        )
        .where(isVisiblePost)
        .toList();
  }

  static List<FeedPost> enrichProfilePosts(
    List<FeedPost> apiPosts,
    List<FeedPost> seedPosts,
  ) {
    final seedById = {for (final post in seedPosts) post.id: post};
    final seedByCaption = <String, FeedPost>{};
    for (final post in seedPosts) {
      final key = post.caption.trim().toLowerCase();
      if (key.isNotEmpty) seedByCaption[key] = post;
    }

    return apiPosts.map((post) {
      if (isDeletedPost(post)) return post;

      var media = visibleMedia(post.media);
      if (media.isNotEmpty) return post.copyWith(media: media);

      final seedMatch = seedById[post.id] ?? seedByCaption[post.caption.trim().toLowerCase()];
      if (seedMatch != null) {
        media = visibleMedia(seedMatch.media);
        if (media.isNotEmpty) {
          return post.copyWith(media: media);
        }
      }

      return post.copyWith(media: media);
    }).toList();
  }

  static List<FeedPost> reconcileSavedPosts(
    List<FeedPost> saved,
    List<FeedPost> liveFeed,
  ) {
    final liveById = {for (final post in liveFeed) post.id: post};
    final result = <FeedPost>[];

    for (final item in saved) {
      if (isDeletedPost(item)) continue;
      if (isLegacySavedAuthor(item)) continue;

      final live = liveById[item.id];
      if (live != null) {
        if (isDeletedPost(live)) continue;
        final merged = enrichProfilePosts([live], [item]).first;
        if (isVisiblePost(merged)) result.add(merged);
        continue;
      }

      if (item.id.startsWith('seed_post_')) {
        final visible = visiblePosts([item]);
        if (visible.isNotEmpty) result.add(visible.first);
        continue;
      }

      if (item.id.startsWith('post_')) continue;

      final visible = visiblePosts([item]);
      if (visible.isNotEmpty && visible.first.media.isNotEmpty) {
        result.add(visible.first);
      }
    }

    return result;
  }

  static List<FeedPost> visibleSavedPosts(
    List<FeedPost> saved, {
    List<FeedPost> liveFeed = const [],
  }) {
    return visiblePosts(reconcileSavedPosts(saved, liveFeed));
  }

  static String resolveImageUrl({
    required String primary,
    required String fallback,
  }) {
    if (isValidMediaUrl(primary)) return primary.trim();
    if (isValidMediaUrl(fallback)) return fallback.trim();
    return '';
  }

  static List<FeedMedia> profileGallery({
    required List<FeedMedia> apiMedia,
    required List<FeedMedia> seedMedia,
    int minPhotos = 3,
  }) {
    final merged = visibleMedia([...apiMedia, ...seedMedia]);
    if (merged.length >= minPhotos) return merged;
    return visibleMedia([...merged, ...seedMedia]);
  }
}
