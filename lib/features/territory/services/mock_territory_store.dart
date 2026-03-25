import '../domain/territory_models.dart';
import '../data/mock/mock_territory_seed.dart';

/// Bellek içi “depo” — TODO: RemoteDataSource + Repository impl.
class MockTerritoryStore {
  TerritoryGameState get initialState => TerritoryGameState(
        users: {...mockTerritoryUsers()},
        territories: List.from(mockTerritoryZones()),
        mapCenter: kDefaultTerritoryCenter,
        liveUserPosition: kDefaultTerritoryCenter,
      );
}
