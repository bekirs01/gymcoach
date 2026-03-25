import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Cihaz GPS mi, otomatik kare rota simülasyonu mu.
enum TerritoryRouteMode { device, simulation }

/// Oyun durumu — Riverpod `TerritoryGameState` ile taşınır.
class TerritoryGameState {
  const TerritoryGameState({
    required this.users,
    required this.territories,
    required this.mapCenter,
    this.liveUserPosition,
    this.activeRoute = const [],
    this.isRecording = false,
    this.mode = TerritoryRouteMode.simulation,
    this.currentUserId = TerritoryModels.currentUserId,
    this.statusMessage,
    this.permissionDenied = false,
  });

  final Map<String, TerritoryProfile> users;
  final List<TerritoryZone> territories;

  /// Harita ilk odak / simülasyon merkezi (İstanbul yakını — demo).
  final LatLng mapCenter;
  final LatLng? liveUserPosition;

  /// Kayıtlı rota (başlangıç dahil, kapanış noktası henüz “tam” olmayabilir).
  final List<LatLng> activeRoute;
  final bool isRecording;
  final TerritoryRouteMode mode;
  final String currentUserId;
  final String? statusMessage;
  final bool permissionDenied;

  TerritoryGameState copyWith({
    Map<String, TerritoryProfile>? users,
    List<TerritoryZone>? territories,
    LatLng? mapCenter,
    LatLng? liveUserPosition,
    List<LatLng>? activeRoute,
    bool? isRecording,
    TerritoryRouteMode? mode,
    String? currentUserId,
    String? statusMessage,
    bool? permissionDenied,
    bool clearLiveUser = false,
    bool clearRoute = false,
    bool clearStatus = false,
  }) {
    return TerritoryGameState(
      users: users ?? this.users,
      territories: territories ?? this.territories,
      mapCenter: mapCenter ?? this.mapCenter,
      liveUserPosition: clearLiveUser ? null : (liveUserPosition ?? this.liveUserPosition),
      activeRoute: clearRoute ? const [] : (activeRoute ?? this.activeRoute),
      isRecording: isRecording ?? this.isRecording,
      mode: mode ?? this.mode,
      currentUserId: currentUserId ?? this.currentUserId,
      statusMessage: clearStatus ? null : (statusMessage ?? this.statusMessage),
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }
}

/// Mock + ileride gerçek kullanıcı için profil.
class TerritoryProfile {
  const TerritoryProfile({
    required this.id,
    required this.displayName,
    required this.avatarLabel,
    required this.themeColor,
    this.totalCaptures = 0,
  });

  final String id;
  final String displayName;
  final String avatarLabel;
  final Color themeColor;

  /// Toplam ele geçirme (mock sayaç; backend’de ayrı tablo olabilir).
  final int totalCaptures;

  TerritoryProfile copyWith({
    String? id,
    String? displayName,
    String? avatarLabel,
    Color? themeColor,
    int? totalCaptures,
  }) {
    return TerritoryProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarLabel: avatarLabel ?? this.avatarLabel,
      themeColor: themeColor ?? this.themeColor,
      totalCaptures: totalCaptures ?? this.totalCaptures,
    );
  }
}

/// Haritadaki bir “bölge” — kapalı poligon halkası (son nokta ilk ile aynı olabilir).
class TerritoryZone {
  const TerritoryZone({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.ring,
    required this.claimedAt,
    required this.areaSqM,
    required this.routeLengthM,
    this.captureCount = 0,
    this.lastCapturerId,
  });

  final String id;
  final String name;
  final String ownerId;

  /// Kapalı halka: [p0,...,pn-1,p0] veya [p0,...,pn-1] (çizim katmanı kapatır).
  final List<LatLng> ring;
  final DateTime claimedAt;
  final double areaSqM;
  final double routeLengthM;
  final int captureCount;
  final String? lastCapturerId;

  /// Çizim için kapalı ring (en az 4 nokta: üç köşe + kapanış).
  List<LatLng> get closedRing {
    if (ring.isEmpty) return ring;
    if (ring.length >= 2) {
      final a = ring.first;
      final b = ring.last;
      if (a.latitude == b.latitude && a.longitude == b.longitude) return ring;
    }
    return [...ring, ring.first];
  }

  TerritoryZone copyWith({
    String? id,
    String? name,
    String? ownerId,
    List<LatLng>? ring,
    DateTime? claimedAt,
    double? areaSqM,
    double? routeLengthM,
    int? captureCount,
    String? lastCapturerId,
  }) {
    return TerritoryZone(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      ring: ring ?? this.ring,
      claimedAt: claimedAt ?? this.claimedAt,
      areaSqM: areaSqM ?? this.areaSqM,
      routeLengthM: routeLengthM ?? this.routeLengthM,
      captureCount: captureCount ?? this.captureCount,
      lastCapturerId: lastCapturerId ?? this.lastCapturerId,
    );
  }
}

class TerritoryModels {
  TerritoryModels._();

  /// Aktif kullanıcı — gerçek auth geldiğinde JWT / uid ile değiştirilecek.
  static const String currentUserId = 'u_me';

  static TerritoryProfile colorForUser(String id, String name, String label) {
    final hash = id.hashCode.abs();
    final hue = (hash % 360).toDouble();
    return TerritoryProfile(
      id: id,
      displayName: name,
      avatarLabel: label,
      themeColor: HSVColor.fromAHSV(1, hue, 0.55, 0.95).toColor(),
      totalCaptures: 0,
    );
  }
}
