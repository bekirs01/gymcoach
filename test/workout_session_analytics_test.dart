import 'package:flutter_test/flutter_test.dart';
import 'package:gym/features/workout/domain/workout_session_analytics.dart';

void main() {
  test('NoOpWorkoutSessionAnalytics invokes without error', () {
    const a = NoOpWorkoutSessionAnalytics();
    a.onExerciseBecameActive(0, 'Squat');
    a.onExerciseLogged(index: 0, sets: 3, reps: 5);
    a.onSessionFinished(const Duration(minutes: 12));
  });
}
