import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/device_user_id.dart';
import '../domain/profile_defaults.dart';
import '../domain/user_profile.dart';

final class ProfileRepository {
  ProfileRepository({
    required SharedPreferences prefs,
    SupabaseClient? client,
  })  : _prefs = prefs,
        _client = client ?? Supabase.instance.client;

  final SharedPreferences _prefs;
  final SupabaseClient _client;
  String? _currentUserId;

  Future<String> currentUserId() async {
    _currentUserId ??= await DeviceUserId.resolve(_prefs);
    return _currentUserId!;
  }

  Future<UserProfile?> fetchProfile(String userId) async {
    try {
      final row = await _client.from('profiles').select().eq('id', userId).maybeSingle();
      if (row == null) return null;
      return _fromRow(Map<String, dynamic>.from(row));
    } catch (e, st) {
      debugPrint('ProfileRepository.fetchProfile failed: $e\n$st');
      return null;
    }
  }

  Future<UserProfile> loadCurrentProfile(UserProfile localFallback) async {
    final uid = await currentUserId();
    final remote = await fetchProfile(uid);
    if (remote == null) return UserProfile.withDefaults(membershipLevel: localFallback.membershipLevel, seed: localFallback);
    return remote.copyWith(membershipLevel: localFallback.membershipLevel);
  }

  Future<void> ensureProfile(UserProfile profile) async {
    final uid = await currentUserId();
    await _client.from('profiles').upsert(_toRow(profile, uid), onConflict: 'id');
  }

  Future<void> saveProfile(UserProfile profile) async {
    final uid = await currentUserId();
    try {
      await _client.from('profiles').upsert(_toRow(profile, uid), onConflict: 'id');
    } catch (e, st) {
      debugPrint('ProfileRepository.saveProfile failed: $e\n$st');
      rethrow;
    }
  }

  Map<String, dynamic> _toRow(UserProfile profile, String uid) {
    return {
      'id': uid,
      'display_name': ProfileDefaults.normalizeDisplayName(profile.displayName),
      'username': profile.username.trim(),
      'avatar_url': profile.avatarUrl.trim(),
      'cover_url': profile.coverUrl.trim(),
      'public_bio': profile.publicBio.trim(),
      'bio': profile.publicBio.trim(),
      'private_notes': profile.privateNotes.trim(),
      'weight_kg': profile.weightKg,
      'height_cm': profile.heightCm.round(),
      'target_weight_kg': profile.targetWeightKg,
      'fitness_goal': profile.fitnessGoal.trim(),
      'training_focus': profile.trainingFocus.trim(),
      'experience_level': profile.experienceLevel.trim(),
      'activity_level': profile.activityLevel.trim(),
      'weekly_workout_target': profile.weeklyWorkoutTarget,
      'is_public_profile': profile.isPublicProfile,
      'is_public': profile.isPublicProfile,
      'location_text': profile.locationText.trim(),
      'membership_level': profile.membershipLevel,
      'notifications_enabled': profile.notificationsEnabled,
      'preferred_language': profile.preferredLanguage,
      'preferred_units': profile.preferredUnits,
      'training_reminders_enabled': profile.notificationsEnabled,
      'training_reminder_time': profile.trainingReminderTime,
      'training_reminder_days': profile.trainingReminderDays,
    };
  }

  UserProfile _fromRow(Map<String, dynamic> row) {
    final publicBio = _readString(row, 'public_bio').isNotEmpty
        ? _readString(row, 'public_bio')
        : _readString(row, 'bio');
    final isPublic = row['is_public_profile'] as bool? ?? row['is_public'] as bool? ?? true;
    final targetRaw = row['target_weight_kg'];
    return UserProfile(
      displayName: ProfileDefaults.normalizeDisplayName(_readString(row, 'display_name')),
      username: _readString(row, 'username'),
      avatarUrl: _readString(row, 'avatar_url'),
      coverUrl: _readString(row, 'cover_url'),
      publicBio: publicBio,
      privateNotes: _readString(row, 'private_notes'),
      weightKg: _readDouble(row, 'weight_kg', ProfileDefaults.weightKg),
      heightCm: _readDouble(row, 'height_cm', ProfileDefaults.heightCm),
      targetWeightKg: targetRaw == null ? null : (targetRaw as num).toDouble(),
      fitnessGoal: _readString(row, 'fitness_goal', fallback: ProfileDefaults.fitnessGoal),
      trainingFocus: _readString(row, 'training_focus', fallback: ProfileDefaults.trainingFocus),
      experienceLevel: _readString(row, 'experience_level', fallback: ProfileDefaults.experienceLevel),
      activityLevel: _readString(row, 'activity_level', fallback: ProfileDefaults.activityLevel),
      weeklyWorkoutTarget: row['weekly_workout_target'] as int? ?? ProfileDefaults.weeklyWorkoutTarget,
      isPublicProfile: isPublic,
      locationText: _readString(row, 'location_text', fallback: ProfileDefaults.locationText),
      membershipLevel: _readString(row, 'membership_level'),
      notificationsEnabled:
          row['training_reminders_enabled'] as bool? ?? row['notifications_enabled'] as bool? ?? true,
      preferredLanguage: _readString(row, 'preferred_language', fallback: 'en'),
      preferredUnits: _readString(row, 'preferred_units', fallback: 'metric'),
      trainingReminderTime: _readString(row, 'training_reminder_time', fallback: '19:00'),
      trainingReminderDays: _readString(row, 'training_reminder_days', fallback: 'every_day'),
    );
  }

  static String _readString(Map<String, dynamic> row, String key, {String fallback = ''}) {
    final value = row[key];
    if (value == null) return fallback;
    return value.toString().trim();
  }

  static double _readDouble(Map<String, dynamic> row, String key, double fallback) {
    final value = row[key];
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }
}
