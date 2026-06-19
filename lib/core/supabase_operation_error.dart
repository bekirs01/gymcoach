import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SupabaseErrorCategory {
  network,
  auth,
  permission,
  schema,
  unknown,
}

final class SupabaseOperationError implements Exception {
  SupabaseOperationError({
    required this.operation,
    required this.category,
    required this.userMessage,
    required this.original,
    this.table,
    this.action,
  });

  final String operation;
  final String? table;
  final String? action;
  final SupabaseErrorCategory category;
  final String userMessage;
  final Object original;

  @override
  String toString() => userMessage;

  static SupabaseOperationError classify({
    required String operation,
    required Object error,
    String? table,
    String? action,
    StackTrace? stackTrace,
    String? fallbackMessage,
  }) {
    debugPrint(
      '[Supabase][$operation] table=${table ?? '-'} action=${action ?? '-'} error=$error',
    );
    if (stackTrace != null) {
      debugPrint('[Supabase][$operation] stackTrace=$stackTrace');
    }

    final category = _categorize(error);
    return SupabaseOperationError(
      operation: operation,
      table: table,
      action: action,
      category: category,
      userMessage: fallbackMessage ?? _messageFor(category),
      original: error,
    );
  }

  static SupabaseErrorCategory _categorize(Object error) {
    if (_isNetworkError(error)) return SupabaseErrorCategory.network;

    if (error is AuthException ||
        error is AuthRetryableFetchException ||
        _messageContains(error, ['not authenticated', 'jwt', 'session', 'sign in'])) {
      return SupabaseErrorCategory.auth;
    }

    if (error is PostgrestException) {
      final code = error.code ?? '';
      final message = error.message.toLowerCase();
      if (code == '42501' ||
          code == 'PGRST301' ||
          message.contains('permission denied') ||
          message.contains('row-level security') ||
          message.contains('rls')) {
        return SupabaseErrorCategory.permission;
      }
      if (code == '42P01' ||
          code == '42703' ||
          code == 'PGRST202' ||
          code == 'PGRST204' ||
          message.contains('does not exist') ||
          message.contains('could not find') ||
          message.contains('column') && message.contains('not found') ||
          message.contains('schema cache')) {
        return SupabaseErrorCategory.schema;
      }
      if (code == '23503' && message.contains('foreign key')) {
        return SupabaseErrorCategory.schema;
      }
    }

    if (_messageContains(error, [
      'permission denied',
      'row-level security',
      'not authorized',
      'unauthorized',
    ])) {
      return SupabaseErrorCategory.permission;
    }

    if (_messageContains(error, [
      'does not exist',
      'could not find',
      'schema cache',
      'column',
      'relation',
      'function',
    ])) {
      return SupabaseErrorCategory.schema;
    }

    return SupabaseErrorCategory.unknown;
  }

  static bool _isNetworkError(Object error) {
    if (error is SocketException) return true;
    if (error is HttpException) return true;
    if (error is TimeoutException) return true;
    if (error is AuthRetryableFetchException) return true;

    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('network is unreachable') ||
        message.contains('connection refused') ||
        message.contains('connection timed out') ||
        message.contains('timed out') ||
        message.contains('no internet');
  }

  static bool _messageContains(Object error, List<String> needles) {
    final message = error.toString().toLowerCase();
    return needles.any(message.contains);
  }

  static String _messageFor(SupabaseErrorCategory category) {
    return switch (category) {
      SupabaseErrorCategory.network => 'No internet connection',
      SupabaseErrorCategory.auth => 'Please sign in to continue',
      SupabaseErrorCategory.permission => 'You do not have permission for this action',
      SupabaseErrorCategory.schema => 'Database setup is incomplete',
      SupabaseErrorCategory.unknown => 'Something went wrong',
    };
  }
}
