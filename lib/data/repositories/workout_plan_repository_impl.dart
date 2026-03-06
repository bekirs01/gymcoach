import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/workout_plan.dart';
import 'workout_plan_repository.dart';

const _keyPlans = 'workout_plans';

/// Local storage ile plan repository - Supabase'e geçişe hazır
class WorkoutPlanRepositoryImpl implements WorkoutPlanRepository {
  WorkoutPlanRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  List<WorkoutPlan> _plans = [];

  Future<void> _loadPlans() async {
    final json = _prefs.getString(_keyPlans);
    if (json == null) {
      _plans = [];
      return;
    }
    try {
      final list = jsonDecode(json) as List;
      _plans = list.map((e) => _planFromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      _plans = [];
    }
  }

  Future<void> _savePlans() async {
    final json = jsonEncode(_plans.map((p) => _planToJson(p)).toList());
    await _prefs.setString(_keyPlans, json);
  }

  Map<String, dynamic> _planToJson(WorkoutPlan plan) {
    return {
      'id': plan.id,
      'name': plan.name,
      'weekdays': plan.weekdays.map((w) => w.index).toList(),
      'exercises': plan.exercises
          .map((e) => {
                'exerciseId': e.exerciseId,
                'exerciseName': e.exerciseName,
                'sets': e.sets,
                'reps': e.reps,
                'durationMinutes': e.durationMinutes,
                'order': e.order,
              })
          .toList(),
      'createdAt': plan.createdAt?.toIso8601String(),
    };
  }

  WorkoutPlan _planFromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      weekdays: (json['weekdays'] as List)
          .map((i) => Weekday.values[i as int])
          .toList(),
      exercises: (json['exercises'] as List)
          .map((e) => PlanExercise(
                exerciseId: e['exerciseId'] as String,
                exerciseName: e['exerciseName'] as String,
                sets: e['sets'] as int?,
                reps: e['reps'] as int?,
                durationMinutes: e['durationMinutes'] as int?,
                order: e['order'] as int?,
              ))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  @override
  Future<List<WorkoutPlan>> getPlans() async {
    await _loadPlans();
    return List.from(_plans);
  }

  @override
  Future<WorkoutPlan?> getPlanById(String id) async {
    await _loadPlans();
    try {
      return _plans.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePlan(WorkoutPlan plan) async {
    await _loadPlans();
    final index = _plans.indexWhere((p) => p.id == plan.id);
    final updated = WorkoutPlan(
      id: plan.id,
      name: plan.name,
      weekdays: plan.weekdays,
      exercises: plan.exercises,
      createdAt: plan.createdAt ?? DateTime.now(),
    );
    if (index >= 0) {
      _plans[index] = updated;
    } else {
      _plans.add(updated);
    }
    await _savePlans();
  }

  @override
  Future<void> deletePlan(String id) async {
    await _loadPlans();
    _plans.removeWhere((p) => p.id == id);
    await _savePlans();
  }
}
