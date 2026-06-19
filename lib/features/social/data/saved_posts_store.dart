import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/feed_media.dart';
import '../domain/feed_post.dart';
import '../domain/social_profile.dart';
import '../../workout_share/domain/feed_post_type.dart';
import '../../workout_share/domain/shared_workout_snapshot.dart';

/// Local persistence for bookmarked feed posts.
final class SavedPostsStore {
  SavedPostsStore(this._prefs);

  static const _key = 'saved_feed_posts_v1';

  final SharedPreferences _prefs;

  List<FeedPost> loadAll() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => _postFromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  bool isSaved(String postId) {
    return loadAll().any((p) => p.id == postId);
  }

  Future<void> save(FeedPost post) async {
    final posts = loadAll().where((p) => p.id != post.id).toList();
    posts.insert(0, post);
    await _prefs.setString(_key, jsonEncode(posts.map(_postToJson).toList()));
  }

  Future<void> remove(String postId) async {
    final posts = loadAll().where((p) => p.id != postId).toList();
    await _prefs.setString(_key, jsonEncode(posts.map(_postToJson).toList()));
  }

  Future<void> replaceAll(List<FeedPost> posts) async {
    await _prefs.setString(_key, jsonEncode(posts.map(_postToJson).toList()));
  }

  Future<bool> toggle(FeedPost post) async {
    if (isSaved(post.id)) {
      await remove(post.id);
      return false;
    }
    await save(post);
    return true;
  }

  static Map<String, dynamic> _postToJson(FeedPost post) {
    return {
      'id': post.id,
      'user_id': post.userId,
      'caption': post.caption,
      'created_at': post.createdAt.toIso8601String(),
      'like_count': post.likeCount,
      'comment_count': post.commentCount,
      'liked_by_me': post.likedByMe,
      'post_type': post.postType.wireValue,
      'shared_workout_snapshot': post.sharedWorkoutSnapshot?.toJson(),
      'author': {
        'id': post.author.userId,
        'display_name': post.author.displayName,
        'avatar_url': post.author.avatarUrl,
        'cover_url': post.author.coverUrl,
      },
      'media': post.media
          .map(
            (m) => {
              'id': m.id,
              'post_id': m.postId,
              'media_url': m.url,
              'media_path': m.path,
              'sort_order': m.sortOrder,
            },
          )
          .toList(),
    };
  }

  static FeedPost _postFromJson(Map<String, dynamic> json) {
    final authorJson = json['author'] as Map<String, dynamic>? ?? const {};
    final mediaRows = json['media'] as List<dynamic>? ?? const [];
    SharedWorkoutSnapshot? sharedWorkoutSnapshot;
    final snapshotRaw = json['shared_workout_snapshot'];
    if (snapshotRaw is Map) {
      sharedWorkoutSnapshot = SharedWorkoutSnapshot.fromJson(Map<String, dynamic>.from(snapshotRaw));
    }
    return FeedPost(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      author: SocialProfile(
        userId: authorJson['id'] as String? ?? '',
        displayName: authorJson['display_name'] as String? ?? '',
        bio: '',
        privateNotes: '',
        avatarUrl: authorJson['avatar_url'] as String? ?? '',
        coverUrl: authorJson['cover_url'] as String? ?? '',
        isPublic: true,
      ),
      media: mediaRows
          .map((e) => FeedMedia.fromRow(Map<String, dynamic>.from(e as Map)))
          .toList(),
      comments: const [],
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      likedByMe: json['liked_by_me'] as bool? ?? false,
      postType: FeedPostType.fromWire(json['post_type'] as String?),
      sharedWorkoutSnapshot: sharedWorkoutSnapshot,
    );
  }
}
