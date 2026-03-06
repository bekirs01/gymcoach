import 'package:equatable/equatable.dart';

/// Haftanın günleri
enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

/// Plan içindeki egzersiz öğesi
class PlanExercise extends Equatable {
  const PlanExercise({
    required this.exerciseId,
    required this.exerciseName,
    this.sets,
    this.reps,
    this.durationMinutes,
    this.order,
  });

  final String exerciseId;
  final String exerciseName;
  final int? sets;
  final int? reps;
  final int? durationMinutes;
  final int? order;

  @override
  List<Object?> get props => [exerciseId];
}

/// Kullanıcının oluşturduğu antrenman planı
class WorkoutPlan extends Equatable {
  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.weekdays,
    required this.exercises,
    this.createdAt,
  });

  final String id;
  final String name;
  final List<Weekday> weekdays;
  final List<PlanExercise> exercises;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id];
}
