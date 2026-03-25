import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/league.dart';

/// Lig: iki puan türü — kamera tekrarları ve (yakında) ikinci sistem
class LeagueScreen extends ConsumerWidget {
  const LeagueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingsAsync = ref.watch(leagueStandingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Lig'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(leagueStandingsProvider),
          ),
        ],
      ),
      body: standingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text(
            'Hata: $e',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        data: (rows) => RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: const Color(0xFF1C2128),
          onRefresh: () async => ref.invalidate(leagueStandingsProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              FilledButton.icon(
                onPressed: () => context.push('/league/camera-setup'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                ),
                icon: const Icon(Icons.photo_camera_rounded),
                label: const Text('İki halter · omuz üstü tekrar (kamera)'),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2128),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white.withOpacity(0.6),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'İkinci puan sistemi yakında eklenecek.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sıralama',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Toplam = kamera + (gelecekte) ikinci puan',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 12),
              ...rows.asMap().entries.map(
                (e) => _rowTile(context, e.key + 1, e.value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowTile(BuildContext context, int rank, LeagueStanding row) {
    final highlight = row.isCurrentUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: highlight
            ? AppColors.primary.withOpacity(0.15)
            : const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: highlight ? AppColors.primary : Colors.white54,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  row.displayName + (highlight ? ' (sen)' : ''),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: highlight
                        ? Colors.white
                        : Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              _scoreChip('Kamera', row.cameraScore, const Color(0xFF22C55E)),
              const SizedBox(width: 8),
              _scoreChip('2.', row.secondaryScore, Colors.white38),
              const SizedBox(width: 8),
              Text(
                '${row.totalScore}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreChip(String label, int value, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: accent)),
        Text(
          '$value',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
