import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/device_user_id.dart';
import '../../features/plans/domain/plan_exercise.dart';
import '../../features/plans/domain/workout_plan.dart';
import '../../features/plans/domain/workout_template.dart';
import '../../features/profile/domain/user_profile.dart';
import '../../features/workout/domain/completed_exercise_log.dart';
import '../../features/workout/domain/workout_completion.dart';
import '../../shared/repositories/training_persistence_repository.dart';
import '../local/training_snapshot_codec.dart';

final class SupabaseTrainingPersistence implements TrainingPersistenceRepository {
  SupabaseTrainingPersistence({
    required SharedPreferences prefs,
    SupabaseClient? client,
  })  : _prefs = prefs,
        _client = client ?? Supabase.instance.client;

  final SharedPreferences _prefs;
  final SupabaseClient _client;
  String? _userId;

  Future<String> _deviceId() async {
    _userId ??= await DeviceUserId.resolve(_prefs);
    return _userId!;
  }

  @override
  Future<TrainingSnapshot?> load() async {
    try {
      final uid = await _deviceId();

      final profileRow = await _client.from('profiles').select().eq('id', uid).maybeSingle();
      if (profileRow == null) return null;

      final planRows = await _client
          .from('workout_plans')
          .select('*, workout_plan_exercises(sort_order, exercise_name)')
          .eq('user_id', uid)
          .order('scheduled_date', ascending: false);

      final completionRows = await _client
          .from('workout_completions')
          .select('*, workout_completion_exercises(*)')
          .eq('user_id', uid)
          .order('completed_at', ascending: false);

      final templates = await _loadTemplates(uid);

      return TrainingSnapshot(
        profile: _profileFromRow(profileRow),
        plans: planRows.map(_planFromRow).toList(),
        completions: completionRows.map(_completionFromRow).toList(),
        templates: templates,
      );
    } catch (e, st) {
      debugPrint('Supabase load failed: $e\n$st');
      return null;
    }
  }

  @override
  Future<void> save(TrainingSnapshot snapshot) async {
    try {
      final uid = await _deviceId();
      final profile = snapshot.profile;

      await _client.from('profiles').upsert({
        'id': uid,
        'display_name': profile.displayName,
        'weight_kg': profile.weightKg,
        'height_cm': profile.heightCm,
        'fitness_goal': profile.fitnessGoal,
        'membership_level': profile.membershipLevel,
        'notifications_enabled': profile.notificationsEnabled,
        'preferred_language': profile.preferredLanguage,
        'preferred_units': profile.preferredUnits,
        'training_reminders_enabled': profile.notificationsEnabled,
        'training_reminder_time': profile.trainingReminderTime,
        'training_reminder_days': profile.trainingReminderDays,
        'bio': profile.bio,
        'private_notes': profile.privateNotes,
        'avatar_url': profile.avatarUrl,
        'cover_url': profile.coverUrl,
        'is_public': profile.isPublic,
      });

      final userPlans = snapshot.plans;
      await _client.from('workout_plans').delete().eq('user_id', uid);

      if (userPlans.isNotEmpty) {
        await _client.from('workout_plans').insert(
          userPlans.map((p) => _planToRow(p, uid)).toList(),
        );

        final planExercises = <Map<String, dynamic>>[];
        for (final plan in userPlans) {
          for (var i = 0; i < plan.exercises.length; i++) {
            final ex = plan.exercises[i];
            planExercises.add({
              'plan_id': plan.id,
              'sort_order': i,
              'exercise_name': ex.name,
              'default_sets': ex.defaultSets,
              'default_reps': ex.defaultReps,
            });
          }
        }
        if (planExercises.isNotEmpty) {
          await _client.from('workout_plan_exercises').insert(planExercises);
        }
      }

      final userCompletions = snapshot.completions;
      await _client.from('workout_completions').delete().eq('user_id', uid);

      if (userCompletions.isEmpty) return;

      await _client.from('workout_completions').insert(
        userCompletions.map((c) => _completionToRow(c, uid)).toList(),
      );

      final exerciseLogs = <Map<String, dynamic>>[];
      for (final completion in userCompletions) {
        for (final log in completion.exerciseLogs) {
          exerciseLogs.add(_exerciseLogToRow(log, completion.id));
        }
      }
      if (exerciseLogs.isNotEmpty) {
        await _client.from('workout_completion_exercises').insert(exerciseLogs);
      }

      await _saveTemplates(uid, snapshot.templates);
    } catch (e, st) {
      debugPrint('Supabase save failed: $e\n$st');
      rethrow;
    }
  }

  UserProfile _profileFromRow(Map<String, dynamic> row) {
    return UserProfile(
      displayName: row['display_name'] as String? ?? '',
      weightKg: (row['weight_kg'] as num?)?.toDouble() ?? 70,
      heightCm: (row['height_cm'] as num?)?.toDouble() ?? 170,
      fitnessGoal: row['fitness_goal'] as String? ?? '',
      membershipLevel: row['membership_level'] as String? ?? '',
      notificationsEnabled:
          row['training_reminders_enabled'] as bool? ?? row['notifications_enabled'] as bool? ?? true,
      preferredLanguage: row['preferred_language'] as String? ?? 'en',
      preferredUnits: row['preferred_units'] as String? ?? 'metric',
      trainingReminderTime: row['training_reminder_time'] as String? ?? '19:00',
      trainingReminderDays: row['training_reminder_days'] as String? ?? 'every_day',
      publicBio: row['public_bio'] as String? ?? row['bio'] as String? ?? '',
      privateNotes: row['private_notes'] as String? ?? '',
      avatarUrl: row['avatar_url'] as String? ?? '',
      coverUrl: row['cover_url'] as String? ?? '',
      isPublicProfile: row['is_public_profile'] as bool? ?? row['is_public'] as bool? ?? true,
    );
  }

  WorkoutPlan _planFromRow(Map<String, dynamic> row) {
    final exercisesRaw = row['workout_plan_exercises'] as List<dynamic>? ?? const [];
    final sorted = exercisesRaw.map((e) => e as Map<String, dynamic>).toList()
      ..sort((a, b) => (a['sort_order'] as int).compareTo(b['sort_order'] as int));

    final dateStr = row['scheduled_date'] as String;
    final dateParts = dateStr.split('-');

    return WorkoutPlan(
      id: row['id'] as String,
      name: row['name'] as String,
      scheduledDate: DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      ),
      scheduledTime: TimeOfDay(
        hour: row['scheduled_hour'] as int,
        minute: row['scheduled_minute'] as int,
      ),
      durationMinutes: row['duration_minutes'] as int,
      difficulty: PlanDifficulty.values.byName(row['difficulty'] as String),
      exercises: sorted
          .map(
            (e) => PlanExercise(
              name: e['exercise_name'] as String,
              defaultSets: e['default_sets'] as int? ?? 3,
              defaultReps: e['default_reps'] as int? ?? 10,
            ),
          )
          .toList(),
      status: PlanStatus.values.byName(row['status'] as String),
    );
  }

  Future<List<WorkoutTemplate>> _loadTemplates(String uid) async {
    try {
      final rows = await _client
          .from('workout_templates')
          .select('*, workout_template_exercises(sort_order, exercise_name, default_sets, default_reps)')
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      return rows.map(_templateFromRow).toList();
    } catch (e) {
      debugPrint('Templates load skipped (run migration?): $e');
      return const [];
    }
  }

  WorkoutTemplate _templateFromRow(Map<String, dynamic> row) {
    final exercisesRaw = row['workout_template_exercises'] as List<dynamic>? ?? const [];
    final sorted = exercisesRaw.map((e) => e as Map<String, dynamic>).toList()
      ..sort((a, b) => (a['sort_order'] as int).compareTo(b['sort_order'] as int));
    return WorkoutTemplate(
      id: row['id'] as String,
      name: row['name'] as String,
      durationMinutes: row['duration_minutes'] as int,
      difficulty: PlanDifficulty.values.byName(row['difficulty'] as String),
      exercises: sorted
          .map(
            (e) => PlanExercise(
              name: e['exercise_name'] as String,
              defaultSets: e['default_sets'] as int? ?? 3,
              defaultReps: e['default_reps'] as int? ?? 10,
            ),
          )
          .toList(),
    );
  }

  Future<void> _saveTemplates(String uid, List<WorkoutTemplate> templates) async {
    try {
      await _client.from('workout_templates').delete().eq('user_id', uid);
      if (templates.isEmpty) return;

      await _client.from('workout_templates').insert(
        templates
            .map(
              (t) => {
                'id': t.id,
                'user_id': uid,
                'name': t.name,
                'duration_minutes': t.durationMinutes,
                'difficulty': t.difficulty.name,
              },
            )
            .toList(),
      );

      final rows = <Map<String, dynamic>>[];
      for (final template in templates) {
        for (var i = 0; i < template.exercises.length; i++) {
          final ex = template.exercises[i];
          rows.add({
            'template_id': template.id,
            'sort_order': i,
            'exercise_name': ex.name,
            'default_sets': ex.defaultSets,
            'default_reps': ex.defaultReps,
          });
        }
      }
      if (rows.isNotEmpty) {
        await _client.from('workout_template_exercises').insert(rows);
      }
    } catch (e) {
      debugPrint('Templates save skipped (run migration?): $e');
    }
  }

  WorkoutCompletion _completionFromRow(Map<String, dynamic> row) {
    final logsRaw = row['workout_completion_exercises'] as List<dynamic>? ?? const [];
    final logs = logsRaw.map((e) => _exerciseLogFromRow(e as Map<String, dynamic>)).toList();

    final namesRaw = row['exercise_names'];
    final exerciseNames = namesRaw is List
        ? namesRaw.cast<String>()
        : const <String>[];

    return WorkoutCompletion(
      id: row['id'] as String,
      title: row['title'] as String,
      workoutType: row['workout_type'] as String? ?? '',
      completedAt: DateTime.parse(row['completed_at'] as String),
      durationMinutes: row['duration_minutes'] as int,
      calories: row['calories'] as int,
      exerciseNames: exerciseNames,
      exerciseLogs: logs,
      caloriesAreEstimated: row['calories_are_estimated'] as bool? ?? true,
    );
  }

  CompletedExerciseLog _exerciseLogFromRow(Map<String, dynamic> row) {
    return CompletedExerciseLog(
      exerciseId: row['id'] as String,
      exerciseName: row['exercise_name'] as String,
      setsCompleted: row['sets_completed'] as int,
      repsCompleted: row['reps_completed'] as int,
      estimatedCalories: row['estimated_calories'] as int,
      completedAt: DateTime.parse(row['completed_at'] as String),
      categoryKey: row['category_key'] as String? ?? 'strength',
    );
  }

  Map<String, dynamic> _planToRow(WorkoutPlan plan, String uid) {
    return {
      'id': plan.id,
      'user_id': uid,
      'name': plan.name,
      'scheduled_date': plan.formattedDate,
      'scheduled_hour': plan.scheduledTime.hour,
      'scheduled_minute': plan.scheduledTime.minute,
      'duration_minutes': plan.durationMinutes,
      'difficulty': plan.difficulty.name,
      'status': plan.status.name,
    };
  }

  Map<String, dynamic> _completionToRow(WorkoutCompletion completion, String uid) {
    return {
      'id': completion.id,
      'user_id': uid,
      'title': completion.title,
      'workout_type': completion.workoutType,
      'completed_at': completion.completedAt.toIso8601String(),
      'duration_minutes': completion.durationMinutes,
      'calories': completion.calories,
      'exercise_names': completion.exerciseNames,
      'calories_are_estimated': completion.caloriesAreEstimated,
    };
  }

  Map<String, dynamic> _exerciseLogToRow(CompletedExerciseLog log, String completionId) {
    return {
      'id': log.exerciseId,
      'completion_id': completionId,
      'exercise_id': null,
      'exercise_name': log.exerciseName,
      'sets_completed': log.setsCompleted,
      'reps_completed': log.repsCompleted,
      'estimated_calories': log.estimatedCalories,
      'category_key': log.categoryKey,
      'completed_at': log.completedAt.toIso8601String(),
    };
  }
}
