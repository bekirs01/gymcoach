import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class ChatAuthSession {
  static Future<String> ensureSignedIn() async {
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;
    if (session != null) {
      return session.user.id;
    }

    final response = await client.auth.signInAnonymously();
    final userId = response.user?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('Unable to start chat session');
    }

    await client.from('profiles').upsert({
      'id': userId,
      'display_name': 'Athlete',
    });

    return userId;
  }

  static String? currentUserId() {
    return Supabase.instance.client.auth.currentSession?.user.id;
  }
}
