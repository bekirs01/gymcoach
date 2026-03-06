import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/user_profile.dart';
import 'user_repository.dart';

const _keyOnboardingComplete = 'onboarding_complete';
const _keyFirstName = 'first_name';
const _keyLastName = 'last_name';
const _keyGender = 'gender';
const _keyAge = 'age';
const _keyHeight = 'height';
const _keyWeight = 'weight';
const _keyGoal = 'goal';
const _keyActivityLevel = 'activity_level';

/// Local storage ile kullanıcı profili - Supabase'e kolay geçiş için
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<UserProfile?> getProfile() async {
    if (!await hasCompletedOnboarding()) return null;

    final genderIndex = _prefs.getInt(_keyGender);
    if (genderIndex == null) return null;

    return UserProfile(
      firstName: _prefs.getString(_keyFirstName),
      lastName: _prefs.getString(_keyLastName),
      gender: Gender.values[genderIndex],
      age: _prefs.getInt(_keyAge) ?? 25,
      heightCm: _prefs.getDouble(_keyHeight) ?? 170,
      weightKg: _prefs.getDouble(_keyWeight) ?? 70,
      goal: FitnessGoal.values[_prefs.getInt(_keyGoal) ?? 0],
      activityLevel: ActivityLevel.values[_prefs.getInt(_keyActivityLevel) ?? 0],
    );
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setBool(_keyOnboardingComplete, true);
    await _prefs.setString(_keyFirstName, profile.firstName ?? '');
    await _prefs.setString(_keyLastName, profile.lastName ?? '');
    await _prefs.setInt(_keyGender, profile.gender.index);
    await _prefs.setInt(_keyAge, profile.age);
    await _prefs.setDouble(_keyHeight, profile.heightCm);
    await _prefs.setDouble(_keyWeight, profile.weightKg);
    await _prefs.setInt(_keyGoal, profile.goal.index);
    await _prefs.setInt(_keyActivityLevel, profile.activityLevel.index);
  }

  @override
  Future<void> clearProfile() async {
    await _prefs.remove(_keyOnboardingComplete);
    await _prefs.remove(_keyFirstName);
    await _prefs.remove(_keyLastName);
    await _prefs.remove(_keyGender);
    await _prefs.remove(_keyAge);
    await _prefs.remove(_keyHeight);
    await _prefs.remove(_keyWeight);
    await _prefs.remove(_keyGoal);
    await _prefs.remove(_keyActivityLevel);
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }
}
