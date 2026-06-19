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
    this.localPreviewBytes,
    this.localVoicePath,
  });

  final String id;
  final String senderId;
  final String body;
  final DateTime sentAt;
  final ChatMessageType messageType;
  final List<ChatAttachment> attachments;
  final String? clientTempId;
  final bool isPending;
  final bool hasFailed;
  final ChatMessageSendState? sendState;
  final Uint8List? localPreviewBytes;
  final String? localVoicePath;

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

  bool isFromCurrentUser(String currentUserId) => senderId == currentUserId;

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? body,
    DateTime? sentAt,
    ChatMessageType? messageType,
    List<ChatAttachment>? attachments,
    String? clientTempId,
    bool? isPending,
    bool? hasFailed,
    ChatMessageSendState? sendState,
    Uint8List? localPreviewBytes,
    String? localVoicePath,
    bool clearSendState = false,
    bool clearLocalPreviewBytes = false,
    bool clearLocalVoicePath = false,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      body: body ?? this.body,
      sentAt: sentAt ?? this.sentAt,
      messageType: messageType ?? this.messageType,
      attachments: attachments ?? this.attachments,
      clientTempId: clientTempId ?? this.clientTempId,
      isPending: isPending ?? this.isPending,
      hasFailed: hasFailed ?? this.hasFailed,
      sendState: clearSendState ? null : (sendState ?? this.sendState),
      localPreviewBytes:
          clearLocalPreviewBytes ? null : (localPreviewBytes ?? this.localPreviewBytes),
      localVoicePath: clearLocalVoicePath ? null : (localVoicePath ?? this.localVoicePath),
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

  factory ChatMessage.fromRow(
    Map<String, dynamic> row, {
    List<ChatAttachment> attachments = const [],
  }) {
    return ChatMessage(
      id: row['id'] as String,
      senderId: row['sender_id'] as String,
      body: row['body'] as String? ?? '',
      sentAt: DateTime.parse(row['created_at'] as String),
      messageType: parseMessageType(row['message_type'] as String?),
      attachments: attachments,
      clientTempId: row['client_temp_id'] as String?,
    );
  }
}
