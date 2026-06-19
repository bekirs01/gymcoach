import '../../../../core/workout_exercise_catalog.dart';

abstract final class ExerciseSessionMetadata {
  static String? muscleGroupFor(String exerciseName) {
    for (final category in WorkoutExerciseCatalog.categories) {
      for (final exercise in category.exercises) {
        if (exercise.name == exerciseName) return category.title;
      }
    }
    return null;
  }

  static String typeBadgeFor(String exerciseName) {
    final lower = exerciseName.toLowerCase();
    if (lower.contains('push-up') ||
        lower.contains('pull-up') ||
        lower.contains('plank') ||
        lower.contains('burpee') ||
        lower.contains('mountain climber') ||
        lower.contains('jump rope')) {
      return 'Bodyweight';
    }
    if (lower.contains('curl') ||
        lower.contains('fly') ||
        lower.contains('raise') ||
        lower.contains('crunch') ||
        lower.contains('curl')) {
      return 'Isolation';
    }
    if (lower.contains('press') ||
        lower.contains('squat') ||
        lower.contains('deadlift') ||
        lower.contains('row') ||
        lower.contains('lunge') ||
        lower.contains('thrust') ||
        lower.contains('dip')) {
      return 'Compound';
    }
    return muscleGroupFor(exerciseName) ?? 'Strength';
  }

  static String equipmentFor(String exerciseName) {
    final lower = exerciseName.toLowerCase();
    if (lower.contains('push-up') ||
        lower.contains('pull-up') ||
        lower.contains('plank') ||
        lower.contains('burpee') ||
        lower.contains('mountain climber') ||
        lower.contains('jump rope') ||
        lower.contains('bridge') ||
        lower.contains('crunch') ||
        lower.contains('leg raise') ||
        lower.contains('bicycle')) {
      return 'Bodyweight';
    }
    if (lower.contains('barbell') || lower.contains('bench press') || lower.contains('deadlift')) {
      return 'Barbell';
    }
    if (lower.contains('dumbbell') || lower.contains('curl') || lower.contains('raise')) {
      return 'Dumbbell';
    }
    if (lower.contains('cable')) return 'Cable';
    if (lower.contains('lat pulldown') || lower.contains('seated row')) return 'Machine';
    if (lower.contains('bike') || lower.contains('stationary')) return 'Bike';
    if (lower.contains('rope')) return 'Jump rope';
    return 'Bodyweight';
  }

  static List<String> formTipsFor(String exerciseName, String? description) {
    final lower = exerciseName.toLowerCase();
    if (lower.contains('biceps curl') || lower.contains('hammer curl')) {
      return const [
        'Keep elbows close to your torso',
        'Avoid using momentum or swinging',
        'Lower the weight with control',
      ];
    }
    if (lower.contains('push-up')) {
      return const [
        'Keep your body in a straight line',
        'Lower with control to full depth',
        'Press through the floor without sagging hips',
      ];
    }
    if (lower.contains('pull-up')) {
      return const [
        'Start from a controlled dead hang',
        'Pull your chest toward the bar',
        'Avoid swinging or kipping',
      ];
    }
    if (lower.contains('plank')) {
      return const [
        'Keep ribs down and glutes engaged',
        'Maintain a straight line head to heels',
        'Breathe steadily without holding your breath',
      ];
    }
    if (lower.contains('bench press') || lower.contains('press')) {
      return const [
        'Retract shoulder blades before pressing',
        'Control the bar on the way down',
        'Drive through your feet for stability',
      ];
    }
    if (lower.contains('squat')) {
      return const [
        'Sit hips back and keep chest tall',
        'Track knees over your toes',
        'Drive through the full foot to stand',
      ];
    }
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
