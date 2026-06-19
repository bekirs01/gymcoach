import '../../profile/domain/user_profile.dart';
import '../../social/data/social_seed_data.dart';
import '../../social/domain/feed_post.dart';
import '../domain/feed_story.dart';

class DemoFeedPost {
  DemoFeedPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.avatarUrl,
    required this.imageUrl,
    required this.caption,
    required this.timeLabel,
    this.likeCount = 1,
    this.commentCount = 0,
    this.liked = false,
    this.saved = false,
  });

  final String id;
  final String userId;
  final String userName;
  final String avatarUrl;
  final String imageUrl;
  final String caption;
  final String timeLabel;
  final int likeCount;
  final int commentCount;
  bool liked;
  bool saved;

  DemoFeedPost copyWith({
    int? likeCount,
    int? commentCount,
    bool? liked,
    bool? saved,
  }) {
    return DemoFeedPost(
      id: id,
      userId: userId,
      userName: userName,
      avatarUrl: avatarUrl,
      imageUrl: imageUrl,
      caption: caption,
      timeLabel: timeLabel,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      liked: liked ?? this.liked,
      saved: saved ?? this.saved,
    );
  }
}

abstract final class FeedDemoData {
  static List<FeedStory> demoStories() => SocialSeedRepository.demoStories();

  static StoryUser ownStoryUser({
    required String displayName,
    required String avatarUrl,
  }) {
    return StoryUser(
      id: SocialSeedRepository.currentUserId,
      displayName: 'Your story',
      avatarUrl: avatarUrl,
      fallbackName: displayName,
      isCurrentUser: true,
    );
  }

  static List<DemoFeedPost> initialPosts({UserProfile? currentProfile}) {
    return SocialSeedRepository.allFeedPosts(currentProfile: currentProfile).map(_fromFeedPost).toList();
  }

  static List<DemoFeedPost> refreshPosts(List<DemoFeedPost> current, {UserProfile? currentProfile}) {
    final freshPost = SocialSeedRepository.refreshPost();
    return [_fromFeedPost(freshPost), ...current];
  }

  static DemoFeedPost _fromFeedPost(FeedPost post) {
    return DemoFeedPost(
      id: post.id,
      userId: post.userId,
      userName: post.author.displayName,
      avatarUrl: post.author.avatarUrl,
      imageUrl: post.media.isNotEmpty ? post.media.first.url : '',
      caption: post.caption,
      timeLabel: _timeLabel(post.createdAt),
      likeCount: post.likeCount,
      commentCount: post.commentCount,
    );
  }

  static String _timeLabel(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inHours < 48) return 'yesterday';
    return '${diff.inDays}d ago';
  }
}
