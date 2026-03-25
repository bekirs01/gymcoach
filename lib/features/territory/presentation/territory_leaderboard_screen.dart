import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/territory_game_notifier.dart';
import '../utils/leaderboard_utils.dart';

/// D — Liderlik: bölge sayısı, toplam alan, ele geçirme.
class TerritoryLeaderboardScreen extends ConsumerWidget {
  const TerritoryLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(territoryGameProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1220),
        appBar: AppBar(
          title: const Text('Liderlik'),
          backgroundColor: const Color(0xFF121A24),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Color(0xFF2DD4BF),
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Bölge'),
              Tab(text: 'Alan'),
              Tab(text: 'Fetih'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _LeaderList(entries: topByTerritoryCount(state)),
            _LeaderList(entries: topByTotalArea(state)),
            _LeaderList(entries: topByCaptures(state)),
          ],
        ),
      ),
    );
  }
}

class _LeaderList extends StatelessWidget {
  const _LeaderList({required this.entries});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final e = entries[i];
        final medal = i == 0
            ? '🥇'
            : i == 1
                ? '🥈'
                : i == 2
                    ? '🥉'
                    : '${i + 1}.';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2632),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Text(medal, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      e.secondaryHint,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                e.score is int ? '${e.score}' : e.score.toStringAsFixed(0),
                style: const TextStyle(
                  color: Color(0xFF2DD4BF),
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
