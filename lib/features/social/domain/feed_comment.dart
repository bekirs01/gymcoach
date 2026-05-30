import 'social_profile.dart';

class FeedComment {
  const FeedComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.body,
    required this.createdAt,
    required this.author,
  });

  final String id;
  final String postId;
  final String userId;
  final String body;
  final DateTime createdAt;
  final SocialProfile author;

  factory FeedComment.fromRow(Map<String, dynamic> row) {
    final profile = row['author'] as Map<String, dynamic>? ?? row['profiles'] as Map<String, dynamic>?;
    return FeedComment(
      id: row['id'] as String? ?? '',
      postId: row['post_id'] as String? ?? '',
      userId: row['user_id'] as String? ?? '',
      body: row['body'] as String? ?? '',
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
      author: SocialProfile.fromRow(profile ?? {'id': row['user_id']}),
    );
  }
}
