enum ChatAttachmentType {
  image,
  voice,
  file,
}

class ChatAttachment {
  const ChatAttachment({
    required this.id,
    required this.messageId,
    required this.conversationId,
    required this.uploaderId,
    required this.storageBucket,
    required this.storagePath,
    required this.mimeType,
    required this.sizeBytes,
    required this.attachmentType,
    this.width,
    this.height,
    this.durationMs,
    this.waveform = const [],
    this.originalFileName,
    this.signedUrl,
    this.createdAt,
  });

  final String id;
  final String messageId;
  final String conversationId;
  final String uploaderId;
  final String storageBucket;
  final String storagePath;
  final String mimeType;
  final int sizeBytes;
  final ChatAttachmentType attachmentType;
  final int? width;
  final int? height;
  final int? durationMs;
  final List<double> waveform;
  final String? originalFileName;
  final String? signedUrl;
  final DateTime? createdAt;

  ChatAttachment copyWith({
    String? id,
    String? messageId,
    String? conversationId,
    String? uploaderId,
    String? storageBucket,
    String? storagePath,
    String? mimeType,
    int? sizeBytes,
    ChatAttachmentType? attachmentType,
    int? width,
    int? height,
    int? durationMs,
    List<double>? waveform,
    String? originalFileName,
    String? signedUrl,
    DateTime? createdAt,
  }) {
    return ChatAttachment(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      uploaderId: uploaderId ?? this.uploaderId,
      storageBucket: storageBucket ?? this.storageBucket,
      storagePath: storagePath ?? this.storagePath,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      attachmentType: attachmentType ?? this.attachmentType,
      width: width ?? this.width,
      height: height ?? this.height,
      durationMs: durationMs ?? this.durationMs,
      waveform: waveform ?? this.waveform,
      originalFileName: originalFileName ?? this.originalFileName,
      signedUrl: signedUrl ?? this.signedUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static ChatAttachmentType typeFromMime(String mimeType, {String? messageType}) {
    if (messageType == 'voice' || mimeType.startsWith('audio/')) {
      return ChatAttachmentType.voice;
    }
    if (mimeType.startsWith('image/')) {
      return ChatAttachmentType.image;
    }
    return ChatAttachmentType.file;
  }

  factory ChatAttachment.fromRow(Map<String, dynamic> row) {
    final waveformRaw = row['waveform'];
    final waveform = <double>[];
    if (waveformRaw is List) {
      for (final value in waveformRaw) {
        if (value is num) waveform.add(value.toDouble().clamp(0.0, 1.0));
      }
    }

    final mimeType = row['mime_type'] as String? ?? '';
    return ChatAttachment(
      id: row['id'] as String,
      messageId: row['message_id'] as String,
      conversationId: row['conversation_id'] as String,
      uploaderId: row['uploader_id'] as String,
      storageBucket: row['storage_bucket'] as String? ?? 'chat-media',
      storagePath: row['storage_path'] as String,
      mimeType: mimeType,
      sizeBytes: (row['size_bytes'] as num?)?.toInt() ?? 0,
      attachmentType: typeFromMime(mimeType),
      width: (row['width'] as num?)?.toInt(),
      height: (row['height'] as num?)?.toInt(),
      durationMs: (row['duration_ms'] as num?)?.toInt(),
      waveform: waveform,
      originalFileName: row['original_file_name'] as String?,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at'] as String) : null,
    );
  }
}
