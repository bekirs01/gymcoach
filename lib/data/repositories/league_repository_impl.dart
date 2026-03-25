import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/league.dart';
import 'league_repository.dart';

const _keyCameraScore = 'league_camera_score';

/// MVP: sabit örnek oyuncular + yerelde saklanan kullanıcı kamera puanı
class LeagueRepositoryImpl implements LeagueRepository {
  LeagueRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _mockNames = [
    'Alex M.',
    'Jordan K.',
    'Sam T.',
    'Riley P.',
  ];

  @override
  Future<int> getCameraScore() async {
    return _prefs.getInt(_keyCameraScore) ?? 0;
  }

  @override
  Future<void> addCameraScore(int delta) async {
    if (delta <= 0) return;
    final now = await getCameraScore();
    await _prefs.setInt(_keyCameraScore, now + delta);
  }

  @override
  Future<List<LeagueStanding>> getStandings(String? currentUserDisplayName) async {
    final userCamera = await getCameraScore();
    final name = (currentUserDisplayName != null && currentUserDisplayName.trim().isNotEmpty)
        ? currentUserDisplayName.trim()
        : 'Sen';

    final userRow = LeagueStanding(
      displayName: name,
      cameraScore: userCamera,
      secondaryScore: 0,
      isCurrentUser: true,
    );

    final mockScores = [120, 95, 78, 64];
    final mocks = List<LeagueStanding>.generate(_mockNames.length, (i) {
      return LeagueStanding(
        displayName: _mockNames[i],
        cameraScore: mockScores[i],
        secondaryScore: 0,
        isCurrentUser: false,
      );
    });

    final all = [...mocks, userRow];
    all.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return all;
  }
}
