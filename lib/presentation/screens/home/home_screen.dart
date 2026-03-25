import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/main_nav_provider.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/user_profile.dart';

/// Motivasyon mesajları - her 3 saatte bir değişir (8 mesaj)
const _motivationMessages = [
  'Маленькие шаги ведут к большим переменам. Сегодня ты молодец! 💪',
  'Дисциплина — мост между целями и достижениями. Продолжай! 🔥',
  'Твоё тело может всё. Поверь в себя! ✨',
  'Каждая тренировка приближает тебя к цели. Не сдавайся! 🌟',
  'Сила не в мышцах, а в упорстве. Ты на правильном пути! 💪',
  'Отдых — часть прогресса. Восстанавливайся и возвращайся сильнее! 🏋️',
  'Сегодняшние усилия — завтрашние результаты. Гордись собой! ⭐',
  'Ты сильнее, чем думаешь. Докажи это себе! 🎯',
];

String _getMotivationForHour(int hour) {
  final index = (hour / 3).floor() % 8;
  return _motivationMessages[index];
}

/// Ana sayfa - koyu tema, iOS tarzı
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(_todayStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            color: Colors.white70,
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userProfileProvider);
              ref.invalidate(_todayStatsProvider);
            },
            color: AppColors.primary,
            backgroundColor: const Color(0xFF1C2128),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(context, profile),
                  const SizedBox(height: 20),
                  _buildGoalCard(context, profile),
                  const SizedBox(height: 20),
                  _buildTodayStats(context, statsAsync),
                  const SizedBox(height: 20),
                  _buildLeagueCard(context),
                  const SizedBox(height: 20),
                  _buildRecommendedExercises(context, ref),
                  const SizedBox(height: 20),
                  _buildMotivationCard(context),
                  const SizedBox(height: 20),
                  _buildInfoCenterCard(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, UserProfile profile) {
    final greeting = _getGreeting(profile);
    return _iOSCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getGoalAdvice(profile.goal),
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(UserProfile profile) {
    final hour = DateTime.now().hour;
    String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Доброе утро';
    } else if (hour < 18) {
      timeGreeting = 'Добрый день';
    } else {
      timeGreeting = 'Добрый вечер';
    }
    final name = profile.firstName?.trim();
    if (name != null && name.isNotEmpty) {
      return '$timeGreeting, $name! 👋';
    }
    return '$timeGreeting! 👋';
  }

  String _getGoalAdvice(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.loseWeight:
        return 'Сегодня рекомендуем лёгкое кардио и силовую тренировку. Поддерживайте дефицит калорий.';
      case FitnessGoal.gainMuscle:
        return 'Увеличьте потребление белка и сосредоточьтесь на силовых тренировках. Достаточный сон критичен для роста мышц.';
      case FitnessGoal.stayFit:
        return 'Продолжайте сбалансированную программу тренировок и питания. Постоянство — ключ к успеху.';
    }
  }

  Widget _buildGoalCard(BuildContext context, UserProfile profile) {
    return _iOSCard(
      context,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withOpacity(0.25),
          AppColors.primary.withOpacity(0.08),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.flag_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Цель на сегодня',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _getDailyGoalText(profile),
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  String _getDailyGoalText(UserProfile profile) {
    switch (profile.goal) {
      case FitnessGoal.loseWeight:
        return '• 30-45 мин упражнений\n• 8 стаканов воды\n• Поддерживать дефицит калорий';
      case FitnessGoal.gainMuscle:
        return '• Силовая тренировка\n• Высокобелковые приёмы пищи\n• 7-8 часов сна';
      case FitnessGoal.stayFit:
        return '• Сбалансированная тренировка\n• Здоровое питание\n• Оставайтесь активными';
    }
  }

  Widget _buildTodayStats(BuildContext context, AsyncValue<Map<String, int>> statsAsync) {
    return statsAsync.when(
      loading: () => _iOSCard(
        context,
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) => _iOSCard(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сводка за сегодня',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _statChip(context, Icons.water_drop_rounded, '${stats['water'] ?? 0}/8', 'Вода', const Color(0xFF0EA5E9)),
                const SizedBox(width: 12),
                _statChip(context, Icons.directions_walk_rounded, '${stats['steps'] ?? 0}', 'Шаги', const Color(0xFF22C55E)),
                const SizedBox(width: 12),
                _statChip(context, Icons.local_fire_department_rounded, '${stats['calories'] ?? 0}', 'Калор', const Color(0xFFF97316)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(BuildContext context, IconData icon, String value, String label, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2128),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: accentColor),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedExercises(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Рекомендуемые упражнения',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () => ref.read(mainNavIndexProvider.notifier).state = 1,
              child: Text(
                'Все',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: FutureBuilder(
            future: ref.read(exerciseRepositoryProvider).getAllExercises(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final exercises = snapshot.data!.take(3).toList();
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: exercises.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final ex = exercises[i];
                  return SizedBox(
                    width: 160,
                    child: _iOSCard(
                      context,
                      onTap: () => context.push('/exercise/${ex.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.fitness_center_rounded, color: AppColors.primary, size: 24),
                          ),
                          const Spacer(),
                          Text(
                            ex.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ex.durationOrRepsText,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationCard(BuildContext context) {
    final message = _getMotivationForHour(DateTime.now().hour);
    return _iOSCard(
      context,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.secondary.withOpacity(0.2),
          AppColors.secondary.withOpacity(0.06),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 28, color: AppColors.secondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Мотивация',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeagueCard(BuildContext context) {
    return _iOSCard(
      context,
      onTap: () => context.push('/league'),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.emoji_events_rounded, size: 28, color: AppColors.secondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Лига',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Соревнуйся: камера + скоро второй зачёт',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.4), size: 24),
        ],
      ),
    );
  }

  Widget _buildInfoCenterCard(BuildContext context) {
    return _iOSCard(
      context,
      onTap: () => context.push('/guide'),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.menu_book_rounded, size: 28, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'База знаний',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Руководства и обучающие материалы по фитнесу',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.4), size: 24),
        ],
      ),
    );
  }

  /// iOS tarzı kart - yuvarlatılmış, koyu tema
  Widget _iOSCard(
    BuildContext context, {
    required Widget child,
    Gradient? gradient,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: gradient,
            color: gradient == null ? const Color(0xFF1C2128) : null,
            border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

final _todayStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.watch(dailyStatsRepositoryProvider);
  final stats = await repo.getTodayStats();
  return {
    'water': stats.waterGlasses,
    'steps': stats.steps,
    'calories': stats.caloriesBurned + stats.caloriesConsumed,
  };
});
