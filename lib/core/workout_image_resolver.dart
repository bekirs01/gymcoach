import 'package:flutter/material.dart';

import 'workout_exercise_catalog.dart';

enum WorkoutImageSource { network, asset }

class ResolvedWorkoutImage {
  const ResolvedWorkoutImage({
    required this.source,
    required this.path,
    this.isExerciseDiagram = false,
  });

  final WorkoutImageSource source;
  final String path;
  final bool isExerciseDiagram;

  ImageProvider get provider {
    if (source == WorkoutImageSource.network) {
      return NetworkImage(path);
    }
    return AssetImage(path);
  }
}

abstract final class WorkoutImageResolver {
  static const defaultWorkoutAsset = 'assets/images/workouts/default_workout.jpg';

  static const _muscleGroupAssets = <String, String>{
    'chest': 'assets/images/workouts/chest.jpg',
    'pec': 'assets/images/workouts/chest.jpg',
    'bench': 'assets/images/workouts/chest.jpg',
    'back': 'assets/images/workouts/back.jpg',
    'lat': 'assets/images/workouts/back.jpg',
    'row': 'assets/images/workouts/back.jpg',
    'pull': 'assets/images/workouts/back.jpg',
    'deadlift': 'assets/images/workouts/back.jpg',
    'legs': 'assets/images/workouts/legs.jpg',
    'leg': 'assets/images/workouts/legs.jpg',
    'squat': 'assets/images/workouts/legs.jpg',
    'lunge': 'assets/images/workouts/legs.jpg',
    'glute': 'assets/images/workouts/legs.jpg',
    'hamstring': 'assets/images/workouts/legs.jpg',
    'quad': 'assets/images/workouts/legs.jpg',
    'calf': 'assets/images/workouts/legs.jpg',
    'glutes': 'assets/images/workouts/legs.jpg',
    'shoulders': 'assets/images/workouts/shoulders.jpg',
    'shoulder': 'assets/images/workouts/shoulders.jpg',
    'delt': 'assets/images/workouts/shoulders.jpg',
    'overhead': 'assets/images/workouts/shoulders.jpg',
    'biceps': 'assets/images/workouts/biceps.jpg',
    'bicep': 'assets/images/workouts/biceps.jpg',
    'curl': 'assets/images/workouts/biceps.jpg',
    'arms': 'assets/images/workouts/biceps.jpg',
    'triceps': 'assets/images/workouts/biceps.jpg',
    'tricep': 'assets/images/workouts/biceps.jpg',
    'core': 'assets/images/workouts/core.jpg',
    'abs': 'assets/images/workouts/core.jpg',
    'plank': 'assets/images/workouts/core.jpg',
    'crunch': 'assets/images/workouts/core.jpg',
    'cardio': 'assets/images/workouts/cardio.jpg',
    'burpee': 'assets/images/workouts/cardio.jpg',
    'rope': 'assets/images/workouts/cardio.jpg',
    'full body': 'assets/images/workouts/full_body.jpg',
    'fullbody': 'assets/images/workouts/full_body.jpg',
    'push': 'assets/images/workouts/chest.jpg',
    'press': 'assets/images/workouts/chest.jpg',
    'fly': 'assets/images/workouts/chest.jpg',
    'dip': 'assets/images/workouts/biceps.jpg',
  };

  static const _categoryAssets = <String, String>{
    'Chest': 'assets/images/workouts/chest.jpg',
    'Back': 'assets/images/workouts/back.jpg',
    'Legs': 'assets/images/workouts/legs.jpg',
    'Glutes': 'assets/images/workouts/legs.jpg',
    'Shoulders': 'assets/images/workouts/shoulders.jpg',
    'Arms': 'assets/images/workouts/biceps.jpg',
    'Core': 'assets/images/workouts/core.jpg',
    'Cardio': 'assets/images/workouts/cardio.jpg',
  };

  static const _exerciseAliases = <String, String>{
    'overhead press': 'Shoulder Press',
    'arnold press': 'Shoulder Press',
    'seated dumbbell press': 'Shoulder Press',
    'barbell curl': 'Biceps Curl',
    'ez bar curl': 'Biceps Curl',
    'cable curl': 'Biceps Curl',
    'concentration curl': 'Biceps Curl',
    'preacher curl': 'Biceps Curl',
    'incline dumbbell curl': 'Biceps Curl',
    'flat bench press': 'Barbell Bench Press',
    'incline barbell press': 'Barbell Bench Press',
    'incline dumbbell press': 'Barbell Bench Press',
    'dumbbell bench press': 'Barbell Bench Press',
    'barbell bench press': 'Barbell Bench Press',
    'pec deck fly': 'Chest Fly',
    'cable chest fly': 'Chest Fly',
    'rear delt fly': 'Face Pull',
    'cable lateral raise': 'Lateral Raise',
    'upright row': 'Lateral Raise',
    'back squat': 'Squat',
    'front squat': 'Squat',
    'leg press': 'Squat',
    'leg extension': 'Squat',
    'calf raise': 'Squat',
    'walking lunge': 'Lunge',
    'bulgarian split squat': 'Lunge',
    'plank hold': 'Plank',
    'hanging leg raise': 'Leg Raise',
    'russian twist': 'Bicycle Crunch',
    'dead bug': 'Plank',
    'pallof press': 'Cable Crunch',
    'barbell row': 'Seated Row',
    'seated cable row': 'Seated Row',
    'chest supported row': 'Seated Row',
    'single arm dumbbell row': 'Seated Row',
    'straight arm pulldown': 'Lat Pulldown',
    'pull ups': 'Pull-up',
    'pull up': 'Pull-up',
    'push ups': 'Push-up',
    'push up': 'Push-up',
    'triceps pushdown': 'Dips',
  };

  static bool isValidNetworkUrl(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) return false;
    return uri.scheme == 'http' || uri.scheme == 'https';
  }

  static bool isLocalAssetPath(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    return trimmed.startsWith('assets/');
  }

  static bool isExerciseDiagramAsset(String assetPath) {
    return assetPath.contains('/workout_exercises/');
  }

  static ResolvedWorkoutImage resolve({
    String? imageUrl,
    String? localImageAsset,
    List<String>? exerciseNames,
    String? muscleGroup,
    String? workoutName,
  }) {
    if (isLocalAssetPath(imageUrl)) {
      localImageAsset = imageUrl;
      imageUrl = null;
    }

    if (isValidNetworkUrl(imageUrl)) {
      return ResolvedWorkoutImage(
        source: WorkoutImageSource.network,
        path: imageUrl!.trim(),
      );
    }

    if (isLocalAssetPath(localImageAsset)) {
      final asset = localImageAsset!.trim();
      return ResolvedWorkoutImage(
        source: WorkoutImageSource.asset,
        path: asset,
        isExerciseDiagram: isExerciseDiagramAsset(asset),
      );
    }

    final names = exerciseNames ?? const [];
    for (final name in names) {
      final exerciseAsset = exerciseAssetForName(name);
      if (exerciseAsset != null) {
        return ResolvedWorkoutImage(
          source: WorkoutImageSource.asset,
          path: exerciseAsset,
          isExerciseDiagram: isExerciseDiagramAsset(exerciseAsset),
        );
      }
    }

    if (names.isEmpty) {
      final groupAsset = muscleGroupAsset(muscleGroup);
      if (groupAsset != null) {
        return ResolvedWorkoutImage(
          source: WorkoutImageSource.asset,
          path: groupAsset,
        );
      }

      final nameAsset = muscleGroupAsset(workoutName);
      if (nameAsset != null) {
        return ResolvedWorkoutImage(
          source: WorkoutImageSource.asset,
          path: nameAsset,
        );
      }
    }

    return const ResolvedWorkoutImage(
      source: WorkoutImageSource.asset,
      path: defaultWorkoutAsset,
    );
  }

  static ResolvedWorkoutImage resolveAsset({
    String? imageUrl,
    String? localImageAsset,
    List<String>? exerciseNames,
    String? muscleGroup,
    String? workoutName,
  }) {
    final resolved = resolve(
      imageUrl: imageUrl,
      localImageAsset: localImageAsset,
      exerciseNames: exerciseNames,
      muscleGroup: muscleGroup,
      workoutName: workoutName,
    );
    if (resolved.source == WorkoutImageSource.network) {
      return const ResolvedWorkoutImage(
        source: WorkoutImageSource.asset,
        path: defaultWorkoutAsset,
      );
    }
    return resolved;
  }

  static String resolveAssetPath({
    String? imageUrl,
    String? localImageAsset,
    List<String>? exerciseNames,
    String? muscleGroup,
    String? workoutName,
  }) {
    return resolveAsset(
      imageUrl: imageUrl,
      localImageAsset: localImageAsset,
      exerciseNames: exerciseNames,
      muscleGroup: muscleGroup,
      workoutName: workoutName,
    ).path;
  }

  static String? exerciseAssetForName(String? name) {
    if (name == null || name.trim().isEmpty) return null;

    final exact = WorkoutExerciseCatalog.imageForName(name);
    if (exact != null) return exact;

    final normalized = _normalize(name);
    final aliasTarget = _exerciseAliases[normalized];
    if (aliasTarget != null) {
      final aliasAsset = WorkoutExerciseCatalog.imageForName(aliasTarget);
      if (aliasAsset != null) return aliasAsset;
    }

    for (final exercise in WorkoutExerciseCatalog.allExercises) {
      if (_normalize(exercise.name) == normalized) {
        return exercise.imageAsset;
      }
    }

    String? bestMatch;
    var bestScore = 0;
    for (final exercise in WorkoutExerciseCatalog.allExercises) {
      final exerciseNormalized = _normalize(exercise.name);
      final score = _matchScore(normalized, exerciseNormalized);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = exercise.imageAsset;
      }
    }
    if (bestScore >= 2) return bestMatch;

    for (final category in WorkoutExerciseCatalog.categories) {
      if (normalized.contains(_normalize(category.title))) {
        return category.exercises.first.imageAsset;
      }
    }

    return null;
  }

  static String? muscleGroupAsset(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final direct = _categoryAssets[value.trim()];
    if (direct != null) return direct;

    final normalized = _normalize(value);
    for (final entry in _muscleGroupAssets.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }

    for (final category in WorkoutExerciseCatalog.categories) {
      if (normalized.contains(_normalize(category.title))) {
        return _categoryAssets[category.title] ?? category.imageAsset;
      }
    }

    return null;
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static int _matchScore(String input, String candidate) {
    if (input == candidate) return 100;
    if (input.contains(candidate) || candidate.contains(input)) {
      return candidate.length > 3 ? 4 : 2;
    }

    final inputTokens = input.split(' ');
    final candidateTokens = candidate.split(' ');
    var shared = 0;
    for (final token in inputTokens) {
      if (token.length < 3) continue;
      if (candidateTokens.any((c) => c == token || c.contains(token) || token.contains(c))) {
        shared++;
      }
    }
    return shared;
  }
}
