import 'package:flutter/material.dart';

import 'plan_exercise.dart';

enum PlanDifficulty { beginner, intermediate, advanced }

enum PlanStatus { planned, completed, missed }

class WorkoutPlan {
  WorkoutPlan({
    required this.id,
    required this.name,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.durationMinutes,
    required this.difficulty,
    List<PlanExercise>? exercises,
    List<String>? exerciseNames,
    required this.status,
  }) : exercises = exercises ??
            (exerciseNames ?? const [])
                .map((n) => PlanExercise(name: n))
                .toList();

  final String id;
  final String name;
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final int durationMinutes;
  final PlanDifficulty difficulty;
  final List<PlanExercise> exercises;
  final PlanStatus status;

  List<String> get exerciseNames => exercises.map((e) => e.name).toList();

  String get formattedDate {
    final m = scheduledDate.month.toString().padLeft(2, '0');
    final d = scheduledDate.day.toString().padLeft(2, '0');
    return '${scheduledDate.year}-$m-$d';
  }

  String get formattedTime {
    final h = scheduledTime.hour.toString().padLeft(2, '0');
    final min = scheduledTime.minute.toString().padLeft(2, '0');
    return '$h:$min';
  }

  static DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static DateTime mondayContaining(DateTime ref) {
    final day = dateOnly(ref);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  static bool isInSameCalendarWeek(DateTime planDate, DateTime reference) {
    final planDay = dateOnly(planDate);
    final mon = mondayContaining(reference);
    final sun = mon.add(const Duration(days: 7));
    return !planDay.isBefore(mon) && planDay.isBefore(sun);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  WorkoutPlan copyWith({
    String? id,
    String? name,
    DateTime? scheduledDate,
    TimeOfDay? scheduledTime,
    int? durationMinutes,
    PlanDifficulty? difficulty,
    List<PlanExercise>? exercises,
    PlanStatus? status,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      difficulty: difficulty ?? this.difficulty,
      exercises: exercises ?? List<PlanExercise>.from(this.exercises),
      status: status ?? this.status,
    );
  }
}
