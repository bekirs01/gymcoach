import 'dart:convert';

import 'package:flutter/material.dart';

import '../../features/plans/domain/plan_exercise.dart';
import '../../features/plans/domain/workout_plan.dart';
import '../../features/plans/domain/workout_template.dart';
import '../../features/profile/domain/profile_defaults.dart';
import '../../features/profile/domain/user_profile.dart';
import '../../features/workout/domain/completed_exercise_log.dart';
import '../../features/workout/domain/workout_completion.dart';

final class TrainingSnapshot {
  const TrainingSnapshot({
    required this.plans,
    required this.completions,
    required this.profile,
    this.templates = const [],
  });

  final List<WorkoutPlan> plans;
  final List<WorkoutCompletion> completions;
  final UserProfile profile;
  final List<WorkoutTemplate> templates;

  String encode() {
    return jsonEncode({
      'v': 2,
      'plans': plans.map(_encodePlan).toList(),
      'completions': completions.map(_encodeCompletion).toList(),
      'profile': _encodeProfile(profile),
      'templates': templates.map(_encodeTemplate).toList(),
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
    final templatesRaw = o['templates'] as List<dynamic>?;
    final templates = templatesRaw == null
        ? const <WorkoutTemplate>[]
        : templatesRaw.map((e) => _decodeTemplate(e as Map<String, dynamic>)).toList();
    return TrainingSnapshot(
      plans: plans,
      completions: completions,
      profile: profile,
      templates: templates,
    );
  }
}

Map<String, dynamic> _encodePlanExercise(PlanExercise e) {
  return {
    'name': e.name,
    'defaultSets': e.defaultSets,
    'defaultReps': e.defaultReps,
  };
}

PlanExercise _decodePlanExercise(Map<String, dynamic> m) {
  return PlanExercise(
    name: m['name'] as String,
    defaultSets: m['defaultSets'] as int? ?? 3,
    defaultReps: m['defaultReps'] as int? ?? 10,
  );
}

List<PlanExercise> _decodePlanExercises(Map<String, dynamic> m) {
  final exercisesRaw = m['exercises'] as List<dynamic>?;
  if (exercisesRaw != null) {
    return exercisesRaw.map((e) => _decodePlanExercise(e as Map<String, dynamic>)).toList();
  }
  final names = (m['exerciseNames'] as List<dynamic>?)?.cast<String>() ?? const <String>[];
  return names.map((n) => PlanExercise(name: n)).toList();
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
    'exercises': p.exercises.map(_encodePlanExercise).toList(),
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
    exercises: _decodePlanExercises(m),
    status: PlanStatus.values.byName(m['status'] as String),
  );
}

Map<String, dynamic> _encodeTemplate(WorkoutTemplate t) {
  return {
    'id': t.id,
    'name': t.name,
    'durationMinutes': t.durationMinutes,
    'difficulty': t.difficulty.name,
    'exercises': t.exercises.map(_encodePlanExercise).toList(),
  };
}

WorkoutTemplate _decodeTemplate(Map<String, dynamic> m) {
  final exercisesRaw = m['exercises'] as List<dynamic>;
  return WorkoutTemplate(
    id: m['id'] as String,
    name: m['name'] as String,
    durationMinutes: m['durationMinutes'] as int,
    difficulty: PlanDifficulty.values.byName(m['difficulty'] as String),
    exercises: exercisesRaw.map((e) => _decodePlanExercise(e as Map<String, dynamic>)).toList(),
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
    'bio': p.publicBio,
    'publicBio': p.publicBio,
    'privateNotes': p.privateNotes,
    'avatarUrl': p.avatarUrl,
    'coverUrl': p.coverUrl,
    'isPublic': p.isPublicProfile,
    'username': p.username,
    'targetWeightKg': p.targetWeightKg,
    'trainingFocus': p.trainingFocus,
    'experienceLevel': p.experienceLevel,
    'activityLevel': p.activityLevel,
    'weeklyWorkoutTarget': p.weeklyWorkoutTarget,
    'locationText': p.locationText,
  };
}

UserProfile _decodeProfile(Map<String, dynamic> m) {
  final displayName = ProfileDefaults.normalizeDisplayName(m['displayName'] as String? ?? '');
  return UserProfile(
    displayName: displayName,
    weightKg: (m['weightKg'] as num?)?.toDouble() ?? ProfileDefaults.weightKg,
    heightCm: (m['heightCm'] as num?)?.toDouble() ?? ProfileDefaults.heightCm,
    fitnessGoal: m['fitnessGoal'] as String? ?? ProfileDefaults.fitnessGoal,
    membershipLevel: m['membershipLevel'] as String? ?? '',
    notificationsEnabled: m['notificationsEnabled'] as bool? ?? true,
    publicBio: m['publicBio'] as String? ?? m['bio'] as String? ?? '',
    privateNotes: m['privateNotes'] as String? ?? '',
    avatarUrl: m['avatarUrl'] as String? ?? '',
    coverUrl: m['coverUrl'] as String? ?? '',
    isPublicProfile: m['isPublic'] as bool? ?? true,
    username: m['username'] as String? ?? '',
    targetWeightKg: (m['targetWeightKg'] as num?)?.toDouble(),
    trainingFocus: m['trainingFocus'] as String? ?? '',
    experienceLevel: m['experienceLevel'] as String? ?? '',
    activityLevel: m['activityLevel'] as String? ?? '',
    weeklyWorkoutTarget: m['weeklyWorkoutTarget'] as int? ?? 0,
    locationText: m['locationText'] as String? ?? '',
  );
}
