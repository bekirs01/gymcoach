import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class SupabaseConfig {
  static String get url =>
      _env('NEXT_PUBLIC_SUPABASE_URL', 'SUPABASE_URL') ??
      const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://vgwcwayexfkeelzueyfb.supabase.co',
      );

  static String get anonKey =>
      _env('NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY', 'SUPABASE_ANON_KEY') ??
      const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: 'sb_publishable_YicCj5QqafDbo8zMgCAbJg_fkaHdmms',
      );

  static String? _env(String primary, String fallback) {
    final primaryValue = dotenv.maybeGet(primary);
    if (primaryValue != null && primaryValue.isNotEmpty) return primaryValue;
    final fallbackValue = dotenv.maybeGet(fallback);
    if (fallbackValue != null && fallbackValue.isNotEmpty) return fallbackValue;
    return null;
  }
}
