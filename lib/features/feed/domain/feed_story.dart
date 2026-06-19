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
  });

  final String id;
  final StoryUser user;
  final List<FeedStorySlide> slides;

  bool get hasSlides => slides.any((slide) => slide.hasContent);
}
