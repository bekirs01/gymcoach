import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/repositories/training_persistence_repository.dart';
import 'training_snapshot_codec.dart';

final class SharedPrefsTrainingPersistence implements TrainingPersistenceRepository {
  SharedPrefsTrainingPersistence(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'training_snapshot_v1';

  @override
  Future<TrainingSnapshot?> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return TrainingSnapshot.decode(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(TrainingSnapshot snapshot) async {
    await _prefs.setString(_key, snapshot.encode());
  }
}
