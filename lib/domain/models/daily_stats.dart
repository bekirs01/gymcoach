import 'package:equatable/equatable.dart';

/// Günlük takip istatistikleri
class DailyStats extends Equatable {
  const DailyStats({
    this.waterGlasses = 0,
    this.steps = 0,
    this.caloriesBurned = 0,
    this.caloriesConsumed = 0,
    this.date,
  });

  final int waterGlasses;
  final int steps;
  final int caloriesBurned;
  final int caloriesConsumed;
  final DateTime? date;

  DailyStats copyWith({
    int? waterGlasses,
    int? steps,
    int? caloriesBurned,
    int? caloriesConsumed,
    DateTime? date,
  }) {
    return DailyStats(
      waterGlasses: waterGlasses ?? this.waterGlasses,
      steps: steps ?? this.steps,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [waterGlasses, steps, caloriesBurned, caloriesConsumed];
}
