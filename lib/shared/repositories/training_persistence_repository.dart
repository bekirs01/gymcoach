import '../../data/local/training_snapshot_codec.dart';

abstract class TrainingPersistenceRepository {
  Future<TrainingSnapshot?> load();

  Future<void> save(TrainingSnapshot snapshot);
}
