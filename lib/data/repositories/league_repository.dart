import '../../domain/models/league.dart';

/// Lig puanları — şimdilik yerel; ileride backend ile değiştirilebilir
abstract class LeagueRepository {
  Future<int> getCameraScore();
  Future<void> addCameraScore(int delta);
  Future<List<LeagueStanding>> getStandings(String? currentUserDisplayName);
}
