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
    this.localVoicePath,
    this.editedAt,
    this.deletedAt,
    this.replyToMessageId,
    this.replyToMessage,
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
  final String? localVoicePath;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final String? replyToMessageId;
  final ChatMessage? replyToMessage;

  bool get isVoice => messageType == ChatMessageType.voice;

  bool get hasImage {
    if (messageType == ChatMessageType.image || messageType == ChatMessageType.mixed) {
      return true;
    }
    return attachments.any((item) => item.attachmentType == ChatAttachmentType.image);
  }

  bool get isFailed =>
      hasFailed || sendState == ChatMessageSendState.failed;

  bool get isUploading =>
      isPending || sendState == ChatMessageSendState.sending;

  bool get isDeleted => deletedAt != null;

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
    for (final attachment in attachments) {
      if (attachment.attachmentType == ChatAttachmentType.image) {
        final url = attachment.signedUrl;
        if (url != null && url.isNotEmpty) return url;
      }
    }
    return null;
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
    String? localVoicePath,
    DateTime? editedAt,
    DateTime? deletedAt,
    String? replyToMessageId,
    ChatMessage? replyToMessage,
    bool clearSendState = false,
    bool clearLocalPreviewBytes = false,
    bool clearLocalVoicePath = false,
    bool clearEditedAt = false,
    bool clearDeletedAt = false,
    bool clearReplyToMessageId = false,
    bool clearReplyToMessage = false,
    bool clearAttachments = false,
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
      localVoicePath: clearLocalVoicePath ? null : (localVoicePath ?? this.localVoicePath),
      editedAt: clearEditedAt ? null : (editedAt ?? this.editedAt),
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      replyToMessageId:
          clearReplyToMessageId ? null : (replyToMessageId ?? this.replyToMessageId),
      replyToMessage: clearReplyToMessage ? null : (replyToMessage ?? this.replyToMessage),
    );
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
    );
  }
}
