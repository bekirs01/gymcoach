enum OutboxItemType {
  chatTextMessage,
  chatImageMessage,
  chatAudioMessage,
  feedPost,
  story,
}

enum OutboxItemStatus {
  pending,
  syncing,
  synced,
  failed,
}

final class OutboxItem {
  const OutboxItem({
    required this.localId,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.retryCount,
    required this.nextRetryAt,
    required this.status,
    required this.payload,
    this.localMediaPath,
    this.remoteId,
    this.remoteMediaPath,
    this.remoteMediaUrl,
  });

  final String localId;
  final OutboxItemType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int retryCount;
  final DateTime nextRetryAt;
  final OutboxItemStatus status;
  final Map<String, dynamic> payload;
  final String? localMediaPath;
  final String? remoteId;
  final String? remoteMediaPath;
  final String? remoteMediaUrl;

  bool get isPending =>
      status == OutboxItemStatus.pending || status == OutboxItemStatus.syncing;

  OutboxItem copyWith({
    DateTime? updatedAt,
    int? retryCount,
    DateTime? nextRetryAt,
    OutboxItemStatus? status,
    Map<String, dynamic>? payload,
    String? localMediaPath,
    String? remoteId,
    String? remoteMediaPath,
    String? remoteMediaUrl,
    bool clearRemoteId = false,
    bool clearRemoteMediaPath = false,
    bool clearRemoteMediaUrl = false,
    bool clearLocalMediaPath = false,
  }) {
    return OutboxItem(
      localId: localId,
      type: type,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      status: status ?? this.status,
      payload: payload ?? this.payload,
      localMediaPath: clearLocalMediaPath ? null : (localMediaPath ?? this.localMediaPath),
      remoteId: clearRemoteId ? null : (remoteId ?? this.remoteId),
      remoteMediaPath:
          clearRemoteMediaPath ? null : (remoteMediaPath ?? this.remoteMediaPath),
      remoteMediaUrl: clearRemoteMediaUrl ? null : (remoteMediaUrl ?? this.remoteMediaUrl),
    );
  }

  static OutboxItemType parseType(String? value) {
    switch (value) {
      case 'chat_image_message':
        return OutboxItemType.chatImageMessage;
      case 'chat_audio_message':
        return OutboxItemType.chatAudioMessage;
      case 'feed_post':
        return OutboxItemType.feedPost;
      case 'story':
        return OutboxItemType.story;
      default:
        return OutboxItemType.chatTextMessage;
    }
  }

  static String typeToWire(OutboxItemType type) {
    switch (type) {
      case OutboxItemType.chatImageMessage:
        return 'chat_image_message';
      case OutboxItemType.chatAudioMessage:
        return 'chat_audio_message';
      case OutboxItemType.feedPost:
        return 'feed_post';
      case OutboxItemType.story:
        return 'story';
      case OutboxItemType.chatTextMessage:
        return 'chat_text_message';
    }
  }

  static OutboxItemStatus parseStatus(String? value) {
    switch (value) {
      case 'syncing':
        return OutboxItemStatus.syncing;
      case 'synced':
        return OutboxItemStatus.synced;
      case 'failed':
        return OutboxItemStatus.failed;
      default:
        return OutboxItemStatus.pending;
    }
  }

  static String statusToWire(OutboxItemStatus status) {
    switch (status) {
      case OutboxItemStatus.syncing:
        return 'syncing';
      case OutboxItemStatus.synced:
        return 'synced';
      case OutboxItemStatus.failed:
        return 'failed';
      case OutboxItemStatus.pending:
        return 'pending';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'local_id': localId,
      'type': typeToWire(type),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'retry_count': retryCount,
      'next_retry_at': nextRetryAt.toIso8601String(),
      'status': statusToWire(status),
      'payload': payload,
      'local_media_path': localMediaPath,
      'remote_id': remoteId,
      'remote_media_path': remoteMediaPath,
      'remote_media_url': remoteMediaUrl,
    };
  }

  factory OutboxItem.fromJson(Map<String, dynamic> json) {
    return OutboxItem(
      localId: json['local_id'] as String? ?? '',
      type: parseType(json['type'] as String?),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      retryCount: (json['retry_count'] as num?)?.toInt() ?? 0,
      nextRetryAt: DateTime.tryParse(json['next_retry_at'] as String? ?? '') ?? DateTime.now(),
      status: parseStatus(json['status'] as String?),
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? const {}),
      localMediaPath: json['local_media_path'] as String?,
      remoteId: json['remote_id'] as String?,
      remoteMediaPath: json['remote_media_path'] as String?,
      remoteMediaUrl: json['remote_media_url'] as String?,
    );
  }
}
