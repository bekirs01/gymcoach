import 'profile_defaults.dart';

class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.weightKg,
    required this.heightCm,
    required this.fitnessGoal,
    required this.membershipLevel,
    required this.notificationsEnabled,
    this.preferredLanguage = 'en',
    this.preferredUnits = 'metric',
    this.trainingReminderTime = '19:00',
    this.trainingReminderDays = 'every_day',
    this.username = '',
    this.publicBio = '',
    this.privateNotes = '',
    this.avatarUrl = '',
    this.coverUrl = '',
    this.isPublicProfile = true,
    this.targetWeightKg,
    this.trainingFocus = '',
    this.experienceLevel = '',
    this.activityLevel = '',
    this.weeklyWorkoutTarget = 0,
    this.locationText = '',
  });

  final String displayName;
  final double weightKg;
  final double heightCm;
  final String fitnessGoal;
  final String membershipLevel;
  final bool notificationsEnabled;
  final String preferredLanguage;
  final String preferredUnits;
  final String trainingReminderTime;
  final String trainingReminderDays;
  final String username;
  final String publicBio;
  final String privateNotes;
  final String avatarUrl;
  final String coverUrl;
  final bool isPublicProfile;
  final double? targetWeightKg;
  final String trainingFocus;
  final String experienceLevel;
  final String activityLevel;
  final int weeklyWorkoutTarget;
  final String locationText;

  String get bio => publicBio;

  bool get isPublic => isPublicProfile;

  UserProfile copyWith({
    String? displayName,
    double? weightKg,
    double? heightCm,
    String? fitnessGoal,
    String? membershipLevel,
    bool? notificationsEnabled,
    String? preferredLanguage,
    String? preferredUnits,
    String? trainingReminderTime,
    String? trainingReminderDays,
    String? username,
    String? publicBio,
    String? privateNotes,
    String? avatarUrl,
    String? coverUrl,
    bool? isPublicProfile,
    double? targetWeightKg,
    bool clearTargetWeightKg = false,
    String? trainingFocus,
    String? experienceLevel,
    String? activityLevel,
    int? weeklyWorkoutTarget,
    String? locationText,
    String? bio,
    bool? isPublic,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      membershipLevel: membershipLevel ?? this.membershipLevel,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredUnits: preferredUnits ?? this.preferredUnits,
      trainingReminderTime: trainingReminderTime ?? this.trainingReminderTime,
      trainingReminderDays: trainingReminderDays ?? this.trainingReminderDays,
      username: username ?? this.username,
      publicBio: bio ?? publicBio ?? this.publicBio,
      privateNotes: privateNotes ?? this.privateNotes,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      isPublicProfile: isPublic ?? isPublicProfile ?? this.isPublicProfile,
      targetWeightKg: clearTargetWeightKg ? null : (targetWeightKg ?? this.targetWeightKg),
      trainingFocus: trainingFocus ?? this.trainingFocus,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      activityLevel: activityLevel ?? this.activityLevel,
      weeklyWorkoutTarget: weeklyWorkoutTarget ?? this.weeklyWorkoutTarget,
      locationText: locationText ?? this.locationText,
    );
  }

  static UserProfile withDefaults({
    required String membershipLevel,
    UserProfile? seed,
  }) {
    final base = seed ?? UserProfile(
      displayName: ProfileDefaults.displayName,
      weightKg: ProfileDefaults.weightKg,
      heightCm: ProfileDefaults.heightCm,
      fitnessGoal: ProfileDefaults.fitnessGoal,
      membershipLevel: membershipLevel,
      notificationsEnabled: true,
      username: ProfileDefaults.username,
      publicBio: ProfileDefaults.publicBio,
      trainingFocus: ProfileDefaults.trainingFocus,
      experienceLevel: ProfileDefaults.experienceLevel,
      activityLevel: ProfileDefaults.activityLevel,
      weeklyWorkoutTarget: ProfileDefaults.weeklyWorkoutTarget,
      locationText: ProfileDefaults.locationText,
      isPublicProfile: ProfileDefaults.isPublicProfile,
    );
    return base.copyWith(
      displayName: ProfileDefaults.normalizeDisplayName(base.displayName),
      username: base.username.trim().isEmpty ? ProfileDefaults.username : base.username,
      publicBio: base.publicBio.trim().isEmpty ? ProfileDefaults.publicBio : base.publicBio,
      trainingFocus: base.trainingFocus.trim().isEmpty ? ProfileDefaults.trainingFocus : base.trainingFocus,
      experienceLevel: base.experienceLevel.trim().isEmpty ? ProfileDefaults.experienceLevel : base.experienceLevel,
      activityLevel: base.activityLevel.trim().isEmpty ? ProfileDefaults.activityLevel : base.activityLevel,
      locationText: base.locationText.trim().isEmpty ? ProfileDefaults.locationText : base.locationText,
      weeklyWorkoutTarget: base.weeklyWorkoutTarget <= 0 ? ProfileDefaults.weeklyWorkoutTarget : base.weeklyWorkoutTarget,
      fitnessGoal: base.fitnessGoal.trim().isEmpty ? ProfileDefaults.fitnessGoal : base.fitnessGoal,
    );
  }
}
