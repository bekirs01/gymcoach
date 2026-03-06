import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/user_profile.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/selection_card.dart';
import 'onboarding_state.dart';

/// Onboarding akışı - 5 adım
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  late OnboardingState _state;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _state = OnboardingState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      setState(() => _currentPage++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final repo = ref.read(userRepositoryProvider);
    final profile = UserProfile(
      firstName: _state.firstName?.trim().isNotEmpty == true ? _state.firstName!.trim() : null,
      lastName: _state.lastName?.trim().isNotEmpty == true ? _state.lastName!.trim() : null,
      gender: _state.gender!,
      age: _state.age!,
      heightCm: _state.heightCm!,
      weightKg: _state.weightKg!,
      goal: _state.goal!,
      activityLevel: _state.activityLevel!,
    );
    await repo.saveProfile(profile);
    if (mounted) context.go('/main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildProgress(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildNameStep(),
                  _buildGenderStep(),
                  _buildBodyStep(),
                  _buildGoalStep(),
                  _buildActivityStep(),
                  _buildSummaryStep(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(6, (i) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: i <= _currentPage ? AppColors.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNameStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Как вас зовут?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Мы будем обращаться к вам по имени.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          TextField(
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Имя',
              hintText: 'Бекир',
            ),
            onChanged: (v) => _state.firstName = v,
          ),
          const SizedBox(height: 16),
          TextField(
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Фамилия',
              hintText: 'Иванов',
            ),
            onChanged: (v) => _state.lastName = v,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Продолжить',
            onPressed: () {
              _state.firstName ??= '';
              _state.lastName ??= '';
              setState(() {});
              _nextPage();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGenderStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ваш пол',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Нам нужно знать это, чтобы создать подходящую программу.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          SelectionCard(
            label: 'Женщина',
            isSelected: _state.gender == Gender.female,
            onTap: () => setState(() {
              _state.gender = Gender.female;
              _nextPage();
            }),
            icon: Icons.female,
          ),
          const SizedBox(height: 12),
          SelectionCard(
            label: 'Мужчина',
            isSelected: _state.gender == Gender.male,
            onTap: () => setState(() {
              _state.gender = Gender.male;
              _nextPage();
            }),
            icon: Icons.male,
          ),
        ],
      ),
    );
  }

  Widget _buildBodyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Данные о теле',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Введите возраст, рост и вес.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Возраст',
              hintText: '25',
              suffixText: 'лет',
            ),
            onChanged: (v) => _state.age = int.tryParse(v),
          ),
          const SizedBox(height: 16),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Рост',
              hintText: '170',
              suffixText: 'см',
            ),
            onChanged: (v) => _state.heightCm = double.tryParse(v),
          ),
          const SizedBox(height: 16),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Вес',
              hintText: '70',
              suffixText: 'кг',
            ),
            onChanged: (v) => _state.weightKg = double.tryParse(v),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Продолжить',
            onPressed: () {
              _state.age ??= 25;
              _state.heightCm ??= 170;
              _state.weightKg ??= 70;
              setState(() {});
              _nextPage();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ваша цель',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Чего вы хотите достичь?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          SelectionCard(
            label: 'Похудеть',
            subtitle: 'Сжигание жира и выносливость',
            isSelected: _state.goal == FitnessGoal.loseWeight,
            onTap: () => setState(() => _state.goal = FitnessGoal.loseWeight),
            icon: Icons.trending_down,
          ),
          const SizedBox(height: 12),
          SelectionCard(
            label: 'Набрать мышечную массу',
            subtitle: 'Сила и объём мышц',
            isSelected: _state.goal == FitnessGoal.gainMuscle,
            onTap: () => setState(() => _state.goal = FitnessGoal.gainMuscle),
            icon: Icons.fitness_center,
          ),
          const SizedBox(height: 12),
          SelectionCard(
            label: 'Поддерживать форму',
            subtitle: 'Общее здоровье и баланс',
            isSelected: _state.goal == FitnessGoal.stayFit,
            onTap: () => setState(() => _state.goal = FitnessGoal.stayFit),
            icon: Icons.self_improvement,
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Продолжить',
            onPressed: _state.goal != null ? _nextPage : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Уровень активности',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Какой у вас опыт тренировок?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          SelectionCard(
            label: 'Начальный',
            subtitle: 'Только начинаю',
            isSelected: _state.activityLevel == ActivityLevel.beginner,
            onTap: () =>
                setState(() => _state.activityLevel = ActivityLevel.beginner),
            icon: Icons.star_outline,
          ),
          const SizedBox(height: 12),
          SelectionCard(
            label: 'Средний',
            subtitle: 'Регулярно тренируюсь',
            isSelected: _state.activityLevel == ActivityLevel.intermediate,
            onTap: () => setState(
                () => _state.activityLevel = ActivityLevel.intermediate),
            icon: Icons.star_half,
          ),
          const SizedBox(height: 12),
          SelectionCard(
            label: 'Продвинутый',
            subtitle: 'Интенсивные тренировки',
            isSelected: _state.activityLevel == ActivityLevel.advanced,
            onTap: () =>
                setState(() => _state.activityLevel = ActivityLevel.advanced),
            icon: Icons.star,
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Продолжить',
            onPressed: _state.activityLevel != null ? _nextPage : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    _state.activityLevel ??= ActivityLevel.beginner;

    String goalText = '';
    switch (_state.goal) {
      case FitnessGoal.loseWeight:
        goalText = 'Похудеть';
        break;
      case FitnessGoal.gainMuscle:
        goalText = 'Набрать мышечную массу';
        break;
      case FitnessGoal.stayFit:
        goalText = 'Поддерживать форму';
        break;
      default:
        goalText = '-';
    }

    String activityText = '';
    switch (_state.activityLevel) {
      case ActivityLevel.beginner:
        activityText = 'Начальный';
        break;
      case ActivityLevel.intermediate:
        activityText = 'Средний';
        break;
      case ActivityLevel.advanced:
        activityText = 'Продвинутый';
        break;
      default:
        activityText = '-';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Сводка',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Проверьте свои данные.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          _summaryRow('Имя', _state.firstName?.isNotEmpty == true ? '${_state.firstName} ${_state.lastName ?? ''}'.trim() : '-'),
          _summaryRow('Пол', _state.gender == Gender.male ? 'Мужчина' : 'Женщина'),
          _summaryRow('Возраст', '${_state.age}'),
          _summaryRow('Рост', '${_state.heightCm} см'),
          _summaryRow('Вес', '${_state.weightKg} кг'),
          _summaryRow('Цель', goalText),
          _summaryRow('Активность', activityText),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Продолжить',
            onPressed: _completeOnboarding,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
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

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: _prevPage,
              child: const Text('Назад'),
            ),
          const Spacer(),
        ],
      ),
    );
  }
}
