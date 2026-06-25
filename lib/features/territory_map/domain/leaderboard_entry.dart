class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.displayName,
    required this.totalAreaSquareMeters,
    required this.territoryCount,
    required this.userId,
    this.avatarUrl = '',
  });

  final int rank;
  final String displayName;
  final double totalAreaSquareMeters;
  final int territoryCount;
  final String userId;
  final String avatarUrl;

  LeaderboardEntry copyWith({
    int? rank,
    String? displayName,
    double? totalAreaSquareMeters,
    int? territoryCount,
    String? userId,
    String? avatarUrl,
  }) {
    return LeaderboardEntry(
      rank: rank ?? this.rank,
      displayName: displayName ?? this.displayName,
      totalAreaSquareMeters: totalAreaSquareMeters ?? this.totalAreaSquareMeters,
      territoryCount: territoryCount ?? this.territoryCount,
      userId: userId ?? this.userId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      displayName: json['display_name'] as String? ?? json['displayName'] as String? ?? 'Unknown',
      totalAreaSquareMeters: (json['total_area_m2'] as num? ??
              json['total_area_square_meters'] as num? ??
              json['totalAreaSquareMeters'] as num? ??
              0)
          .toDouble(),
      territoryCount: (json['territory_count'] as num? ?? json['territoryCount'] as num? ?? 0)
          .toInt(),
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String? ?? '',
    );
  }
}
