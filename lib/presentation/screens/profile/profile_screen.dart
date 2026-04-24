import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/providers.dart';
import '../../../domain/models/user_profile.dart';

/// Profil sayfası - kullanıcı bilgileri
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text(AppConstants.loadDataError)),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text(AppConstants.profileNotFound));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(context, profile),
                const SizedBox(height: 24),
                _buildInfoCard(context, profile),
                const SizedBox(height: 24),
                _buildInfoCenterCard(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                profile.gender == Gender.male ? Icons.male : Icons.female,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.gender == Gender.male ? 'Мужчина' : 'Женщина',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _goalText(profile.goal),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _goalText(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.loseWeight:
        return 'Цель: Похудеть';
      case FitnessGoal.gainMuscle:
        return 'Цель: Набрать мышечную массу';
      case FitnessGoal.stayFit:
        return 'Цель: Поддерживать форму';
    }
  }

  Widget _buildInfoCard(BuildContext context, UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Мои данные',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _infoRow(context, 'Возраст', '${profile.age}'),
            _infoRow(context, 'Рост', '${profile.heightCm} см'),
            _infoRow(context, 'Вес', '${profile.weightKg} кг'),
            _infoRow(context, 'Активность', _activityText(profile.activityLevel)),
          ],
        ),
      ),
    );
  }

  String _activityText(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.beginner:
        return 'Начальный';
      case ActivityLevel.intermediate:
        return 'Средний';
      case ActivityLevel.advanced:
        return 'Продвинутый';
    }
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCenterCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.menu_book),
        title: const Text('База знаний'),
        subtitle: const Text('Руководства и обучающие материалы по фитнесу'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/guide'),
      ),
    );
  }
}
