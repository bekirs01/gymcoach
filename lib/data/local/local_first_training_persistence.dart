import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/repositories/training_persistence_repository.dart';
import 'shared_prefs_training_persistence.dart';
import 'training_snapshot_codec.dart';

/// Loads training data from local storage instantly; syncs to remote when available.
final class LocalFirstTrainingPersistence implements TrainingPersistenceRepository {
  LocalFirstTrainingPersistence({required SharedPreferences prefs})
      : _local = SharedPrefsTrainingPersistence(prefs);

  final SharedPrefsTrainingPersistence _local;
  TrainingPersistenceRepository? _remote;

  void attachRemote(TrainingPersistenceRepository remote) {
    _remote = remote;
  }

  @override
  Future<TrainingSnapshot?> load() => _local.load();

  @override
  Future<void> save(TrainingSnapshot snapshot) async {
    await _local.save(snapshot);
    final remote = _remote;
    if (remote == null) return;
    try {
      await remote.save(snapshot);
    } catch (e, st) {
      debugPrint('Remote training save failed: $e\n$st');
    }
  }
}
