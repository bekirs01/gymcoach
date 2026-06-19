import 'package:flutter/material.dart';

import '../../../core/workout_exercise_catalog.dart';
import '../../plans/domain/plan_exercise.dart';
import '../../plans/domain/workout_plan.dart';

class SharedWorkoutExerciseSnapshot {
  const SharedWorkoutExerciseSnapshot({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.targetMuscle,
    required this.equipment,
    required this.orderIndex,
  });

  final String name;
  final String imageUrl;
  final String description;
  final int sets;
  final int reps;
  final int restSeconds;
  final String targetMuscle;
  final String equipment;
  final int orderIndex;

  factory SharedWorkoutExerciseSnapshot.fromJson(Map<String, dynamic> json) {
    return SharedWorkoutExerciseSnapshot(
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      sets: (json['sets'] as num?)?.toInt() ?? 3,
      reps: (json['reps'] as num?)?.toInt() ?? 10,
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 60,
      targetMuscle: json['targetMuscle'] as String? ?? '',
      equipment: json['equipment'] as String? ?? '',
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'targetMuscle': targetMuscle,
      'equipment': equipment,
      'orderIndex': orderIndex,
    };
  }

  PlanExercise toPlanExercise() {
    return PlanExercise(
      name: name,
      defaultSets: sets,
      defaultReps: reps,
    );
  }
}

class SharedWorkoutSnapshot {
  const SharedWorkoutSnapshot({
    required this.originalWorkoutId,
    required this.name,
    required this.imageUrl,
    required this.exercises,
    required this.exerciseCount,
    required this.estimatedDuration,
    required this.muscleGroup,
    required this.createdByUserId,
    required this.difficulty,
    required this.scheduledTime,
  });

  final String originalWorkoutId;
  final String name;
  final String imageUrl;
  final List<SharedWorkoutExerciseSnapshot> exercises;
  final int exerciseCount;
  final int estimatedDuration;
  final String muscleGroup;
  final String createdByUserId;
  final String difficulty;
  final String scheduledTime;

  factory SharedWorkoutSnapshot.fromJson(Map<String, dynamic> json) {
    final exerciseRows = json['exercises'] as List<dynamic>? ?? const [];
    final exercises = exerciseRows
        .map((row) => SharedWorkoutExerciseSnapshot.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return SharedWorkoutSnapshot(
      originalWorkoutId: json['originalWorkoutId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      exercises: exercises,
      exerciseCount: (json['exerciseCount'] as num?)?.toInt() ?? exercises.length,
      estimatedDuration: (json['estimatedDuration'] as num?)?.toInt() ?? 45,
      muscleGroup: json['muscleGroup'] as String? ?? '',
      createdByUserId: json['createdByUserId'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'beginner',
      scheduledTime: json['scheduledTime'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalWorkoutId': originalWorkoutId,
      'name': name,
      'imageUrl': imageUrl,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'exerciseCount': exerciseCount,
      'estimatedDuration': estimatedDuration,
      'muscleGroup': muscleGroup,
      'createdByUserId': createdByUserId,
      'difficulty': difficulty,
      'scheduledTime': scheduledTime,
    };
  }

  factory SharedWorkoutSnapshot.fromWorkoutPlan(
    WorkoutPlan plan, {
    required String createdByUserId,
  }) {
    final firstExercise = plan.exercises.isEmpty ? null : plan.exercises.first.name;
    final imageUrl = WorkoutExerciseCatalog.imageForName(firstExercise) ?? '';
    final muscleGroup = WorkoutExerciseCatalog.categoryTitleForName(firstExercise) ?? '';

    final exercises = <SharedWorkoutExerciseSnapshot>[];
    for (var i = 0; i < plan.exercises.length; i++) {
      final exercise = plan.exercises[i];
      final entry = WorkoutExerciseCatalog.entryForName(exercise.name);
      exercises.add(
        SharedWorkoutExerciseSnapshot(
          name: exercise.name,
          imageUrl: entry?.imageAsset ?? WorkoutExerciseCatalog.imageForName(exercise.name) ?? '',
          description: entry?.description ?? '',
          sets: exercise.defaultSets,
          reps: exercise.defaultReps,
          restSeconds: 60,
          targetMuscle: WorkoutExerciseCatalog.categoryTitleForName(exercise.name) ?? '',
          equipment: '',
          orderIndex: i,
        ),
      );
    }

    return SharedWorkoutSnapshot(
      originalWorkoutId: plan.id,
      name: plan.name,
      imageUrl: imageUrl,
      exercises: exercises,
      exerciseCount: plan.exercises.length,
      estimatedDuration: plan.durationMinutes,
      muscleGroup: muscleGroup,
      createdByUserId: createdByUserId,
      difficulty: plan.difficulty.name,
      scheduledTime: plan.formattedTime,
    );
  }

  WorkoutPlan toWorkoutPlan({required String newId, required String name}) {
    final now = DateTime.now();
    final planDifficulty = PlanDifficulty.values.firstWhere(
      (value) => value.name == difficulty,
      orElse: () => PlanDifficulty.beginner,
    );
    final parts = scheduledTime.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 18 : 18;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 30 : 30;

    return WorkoutPlan(
      id: newId,
      name: name,
      scheduledDate: WorkoutPlan.dateOnly(now),
      scheduledTime: TimeOfDay(hour: hour, minute: minute),
      durationMinutes: estimatedDuration,
      difficulty: planDifficulty,
      exercises: exercises.map((e) => e.toPlanExercise()).toList(),
      status: PlanStatus.planned,
    );
  }
}
