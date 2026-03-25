enum CameraExerciseType {
  dumbbellShoulderPress,
  barbellShoulderPress,
  pushPress,
}

extension CameraExerciseTypeX on CameraExerciseType {
  String get id {
    switch (this) {
      case CameraExerciseType.dumbbellShoulderPress:
        return 'dumbbell_shoulder_press';
      case CameraExerciseType.barbellShoulderPress:
        return 'barbell_shoulder_press';
      case CameraExerciseType.pushPress:
        return 'push_press';
    }
  }

  String get title {
    switch (this) {
      case CameraExerciseType.dumbbellShoulderPress:
        return 'Dumbbell Shoulder Press';
      case CameraExerciseType.barbellShoulderPress:
        return 'Barbell Shoulder Press';
      case CameraExerciseType.pushPress:
        return 'Push Press';
    }
  }

  String get subtitle {
    switch (this) {
      case CameraExerciseType.dumbbellShoulderPress:
        return 'Iki elde dumbbell ile omuz ustu press.';
      case CameraExerciseType.barbellShoulderPress:
        return 'Barbell ile omuzdan yukariya press.';
      case CameraExerciseType.pushPress:
        return 'Bacak destegiyle hizli yukari itis.';
    }
  }

  double get calorieFactor {
    switch (this) {
      case CameraExerciseType.dumbbellShoulderPress:
        return 0.0035;
      case CameraExerciseType.barbellShoulderPress:
        return 0.0040;
      case CameraExerciseType.pushPress:
        return 0.0044;
    }
  }
}

CameraExerciseType cameraExerciseTypeFromId(String? id) {
  if (id == null) return CameraExerciseType.dumbbellShoulderPress;
  for (final t in CameraExerciseType.values) {
    if (t.id == id) return t;
  }
  return CameraExerciseType.dumbbellShoulderPress;
}
