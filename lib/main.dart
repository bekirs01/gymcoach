import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/gymcoach_app.dart';
import 'core/auth_session_service.dart';
import 'core/supabase_config.dart';

Future<void> _loadEnv() async {
  try {
    await dotenv.load(fileName: '.env');
    return;
  } catch (_) {}

  try {
    await dotenv.load(fileName: '.env.example');
  } catch (_) {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();  await _loadEnv();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  try {
    await AuthSessionService.ensureSession();
  } catch (error) {
    debugPrint('[main] Guest session bootstrap failed: $error');
  }
  runApp(const GymCoachApp());
}
