import 'package:flutter/foundation.dart';

abstract final class SupabaseDebugLog {
  static void session(String message) {
    if (kDebugMode) debugPrint('[SupabaseSession] $message');
  }

  static void storage(String message) {
    if (kDebugMode) debugPrint('[SupabaseStorage] $message');
  }

  static void database(String message) {
    if (kDebugMode) debugPrint('[SupabaseDatabase] $message');
  }

  static void realtime(String message) {
    if (kDebugMode) debugPrint('[SupabaseRealtime] $message');
  }

  static void merge(String message) {
    if (kDebugMode) debugPrint('[SupabaseMerge] $message');
  }
}
