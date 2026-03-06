import '../../../domain/models/user_profile.dart';

/// Onboarding adımlarında toplanan veri
class OnboardingState {
  String? firstName;
  String? lastName;
  Gender? gender;
  int? age;
  double? heightCm;
  double? weightKg;
  FitnessGoal? goal;
  ActivityLevel? activityLevel;
}
