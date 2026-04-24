/// Константы приложения
class AppConstants {
  AppConstants._();

  static const String appName = 'GymCoach';
  static const int maxWaterGlasses = 12;
  static const int defaultStepGoal = 10000;
  static const int defaultCalorieGoal = 2000;

  /// Сообщения для пользователя (без технических деталей).
  static const String loadDataError =
      'Не удалось загрузить данные. Повторите попытку.';
  static const String genericError =
      'Что-то пошло не так. Повторите позже.';
  static const String cameraGenericError =
      'Не удалось открыть камеру. Проверьте разрешения в настройках.';
  static const String profileNotFound = 'Профиль не найден';
}
