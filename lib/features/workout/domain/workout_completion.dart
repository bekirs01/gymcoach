class WorkoutCompletion {
  const WorkoutCompletion({
    required this.id,
    required this.title,
    required this.workoutType,
    required this.completedAt,
    required this.durationMinutes,
    required this.calories,
    required this.exerciseNames,
  });

  final String id;
  final String title;
  final String workoutType;
  final DateTime completedAt;
  final int durationMinutes;
  final int calories;
  final List<String> exerciseNames;

  static List<WorkoutCompletion> sample() {
    final now = DateTime.now();
    return [
      WorkoutCompletion(
        id: 's1',
        title: 'Leg Day',
        workoutType: 'Lower body',
        completedAt: now.subtract(const Duration(days: 1)),
        durationMinutes: 52,
        calories: 420,
        exerciseNames: const ['Squats', 'Lunges', 'Leg Press', 'Calf Raises'],
      ),
      WorkoutCompletion(
        id: 's2',
        title: 'Core Session',
        workoutType: 'Core',
        completedAt: now.subtract(const Duration(days: 3)),
        durationMinutes: 28,
        calories: 210,
        exerciseNames: const ['Plank', 'Bicycle Crunches', 'Russian Twists'],
      ),
      WorkoutCompletion(
        id: 's3',
        title: 'Morning Run',
        workoutType: 'Outdoor cardio',
        completedAt: now.subtract(const Duration(days: 6)),
        durationMinutes: 35,
        calories: 380,
        exerciseNames: const ['Running', 'Dynamic Warm-up'],
      ),
    ];
  }
}
