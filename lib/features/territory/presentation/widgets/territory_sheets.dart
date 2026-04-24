import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/territory_models.dart';
import '../../services/territory_game_notifier.dart';
import '../../utils/route_capture_logic.dart';

/// Лист после замыкания зоны — имя и сохранение.
Future<void> showTerritoryCompletionSheet({
  required BuildContext context,
  required WidgetRef ref,
  required RouteCaptureOutcome success,
}) async {
  final nameCtrl = TextEditingController(text: 'Моя зона');
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF121A24),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14B8A6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flag_circle_rounded,
                      color: Color(0xFF2DD4BF), size: 28),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Территория закрыта!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Дайте название — очки попадут в таблицу.',
              style: TextStyle(color: Colors.white.withOpacity(0.72), height: 1.35),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Название',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.65)),
                filled: true,
                fillColor: const Color(0xFF1C2632),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            _metricRow(Icons.shape_line_outlined, 'Площадь',
                '${success.areaSqM.toStringAsFixed(0)} м²'),
            const SizedBox(height: 8),
            _metricRow(Icons.route_rounded, 'Длина маршрута',
                '${success.pathLengthM.toStringAsFixed(0)} м'),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref.read(territoryGameProvider.notifier).saveCompletedTerritory(
                      name: nameCtrl.text,
                      closedRing: success.closedRing,
                      areaSqM: success.areaSqM,
                      pathLengthM: success.pathLengthM,
                    );
                Navigator.of(ctx).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Сохранено. Смотрите рейтинг лиги.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF0F766E),
                    ),
                  );
                }
              },
              child: const Text('Сохранить'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Отмена', style: TextStyle(color: Colors.white.withOpacity(0.6))),
            ),
          ],
        ),
      );
    },
  );
}

Widget _metricRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, color: const Color(0xFF94A3B8), size: 22),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

/// Детали зоны — нижний лист.
Future<void> showTerritoryDetailSheet(
  BuildContext context,
  TerritoryZone zone,
  Map<String, TerritoryProfile> users,
) async {
  final owner = users[zone.ownerId];
  final last = zone.lastCapturerId != null ? users[zone.lastCapturerId] : null;
  final df = DateFormat.yMMMd().add_Hm();

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF121A24),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            zone.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _detailLine('Владелец', owner?.displayName ?? zone.ownerId),
          _detailLine('Захват / обновление', df.format(zone.claimedAt)),
          _detailLine('Площадь', '${zone.areaSqM.toStringAsFixed(0)} м²'),
          _detailLine('Смен владельца', '${zone.captureCount}'),
          if (last != null)
            _detailLine('Последний захват', last.displayName),
          const SizedBox(height: 12),
          Text(
            'Демо-данные: правила в движке пересечений.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _detailLine(String k, String v) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            k,
            style: TextStyle(color: Colors.white.withOpacity(0.55)),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
