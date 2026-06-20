import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'auth_session_service.dart';

abstract final class DeviceUserId {
  static const _key = 'device_user_id';

  static Future<String> resolve(SharedPreferences prefs) async {
    final authId = await AuthSessionService.ensureSupabaseSession();
    final stored = prefs.getString(_key);
    if (stored != authId) {
      await prefs.setString(_key, authId);
    }
    return authId;
  }

  static Future<String> legacyResolve(SharedPreferences prefs) async {
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = const Uuid().v4();
    await prefs.setString(_key, id);
    return id;
  }
}
