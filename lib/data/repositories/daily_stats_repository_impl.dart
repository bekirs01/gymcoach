import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/daily_stats.dart';
import 'daily_stats_repository.dart';

const _keyStats = 'daily_stats';
const _keyStatsDate = 'daily_stats_date';

/// Local günlük istatistik - mock/geçici
class DailyStatsRepositoryImpl implements DailyStatsRepository {
  DailyStatsRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<DailyStats> getTodayStats() async {
    final dateStr = _prefs.getString(_keyStatsDate);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (dateStr != today) {
      return const DailyStats();
    }

    final json = _prefs.getString(_keyStats);
    if (json == null) return const DailyStats();

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return DailyStats(
        waterGlasses: map['waterGlasses'] as int? ?? 0,
        steps: map['steps'] as int? ?? 0,
        caloriesBurned: map['caloriesBurned'] as int? ?? 0,
        caloriesConsumed: map['caloriesConsumed'] as int? ?? 0,
      );
    } catch (_) {
      return const DailyStats();
    }
  }

  @override
  Future<void> updateStats(DailyStats stats) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _prefs.setString(_keyStatsDate, today);
    await _prefs.setString(
      _keyStats,
      jsonEncode({
        'waterGlasses': stats.waterGlasses,
        'steps': stats.steps,
        'caloriesBurned': stats.caloriesBurned,
        'caloriesConsumed': stats.caloriesConsumed,
      }),
    );
  }
}
