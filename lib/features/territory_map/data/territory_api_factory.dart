import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/device_user_id.dart';
import '../config/territory_config.dart';
import 'mock_territory_api_client.dart';
import 'supabase_territory_api_client.dart';
import 'territory_api_client.dart';

Future<TerritoryApiClient> createTerritoryApiClient({
  required SharedPreferences prefs,
  required String displayName,
  SupabaseClient? client,
}) async {
  final userId = await DeviceUserId.resolve(prefs);
  if (TerritoryConfig.useMock) {
    return MockTerritoryApiClient(
      currentUserId: userId,
      currentUserDisplayName: displayName,
    );
  }
  return SupabaseTerritoryApiClient(
    client: client,
    currentUserId: userId,
    currentUserDisplayName: displayName,
  );
}
