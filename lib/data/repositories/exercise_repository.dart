import '../../domain/models/exercise.dart';

/// Egzersiz repository arayüzü
abstract class ExerciseRepository {
  Future<List<Exercise>> getAllExercises();
  Future<List<Exercise>> getExercisesByCategory(ExerciseCategory category);
  Future<Exercise?> getExerciseById(String id);
}
