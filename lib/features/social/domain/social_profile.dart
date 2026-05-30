class SocialProfile {
  const SocialProfile({
    required this.userId,
    required this.displayName,
    required this.bio,
    required this.privateNotes,
    required this.avatarUrl,
    required this.coverUrl,
    required this.isPublic,
  });

  final String userId;
  final String displayName;
  final String bio;
  final String privateNotes;
  final String avatarUrl;
  final String coverUrl;
  final bool isPublic;

  bool get hasAvatar => avatarUrl.trim().isNotEmpty;

  factory SocialProfile.fromRow(Map<String, dynamic> row) {
    return SocialProfile(
      userId: row['id'] as String? ?? row['user_id'] as String? ?? '',
      displayName: row['display_name'] as String? ?? '',
      bio: row['bio'] as String? ?? '',
      privateNotes: row['private_notes'] as String? ?? '',
      avatarUrl: row['avatar_url'] as String? ?? '',
      coverUrl: row['cover_url'] as String? ?? '',
      isPublic: row['is_public'] as bool? ?? true,
    );
  }
}
