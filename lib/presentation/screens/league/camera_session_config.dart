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
        return 'Жим гантелей над головой';
      case CameraExerciseType.barbellShoulderPress:
        return 'Жим штанги стоя';
      case CameraExerciseType.pushPress:
        return 'Толчок';
    }
  }

  String get subtitle {
    switch (this) {
      case CameraExerciseType.dumbbellShoulderPress:
        return 'Две гантели, жим над плечами.';
      case CameraExerciseType.barbellShoulderPress:
        return 'Штанга, движение вверх от плеч.';
      case CameraExerciseType.pushPress:
        return 'Рывок с подскоком — быстрый жим.';
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
