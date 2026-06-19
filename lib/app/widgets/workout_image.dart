import 'package:flutter/material.dart';

import '../../core/workout_image_resolver.dart';

class WorkoutImage extends StatelessWidget {
  const WorkoutImage({
    super.key,
    this.imageUrl,
    this.localImageAsset,
    this.exerciseNames,
    this.muscleGroup,
    this.workoutName,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.medium,
  });

  final String? imageUrl;
  final String? localImageAsset;
  final List<String>? exerciseNames;
  final String? muscleGroup;
  final String? workoutName;
  final BoxFit fit;
  final Alignment alignment;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    final resolved = WorkoutImageResolver.resolve(
      imageUrl: imageUrl,
      localImageAsset: localImageAsset,
      exerciseNames: exerciseNames,
      muscleGroup: muscleGroup,
      workoutName: workoutName,
    );
    final imageFit = resolved.isExerciseDiagram ? BoxFit.contain : fit;
    final fallback = WorkoutImageResolver.defaultWorkoutAsset;

    if (resolved.source == WorkoutImageSource.network) {
      return Image.network(
        resolved.path,
        fit: imageFit,
        alignment: alignment,
        filterQuality: filterQuality,
        errorBuilder: (_, _, _) => Image.asset(
          fallback,
          fit: fit,
          alignment: alignment,
          filterQuality: filterQuality,
        ),
      );
    }

    return Image.asset(
      resolved.path,
      fit: imageFit,
      alignment: alignment,
      filterQuality: filterQuality,
      errorBuilder: (_, _, _) => Image.asset(
        fallback,
        fit: fit,
        alignment: alignment,
        filterQuality: filterQuality,
      ),
    );
  }
}
