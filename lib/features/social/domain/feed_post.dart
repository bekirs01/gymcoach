import '../../workout_share/domain/feed_post_type.dart';
import '../../workout_share/domain/shared_workout_snapshot.dart';
import 'feed_comment.dart';
import 'feed_media.dart';
import 'social_profile.dart';

class FeedPost {
  const FeedPost({
    required this.id,
    required this.userId,
    required this.caption,
    required this.createdAt,
    required this.author,
    required this.media,
    required this.comments,
    required this.likeCount,
    required this.commentCount,
    required this.likedByMe,
    this.postType = FeedPostType.normal,
    this.sharedWorkoutSnapshot,
  });

  final String id;
  final String userId;
  final String caption;
  final DateTime createdAt;
  final SocialProfile author;
  final List<FeedMedia> media;
  final List<FeedComment> comments;
  final int likeCount;
  final int commentCount;
  final bool likedByMe;
  final FeedPostType postType;
  final SharedWorkoutSnapshot? sharedWorkoutSnapshot;

  bool get isWorkoutShare => postType == FeedPostType.workoutShare;

  FeedPost copyWith({
    String? id,
    String? userId,
    String? caption,
    DateTime? createdAt,
    SocialProfile? author,
    List<FeedMedia>? media,
    List<FeedComment>? comments,
    int? likeCount,
    int? commentCount,
    bool? likedByMe,
    FeedPostType? postType,
    SharedWorkoutSnapshot? sharedWorkoutSnapshot,
  }) {
    return FeedPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
      media: media ?? this.media,
      comments: comments ?? this.comments,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      likedByMe: likedByMe ?? this.likedByMe,
      postType: postType ?? this.postType,
      sharedWorkoutSnapshot: sharedWorkoutSnapshot ?? this.sharedWorkoutSnapshot,
    );
  }

  factory FeedPost.fromRow(Map<String, dynamic> row, String currentUserId) {
    final mediaRows = row['feed_post_media'] as List<dynamic>? ?? const [];
    final commentsRows = row['feed_comments'] as List<dynamic>? ?? const [];
    final likeRows = row['feed_likes'] as List<dynamic>? ?? const [];
    final authorRow = row['author'] as Map<String, dynamic>? ?? row['profiles'] as Map<String, dynamic>?;
    final media = mediaRows
        .map((e) => FeedMedia.fromRow(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final comments = commentsRows
        .map((e) => FeedComment.fromRow(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final postType = FeedPostType.fromWire(row['post_type'] as String?);
    SharedWorkoutSnapshot? sharedWorkoutSnapshot;
    final snapshotRaw = row['shared_workout_snapshot'];
    if (snapshotRaw is Map) {
      sharedWorkoutSnapshot = SharedWorkoutSnapshot.fromJson(Map<String, dynamic>.from(snapshotRaw));
    }

    return FeedPost(
      id: row['id'] as String? ?? '',
      userId: row['user_id'] as String? ?? '',
      caption: row['caption'] as String? ?? '',
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
      author: SocialProfile.fromRow(authorRow ?? {'id': row['user_id']}),
      media: media,
      comments: comments,
      likeCount: likeRows.length,
      commentCount: comments.length,
      likedByMe: likeRows.any((e) => (e as Map)['user_id'] == currentUserId),
      postType: postType,
      sharedWorkoutSnapshot: sharedWorkoutSnapshot,
    );
  }
}
