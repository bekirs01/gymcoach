class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.weightKg,
    required this.heightCm,
    required this.fitnessGoal,
    required this.membershipLevel,
    required this.notificationsEnabled,
    this.bio = '',
    this.privateNotes = '',
    this.avatarUrl = '',
    this.coverUrl = '',
    this.isPublic = true,
  });

  final String displayName;
  final double weightKg;
  final double heightCm;
  final String fitnessGoal;
  final String membershipLevel;
  final bool notificationsEnabled;
  final String bio;
  final String privateNotes;
  final String avatarUrl;
  final String coverUrl;
  final bool isPublic;

  UserProfile copyWith({
    String? displayName,
    double? weightKg,
    double? heightCm,
    String? fitnessGoal,
    String? membershipLevel,
    bool? notificationsEnabled,
    String? bio,
    String? privateNotes,
    String? avatarUrl,
    String? coverUrl,
    bool? isPublic,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      membershipLevel: membershipLevel ?? this.membershipLevel,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      bio: bio ?? this.bio,
      privateNotes: privateNotes ?? this.privateNotes,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
