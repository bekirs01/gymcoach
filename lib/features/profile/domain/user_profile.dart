class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.weightKg,
    required this.heightCm,
    required this.fitnessGoal,
    required this.membershipLevel,
    required this.notificationsEnabled,
  });

  final String displayName;
  final double weightKg;
  final double heightCm;
  final String fitnessGoal;
  final String membershipLevel;
  final bool notificationsEnabled;

  UserProfile copyWith({
    String? displayName,
    double? weightKg,
    double? heightCm,
    String? fitnessGoal,
    String? membershipLevel,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      membershipLevel: membershipLevel ?? this.membershipLevel,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
