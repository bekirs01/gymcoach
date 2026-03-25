import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/daily_stats_repository.dart';
import '../../data/repositories/daily_stats_repository_impl.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/exercise_repository_impl.dart';
import '../../data/repositories/guide_repository.dart';
import '../../data/repositories/guide_repository_impl.dart';
import '../../data/repositories/league_repository.dart';
import '../../data/repositories/league_repository_impl.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/workout_plan_repository.dart';
import '../../data/repositories/workout_plan_repository_impl.dart';
import '../../domain/models/league.dart';
import '../../domain/models/user_profile.dart';

/// SharedPreferences - main'de override edilir
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError('SharedPreferences must be overridden in main()');
});

/// User repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserRepositoryImpl(prefs);
});

/// Exercise repository
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepositoryImpl();
});

/// Workout plan repository
final workoutPlanRepositoryProvider = Provider<WorkoutPlanRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WorkoutPlanRepositoryImpl(prefs);
});

/// Guide repository
final guideRepositoryProvider = Provider<GuideRepository>((ref) {
  return GuideRepositoryImpl();
});

/// Daily stats repository
final dailyStatsRepositoryProvider = Provider<DailyStatsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DailyStatsRepositoryImpl(prefs);
});

/// Lig puanları
final leagueRepositoryProvider = Provider<LeagueRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LeagueRepositoryImpl(prefs);
});

/// Lig tablosu (profil adı ile)
final leagueStandingsProvider = FutureProvider<List<LeagueStanding>>((ref) async {
  final profile = await ref.watch(userProfileProvider.future);
  final name = profile?.firstName;
  final repo = ref.watch(leagueRepositoryProvider);
  return repo.getStandings(name);
});

/// Onboarding tamamlandı mı
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.hasCompletedOnboarding();
});

/// Kullanıcı profili
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getProfile();
});
