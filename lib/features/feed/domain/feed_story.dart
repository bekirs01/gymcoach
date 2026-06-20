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
    this.localPath,
  });

  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? localPath;

  bool get hasContent =>
      (imageUrl != null && imageUrl!.isNotEmpty) ||
      imageBytes != null ||
      (localPath != null && localPath!.isNotEmpty);
}

class FeedStory {
  const FeedStory({
    required this.id,
    required this.user,
    required this.slides,
    this.latestAt,
    this.localId,
    this.isPendingUpload = false,
    this.uploadFailed = false,
  });

  final String id;
  final StoryUser user;
  final List<FeedStorySlide> slides;
  final DateTime? latestAt;
  final String? localId;
  final bool isPendingUpload;
  final bool uploadFailed;

  bool get hasSlides => slides.any((slide) => slide.hasContent);

  FeedStory copyWith({
    String? id,
    StoryUser? user,
    List<FeedStorySlide>? slides,
    DateTime? latestAt,
    String? localId,
    bool? isPendingUpload,
    bool? uploadFailed,
  }) {
    return FeedStory(
      id: id ?? this.id,
      user: user ?? this.user,
      slides: slides ?? this.slides,
      latestAt: latestAt ?? this.latestAt,
      localId: localId ?? this.localId,
      isPendingUpload: isPendingUpload ?? this.isPendingUpload,
      uploadFailed: uploadFailed ?? this.uploadFailed,
    );
  }

  FeedStory copyWithUser(StoryUser user) => copyWith(user: user);

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
