import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local/local_first_training_persistence.dart';
import '../data/remote/supabase_training_persistence.dart';
import 'auth_session_service.dart';
import 'offline/offline_sync_service.dart';
import 'supabase_config.dart';

Future<void> _loadEnv() async {
  try {
    await dotenv.load(fileName: '.env');
    return;
  } catch (_) {}

  try {
    await dotenv.load(fileName: '.env.example');
  } catch (_) {}
}

/// Runs after [runApp] so the UI can appear immediately.
Future<void> bootstrapAppServices({
  required SharedPreferences prefs,
  LocalFirstTrainingPersistence? trainingPersistence,
}) async {
  await _loadEnv();
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (error, stackTrace) {
    debugPrint('[bootstrap] Supabase init failed: $error');
    debugPrint('[bootstrap] stackTrace=$stackTrace');
    return;
  }

  try {
    await AuthSessionService.ensureSession();
  } catch (error) {
    debugPrint('[bootstrap] Guest session bootstrap failed: $error');
  }

  trainingPersistence?.attachRemote(
    SupabaseTrainingPersistence(prefs: prefs),
  );

  try {
    final sync = await OfflineSyncService.ensureInitialized(prefs);
    sync.start();
  } catch (error, stackTrace) {
    debugPrint('[bootstrap] Offline sync init failed: $error');
    debugPrint('[bootstrap] stackTrace=$stackTrace');
  }
}
