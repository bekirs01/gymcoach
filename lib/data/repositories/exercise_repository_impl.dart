import '../../domain/models/exercise.dart';
import '../mock/mock_exercises.dart';
import 'exercise_repository.dart';

/// Mock egzersiz repository - API/Supabase ile değiştirilebilir
class ExerciseRepositoryImpl implements ExerciseRepository {
  @override
  Future<List<Exercise>> getAllExercises() async {
    return mockExercises;
  }

  @override
  Future<List<Exercise>> getExercisesByCategory(ExerciseCategory category) async {
    return mockExercises.where((e) => e.category == category).toList();
  }

  @override
  Future<Exercise?> getExerciseById(String id) async {
    try {
      return mockExercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
