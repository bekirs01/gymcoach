abstract final class ProfileDefaults {
  static const displayName = 'Бекир Сучыкаран';
  static const username = '';
  static const locationText = 'Yekaterinburg, Russia';
  static const weightKg = 78.5;
  static const heightCm = 178.0;
  static const fitnessGoal = 'Strength and conditioning';
  static const trainingFocus = 'Strength training, mobility, and consistency';
  static const experienceLevel = 'intermediate';
  static const activityLevel = 'moderate';
  static const weeklyWorkoutTarget = 4;
  static const publicBio = 'Building consistency one session at a time.';
  static const isPublicProfile = true;

  static const legacyDisplayName = 'Alex Morgan';
  static const legacyMisspelledDisplayName = 'Бекир Сучукаран';

  static String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    if (parts.isEmpty) return '?';
    final p = parts.first;
    return p.length >= 2 ? p.substring(0, 2) : p;
  }

  static String normalizeDisplayName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty ||
        trimmed == legacyDisplayName ||
        trimmed == legacyMisspelledDisplayName) {
      return displayName;
    }
    return trimmed;
  }

  static String weeklyTargetLabel(int target) {
    if (target <= 0) return '$weeklyWorkoutTarget workouts / week';
    if (target == 1) return '1 workout / week';
    return '$target workouts / week';
  }
}
