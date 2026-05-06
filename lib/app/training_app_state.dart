import 'package:flutter/foundation.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../core/seed_data.dart';
import '../data/local/training_snapshot_codec.dart';
import '../features/plans/domain/workout_plan.dart';
import '../features/profile/domain/user_profile.dart';
import '../features/workout/domain/workout_completion.dart';
import '../shared/repositories/training_persistence_repository.dart';

final class TrainingAppState extends ChangeNotifier {
  TrainingAppState({required TrainingPersistenceRepository persistence}) : _persistence = persistence;

  final TrainingPersistenceRepository _persistence;

  var _bootstrapped = false;
  var _ready = false;
  String? _localeName;

  bool get isReady => _ready;

  List<WorkoutPlan> _plans = [];
  List<WorkoutCompletion> _completions = [];
  late UserProfile _profile;

  List<WorkoutPlan> get plans => List.unmodifiable(_plans);
  List<WorkoutCompletion> get completions => List.unmodifiable(_completions);
  UserProfile get profile => _profile;

  Future<void> ensureBootstrapped(AppLocalizations l10n) async {
    if (_bootstrapped) {
      if (_localeName == l10n.localeName) return;
      _localeName = l10n.localeName;
      _plans = mergeSeedPlans(_plans, seedPlans(l10n));
      _completions = mergeSeedCompletions(_completions, seedCompletions(l10n));
      _profile = _localizedProfile(_profile, l10n);
      notifyListeners();
      await _persist();
      return;
    }
    _bootstrapped = true;
    _localeName = l10n.localeName;
    final existing = await _persistence.load();
    if (existing != null) {
      _plans = List<WorkoutPlan>.from(existing.plans);
      _completions = List<WorkoutCompletion>.from(existing.completions);
      _profile = existing.profile;
    } else {
      _plans = mergeSeedPlans([], seedPlans(l10n));
      _completions = mergeSeedCompletions([], seedCompletions(l10n));
      _profile = UserProfile(
        displayName: 'Alex Morgan',
        weightKg: 78.5,
        heightCm: 178,
        fitnessGoal: l10n.profileDefaultGoal,
        membershipLevel: l10n.membershipPremium,
        notificationsEnabled: true,
      );
      await _persist();
    }
    _ready = true;
    notifyListeners();
  }

  UserProfile _localizedProfile(UserProfile profile, AppLocalizations l10n) {
    final knownGoals = {'Strength and conditioning', 'Сила и общая подготовка'};
    final knownMemberships = {
      'Free': l10n.membershipFree,
      'Basic': l10n.membershipFree,
      'Базовый': l10n.membershipFree,
      'Plus': l10n.membershipPlus,
      'Плюс': l10n.membershipPlus,
      'Premium': l10n.membershipPremium,
      'Премиум': l10n.membershipPremium,
    };
    return profile.copyWith(
      fitnessGoal: knownGoals.contains(profile.fitnessGoal) ? l10n.profileDefaultGoal : profile.fitnessGoal,
      membershipLevel: knownMemberships[profile.membershipLevel] ?? profile.membershipLevel,
    );
  }

  Future<void> _persist() async {
    await _persistence.save(
      TrainingSnapshot(
        plans: _plans,
        completions: _completions,
        profile: _profile,
      ),
    );
  }

  Future<void> addPlan(WorkoutPlan plan) async {
    _plans.insert(0, plan);
    notifyListeners();
    await _persist();
  }

  Future<void> upsertPlan(WorkoutPlan plan) async {
    final i = _plans.indexWhere((p) => p.id == plan.id);
    if (i >= 0) {
      _plans[i] = plan;
    } else {
      _plans.insert(0, plan);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> removePlan(WorkoutPlan plan) async {
    _plans.removeWhere((p) => p.id == plan.id);
    notifyListeners();
    await _persist();
  }

  Future<void> completePlanSession(WorkoutPlan plan, WorkoutCompletion completion) async {
    final i = _plans.indexWhere((p) => p.id == plan.id);
    if (i >= 0) {
      _plans[i] = _plans[i].copyWith(status: PlanStatus.completed);
    }
    _completions.insert(0, completion);
    notifyListeners();
    await _persist();
  }

  Future<void> insertCompletionOnly(WorkoutCompletion completion) async {
    _completions.insert(0, completion);
    notifyListeners();
    await _persist();
  }

  Future<void> updateProfile(UserProfile next) async {
    _profile = next;
    notifyListeners();
    await _persist();
  }
}
