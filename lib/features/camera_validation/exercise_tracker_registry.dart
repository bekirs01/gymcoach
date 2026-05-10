import 'tracking/exercise_tracker.dart';
import 'tracking/trackers/deadlift_tracker.dart';
import 'tracking/trackers/jumping_jack_tracker.dart';
import 'tracking/trackers/lunge_tracker.dart';
import 'tracking/trackers/plank_tracker.dart';
import 'tracking/trackers/pull_up_tracker.dart';
import 'tracking/trackers/push_up_tracker.dart';
import 'tracking/trackers/shoulder_press_tracker.dart';
import 'tracking/trackers/squat_tracker.dart';
import 'tracking/trackers/unsupported_tracker.dart';

abstract final class ExerciseTrackerRegistry {
  static final Map<String, ExerciseTracker Function()> _factories = {
    'squats': SquatTracker.new,
    'push_ups': PushUpTracker.new,
    'shoulder_press': ShoulderPressTracker.new,
    'lunges': LungeTracker.new,
    'jumping_jacks': JumpingJackTracker.new,
    'pull_ups': PullUpTracker.new,
    'plank': PlankTracker.new,
    'deadlift': DeadliftTracker.new,
    'running': () => UnsupportedExerciseTracker('cardio_unsupported'),
  };

  static ExerciseTracker resolve(String canonicalId) {
    final factory = _factories[canonicalId];
    if (factory == null) {
      return UnsupportedExerciseTracker('unknown_exercise');
    }
    return factory();
  }

  static bool isCameraSupported(String canonicalId) {
    return _factories.containsKey(canonicalId) && canonicalId != 'running';
  }
}
