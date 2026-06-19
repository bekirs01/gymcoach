import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/profile/domain/profile_defaults.dart';

abstract final class AuthSessionService {
  static const guestUsername = 'bekir_guest';

  static String? get currentUserId =>
      Supabase.instance.client.auth.currentSession?.user.id;

  static bool get isGuestUser {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;
    return user.isAnonymous;
  }

  static Future<Session> ensureSession() async {
    final client = Supabase.instance.client;
    final existing = client.auth.currentSession;
    if (existing != null) {
      await _ensureProfile(existing.user.id, existing.user.isAnonymous);
      return existing;
    }

    try {
      final response = await client.auth.signInAnonymously();
      final session = response.session;
      final userId = response.user?.id;
      if (session == null || userId == null || userId.isEmpty) {
        throw StateError('Could not start guest session');
      }
      await _ensureProfile(userId, response.user?.isAnonymous ?? true);
      return session;
    } on AuthException catch (error, stackTrace) {
      debugPrint('Enable Anonymous sign-ins in Supabase Auth settings.');
      debugPrint('[AuthSessionService] signInAnonymously failed: $error');
      debugPrint('[AuthSessionService] stackTrace=$stackTrace');
      throw StateError('Could not start guest session');
    } catch (error, stackTrace) {
      final message = error.toString().toLowerCase();
      if (message.contains('anonymous') ||
          message.contains('sign-in provider') ||
          message.contains('disabled')) {
        debugPrint('Enable Anonymous sign-ins in Supabase Auth settings.');
      }
      debugPrint('[AuthSessionService] ensureSession failed: $error');
      debugPrint('[AuthSessionService] stackTrace=$stackTrace');
      throw StateError('Could not start guest session');
    }
  }

  static Future<void> _ensureProfile(String userId, bool isAnonymous) async {
    final client = Supabase.instance.client;

    try {
      if (!isAnonymous) {
        final existing = await client
            .from('profiles')
            .select('id')
            .eq('id', userId)
            .maybeSingle();
        if (existing != null) return;
      }

      await client.from('profiles').upsert({
        'id': userId,
        'display_name': ProfileDefaults.displayName,
        'username': isAnonymous ? guestUsername : ProfileDefaults.username,
        'public_bio': ProfileDefaults.publicBio,
        'is_public_profile': ProfileDefaults.isPublicProfile,
      }, onConflict: 'id');
    } catch (error, stackTrace) {
      debugPrint('[AuthSessionService] ensureProfile failed: $error');
      debugPrint('[AuthSessionService] stackTrace=$stackTrace');
    }
  }
}
