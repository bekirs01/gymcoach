import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class MapStyleConfig {
  /// Colorful OSM-style map (similar to standard Google/Apple maps).
  static const standardStyleUrl = 'https://tiles.openfreemap.org/styles/liberty';
  static const libertyStyleUrl = 'https://tiles.openfreemap.org/styles/liberty';

  static String styleUrlFor(TerritoryMapVisualMode mode) {
    return switch (mode) {
      TerritoryMapVisualMode.standard => standardStyleUrl,
      TerritoryMapVisualMode.liberty => libertyStyleUrl,
    };
  }
}

enum TerritoryMapVisualMode { standard, liberty }

abstract final class TerritoryConfig {
  static const minCapturePoints = 4;
  static const minAreaSquareMeters = 100.0;
  static const maxAccuracyMeters = 50.0;
  static const warnAccuracyMeters = 25.0;
  static const minPointDistanceMeters = 4.0;
  static const maxClosureDistanceMeters = 35.0;
  static const maxSpeedMps = 12.0;

  static bool get useMock {
    final value = dotenv.maybeGet('TERRITORY_USE_MOCK') ??
        const String.fromEnvironment('TERRITORY_USE_MOCK', defaultValue: 'false');
    return value.toLowerCase() == 'true';
  }
}
