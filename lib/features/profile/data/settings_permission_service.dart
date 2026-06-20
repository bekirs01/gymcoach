import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

enum SettingsPermissionKind {
  notifications,
  camera,
  microphone,
  photos,
  location,
}

enum SettingsPermissionStatusLabel {
  allowed,
  notAllowed,
  limited,
  restricted,
}

final class SettingsPermissionSnapshot {
  const SettingsPermissionSnapshot({
    required this.isGranted,
    required this.label,
    required this.canRequest,
  });

  final bool isGranted;
  final SettingsPermissionStatusLabel label;
  final bool canRequest;

  String get labelText => switch (label) {
        SettingsPermissionStatusLabel.allowed => 'Allowed',
        SettingsPermissionStatusLabel.notAllowed => 'Not allowed',
        SettingsPermissionStatusLabel.limited => 'Limited',
        SettingsPermissionStatusLabel.restricted => 'Restricted',
      };
}

final class SettingsPermissionService {
  Future<SettingsPermissionSnapshot> read(SettingsPermissionKind kind) async {
    if (kind == SettingsPermissionKind.location) {
      return _readLocation();
    }
    final permission = _permissionFor(kind);
    final status = await permission.status;
    return _mapStatus(status);
  }

  Future<SettingsPermissionSnapshot> request(SettingsPermissionKind kind) async {
    if (kind == SettingsPermissionKind.location) {
      return _requestLocation();
    }
    final permission = _permissionFor(kind);
    final status = await permission.request();
    return _mapStatus(status);
  }

  Future<bool> openSystemSettings() => openAppSettings();

  Permission _permissionFor(SettingsPermissionKind kind) {
    return switch (kind) {
      SettingsPermissionKind.notifications => Permission.notification,
      SettingsPermissionKind.camera => Permission.camera,
      SettingsPermissionKind.microphone => Permission.microphone,
      SettingsPermissionKind.photos => Permission.photos,
      SettingsPermissionKind.location => Permission.locationWhenInUse,
    };
  }

  SettingsPermissionSnapshot _mapStatus(PermissionStatus status) {
    return switch (status) {
      PermissionStatus.granted => const SettingsPermissionSnapshot(
          isGranted: true,
          label: SettingsPermissionStatusLabel.allowed,
          canRequest: false,
        ),
      PermissionStatus.limited => const SettingsPermissionSnapshot(
          isGranted: true,
          label: SettingsPermissionStatusLabel.limited,
          canRequest: false,
        ),
      PermissionStatus.provisional => const SettingsPermissionSnapshot(
          isGranted: true,
          label: SettingsPermissionStatusLabel.allowed,
          canRequest: false,
        ),
      PermissionStatus.restricted => const SettingsPermissionSnapshot(
          isGranted: false,
          label: SettingsPermissionStatusLabel.restricted,
          canRequest: false,
        ),
      PermissionStatus.denied => const SettingsPermissionSnapshot(
          isGranted: false,
          label: SettingsPermissionStatusLabel.notAllowed,
          canRequest: true,
        ),
      PermissionStatus.permanentlyDenied => const SettingsPermissionSnapshot(
          isGranted: false,
          label: SettingsPermissionStatusLabel.notAllowed,
          canRequest: false,
        ),
    };
  }

  Future<SettingsPermissionSnapshot> _readLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const SettingsPermissionSnapshot(
        isGranted: false,
        label: SettingsPermissionStatusLabel.notAllowed,
        canRequest: true,
      );
    }
    final permission = await Geolocator.checkPermission();
    return switch (permission) {
      LocationPermission.always || LocationPermission.whileInUse => const SettingsPermissionSnapshot(
          isGranted: true,
          label: SettingsPermissionStatusLabel.allowed,
          canRequest: false,
        ),
      LocationPermission.denied => const SettingsPermissionSnapshot(
          isGranted: false,
          label: SettingsPermissionStatusLabel.notAllowed,
          canRequest: true,
        ),
      LocationPermission.deniedForever => const SettingsPermissionSnapshot(
          isGranted: false,
          label: SettingsPermissionStatusLabel.notAllowed,
          canRequest: false,
        ),
      LocationPermission.unableToDetermine => const SettingsPermissionSnapshot(
          isGranted: false,
          label: SettingsPermissionStatusLabel.notAllowed,
          canRequest: true,
        ),
    };
  }

  Future<SettingsPermissionSnapshot> _requestLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const SettingsPermissionSnapshot(
        isGranted: false,
        label: SettingsPermissionStatusLabel.notAllowed,
        canRequest: true,
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return switch (permission) {
      LocationPermission.always || LocationPermission.whileInUse => const SettingsPermissionSnapshot(
          isGranted: true,
          label: SettingsPermissionStatusLabel.allowed,
          canRequest: false,
        ),
      LocationPermission.deniedForever => const SettingsPermissionSnapshot(
          isGranted: false,
          label: SettingsPermissionStatusLabel.notAllowed,
          canRequest: false,
        ),
      _ => const SettingsPermissionSnapshot(
          isGranted: false,
          label: SettingsPermissionStatusLabel.notAllowed,
          canRequest: true,
        ),
    };
  }
}
