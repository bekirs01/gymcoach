import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/device_user_id.dart';
import '../../../core/supabase_operation_error.dart';
import '../../profile/domain/user_profile.dart';
import '../../plans/domain/workout_plan.dart';
import '../../social/domain/feed_post.dart';
import '../../social/domain/social_profile.dart';
import '../domain/feed_post_type.dart';
import '../domain/shared_workout_snapshot.dart';

sealed class CopyWorkoutResult {
  const CopyWorkoutResult();
}

final class CopyWorkoutSuccess extends CopyWorkoutResult {
  const CopyWorkoutSuccess(this.plan);

  final WorkoutPlan plan;
}

final class CopyWorkoutAlreadyExists extends CopyWorkoutResult {
  const CopyWorkoutAlreadyExists();
}

final class CopyWorkoutFailure extends CopyWorkoutResult {
  const CopyWorkoutFailure(this.message);

  final String message;
}

class WorkoutShareException implements Exception {
  WorkoutShareException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class WorkoutShareRepository {
  WorkoutShareRepository({
    required SharedPreferences prefs,
    SupabaseClient? client,
  })  : _prefs = prefs,
        _client = client ?? Supabase.instance.client;

  static const _localCopiesKey = 'workout_copies_v1';

  final SharedPreferences _prefs;
  final SupabaseClient _client;
  String? _currentUserId;

  Future<String> currentUserId() => _userId();

  Future<String> _userId() async {
    _currentUserId ??= await DeviceUserId.resolve(_prefs);
    return _currentUserId!;
  }

  Future<bool> hasCopiedWorkout(String feedPostId) async {
    final uid = await _userId();
    try {
      final row = await _client
          .from('workout_copies')
          .select('id')
          .eq('user_id', uid)
          .eq('feed_post_id', feedPostId)
          .maybeSingle();
      if (row != null) return true;
    } catch (_) {}
    return _localCopyPostIds().contains(feedPostId);
  }

  Future<void> ensureAuthorProfile(UserProfile profile) async {
    final uid = await _userId();
    try {
      await _client.from('profiles').upsert({
        'id': uid,
        'display_name': profile.displayName,
        'weight_kg': profile.weightKg,
        'height_cm': profile.heightCm,
        'fitness_goal': profile.fitnessGoal,
        'membership_level': profile.membershipLevel,
        'notifications_enabled': profile.notificationsEnabled,
      });
    } catch (error, stackTrace) {
      throw SupabaseOperationError.classify(
        operation: 'workout_share_ensure_profile',
        table: 'profiles',
        action: 'upsert',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'Could not share workout',
      );
    }
  }

  Future<FeedPost> shareWorkout({
    required WorkoutPlan plan,
    required String caption,
    required SocialProfile author,
    required UserProfile profile,
  }) async {
    if (plan.exercises.isEmpty) {
      throw WorkoutShareException('Add at least one exercise before sharing.');
    }

    await ensureAuthorProfile(profile);

    final uid = await _userId();
    final snapshot = SharedWorkoutSnapshot.fromWorkoutPlan(
      plan,
      createdByUserId: uid,
    );
    final postId = 'post_${DateTime.now().microsecondsSinceEpoch}';
    final now = DateTime.now();

    try {
      await _client.from('feed_posts').insert({
        'id': postId,
        'user_id': uid,
        'caption': caption.trim(),
        'visibility': 'public',
        'post_type': FeedPostType.workoutShare.wireValue,
        'shared_workout_snapshot': snapshot.toJson(),
        'shared_workout_id': plan.id,
      });
    } catch (error, stackTrace) {
      throw SupabaseOperationError.classify(
        operation: 'workout_share_insert',
        table: 'feed_posts',
        action: 'insert',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'Could not share workout',
      );
    }

    return FeedPost(
      id: postId,
      userId: uid,
      caption: caption.trim(),
      createdAt: now,
      author: author,
      media: const [],
      comments: const [],
      likeCount: 0,
      commentCount: 0,
      likedByMe: false,
      postType: FeedPostType.workoutShare,
      sharedWorkoutSnapshot: snapshot,
    );
  }

  Future<CopyWorkoutResult> copyWorkout({
    required FeedPost post,
    required List<WorkoutPlan> existingPlans,
  }) async {
    final snapshot = post.sharedWorkoutSnapshot;
    if (snapshot == null) {
      return const CopyWorkoutFailure('Workout data is unavailable.');
    }

    if (await hasCopiedWorkout(post.id)) {
      return const CopyWorkoutAlreadyExists();
    }

    final uid = await _userId();
    final copiedWorkoutId = DateTime.now().microsecondsSinceEpoch.toString();
    final planName = _resolveCopyName(snapshot.name, existingPlans);
    final plan = snapshot.toWorkoutPlan(newId: copiedWorkoutId, name: planName);

    try {
      await _client.from('workout_copies').insert({
        'id': 'copy_$copiedWorkoutId',
        'user_id': uid,
        'feed_post_id': post.id,
        'original_workout_id': snapshot.originalWorkoutId,
        'copied_workout_id': copiedWorkoutId,
      });
    } catch (_) {}
    await _recordLocalCopy(post.id);

    return CopyWorkoutSuccess(plan);
  }

  String _resolveCopyName(String baseName, List<WorkoutPlan> existingPlans) {
    final trimmed = baseName.trim();
    if (trimmed.isEmpty) return 'Workout copy';
    final names = existingPlans.map((plan) => plan.name.trim().toLowerCase()).toSet();
    if (!names.contains(trimmed.toLowerCase())) return trimmed;
    final copyName = '$trimmed copy';
    if (!names.contains(copyName.toLowerCase())) return copyName;
    return '$trimmed copy ${DateTime.now().millisecondsSinceEpoch}';
  }

  Set<String> _localCopyPostIds() {
    final raw = _prefs.getString(_localCopiesKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _recordLocalCopy(String feedPostId) async {
    final ids = _localCopyPostIds()..add(feedPostId);
    await _prefs.setString(_localCopiesKey, jsonEncode(ids.toList()));
  }
}
