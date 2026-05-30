import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/device_user_id.dart';
import '../../profile/domain/user_profile.dart';
import '../domain/feed_comment.dart';
import '../domain/feed_post.dart';
import '../domain/social_profile.dart';
import 'saved_posts_store.dart';

final class SocialApiClient {
  SocialApiClient({
    required SharedPreferences prefs,
    SupabaseClient? client,
  })  : _prefs = prefs,
        _client = client ?? Supabase.instance.client;

  static const bucket = 'profile-media';

  final SharedPreferences _prefs;
  final SupabaseClient _client;
  String? _currentUserId;

  Future<String> currentUserId() async {
    _currentUserId ??= await DeviceUserId.resolve(_prefs);
    return _currentUserId!;
  }

  Future<void> ensureProfile(UserProfile profile) async {
    final uid = await currentUserId();
    await _client.from('profiles').upsert({
      'id': uid,
      'display_name': profile.displayName,
      'weight_kg': profile.weightKg,
      'height_cm': profile.heightCm,
      'fitness_goal': profile.fitnessGoal,
      'membership_level': profile.membershipLevel,
      'notifications_enabled': profile.notificationsEnabled,
    });
  }

  Future<SocialProfile?> getProfile(String userId) async {
    try {
      final row = await _client.from('profiles').select().eq('id', userId).maybeSingle();
      if (row == null) return null;
      return SocialProfile.fromRow(row);
    } catch (_) {
      final row = await _client
          .from('profiles')
          .select('id, display_name, avatar_url, cover_url')
          .eq('id', userId)
          .maybeSingle();
      if (row == null) return null;
      return SocialProfile(
        userId: row['id'] as String,
        displayName: row['display_name'] as String? ?? '',
        bio: '',
        privateNotes: '',
        avatarUrl: row['avatar_url'] as String? ?? '',
        coverUrl: row['cover_url'] as String? ?? '',
        isPublic: true,
      );
    }
  }

  Future<SocialProfile?> getCurrentProfile() async {
    return getProfile(await currentUserId());
  }

  Future<void> updateProfile({
    required String displayName,
    required String bio,
    required String privateNotes,
    required String avatarUrl,
    required String coverUrl,
    required bool isPublic,
  }) async {
    final uid = await currentUserId();
    await _client.from('profiles').update({
      'display_name': displayName,
      'bio': bio,
      'private_notes': privateNotes,
      'avatar_url': avatarUrl,
      'cover_url': coverUrl,
      'is_public': isPublic,
    }).eq('id', uid);
  }

  Future<String> uploadImage(XFile file, String folder) async {
    final uid = await currentUserId();
    final ext = file.name.split('.').last.toLowerCase();
    final safeExt = ext.length <= 5 ? ext : 'jpg';
    final path = '$uid/$folder/${DateTime.now().microsecondsSinceEpoch}.$safeExt';
    final bytes = await file.readAsBytes();
    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: _contentType(safeExt), upsert: true),
        );
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<List<FeedPost>> fetchFeed({int limit = 40}) async {
    final uid = await currentUserId();
    final blockedRows = await _client
        .from('user_blocks')
        .select('blocked_user_id')
        .eq('blocker_user_id', uid);
    final blocked = blockedRows.map((e) => e['blocked_user_id'] as String).toSet();

    final rows = await _client
        .from('feed_posts')
        .select(
          '*, author:profiles!feed_posts_user_id_fkey(*), feed_post_media(*), feed_likes(user_id), '
          'feed_comments(*, author:profiles!feed_comments_user_id_fkey(*))',
        )
        .eq('visibility', 'public')
        .order('created_at', ascending: false)
        .limit(limit);

    return rows
        .map((row) => FeedPost.fromRow(Map<String, dynamic>.from(row as Map), uid))
        .where((post) => !blocked.contains(post.userId))
        .toList();
  }

  Future<List<FeedPost>> fetchUserPosts(String userId) async {
    final uid = await currentUserId();
    final rows = await _client
        .from('feed_posts')
        .select(
          '*, author:profiles!feed_posts_user_id_fkey(*), feed_post_media(*), feed_likes(user_id), '
          'feed_comments(*, author:profiles!feed_comments_user_id_fkey(*))',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return rows.map((row) => FeedPost.fromRow(Map<String, dynamic>.from(row as Map), uid)).toList();
  }

  Future<void> createPost({required String caption, required List<XFile> images}) async {
    final uid = await currentUserId();
    final now = DateTime.now().microsecondsSinceEpoch.toString();
    final postId = 'post_$now';
    await _client.from('feed_posts').insert({
      'id': postId,
      'user_id': uid,
      'caption': caption.trim(),
      'visibility': 'public',
    });

    final mediaRows = <Map<String, dynamic>>[];
    for (var i = 0; i < images.length; i++) {
      final url = await uploadImage(images[i], 'posts/$postId');
      mediaRows.add({
        'id': '${postId}_media_$i',
        'post_id': postId,
        'media_url': url,
        'media_path': url,
        'sort_order': i,
      });
    }
    if (mediaRows.isNotEmpty) {
      await _client.from('feed_post_media').insert(mediaRows);
    }
  }

  Future<void> deletePost(String postId) async {
    await _client.from('feed_posts').delete().eq('id', postId);
  }

  Future<void> toggleLike(FeedPost post) async {
    final uid = await currentUserId();
    if (post.likedByMe) {
      await _client.from('feed_likes').delete().eq('post_id', post.id).eq('user_id', uid);
    } else {
      await _client.from('feed_likes').upsert({'post_id': post.id, 'user_id': uid});
    }
  }

  Future<FeedComment> addComment(String postId, String body) async {
    final uid = await currentUserId();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final row = await _client
        .from('feed_comments')
        .insert({
          'id': id,
          'post_id': postId,
          'user_id': uid,
          'body': body.trim(),
        })
        .select('*, author:profiles!feed_comments_user_id_fkey(*)')
        .single();
    return FeedComment.fromRow(row);
  }

  Future<void> blockUser(String userId) async {
    final uid = await currentUserId();
    if (uid == userId) return;
    await _client.from('user_blocks').upsert({
      'blocker_user_id': uid,
      'blocked_user_id': userId,
    });
  }

  Future<void> reportPost({required String postId, required String userId, String reason = ''}) async {
    final uid = await currentUserId();
    await _client.from('feed_reports').insert({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'reporter_user_id': uid,
      'post_id': postId.isEmpty ? null : postId,
      'reported_user_id': userId,
      'reason': reason,
    });
  }

  SavedPostsStore get savedPosts => SavedPostsStore(_prefs);

  Future<bool> toggleSavePost(FeedPost post) => savedPosts.toggle(post);

  bool isPostSaved(String postId) => savedPosts.isSaved(postId);

  List<FeedPost> loadSavedPosts() => savedPosts.loadAll();

  String _contentType(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
