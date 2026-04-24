import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import 'camera_session_config.dart';

class LeagueCameraSetupScreen extends ConsumerStatefulWidget {
  const LeagueCameraSetupScreen({super.key});

  @override
  ConsumerState<LeagueCameraSetupScreen> createState() =>
      _LeagueCameraSetupScreenState();
}

class _LeagueCameraSetupScreenState
    extends ConsumerState<LeagueCameraSetupScreen> {
  CameraExerciseType _exercise = CameraExerciseType.dumbbellShoulderPress;
  double _weightKg = 10;
  bool _seededFromProfile = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    profileAsync.whenData((profile) {
      if (_seededFromProfile || profile == null) return;
      _seededFromProfile = true;
      final profileWeight = profile.weightKg.clamp(1, 200).toDouble();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _weightKg = profileWeight);
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Камера'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: [
          Text(
            '1) Упражнение  2) Вес  3) Запуск',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          ...CameraExerciseType.values.map(_exerciseCard),
          const SizedBox(height: 16),
          _weightCard(profileAsync.valueOrNull?.weightKg),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              final w = _weightKg.toStringAsFixed(1);
              context.push(
                '/league/camera-reps?exercise=${_exercise.id}&weight=$w',
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Старт камеры'),
          ),
        ],
      ),
    );
  }

  Widget _exerciseCard(CameraExerciseType type) {
    final selected = type == _exercise;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected
            ? AppColors.primary.withOpacity(0.18)
            : const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _exercise = type),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Icon(
                  _iconFor(type),
                  color: selected ? AppColors.primary : Colors.white70,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        type.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.68),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _weightCard(double? profileWeight) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Вес',
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            profileWeight == null
                ? 'Вес из профиля не найден — используется значение по умолчанию.'
                : 'Вес из профиля: $profileWeight кг. Можно изменить.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.62),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Slider(
                  min: 1,
                  max: 200,
                  divisions: 199,
                  activeColor: AppColors.primary,
                  value: _weightKg.clamp(1, 200),
                  onChanged: (v) =>
                      setState(() => _weightKg = v.roundToDouble()),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(
                  '${_weightKg.round()} kg',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconFor(CameraExerciseType type) {
    switch (type) {
      case CameraExerciseType.dumbbellShoulderPress:
        return Icons.fitness_center_rounded;
      case CameraExerciseType.barbellShoulderPress:
        return Icons.sports_gymnastics_rounded;
      case CameraExerciseType.pushPress:
        return Icons.rocket_launch_rounded;
    }
  }
}
