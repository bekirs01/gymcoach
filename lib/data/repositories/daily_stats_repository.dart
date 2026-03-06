import '../../domain/models/daily_stats.dart';

/// Günlük istatistik repository arayüzü
abstract class DailyStatsRepository {
  Future<DailyStats> getTodayStats();
  Future<void> updateStats(DailyStats stats);
}
