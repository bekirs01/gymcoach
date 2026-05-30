class Territory {
  const Territory({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.ownerDisplayName,
    required this.areaSquareMeters,
    required this.capturedAt,
    required this.polygonGeoJson,
    required this.isOwnedByCurrentUser,
    this.ownerAvatarUrl = '',
  });

  final String id;
  final String name;
  final String ownerId;
  final String ownerDisplayName;
  final String ownerAvatarUrl;
  final double areaSquareMeters;
  final DateTime capturedAt;
  final Map<String, dynamic> polygonGeoJson;
  final bool isOwnedByCurrentUser;

  Territory copyWith({
    String? name,
    String? ownerDisplayName,
    String? ownerAvatarUrl,
    bool? isOwnedByCurrentUser,
  }) {
    return Territory(
      id: id,
      name: name ?? this.name,
      ownerId: ownerId,
      ownerDisplayName: ownerDisplayName ?? this.ownerDisplayName,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
      areaSquareMeters: areaSquareMeters,
      capturedAt: capturedAt,
      polygonGeoJson: polygonGeoJson,
      isOwnedByCurrentUser: isOwnedByCurrentUser ?? this.isOwnedByCurrentUser,
    );
  }

  factory Territory.fromJson(Map<String, dynamic> json, {required String currentUserId}) {
    final ownerId = json['owner_user_id'] as String? ?? json['owner_id'] as String? ?? json['ownerId'] as String? ?? '';
    final geometry = json['geometry'] as Map?;
    final polygon = json['polygon_geojson'] as Map? ?? json['polygonGeoJson'] as Map?;
    return Territory(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Territory',
      ownerId: ownerId,
      ownerDisplayName:
          json['owner_display_name'] as String? ?? json['ownerDisplayName'] as String? ?? 'Unknown',
      ownerAvatarUrl: json['owner_avatar_url'] as String? ?? json['ownerAvatarUrl'] as String? ?? '',
      areaSquareMeters: (json['area_m2'] as num? ??
              json['area_square_meters'] as num? ??
              json['areaSquareMeters'] as num? ??
              0)
          .toDouble(),
      capturedAt: DateTime.parse(
        json['captured_at'] as String? ?? json['capturedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      polygonGeoJson: Map<String, dynamic>.from(geometry ?? polygon ?? const {}),
      isOwnedByCurrentUser: ownerId == currentUserId,
    );
  }
}
