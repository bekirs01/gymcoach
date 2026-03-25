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
      return 'Konum izni kalıcı olarak kapalı. Ayarlardan aç.';
    }
    if (perm == LocationPermission.denied) {
      return 'Konum izni gerekli.';
    }

    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return 'Cihazda konum servisini aç.';
    }
    return null;
  }
}
