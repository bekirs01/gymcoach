import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../domain/territory_models.dart';
import '../services/territory_game_notifier.dart';
import '../utils/polygon_utils.dart';
import 'territory_leaderboard_screen.dart';
import 'widgets/territory_sheets.dart';

/// A — Tam ekran harita + oyun kontrolleri.
///
/// TODO: Üretimde karo URL / API anahtarı yapılandırması ve offline cache.
class TerritoryMapScreen extends ConsumerStatefulWidget {
  const TerritoryMapScreen({super.key});

  @override
  ConsumerState<TerritoryMapScreen> createState() => _TerritoryMapScreenState();
}

class _TerritoryMapScreenState extends ConsumerState<TerritoryMapScreen> {
  final MapController _map = MapController();
  double _zoom = 15.5;

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  bool _same(LatLng? a, LatLng b) {
    if (a == null) return false;
    return (a.latitude - b.latitude).abs() < 1e-7 &&
        (a.longitude - b.longitude).abs() < 1e-7;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(territoryGameProvider);
    final notifier = ref.read(territoryGameProvider.notifier);

    ref.listen<TerritoryGameState>(territoryGameProvider, (prev, next) {
      if (prev == null) return;
      if (_same(prev.mapCenter, next.mapCenter)) return;
      _map.move(next.mapCenter, _zoom);
    });

    final polygons = <Polygon<String>>[
      for (final z in state.territories)
        Polygon(
          points: z.closedRing,
          color: (state.users[z.ownerId]?.themeColor ?? Colors.teal)
              .withOpacity(0.28),
          borderStrokeWidth: 2.2,
          borderColor:
              state.users[z.ownerId]?.themeColor ?? const Color(0xFF14B8A6),
          label: z.name,
          labelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
          ),
          hitValue: z.id,
        ),
    ];

    final userPos = state.liveUserPosition ?? state.mapCenter;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: state.mapCenter,
                initialZoom: _zoom,
                backgroundColor: const Color(0xFF0B1220),
                onTap: (tap, latlng) {
                  for (final z in state.territories.reversed) {
                    if (PolygonUtils.pointInPolygon(latlng, z.closedRing)) {
                      showTerritoryDetailSheet(context, z, state.users);
                      return;
                    }
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.gymcoach',
                ),
                PolygonLayer(polygons: polygons),
                if (state.activeRoute.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: state.activeRoute,
                        strokeWidth: 4,
                        color: const Color(0xFF2DD4BF),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userPos,
                      width: 36,
                      height: 36,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF14B8A6).withOpacity(0.95),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black54,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.navigation_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: Colors.white,
                      ),
                      const Expanded(
                        child: Text(
                          'Территория',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const TerritoryLeaderboardScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.emoji_events_outlined),
                        color: const Color(0xFF2DD4BF),
                      ),
                    ],
                  ),
                  if (state.statusMessage != null)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xCC121A24),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFF2DD4BF).withOpacity(0.35)),
                      ),
                      child: Text(
                        state.statusMessage!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13, height: 1.3),
                      ),
                    ),
                  const Spacer(),
                  _controlPanel(context, state, notifier),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlPanel(
    BuildContext context,
    TerritoryGameState state,
    TerritoryGameNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0B1220).withOpacity(0.2),
            const Color(0xEE0B1220),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Пройдите маршрут и замкните область — игра + спорт.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onPressed: state.isRecording
                    ? null
                    : () => notifier.startRecording(),
                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                label: const Text('Старт'),
              ),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1C2632),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onPressed: state.isRecording ? () => notifier.stopRecording() : null,
                icon: const Icon(Icons.pause_rounded),
                label: const Text('Пауза'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2DD4BF),
                  side: const BorderSide(color: Color(0xFF2DD4BF)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onPressed: () async {
                  final outcome = notifier.tryCloseRoute();
                  if (!outcome.isSuccess) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            outcome.message ?? 'Маршрут ещё не готов.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                    return;
                  }
                  await showTerritoryCompletionSheet(
                    context: context,
                    ref: ref,
                    success: outcome,
                  );
                },
                icon: const Icon(Icons.task_alt_rounded, size: 20),
                label: const Text('Завершить'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: notifier.startSimulationRun,
                  icon: const Icon(Icons.smart_toy_outlined),
                  label: const Text('Симуляция'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: notifier.recenterMapOnUser,
                  icon: const Icon(Icons.my_location_rounded),
                  label: const Text('Ко мне'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: notifier.useDeviceMode,
                  icon: const Icon(Icons.gps_fixed_rounded,
                      color: Color(0xFF38BDF8), size: 20),
                  label: const Text('GPS', style: TextStyle(color: Colors.white)),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: notifier.useSimulationMode,
                  icon: const Icon(Icons.videogame_asset_outlined,
                      color: Color(0xFFFBBF24), size: 20),
                  label:
                      const Text('Симуляция', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: notifier.clearRoute,
            child: Text(
              'Очистить маршрут',
              style: TextStyle(color: Colors.white.withOpacity(0.55)),
            ),
          ),
          if (state.permissionDenied)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Без доступа к геолокации используйте режим симуляции.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.amber.shade200,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
