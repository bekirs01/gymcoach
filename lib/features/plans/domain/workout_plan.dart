import 'package:flutter/material.dart';

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
    required this.exerciseNames,
    required this.status,
  });

  final String id;
  final String name;
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final int durationMinutes;
  final PlanDifficulty difficulty;
  final List<String> exerciseNames;
  final PlanStatus status;

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
    List<String>? exerciseNames,
    PlanStatus? status,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      difficulty: difficulty ?? this.difficulty,
      exerciseNames: exerciseNames ?? List<String>.from(this.exerciseNames),
      status: status ?? this.status,
    );
  }

  static List<WorkoutPlan> samplePlans() {
    final now = DateTime.now();
    final today = dateOnly(now);

    return [
      WorkoutPlan(
        id: 'seed_push',
        name: 'Push Day',
        scheduledDate: today,
        scheduledTime: const TimeOfDay(hour: 18, minute: 30),
        durationMinutes: 45,
        difficulty: PlanDifficulty.intermediate,
        exerciseNames: const ['Push-ups', 'Shoulder Press', 'Pull-ups'],
        status: PlanStatus.planned,
      ),
      WorkoutPlan(
        id: 'seed_lower',
        name: 'Lower Body',
        scheduledDate: today.add(const Duration(days: 1)),
        scheduledTime: const TimeOfDay(hour: 17, minute: 0),
        durationMinutes: 50,
        difficulty: PlanDifficulty.intermediate,
        exerciseNames: const ['Squats', 'Lunges', 'Running'],
        status: PlanStatus.planned,
      ),
      WorkoutPlan(
        id: 'seed_cardio',
        name: 'Cardio Session',
        scheduledDate: today.subtract(const Duration(days: 1)),
        scheduledTime: const TimeOfDay(hour: 7, minute: 15),
        durationMinutes: 35,
        difficulty: PlanDifficulty.beginner,
        exerciseNames: const ['Running', 'Jumping Jacks'],
        status: PlanStatus.completed,
      ),
      WorkoutPlan(
        id: 'seed_core',
        name: 'Core Stability',
        scheduledDate: today.subtract(const Duration(days: 3)),
        scheduledTime: const TimeOfDay(hour: 12, minute: 0),
        durationMinutes: 28,
        difficulty: PlanDifficulty.advanced,
        exerciseNames: const ['Plank', 'Lunges'],
        status: PlanStatus.missed,
      ),
    ];
  }
}
