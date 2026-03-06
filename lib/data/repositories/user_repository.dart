import '../../domain/models/user_profile.dart';

/// Kullanıcı profili repository arayüzü
/// Supabase entegrasyonunda bu interface implement edilecek
abstract class UserRepository {
  Future<UserProfile?> getProfile();
  Future<void> saveProfile(UserProfile profile);
  Future<void> clearProfile();
  Future<bool> hasCompletedOnboarding();
}
