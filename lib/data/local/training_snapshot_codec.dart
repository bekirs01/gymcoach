import 'dart:convert';

import 'package:flutter/material.dart';

import '../../features/plans/domain/workout_plan.dart';
import '../../features/profile/domain/user_profile.dart';
import '../../features/workout/domain/completed_exercise_log.dart';
import '../../features/workout/domain/workout_completion.dart';

final class TrainingSnapshot {
  const TrainingSnapshot({
    required this.plans,
    required this.completions,
    required this.profile,
  });

  final List<WorkoutPlan> plans;
  final List<WorkoutCompletion> completions;
  final UserProfile profile;

  String encode() {
    return jsonEncode({
      'v': 1,
      'plans': plans.map(_encodePlan).toList(),
      'completions': completions.map(_encodeCompletion).toList(),
      'profile': _encodeProfile(profile),
    });
  }

  static TrainingSnapshot decode(String raw) {
    final o = jsonDecode(raw) as Map<String, dynamic>;
    final plans = (o['plans'] as List<dynamic>)
        .map((e) => _decodePlan(e as Map<String, dynamic>))
        .toList();
    final completions = (o['completions'] as List<dynamic>)
        .map((e) => _decodeCompletion(e as Map<String, dynamic>))
        .toList();
    final profile = _decodeProfile(o['profile'] as Map<String, dynamic>);
    return TrainingSnapshot(plans: plans, completions: completions, profile: profile);
  }
}

Map<String, dynamic> _encodePlan(WorkoutPlan p) {
  return {
    'id': p.id,
    'name': p.name,
    'scheduledDate': '${p.scheduledDate.year}-${p.scheduledDate.month.toString().padLeft(2, '0')}-${p.scheduledDate.day.toString().padLeft(2, '0')}',
    'scheduledHour': p.scheduledTime.hour,
    'scheduledMinute': p.scheduledTime.minute,
    'durationMinutes': p.durationMinutes,
    'difficulty': p.difficulty.name,
    'exerciseNames': p.exerciseNames,
    'status': p.status.name,
  };
}

WorkoutPlan _decodePlan(Map<String, dynamic> m) {
  final ds = m['scheduledDate'] as String;
  final parts = ds.split('-');
  final y = int.parse(parts[0]);
  final mo = int.parse(parts[1]);
  final d = int.parse(parts[2]);
  return WorkoutPlan(
    id: m['id'] as String,
    name: m['name'] as String,
    scheduledDate: DateTime(y, mo, d),
    scheduledTime: TimeOfDay(
      hour: m['scheduledHour'] as int,
      minute: m['scheduledMinute'] as int,
    ),
    durationMinutes: m['durationMinutes'] as int,
    difficulty: PlanDifficulty.values.byName(m['difficulty'] as String),
    exerciseNames: (m['exerciseNames'] as List<dynamic>).cast<String>(),
    status: PlanStatus.values.byName(m['status'] as String),
  );
}

Map<String, dynamic> _encodeCompletion(WorkoutCompletion c) {
  return {
    'id': c.id,
    'title': c.title,
    'workoutType': c.workoutType,
    'completedAt': c.completedAt.toIso8601String(),
    'durationMinutes': c.durationMinutes,
    'calories': c.calories,
    'exerciseNames': c.exerciseNames,
    'exerciseLogs': c.exerciseLogs.map(_encodeExerciseLog).toList(),
    'caloriesAreEstimated': c.caloriesAreEstimated,
  };
}

Map<String, dynamic> _encodeExerciseLog(CompletedExerciseLog e) {
  return {
    'exerciseId': e.exerciseId,
    'exerciseName': e.exerciseName,
    'setsCompleted': e.setsCompleted,
    'repsCompleted': e.repsCompleted,
    'estimatedCalories': e.estimatedCalories,
    'completedAt': e.completedAt.toIso8601String(),
    'categoryKey': e.categoryKey,
  };
}

CompletedExerciseLog _decodeExerciseLog(Map<String, dynamic> m) {
  return CompletedExerciseLog(
    exerciseId: m['exerciseId'] as String,
    exerciseName: m['exerciseName'] as String,
    setsCompleted: m['setsCompleted'] as int,
    repsCompleted: m['repsCompleted'] as int,
    estimatedCalories: m['estimatedCalories'] as int,
    completedAt: DateTime.parse(m['completedAt'] as String),
    categoryKey: m['categoryKey'] as String,
  );
}

WorkoutCompletion _decodeCompletion(Map<String, dynamic> m) {
  final logsRaw = m['exerciseLogs'] as List<dynamic>?;
  final logs = logsRaw == null
      ? const <CompletedExerciseLog>[]
      : logsRaw.map((e) => _decodeExerciseLog(e as Map<String, dynamic>)).toList();
  return WorkoutCompletion(
    id: m['id'] as String,
    title: m['title'] as String,
    workoutType: m['workoutType'] as String,
    completedAt: DateTime.parse(m['completedAt'] as String),
    durationMinutes: m['durationMinutes'] as int,
    calories: m['calories'] as int,
    exerciseNames: (m['exerciseNames'] as List<dynamic>).cast<String>(),
    exerciseLogs: logs,
    caloriesAreEstimated: m['caloriesAreEstimated'] as bool? ?? true,
  );
}

Map<String, dynamic> _encodeProfile(UserProfile p) {
  return {
    'displayName': p.displayName,
    'weightKg': p.weightKg,
    'heightCm': p.heightCm,
    'fitnessGoal': p.fitnessGoal,
    'membershipLevel': p.membershipLevel,
    'notificationsEnabled': p.notificationsEnabled,
  };
}

UserProfile _decodeProfile(Map<String, dynamic> m) {
  return UserProfile(
    displayName: m['displayName'] as String,
    weightKg: (m['weightKg'] as num).toDouble(),
    heightCm: (m['heightCm'] as num).toDouble(),
    fitnessGoal: m['fitnessGoal'] as String,
    membershipLevel: m['membershipLevel'] as String,
    notificationsEnabled: m['notificationsEnabled'] as bool,
  );
}
