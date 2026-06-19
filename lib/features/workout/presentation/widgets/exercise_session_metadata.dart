import '../../domain/exercise_instruction_data.dart';

abstract final class ExerciseSessionMetadata {
  static String? muscleGroupFor(String exerciseName) {
    return ExerciseInstructionData.muscleGroupFor(exerciseName);
  }

  static String typeBadgeFor(String exerciseName) {
    return ExerciseInstructionData.typeBadgeFor(exerciseName);
  }

  static String equipmentFor(String exerciseName) {
    return ExerciseInstructionData.forExercise(exerciseName).equipment;
  }

  static List<String> formTipsFor(String exerciseName, String? description) {
    final instruction = ExerciseInstructionData.forExercise(exerciseName);
    if (instruction.formTips.isNotEmpty) return instruction.formTips;
    if (description != null && description.isNotEmpty) {
      final sentences = description
          .split(RegExp(r'[.!?]'))
          .map((s) => s.trim())
          .where((s) => s.length > 12)
          .take(3)
          .toList();
      if (sentences.length >= 2) return sentences;
    }
    final muscle = muscleGroupFor(exerciseName);
    if (muscle != null) {
      return [
        'Focus on controlled movement throughout',
        'Keep tension on the $muscle muscles',
        'Breathe steadily and avoid rushing reps',
      ];
    }
    return const [
      'Move with control on every rep',
      'Keep proper posture and core braced',
      'Stop if you feel sharp pain',
    ];
  }
}
