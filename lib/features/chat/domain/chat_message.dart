import 'dart:typed_data';

import 'chat_attachment.dart';

enum ChatMessageType {
  text,
  image,
  voice,
  mixed,
}

enum ChatMessageSendState {
  idle,
  sending,
  failed,
}

enum ChatDeliveryStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

enum ChatSenderType {
  user,
  seededContact,
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.body,
    required this.sentAt,
    this.messageType = ChatMessageType.text,
    this.attachments = const [],
    this.clientTempId,
    this.isPending = false,
    this.hasFailed = false,
    this.sendState,
    this.senderType = ChatSenderType.user,
    this.localPreviewBytes,
    this.localImagePath,
    this.localVoicePath,
    this.editedAt,
    this.deletedAt,
    this.replyToMessageId,
    this.replyToMessage,
    this.deliveryStatus = ChatDeliveryStatus.sent,
    this.deliveredAt,
    this.readAt,
    this.deletedForEveryone = false,
    this.mediaBucket,
    this.mediaPath,
    this.mediaUrl,
    this.audioDurationMs,
    this.audioWaveform = const [],
  });

  final String id;
  final String senderId;
  final String body;
  final DateTime sentAt;
  final ChatSenderType senderType;
  final ChatMessageType messageType;
  final List<ChatAttachment> attachments;
  final String? clientTempId;
  final bool isPending;
  final bool hasFailed;
  final ChatMessageSendState? sendState;
  final Uint8List? localPreviewBytes;
  final String? localImagePath;
  final String? localVoicePath;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final String? replyToMessageId;
  final ChatMessage? replyToMessage;
  final ChatDeliveryStatus deliveryStatus;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final bool deletedForEveryone;
  final String? mediaBucket;
  final String? mediaPath;
  final String? mediaUrl;
  final int? audioDurationMs;
  final List<double> audioWaveform;

  bool get isVoice => messageType == ChatMessageType.voice;

  bool get hasImage {
    if (messageType == ChatMessageType.image || messageType == ChatMessageType.mixed) {
      return true;
    }
    return attachments.any((item) => item.attachmentType == ChatAttachmentType.image);
  }

  bool get isFailed =>
      hasFailed ||
      sendState == ChatMessageSendState.failed ||
      deliveryStatus == ChatDeliveryStatus.failed;

  bool get isUploading =>
      isPending ||
      sendState == ChatMessageSendState.sending ||
      deliveryStatus == ChatDeliveryStatus.sending;

  bool get isDeleted => deletedAt != null || deletedForEveryone;

  bool get isEdited => editedAt != null;

  bool get hasReply => replyToMessageId != null;

  bool get hasCopyableText => body.trim().isNotEmpty && !isVoice && !isDeleted;

  bool canEditFor(String currentUserId) {
    if (isDeleted || isPending || isFailed) return false;
    if (!isFromCurrentUser(currentUserId)) return false;
    if (isVoice && body.trim().isEmpty) return false;
    if (hasImage && body.trim().isEmpty) return false;
    return messageType == ChatMessageType.text ||
        (body.trim().isNotEmpty && (hasImage || messageType == ChatMessageType.mixed));
  }

  String? get primaryImageUrl {
    final inline = mediaUrl;
    if (inline != null && inline.isNotEmpty) return inline;
    for (final attachment in attachments) {
      if (attachment.attachmentType == ChatAttachmentType.image) {
        final url = attachment.signedUrl;
        if (url != null && url.isNotEmpty) return url;
      }
    }
    return null;
  }

  String? get primaryVoiceUrl {
    final inline = mediaUrl;
    if (inline != null && inline.isNotEmpty) return inline;
    final attachment = voiceAttachment;
    final url = attachment?.signedUrl;
    if (url != null && url.isNotEmpty) return url;
    return localVoicePath;
  }

  ChatAttachment? get voiceAttachment {
    for (final attachment in attachments) {
      if (attachment.attachmentType == ChatAttachmentType.voice) return attachment;
    }
    return null;
  }

  bool isFromCurrentUser(String currentUserId) {
    if (senderType == ChatSenderType.seededContact) return false;
    return senderId == currentUserId;
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? body,
    DateTime? sentAt,
    ChatMessageType? messageType,
    ChatSenderType? senderType,
    List<ChatAttachment>? attachments,
    String? clientTempId,
    bool? isPending,
    bool? hasFailed,
    ChatMessageSendState? sendState,
    Uint8List? localPreviewBytes,
    String? localImagePath,
    String? localVoicePath,
    DateTime? editedAt,
    DateTime? deletedAt,
    String? replyToMessageId,
    ChatMessage? replyToMessage,
    bool clearSendState = false,
    bool clearLocalPreviewBytes = false,
    bool clearLocalImagePath = false,
    bool clearLocalVoicePath = false,
    bool clearEditedAt = false,
    bool clearDeletedAt = false,
    bool clearReplyToMessageId = false,
    bool clearReplyToMessage = false,
    bool clearAttachments = false,
    ChatDeliveryStatus? deliveryStatus,
    DateTime? deliveredAt,
    DateTime? readAt,
    bool? deletedForEveryone,
    String? mediaBucket,
    String? mediaPath,
    String? mediaUrl,
    int? audioDurationMs,
    List<double>? audioWaveform,
    bool clearDeliveredAt = false,
    bool clearReadAt = false,
    bool clearMediaBucket = false,
    bool clearMediaPath = false,
    bool clearMediaUrl = false,
    bool clearAudioDurationMs = false,
    bool clearAudioWaveform = false,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      body: body ?? this.body,
      sentAt: sentAt ?? this.sentAt,
      messageType: messageType ?? this.messageType,
      senderType: senderType ?? this.senderType,
      attachments: clearAttachments ? const [] : (attachments ?? this.attachments),
      clientTempId: clientTempId ?? this.clientTempId,
      isPending: isPending ?? this.isPending,
      hasFailed: hasFailed ?? this.hasFailed,
      sendState: clearSendState ? null : (sendState ?? this.sendState),
      localPreviewBytes:
          clearLocalPreviewBytes ? null : (localPreviewBytes ?? this.localPreviewBytes),
      localImagePath: clearLocalImagePath ? null : (localImagePath ?? this.localImagePath),
      localVoicePath: clearLocalVoicePath ? null : (localVoicePath ?? this.localVoicePath),
      editedAt: clearEditedAt ? null : (editedAt ?? this.editedAt),
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      replyToMessageId:
          clearReplyToMessageId ? null : (replyToMessageId ?? this.replyToMessageId),
      replyToMessage: clearReplyToMessage ? null : (replyToMessage ?? this.replyToMessage),
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveredAt: clearDeliveredAt ? null : (deliveredAt ?? this.deliveredAt),
      readAt: clearReadAt ? null : (readAt ?? this.readAt),
      deletedForEveryone: deletedForEveryone ?? this.deletedForEveryone,
      mediaBucket: clearMediaBucket ? null : (mediaBucket ?? this.mediaBucket),
      mediaPath: clearMediaPath ? null : (mediaPath ?? this.mediaPath),
      mediaUrl: clearMediaUrl ? null : (mediaUrl ?? this.mediaUrl),
      audioDurationMs: clearAudioDurationMs ? null : (audioDurationMs ?? this.audioDurationMs),
      audioWaveform: clearAudioWaveform ? const [] : (audioWaveform ?? this.audioWaveform),
    );
  }

  static ChatDeliveryStatus parseDeliveryStatus(String? value) {
    switch (value) {
      case 'sending':
        return ChatDeliveryStatus.sending;
      case 'delivered':
        return ChatDeliveryStatus.delivered;
      case 'read':
        return ChatDeliveryStatus.read;
      case 'failed':
        return ChatDeliveryStatus.failed;
      default:
        return ChatDeliveryStatus.sent;
    }
  }

  static String deliveryStatusToDb(ChatDeliveryStatus status) {
    switch (status) {
      case ChatDeliveryStatus.sending:
        return 'sending';
      case ChatDeliveryStatus.delivered:
        return 'delivered';
      case ChatDeliveryStatus.read:
        return 'read';
      case ChatDeliveryStatus.failed:
        return 'failed';
      case ChatDeliveryStatus.sent:
        return 'sent';
    }
  }

  static ChatMessageType parseMessageType(String? value) {
    switch (value) {
      case 'image':
        return ChatMessageType.image;
      case 'voice':
        return ChatMessageType.voice;
      case 'mixed':
        return ChatMessageType.mixed;
      default:
        return ChatMessageType.text;
    }
  }

  static String messageTypeToDb(ChatMessageType type) {
    switch (type) {
      case ChatMessageType.image:
        return 'image';
      case ChatMessageType.voice:
        return 'voice';
      case ChatMessageType.mixed:
        return 'mixed';
      case ChatMessageType.text:
        return 'text';
    }
  }

  static ChatSenderType parseSenderType(String? value) {
    if (value == 'seeded_contact') return ChatSenderType.seededContact;
    return ChatSenderType.user;
  }

  static DateTime? _parseOptionalTimestamp(Object? value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }

  factory ChatMessage.fromRow(
    Map<String, dynamic> row, {
    List<ChatAttachment> attachments = const [],
    ChatMessage? replyToMessage,
  }) {
    final waveformRaw = row['audio_waveform'];
    final waveform = <double>[];
    if (waveformRaw is List) {
      for (final value in waveformRaw) {
        if (value is num) waveform.add(value.toDouble().clamp(0.0, 1.0));
      }
    }

    return ChatMessage(
      id: row['id'] as String,
      senderId: row['sender_id'] as String,
      body: row['body'] as String? ?? '',
      sentAt: DateTime.parse(row['created_at'] as String),
      senderType: parseSenderType(row['sender_type'] as String?),
      messageType: parseMessageType(row['message_type'] as String?),
      attachments: attachments,
      clientTempId: row['client_temp_id'] as String?,
      editedAt: _parseOptionalTimestamp(row['edited_at']),
      deletedAt: _parseOptionalTimestamp(row['deleted_at']),
      replyToMessageId: row['reply_to_message_id'] as String?,
      replyToMessage: replyToMessage,
      deliveryStatus: parseDeliveryStatus(row['status'] as String?),
      deliveredAt: _parseOptionalTimestamp(row['delivered_at']),
      readAt: _parseOptionalTimestamp(row['read_at']),
      deletedForEveryone: row['deleted_for_everyone'] == true,
      mediaBucket: row['media_bucket'] as String?,
      mediaPath: row['media_path'] as String?,
      mediaUrl: row['media_url'] as String?,
      audioDurationMs: (row['audio_duration_ms'] as num?)?.toInt(),
      audioWaveform: waveform,
    );
  }
}
