import 'package:equatable/equatable.dart';

/// Öğün tipi
enum MealType { breakfast, lunch, dinner, snack }

/// Öğün örneği
class Meal extends Equatable {
  const Meal({
    required this.type,
    required this.name,
    required this.description,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  final MealType type;
  final String name;
  final String description;
  final int? calories;
  final int? protein;
  final int? carbs;
  final int? fat;

  String get typeDisplayName {
    switch (type) {
      case MealType.breakfast:
        return 'Завтрак';
      case MealType.lunch:
        return 'Обед';
      case MealType.dinner:
        return 'Ужин';
      case MealType.snack:
        return 'Перекус';
    }
  }

  @override
  List<Object?> get props => [type, name];
}
