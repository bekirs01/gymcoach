import 'data/exercise_tracking_catalog.dart';
import 'tracking/exercise_tracker.dart';

abstract final class ExerciseTrackerRegistry {
  static ExerciseTracker resolve(String canonicalId) {
    return ExerciseTrackingCatalog.buildTracker(canonicalId);
  }

  static bool isCameraSupported(String canonicalId) {
    return ExerciseTrackingCatalog.isCameraSupported(canonicalId);
  }
}
