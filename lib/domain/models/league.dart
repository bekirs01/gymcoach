import 'package:equatable/equatable.dart';

/// Lig tablosunda tek satır (sen + örnek rakipler)
class LeagueStanding extends Equatable {
  const LeagueStanding({
    required this.displayName,
    required this.cameraScore,
    required this.secondaryScore,
    required this.isCurrentUser,
  });

  final String displayName;
  /// Kamera / hiz çizgisi ile kazanılan puan
  final int cameraScore;
  /// İkinci puan sistemi (henüz tanımlanacak)
  final int secondaryScore;
  final bool isCurrentUser;

  int get totalScore => cameraScore + secondaryScore;

  @override
  List<Object?> get props => [displayName, cameraScore, secondaryScore, isCurrentUser];
}
