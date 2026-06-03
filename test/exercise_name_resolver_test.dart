import 'package:gym/features/camera_validation/data/exercise_name_resolver.dart';
import 'package:gym/features/camera_validation/exercise_tracker_registry.dart';
import 'package:gym/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('resolves localized exercise names to canonical ids', () {
    expect(ExerciseNameResolver.canonicalIdForName(l10n.exSquats, l10n), 'squats');
    expect(ExerciseNameResolver.canonicalIdForName(l10n.exPushUps, l10n), 'push_ups');
    expect(ExerciseNameResolver.canonicalIdForName(l10n.exShoulderPress, l10n), 'shoulder_press');
    expect(ExerciseNameResolver.canonicalIdForName(l10n.exBackSquat, l10n), 'squats');
    expect(ExerciseNameResolver.canonicalIdForName(l10n.exDeadlift, l10n), 'deadlift');
    expect(ExerciseNameResolver.canonicalIdForName('Push-up', l10n), 'push_ups');
    expect(ExerciseNameResolver.canonicalIdForName('Squat', l10n), 'squats');
    expect(ExerciseNameResolver.canonicalIdForName('Barbell Bench Press', l10n), 'bench_press');
    expect(ExerciseNameResolver.canonicalIdForName('Mountain Climber', l10n), 'mountain_climber');
  });

  test('registry supports all catalog exercises', () {
    expect(ExerciseTrackerRegistry.isCameraSupported('running'), isFalse);
    expect(ExerciseTrackerRegistry.isCameraSupported('squats'), isTrue);
    expect(ExerciseTrackerRegistry.isCameraSupported('deadlift'), isTrue);
    expect(ExerciseTrackerRegistry.isCameraSupported('bench_press'), isTrue);
    expect(ExerciseTrackerRegistry.isCameraSupported('bicycle_crunch'), isTrue);
  });
}
