import 'package:equatable/equatable.dart';

/// Kullanıcı cinsiyeti
enum Gender { male, female }

/// Fitness hedefi
enum FitnessGoal { loseWeight, gainMuscle, stayFit }

/// Aktivite seviyesi
enum ActivityLevel { beginner, intermediate, advanced }

/// Onboarding tamamlanmış kullanıcı profili
/// Supabase entegrasyonu için uyumlu yapı
class UserProfile extends Equatable {
  const UserProfile({
    required this.gender,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.activityLevel,
    this.id,
    this.firstName,
    this.lastName,
    this.createdAt,
  });

  final String? id;
  final String? firstName;
  final String? lastName;
  final Gender gender;

  /// İsim + soyisim (gösterim için)
  String get displayName {
    if (firstName != null && lastName != null && lastName!.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    return firstName ?? '';
  }
  final int age;
  final double heightCm;
  final double weightKg;
  final FitnessGoal goal;
  final ActivityLevel activityLevel;
  final DateTime? createdAt;

  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    Gender? gender,
    int? age,
    double? heightCm,
    double? weightKg,
    FitnessGoal? goal,
    ActivityLevel? activityLevel,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, firstName, lastName, gender, age, heightCm, weightKg, goal, activityLevel];
}
