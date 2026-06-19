String normalizeExerciseName(String exerciseName) {
  return exerciseName.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
}

const _cameraTrackingSquatNames = {
  'squat',
  'bodyweight squat',
  'barbell squat',
  'goblet squat',
};

bool isCameraTrackingSupported(String exerciseName) {
  return _cameraTrackingSquatNames.contains(normalizeExerciseName(exerciseName));
}
