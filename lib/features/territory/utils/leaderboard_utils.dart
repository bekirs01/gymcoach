import '../domain/territory_models.dart';

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.score,
    required this.secondaryHint,
  });

  final String userId;
  final String displayName;
  final num score;
  final String secondaryHint;
}

/// En çok bölge.
List<LeaderboardEntry> topByTerritoryCount(TerritoryGameState state) {
  final counts = <String, int>{};
  for (final z in state.territories) {
    counts[z.ownerId] = (counts[z.ownerId] ?? 0) + 1;
  }
  final rows = state.users.entries.map((e) {
    final c = counts[e.key] ?? 0;
    return LeaderboardEntry(
      userId: e.key,
      displayName: e.value.displayName,
      score: c,
      secondaryHint: '$c bölge',
    );
  }).toList()
    ..sort((a, b) => b.score.compareTo(a.score));
  return rows;
}

/// Toplam alan (m²).
List<LeaderboardEntry> topByTotalArea(TerritoryGameState state) {
  final area = <String, double>{};
  for (final z in state.territories) {
    area[z.ownerId] = (area[z.ownerId] ?? 0) + z.areaSqM;
  }
  final rows = state.users.entries.map((e) {
    final a = area[e.key] ?? 0;
    return LeaderboardEntry(
      userId: e.key,
      displayName: e.value.displayName,
      score: a,
      secondaryHint: '${a.toStringAsFixed(0)} m²',
    );
  }).toList()
    ..sort((a, b) => b.score.compareTo(a.score));
  return rows;
}

/// Ele geçirme sayısı (mock profil alanı).
List<LeaderboardEntry> topByCaptures(TerritoryGameState state) {
  final rows = state.users.entries
      .map(
        (e) => LeaderboardEntry(
          userId: e.key,
          displayName: e.value.displayName,
          score: e.value.totalCaptures,
          secondaryHint: '${e.value.totalCaptures} fetih',
        ),
      )
      .toList()
    ..sort((a, b) => b.score.compareTo(a.score));
  return rows;
}
