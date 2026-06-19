import 'dart:typed_data';

class StoryUser {
  const StoryUser({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    this.fallbackName = '',
    this.isCurrentUser = false,
  });

  final String id;
  final String displayName;
  final String avatarUrl;
  final String fallbackName;
  final bool isCurrentUser;

  String get avatarLabel => fallbackName.isNotEmpty ? fallbackName : displayName;
}

class FeedStorySlide {
  const FeedStorySlide({
    this.imageUrl,
    this.imageBytes,
  });

  final String? imageUrl;
  final Uint8List? imageBytes;

  bool get hasContent => (imageUrl != null && imageUrl!.isNotEmpty) || imageBytes != null;
}

class FeedStory {
  const FeedStory({
    required this.id,
    required this.user,
    required this.slides,
    this.latestAt,
  });

  final String id;
  final StoryUser user;
  final List<FeedStorySlide> slides;
  final DateTime? latestAt;

  bool get hasSlides => slides.any((slide) => slide.hasContent);

  FeedStory copyWithUser(StoryUser user) {
    return FeedStory(
      id: id,
      user: user,
      slides: slides,
      latestAt: latestAt,
    );
  }

  static FeedStory fromStoryRows(
    String userId,
    StoryUser user,
    List<Map<String, dynamic>> rows,
  ) {
    final slides = rows
        .map(
          (row) => FeedStorySlide(
            imageUrl: row['media_url'] as String?,
          ),
        )
        .where((slide) => slide.hasContent)
        .toList();
    DateTime? latestAt;
    for (final row in rows) {
      final createdAt = DateTime.tryParse(row['created_at'] as String? ?? '');
      if (createdAt == null) continue;
      if (latestAt == null || createdAt.isAfter(latestAt)) {
        latestAt = createdAt;
      }
    }
    return FeedStory(
      id: 'story_$userId',
      user: user,
      slides: slides,
      latestAt: latestAt,
    );
  }

  static StoryUser storyUserFromAuthor(
    Map<String, dynamic>? author,
    String userId, {
    required bool isCurrentUser,
  }) {
    return StoryUser(
      id: userId,
      displayName: isCurrentUser ? 'Your story' : (author?['display_name'] as String? ?? ''),
      avatarUrl: author?['avatar_url'] as String? ?? '',
      fallbackName: author?['display_name'] as String? ?? '',
      isCurrentUser: isCurrentUser,
    );
  }
}
