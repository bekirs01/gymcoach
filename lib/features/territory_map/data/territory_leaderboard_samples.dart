import '../../social/data/social_seed_data.dart';
import '../domain/leaderboard_entry.dart';

abstract final class TerritoryLeaderboardSamples {
  static const _sampleUserIds = [
    'seed_sofia',
    'seed_maria',
    'seed_maxim',
    'seed_anastasia',
    'seed_ekaterina',
  ];

  static const _sampleAreas = [4820.0, 3650.0, 2910.0, 2240.0, 1780.0];
  static const _sampleCounts = [5, 4, 3, 3, 2];

  static List<LeaderboardEntry> demoEntries({String? currentUserId}) {
    final entries = <LeaderboardEntry>[];
    for (var i = 0; i < _sampleUserIds.length; i++) {
      final userId = _sampleUserIds[i];
      final user = SocialSeedRepository.userById(userId);
      if (user == null) continue;
      entries.add(
        LeaderboardEntry(
          rank: i + 1,
          displayName: user.displayName,
          totalAreaSquareMeters: _sampleAreas[i],
          territoryCount: _sampleCounts[i],
          userId: userId,
          avatarUrl: user.avatarUrl,
        ),
      );
    }
    if (currentUserId != null &&
        currentUserId.isNotEmpty &&
        !entries.any((entry) => entry.userId == currentUserId)) {
      entries.add(
        LeaderboardEntry(
          rank: entries.length + 1,
          displayName: 'You',
          totalAreaSquareMeters: 640,
          territoryCount: 1,
          userId: currentUserId,
        ),
      );
    }
    return entries;
  }

  static List<LeaderboardEntry> mergeWithSamples(
    List<LeaderboardEntry> remote, {
    String? currentUserId,
  }) {
    if (remote.length >= 3) return remote;
    final byUserId = {for (final entry in remote) entry.userId: entry};
    final merged = <LeaderboardEntry>[...remote];
    for (final sample in demoEntries(currentUserId: currentUserId)) {
      if (byUserId.containsKey(sample.userId)) continue;
      merged.add(sample.copyWith(rank: merged.length + 1));
    }
    merged.sort((a, b) => b.totalAreaSquareMeters.compareTo(a.totalAreaSquareMeters));
    return List.generate(
      merged.length,
      (index) => merged[index].copyWith(rank: index + 1),
    );
  }
}
