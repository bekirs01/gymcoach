import '../../social/domain/feed_media.dart';
import '../../social/domain/feed_post.dart';

abstract final class ProfileMediaFilter {
  static bool isValidMediaUrl(String? url) {
    final trimmed = url?.trim() ?? '';
    if (trimmed.isEmpty) return false;
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return false;
    }
    return true;
  }

  static bool isVisiblePost(FeedPost post) {
    if (post.id.trim().isEmpty) return false;
    final hasCaption = post.caption.trim().isNotEmpty;
    final hasMedia = post.media.any((item) => isValidMediaUrl(item.url));
    final hasWorkoutShare = post.isWorkoutShare && post.sharedWorkoutSnapshot != null;
    return hasCaption || hasMedia || hasWorkoutShare;
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
