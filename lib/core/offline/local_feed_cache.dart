import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../features/feed/domain/feed_story.dart';
import '../../features/social/domain/feed_post.dart';
import '../../features/social/domain/feed_media.dart';
import '../../features/social/domain/social_profile.dart';
import '../../features/workout_share/domain/feed_post_type.dart';
import '../../features/workout_share/domain/shared_workout_snapshot.dart';

final class LocalFeedCache {
  LocalFeedCache._();

  static LocalFeedCache? _instance;
  static LocalFeedCache get instance => _instance ??= LocalFeedCache._();

  static const _fileName = 'feed_cache.json';
  static const _folderName = 'gymcoach_outbox';

  List<FeedPost> _pendingPosts = [];
  List<FeedStory> _pendingStories = [];
  FeedStory? _cachedOwnStory;
  List<FeedStory> _cachedApiStories = const [];
  var _loaded = false;
  File? _file;

  Future<File> _ensureFile() async {
    if (_file != null) return _file!;
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/$_folderName');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    _file = File('${folder.path}/$_fileName');
    return _file!;
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final file = await _ensureFile();
    if (!await file.exists()) {
      _loaded = true;
      return;
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        _loaded = true;
        return;
      }
      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final postRows = map['pending_posts'] as List<dynamic>? ?? const [];
      final storyRows = map['pending_stories'] as List<dynamic>? ?? const [];
      _pendingPosts = postRows
          .map((row) => _postFromJson(Map<String, dynamic>.from(row as Map)))
          .toList();
      _pendingStories = storyRows
          .map((row) => _storyFromJson(Map<String, dynamic>.from(row as Map)))
          .toList();
      final ownStoryRow = map['cached_own_story'];
      if (ownStoryRow is Map) {
        _cachedOwnStory = _storyFromJson(Map<String, dynamic>.from(ownStoryRow));
      }
      final cachedStoryRows = map['cached_api_stories'] as List<dynamic>? ?? const [];
      _cachedApiStories = cachedStoryRows
          .map((row) => _storyFromJson(Map<String, dynamic>.from(row as Map)))
          .toList();
    } catch (_) {}
    _loaded = true;
  }

  List<FeedPost> pendingPosts() => List.unmodifiable(_pendingPosts);

  List<FeedStory> pendingStories() => List.unmodifiable(_pendingStories);

  FeedStory? ownPendingStory(String userId) {
    for (final story in _pendingStories) {
      if (story.user.id == userId) return story;
    }
    return null;
  }

  FeedStory? cachedOwnStory() => _cachedOwnStory;

  List<FeedStory> cachedApiStories() => List.unmodifiable(_cachedApiStories);

  Future<void> saveSyncedStories({
    FeedStory? own,
    required List<FeedStory> apiStories,
  }) async {
    await ensureLoaded();
    _cachedOwnStory = own;
    _cachedApiStories = List<FeedStory>.from(apiStories);
    await _persist();
  }

  Future<void> upsertPost(FeedPost post) async {
    await ensureLoaded();
    _pendingPosts.removeWhere(
      (item) => item.id == post.id || (post.localId != null && item.localId == post.localId),
    );
    if (post.isPendingUpload || post.uploadFailed) {
      _pendingPosts.insert(0, post);
    }
    await _persist();
  }

  Future<void> removePost({String? postId, String? localId}) async {
    await ensureLoaded();
    _pendingPosts.removeWhere(
      (item) =>
          (postId != null && item.id == postId) ||
          (localId != null && item.localId == localId),
    );
    await _persist();
  }

  Future<void> upsertStory(FeedStory story) async {
    await ensureLoaded();
    _pendingStories.removeWhere(
      (item) =>
          item.id == story.id ||
          (story.localId != null && item.localId == story.localId) ||
          (story.user.isCurrentUser && item.user.isCurrentUser),
    );
    if (story.isPendingUpload || story.uploadFailed) {
      _pendingStories.insert(0, story);
    }
    await _persist();
  }

  Future<void> removeStory({String? storyId, String? localId}) async {
    await ensureLoaded();
    _pendingStories.removeWhere(
      (item) =>
          (storyId != null && item.id == storyId) ||
          (localId != null && item.localId == localId),
    );
    await _persist();
  }

  static List<FeedPost> mergePosts({
    required List<FeedPost> remote,
    required List<FeedPost> local,
  }) {
    final byKey = <String, FeedPost>{};
    for (final post in remote) {
      byKey[_postKey(post)] = post;
    }
    for (final post in local) {
      final key = _postKey(post);
      final existing = byKey[key];
      if (existing == null || post.isPendingUpload || post.uploadFailed) {
        byKey[key] = post;
      }
    }
    final merged = byKey.values.toList();
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  static String _postKey(FeedPost post) {
    if (post.localId != null && post.localId!.isNotEmpty) {
      return 'local:${post.localId}';
    }
    return 'id:${post.id}';
  }

  Future<void> _persist() async {
    final file = await _ensureFile();
    final map = {
      'pending_posts': _pendingPosts.map(_postToJson).toList(),
      'pending_stories': _pendingStories.map(_storyToJson).toList(),
      if (_cachedOwnStory != null) 'cached_own_story': _storyToJson(_cachedOwnStory!),
      'cached_api_stories': _cachedApiStories.map(_storyToJson).toList(),
    };
    await file.writeAsString(jsonEncode(map), flush: true);
  }
}

Map<String, dynamic> _postToJson(FeedPost post) {
  return {
    'id': post.id,
    'local_id': post.localId,
    'user_id': post.userId,
    'caption': post.caption,
    'created_at': post.createdAt.toIso8601String(),
    'like_count': post.likeCount,
    'comment_count': post.commentCount,
    'liked_by_me': post.likedByMe,
    'post_type': post.postType.wireValue,
    'is_pending_upload': post.isPendingUpload,
    'upload_failed': post.uploadFailed,
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
            'local_path': m.localPath,
          },
        )
        .toList(),
    'local_media_paths': post.localMediaPaths,
  };
}

FeedPost _postFromJson(Map<String, dynamic> json) {
  final authorJson = json['author'] as Map<String, dynamic>? ?? const {};
  final mediaRows = json['media'] as List<dynamic>? ?? const [];
  final localPaths = (json['local_media_paths'] as List<dynamic>? ?? const [])
      .map((e) => e.toString())
      .toList();
  SharedWorkoutSnapshot? sharedWorkoutSnapshot;
  final snapshotRaw = json['shared_workout_snapshot'];
  if (snapshotRaw is Map) {
    sharedWorkoutSnapshot = SharedWorkoutSnapshot.fromJson(Map<String, dynamic>.from(snapshotRaw));
  }
  return FeedPost(
    id: json['id'] as String? ?? '',
    localId: json['local_id'] as String?,
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
        .map((e) => _mediaFromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    comments: const [],
    likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
    commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
    likedByMe: json['liked_by_me'] as bool? ?? false,
    postType: FeedPostType.fromWire(json['post_type'] as String?),
    sharedWorkoutSnapshot: sharedWorkoutSnapshot,
    isPendingUpload: json['is_pending_upload'] as bool? ?? false,
    uploadFailed: json['upload_failed'] as bool? ?? false,
    localMediaPaths: localPaths,
  );
}

FeedMedia _mediaFromJson(Map<String, dynamic> json) {
  return FeedMedia(
    id: json['id'] as String? ?? '',
    postId: json['post_id'] as String? ?? '',
    url: json['media_url'] as String? ?? '',
    path: json['media_path'] as String? ?? '',
    sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    localPath: json['local_path'] as String?,
  );
}

Map<String, dynamic> _storyToJson(FeedStory story) {
  return {
    'id': story.id,
    'local_id': story.localId,
    'user': {
      'id': story.user.id,
      'display_name': story.user.displayName,
      'avatar_url': story.user.avatarUrl,
      'fallback_name': story.user.fallbackName,
      'is_current_user': story.user.isCurrentUser,
    },
    'slides': story.slides
        .map(
          (slide) => {
            'image_url': slide.imageUrl,
            'local_path': slide.localPath,
          },
        )
        .toList(),
    'latest_at': story.latestAt?.toIso8601String(),
    'is_pending_upload': story.isPendingUpload,
    'upload_failed': story.uploadFailed,
  };
}

FeedStory _storyFromJson(Map<String, dynamic> json) {
  final userJson = json['user'] as Map<String, dynamic>? ?? const {};
  final slideRows = json['slides'] as List<dynamic>? ?? const [];
  return FeedStory(
    id: json['id'] as String? ?? '',
    localId: json['local_id'] as String?,
    user: StoryUser(
      id: userJson['id'] as String? ?? '',
      displayName: userJson['display_name'] as String? ?? '',
      avatarUrl: userJson['avatar_url'] as String? ?? '',
      fallbackName: userJson['fallback_name'] as String? ?? '',
      isCurrentUser: userJson['is_current_user'] as bool? ?? false,
    ),
    slides: slideRows
        .map(
          (row) {
            final map = Map<String, dynamic>.from(row as Map);
            return FeedStorySlide(
              imageUrl: map['image_url'] as String?,
              localPath: map['local_path'] as String?,
            );
          },
        )
        .toList(),
    latestAt: DateTime.tryParse(json['latest_at'] as String? ?? ''),
    isPendingUpload: json['is_pending_upload'] as bool? ?? false,
    uploadFailed: json['upload_failed'] as bool? ?? false,
  );
}
