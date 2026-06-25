import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../features/chat/domain/chat_attachment.dart';
import '../../features/chat/domain/chat_conversation.dart';
import '../../features/chat/domain/chat_message.dart';

final class LocalChatCache {
  LocalChatCache._();

  static LocalChatCache? _instance;
  static LocalChatCache get instance => _instance ??= LocalChatCache._();

  static const _fileName = 'chat_cache.json';
  static const _folderName = 'gymcoach_outbox';

  final Map<String, _CachedConversation> _conversations = {};
  var _loaded = false;
  File? _file;

  Future<File> _ensureFile() async {
    if (_file != null) return _file!;
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/$_folderName');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    _file = File('${folder.path}/$_fileName');
    return _file!;
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final file = await _ensureFile();
    if (!await file.exists()) {
      _loaded = true;
      return;
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        _loaded = true;
        return;
      }
      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final conversations = map['conversations'] as Map<String, dynamic>? ?? {};
      for (final entry in conversations.entries) {
        _conversations[entry.key] = _CachedConversation.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
      }
    } catch (_) {}
    _loaded = true;
  }

  Future<void> saveConversation(ChatConversation conversation) async {
    await ensureLoaded();
    _conversations[conversation.id] = _CachedConversation.fromConversation(
      conversation,
    );
    await _persist();
  }

  Future<void> saveMessages({
    required String conversationId,
    required List<ChatMessage> messages,
    ChatConversation? meta,
  }) async {
    await ensureLoaded();
    final existing = _conversations[conversationId];
    if (existing != null) {
      _conversations[conversationId] = existing.copyWith(messages: messages);
    } else if (meta != null) {
      _conversations[conversationId] = _CachedConversation.fromConversation(
        meta.copyWith(messages: messages),
      );
    } else {
      return;
    }
    await _persist();
  }

  ChatConversation? conversationFor(String conversationId) {
    final cached = _conversations[conversationId];
    return cached?.toConversation();
  }

  ChatConversation? conversationForParticipant(String participantUserId) {
    for (final cached in _conversations.values) {
      if (cached.participantUserId == participantUserId) {
        return cached.toConversation();
      }
    }
    return null;
  }

  String? conversationIdForParticipant(String participantUserId) {
    for (final entry in _conversations.entries) {
      if (entry.value.participantUserId == participantUserId) {
        return entry.key;
      }
    }
    return null;
  }

  List<ChatConversation> allConversations() {
    return _conversations.values.map((item) => item.toConversation()).toList();
  }

  Future<void> upsertMessage({
    required String conversationId,
    required ChatMessage message,
    ChatConversation? meta,
  }) async {
    await ensureLoaded();
    var cached = _conversations[conversationId];
    if (cached == null && meta != null) {
      cached = _CachedConversation.fromConversation(meta);
      _conversations[conversationId] = cached;
    }
    if (cached == null) return;

    final messages = List<ChatMessage>.from(cached.messages);
    final index = messages.indexWhere(
      (item) =>
          item.id == message.id ||
          (message.clientTempId != null &&
              item.clientTempId == message.clientTempId),
    );
    if (index >= 0) {
      messages[index] = message;
    } else {
      messages.add(message);
    }
    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    _conversations[conversationId] = cached.copyWith(
      messages: messages,
      cachedLastMessageText: _previewFor(message),
      cachedLastMessageTime: message.sentAt,
    );
    await _persist();
  }

  Future<void> removeMessage({
    required String conversationId,
    required String messageId,
    String? clientTempId,
  }) async {
    await ensureLoaded();
    final cached = _conversations[conversationId];
    if (cached == null) return;
    final messages = cached.messages
        .where(
          (item) =>
              item.id != messageId &&
              (clientTempId == null || item.clientTempId != clientTempId),
        )
        .toList();
    _conversations[conversationId] = cached.copyWith(messages: messages);
    await _persist();
  }

  static List<ChatMessage> mergeMessages({
    required List<ChatMessage> remote,
    required List<ChatMessage> local,
  }) {
    final byKey = <String, ChatMessage>{};

    for (final message in remote) {
      byKey[_mergeKey(message)] = message;
    }

    for (final message in local) {
      final key = _mergeKey(message);
      final existing = byKey[key];
      if (existing == null) {
        byKey[key] = message;
        continue;
      }
      if (_shouldPreferLocal(existing, message)) {
        byKey[key] = _mergeLocalMedia(message, existing);
      } else {
        byKey[key] = _mergeLocalMedia(existing, message);
      }
    }

    final merged = dedupeMessages(byKey.values.toList());
    merged.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return merged;
  }

  static List<ChatMessage> dedupeMessages(List<ChatMessage> messages) {
    final byKey = <String, ChatMessage>{};

    for (final message in messages) {
      final key = _semanticKey(message);
      final existing = byKey[key];
      if (existing == null) {
        byKey[key] = message;
        continue;
      }
      byKey[key] = _preferMessage(existing, message);
    }

    final deduped = byKey.values.toList();
    deduped.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return deduped;
  }

  static String _mergeKey(ChatMessage message) {
    if (message.clientTempId != null && message.clientTempId!.isNotEmpty) {
      return 'temp:${message.clientTempId}';
    }
    return 'id:${message.id}';
  }

  static String _semanticKey(ChatMessage message) {
    final tempId = message.clientTempId;
    if (tempId != null && tempId.isNotEmpty) return 'temp:$tempId';

    final body = message.body
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
    final mediaKey =
        message.mediaPath ??
        message.attachments
            .where((item) => item.storagePath.isNotEmpty)
            .map((item) => item.storagePath)
            .join('|');
    final senderKey =
        message.senderType == ChatSenderType.seededContact ||
            message.senderId.startsWith('seed_')
        ? message.senderId
        : '';

    if (senderKey.isNotEmpty && body.isNotEmpty) {
      return 'seed:$senderKey:${message.messageType.name}:$body:$mediaKey';
    }
    if (_demoSeedBodies.contains(body)) {
      return 'demo:${message.messageType.name}:$body:$mediaKey';
    }
    return 'id:${message.id}';
  }

  static final Set<String> _demoSeedBodies = {
    'hey, did you train today?',
    'yes, just finished shoulders.',
    'nice, i\'m going to the gym later.',
    'send your workout after.',
    'sure 😄',
    'how was your leg day?',
    'hard but good.',
    'same here, i\'m still tired.',
    'recovery day tomorrow.',
    'did you try the new stretch routine?',
    'not yet, sending it now.',
    'sent a workout plan',
    'any tips for pacing on long runs?',
    'start slow, finish strong.',
    'thanks for the tips!',
    'squats felt heavy today.',
    'same, deload week maybe?',
    'leg day was intense',
  };

  static ChatMessage _preferMessage(ChatMessage current, ChatMessage incoming) {
    if (_shouldPreferLocal(incoming, current)) return current;
    if (_shouldPreferLocal(current, incoming)) return incoming;
    if (current.id.startsWith('msg_') && !incoming.id.startsWith('msg_')) {
      return _mergeLocalMedia(incoming, current);
    }
    if (incoming.id.startsWith('msg_') && !current.id.startsWith('msg_')) {
      return _mergeLocalMedia(current, incoming);
    }
    return incoming.sentAt.isAfter(current.sentAt)
        ? _mergeLocalMedia(incoming, current)
        : _mergeLocalMedia(current, incoming);
  }

  static bool _shouldPreferLocal(ChatMessage remote, ChatMessage local) {
    if (local.isPending || local.isUploading) return true;
    if (local.isFailed && !remote.isFailed) return true;
    if (local.id.startsWith('pending_') && !remote.id.startsWith('pending_')) {
      return false;
    }
    if (local.hasImage &&
        (local.localImagePath?.isNotEmpty == true ||
            local.localPreviewBytes != null) &&
        (remote.primaryImageUrl == null || remote.primaryImageUrl!.isEmpty)) {
      return true;
    }
    if (local.isVoice &&
        local.localVoicePath?.isNotEmpty == true &&
        (remote.primaryVoiceUrl == null || remote.primaryVoiceUrl!.isEmpty)) {
      return true;
    }
    return false;
  }

  static ChatMessage _mergeLocalMedia(
    ChatMessage primary,
    ChatMessage secondary,
  ) {
    return primary.copyWith(
      localPreviewBytes:
          primary.localPreviewBytes ?? secondary.localPreviewBytes,
      localImagePath: primary.localImagePath ?? secondary.localImagePath,
      localVoicePath: primary.localVoicePath ?? secondary.localVoicePath,
      isPending: primary.isPending || secondary.isPending,
      hasFailed: primary.hasFailed || secondary.hasFailed,
    );
  }

  static String _previewFor(ChatMessage message) {
    if (message.isDeleted) return 'This message was deleted';
    if (message.isVoice) return 'Voice message';
    if (message.hasImage) {
      final caption = message.body.trim();
      return caption.isEmpty ? 'Photo' : caption;
    }
    return message.body;
  }

  Future<void> _persist() async {
    final file = await _ensureFile();
    final map = {
      'conversations': {
        for (final entry in _conversations.entries)
          entry.key: entry.value.toJson(),
      },
    };
    await file.writeAsString(jsonEncode(map), flush: true);
  }
}

final class _CachedConversation {
  const _CachedConversation({
    required this.id,
    required this.participantUserId,
    required this.participantName,
    required this.avatarUrl,
    required this.messages,
    required this.unreadCount,
    required this.statusText,
    required this.isRemote,
    required this.isSeeded,
    this.cachedLastMessageText,
    this.cachedLastMessageTime,
  });

  final String id;
  final String participantUserId;
  final String participantName;
  final String avatarUrl;
  final List<ChatMessage> messages;
  final int unreadCount;
  final String statusText;
  final bool isRemote;
  final bool isSeeded;
  final String? cachedLastMessageText;
  final DateTime? cachedLastMessageTime;

  ChatConversation toConversation() {
    return ChatConversation(
      id: id,
      participantUserId: participantUserId,
      participantName: participantName,
      avatarUrl: avatarUrl,
      messages: messages,
      unreadCount: unreadCount,
      statusText: statusText,
      isRemote: isRemote,
      isSeeded: isSeeded,
      cachedLastMessageText: cachedLastMessageText,
      cachedLastMessageTime: cachedLastMessageTime,
    );
  }

  _CachedConversation copyWith({
    List<ChatMessage>? messages,
    String? cachedLastMessageText,
    DateTime? cachedLastMessageTime,
  }) {
    return _CachedConversation(
      id: id,
      participantUserId: participantUserId,
      participantName: participantName,
      avatarUrl: avatarUrl,
      messages: messages ?? this.messages,
      unreadCount: unreadCount,
      statusText: statusText,
      isRemote: isRemote,
      isSeeded: isSeeded,
      cachedLastMessageText:
          cachedLastMessageText ?? this.cachedLastMessageText,
      cachedLastMessageTime:
          cachedLastMessageTime ?? this.cachedLastMessageTime,
    );
  }

  static _CachedConversation fromConversation(ChatConversation conversation) {
    return _CachedConversation(
      id: conversation.id,
      participantUserId: conversation.participantUserId,
      participantName: conversation.participantName,
      avatarUrl: conversation.avatarUrl,
      messages: conversation.messages,
      unreadCount: conversation.unreadCount,
      statusText: conversation.statusText,
      isRemote: conversation.isRemote,
      isSeeded: conversation.isSeeded,
      cachedLastMessageText: conversation.cachedLastMessageText,
      cachedLastMessageTime: conversation.cachedLastMessageTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_user_id': participantUserId,
      'participant_name': participantName,
      'avatar_url': avatarUrl,
      'messages': messages.map(_messageToJson).toList(),
      'unread_count': unreadCount,
      'status_text': statusText,
      'is_remote': isRemote,
      'is_seeded': isSeeded,
      'cached_last_message_text': cachedLastMessageText,
      'cached_last_message_time': cachedLastMessageTime?.toIso8601String(),
    };
  }

  factory _CachedConversation.fromJson(Map<String, dynamic> json) {
    final messageRows = json['messages'] as List<dynamic>? ?? const [];
    return _CachedConversation(
      id: json['id'] as String? ?? '',
      participantUserId: json['participant_user_id'] as String? ?? '',
      participantName: json['participant_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      messages: messageRows
          .map((row) => _messageFromJson(Map<String, dynamic>.from(row as Map)))
          .toList(),
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      statusText: json['status_text'] as String? ?? 'Online',
      isRemote: json['is_remote'] as bool? ?? true,
      isSeeded: json['is_seeded'] as bool? ?? false,
      cachedLastMessageText: json['cached_last_message_text'] as String?,
      cachedLastMessageTime: DateTime.tryParse(
        json['cached_last_message_time'] as String? ?? '',
      ),
    );
  }
}

Map<String, dynamic> _messageToJson(ChatMessage message) {
  return {
    'id': message.id,
    'sender_id': message.senderId,
    'body': message.body,
    'sent_at': message.sentAt.toIso8601String(),
    'message_type': ChatMessage.messageTypeToDb(message.messageType),
    'sender_type': message.senderType == ChatSenderType.seededContact
        ? 'seeded_contact'
        : 'user',
    'client_temp_id': message.clientTempId,
    'is_pending': message.isPending,
    'has_failed': message.hasFailed,
    'send_state': message.sendState?.name,
    'local_image_path': message.localImagePath,
    'local_voice_path': message.localVoicePath,
    'edited_at': message.editedAt?.toIso8601String(),
    'deleted_at': message.deletedAt?.toIso8601String(),
    'reply_to_message_id': message.replyToMessageId,
    'delivery_status': ChatMessage.deliveryStatusToDb(message.deliveryStatus),
    'delivered_at': message.deliveredAt?.toIso8601String(),
    'read_at': message.readAt?.toIso8601String(),
    'deleted_for_everyone': message.deletedForEveryone,
    'media_bucket': message.mediaBucket,
    'media_path': message.mediaPath,
    'media_url': message.mediaUrl,
    'audio_duration_ms': message.audioDurationMs,
    'audio_waveform': message.audioWaveform,
    'attachments': message.attachments.map(_attachmentToJson).toList(),
  };
}

ChatMessage _messageFromJson(Map<String, dynamic> json) {
  final waveformRaw = json['audio_waveform'];
  final waveform = <double>[];
  if (waveformRaw is List) {
    for (final value in waveformRaw) {
      if (value is num) waveform.add(value.toDouble().clamp(0.0, 1.0));
    }
  }

  ChatMessageSendState? sendState;
  final sendStateRaw = json['send_state'] as String?;
  if (sendStateRaw == 'sending') {
    sendState = ChatMessageSendState.sending;
  } else if (sendStateRaw == 'failed') {
    sendState = ChatMessageSendState.failed;
  }

  final attachmentRows = json['attachments'] as List<dynamic>? ?? const [];
  final attachments = attachmentRows
      .map((row) => _attachmentFromJson(Map<String, dynamic>.from(row as Map)))
      .toList();

  return ChatMessage(
    id: json['id'] as String? ?? '',
    senderId: json['sender_id'] as String? ?? '',
    body: json['body'] as String? ?? '',
    sentAt:
        DateTime.tryParse(json['sent_at'] as String? ?? '') ?? DateTime.now(),
    messageType: ChatMessage.parseMessageType(json['message_type'] as String?),
    senderType: ChatMessage.parseSenderType(json['sender_type'] as String?),
    clientTempId: json['client_temp_id'] as String?,
    isPending: json['is_pending'] as bool? ?? false,
    hasFailed: json['has_failed'] as bool? ?? false,
    sendState: sendState,
    localImagePath: json['local_image_path'] as String?,
    localVoicePath: json['local_voice_path'] as String?,
    editedAt: DateTime.tryParse(json['edited_at'] as String? ?? ''),
    deletedAt: DateTime.tryParse(json['deleted_at'] as String? ?? ''),
    replyToMessageId: json['reply_to_message_id'] as String?,
    deliveryStatus: ChatMessage.parseDeliveryStatus(
      json['delivery_status'] as String?,
    ),
    deliveredAt: DateTime.tryParse(json['delivered_at'] as String? ?? ''),
    readAt: DateTime.tryParse(json['read_at'] as String? ?? ''),
    deletedForEveryone: json['deleted_for_everyone'] as bool? ?? false,
    mediaBucket: json['media_bucket'] as String?,
    mediaPath: json['media_path'] as String?,
    mediaUrl: json['media_url'] as String?,
    audioDurationMs: (json['audio_duration_ms'] as num?)?.toInt(),
    audioWaveform: waveform,
    attachments: attachments,
  );
}

Map<String, dynamic> _attachmentToJson(ChatAttachment attachment) {
  return {
    'id': attachment.id,
    'message_id': attachment.messageId,
    'conversation_id': attachment.conversationId,
    'uploader_id': attachment.uploaderId,
    'storage_bucket': attachment.storageBucket,
    'storage_path': attachment.storagePath,
    'mime_type': attachment.mimeType,
    'size_bytes': attachment.sizeBytes,
    'attachment_type': attachment.attachmentType.name,
    'width': attachment.width,
    'height': attachment.height,
    'duration_ms': attachment.durationMs,
    'waveform': attachment.waveform,
    'original_file_name': attachment.originalFileName,
    'signed_url': attachment.signedUrl,
    'created_at': attachment.createdAt?.toIso8601String(),
  };
}

ChatAttachment _attachmentFromJson(Map<String, dynamic> json) {
  final waveformRaw = json['waveform'];
  final waveform = <double>[];
  if (waveformRaw is List) {
    for (final value in waveformRaw) {
      if (value is num) waveform.add(value.toDouble().clamp(0.0, 1.0));
    }
  }

  final typeRaw = json['attachment_type'] as String?;
  final mimeType = json['mime_type'] as String? ?? '';
  final attachmentType = switch (typeRaw) {
    'image' => ChatAttachmentType.image,
    'voice' => ChatAttachmentType.voice,
    'file' => ChatAttachmentType.file,
    _ => ChatAttachment.typeFromMime(mimeType),
  };

  return ChatAttachment(
    id: json['id'] as String? ?? '',
    messageId: json['message_id'] as String? ?? '',
    conversationId: json['conversation_id'] as String? ?? '',
    uploaderId: json['uploader_id'] as String? ?? '',
    storageBucket: json['storage_bucket'] as String? ?? 'chat-media',
    storagePath: json['storage_path'] as String? ?? '',
    mimeType: mimeType,
    sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
    attachmentType: attachmentType,
    width: (json['width'] as num?)?.toInt(),
    height: (json['height'] as num?)?.toInt(),
    durationMs: (json['duration_ms'] as num?)?.toInt(),
    waveform: waveform,
    originalFileName: json['original_file_name'] as String?,
    signedUrl: json['signed_url'] as String?,
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
  );
}
