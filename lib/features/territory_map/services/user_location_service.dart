import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';

enum UserLocationFailure {
  serviceDisabled,
  permissionDenied,
  timeout,
  unavailable,
}

class UserLocationResult {
  const UserLocationResult.success(this.position) : failure = null;

  const UserLocationResult.failure(this.failure) : position = null;

  final Position? position;
  final UserLocationFailure? failure;

  bool get isSuccess => position != null;
}

class UserLocationService {
  static const _resolveTimeout = Duration(seconds: 15);
  static const _recentPositionMaxAge = Duration(minutes: 2);
  static const _maxCachedAccuracyMeters = 150.0;

  Future<UserLocationResult> resolveCurrentPosition({bool forceFresh = false}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const UserLocationResult.failure(UserLocationFailure.serviceDisabled);
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      return const UserLocationResult.failure(UserLocationFailure.permissionDenied);
    }

    if (!forceFresh) {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && _isUsableCached(lastKnown)) {
        return UserLocationResult.success(lastKnown);
      }
    }

    return _resolveFreshPosition(forceFresh: forceFresh);
  }

  Future<UserLocationResult> _resolveFreshPosition({required bool forceFresh}) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _resolveSettings(),
      );
      if (_isValid(position)) {
        return UserLocationResult.success(position);
      }
      return const UserLocationResult.failure(UserLocationFailure.unavailable);
    } on TimeoutException {
      return _resolveFromStream(forceFresh: forceFresh);
    } catch (_) {
      if (!forceFresh) {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null && _isUsableCached(lastKnown)) {
          return UserLocationResult.success(lastKnown);
        }
      }
      return const UserLocationResult.failure(UserLocationFailure.unavailable);
    }
  }

  Future<UserLocationResult> _resolveFromStream({required bool forceFresh}) async {
    try {
      final position = await Geolocator.getPositionStream(
        locationSettings: _watchSettings(distanceFilter: 0),
      ).first.timeout(_resolveTimeout);
      if (_isValid(position)) {
        return UserLocationResult.success(position);
      }
      return const UserLocationResult.failure(UserLocationFailure.unavailable);
    } on TimeoutException {
      if (!forceFresh) {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null && _isUsableCached(lastKnown)) {
          return UserLocationResult.success(lastKnown);
        }
      }
      return const UserLocationResult.failure(UserLocationFailure.timeout);
    } catch (_) {
      return const UserLocationResult.failure(UserLocationFailure.unavailable);
    }
  }

  Stream<Position> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: _watchSettings(distanceFilter: 5),
    );
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  LocationSettings _resolveSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        forceLocationManager: false,
        intervalDuration: const Duration(seconds: 1),
        timeLimit: _resolveTimeout,
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.best,
        activityType: ActivityType.fitness,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        timeLimit: _resolveTimeout,
      );
    }
    return LocationSettings(
      accuracy: LocationAccuracy.best,
      timeLimit: _resolveTimeout,
    );
  }

  LocationSettings _watchSettings({required int distanceFilter}) {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: distanceFilter,
        forceLocationManager: false,
        intervalDuration: const Duration(seconds: 2),
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.best,
        activityType: ActivityType.fitness,
        distanceFilter: distanceFilter,
        pauseLocationUpdatesAutomatically: false,
      );
    }
    return LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: distanceFilter,
    );
  }

  bool _isValid(Position position) {
    if (!position.latitude.isFinite || !position.longitude.isFinite) return false;
    if (position.latitude == 0 && position.longitude == 0) return false;
    return true;
  }

  bool _isUsableCached(Position position) {
    if (!_isValid(position)) return false;
    if (!_isRecent(position)) return false;
    if (position.accuracy > _maxCachedAccuracyMeters) return false;
    return true;
  }

  bool _isRecent(Position position) {
    return DateTime.now().difference(position.timestamp) <= _recentPositionMaxAge;
  }
}
