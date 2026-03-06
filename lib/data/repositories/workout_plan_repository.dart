import '../../domain/models/workout_plan.dart';

/// Antrenman planı repository arayüzü
abstract class WorkoutPlanRepository {
  Future<List<WorkoutPlan>> getPlans();
  Future<WorkoutPlan?> getPlanById(String id);
  Future<void> savePlan(WorkoutPlan plan);
  Future<void> deletePlan(String id);
}
