class FeedMedia {
  const FeedMedia({
    required this.id,
    required this.postId,
    required this.url,
    required this.path,
    required this.sortOrder,
    this.localPath,
  });

  final String id;
  final String postId;
  final String url;
  final String path;
  final int sortOrder;
  final String? localPath;

  factory FeedMedia.fromRow(Map<String, dynamic> row) {
    return FeedMedia(
      id: row['id'] as String? ?? '',
      postId: row['post_id'] as String? ?? '',
      url: row['media_url'] as String? ?? '',
      path: row['media_path'] as String? ?? '',
      sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
      localPath: row['local_path'] as String?,
    );
  }
}
