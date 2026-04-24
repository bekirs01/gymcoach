import 'package:geolocator/geolocator.dart';

/// Konum izinleri — ileride `permission_handler` ile birleştirilebilir.
class LocationPermissionService {
  LocationPermissionService._();

  /// Konum servisi kapalı / izin yok / reddedildi durumlarını metinle döndürür.
  static Future<String?> ensureReady() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      return 'Доступ к геолокации отключён. Включите в настройках.';
    }
    if (perm == LocationPermission.denied) {
      return 'Нужен доступ к геолокации.';
    }

    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return 'Включите геолокацию в настройках устройства.';
    }
    return null;
  }
}
