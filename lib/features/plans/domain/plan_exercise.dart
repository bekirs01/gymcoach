class PlanExercise {
  const PlanExercise({
    required this.name,
    this.defaultSets = 3,
    this.defaultReps = 10,
  });

  final String name;
  final int defaultSets;
  final int defaultReps;

  PlanExercise copyWith({
    String? name,
    int? defaultSets,
    int? defaultReps,
  }) {
    return PlanExercise(
      name: name ?? this.name,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
    );
  }
}
