import 'package:equatable/equatable.dart';

/// Egzersiz zorluk seviyesi
enum DifficultyLevel { beginner, intermediate, advanced }

/// Egzersiz kategorisi
enum ExerciseCategory {
  arm,
  leg,
  chest,
  back,
  shoulder,
  abs,
  fullBody,
}

/// Tek bir egzersiz modeli
class Exercise extends Equatable {
  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.targetMuscle,
    required this.difficulty,
    required this.description,
    this.durationMinutes,
    this.reps,
    this.sets,
    this.tips,
    this.warnings,
  });

  final String id;
  final String name;
  final ExerciseCategory category;
  final String targetMuscle;
  final DifficultyLevel difficulty;
  final String description;
  final int? durationMinutes;
  final int? reps;
  final int? sets;
  final List<String>? tips;
  final List<String>? warnings;

  String get categoryDisplayName {
    switch (category) {
      case ExerciseCategory.arm:
        return 'Руки';
      case ExerciseCategory.leg:
        return 'Ноги';
      case ExerciseCategory.chest:
        return 'Грудь';
      case ExerciseCategory.back:
        return 'Спина';
      case ExerciseCategory.shoulder:
        return 'Плечи';
      case ExerciseCategory.abs:
        return 'Пресс';
      case ExerciseCategory.fullBody:
        return 'Всё тело';
    }
  }

  String get difficultyDisplayName {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Начальный';
      case DifficultyLevel.intermediate:
        return 'Средний';
      case DifficultyLevel.advanced:
        return 'Продвинутый';
    }
  }

  String get durationOrRepsText {
    if (durationMinutes != null) return '$durationMinutes мин';
    if (reps != null && sets != null) return '$sets x $reps повтор';
    if (reps != null) return '$reps повтор';
    return '-';
  }

  @override
  List<Object?> get props => [id];
}
