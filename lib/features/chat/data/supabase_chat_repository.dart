import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/auth_session_service.dart';
import '../../../core/supabase_operation_error.dart';
import '../../../core/supabase_debug_log.dart';
import '../../social/data/social_seed_data.dart';
import '../domain/chat_attachment.dart';
import '../domain/chat_conversation.dart';
import '../domain/chat_message.dart';
import 'chat_local_store.dart';
import 'waveform_utils.dart';

final class SupabaseChatRepository {
  SupabaseChatRepository({
    required SharedPreferences prefs,
    SupabaseClient? client,
  })  : _prefs = prefs,
        _client = client ?? Supabase.instance.client;

  static const bucket = 'chat-media';
  static const _uuid = Uuid();

  static List<ChatConversation>? _sessionConversations;

  static List<ChatConversation> initialConversationsForDisplay() {
    ChatLocalStore.ensureInitialized();
    final cached = _sessionConversations;
    if (cached != null && cached.isNotEmpty) {
      return List<ChatConversation>.from(cached);
    }
    return ChatLocalStore.orderedConversations();
  }

  final SharedPreferences _prefs;
  final SupabaseClient _client;
  RealtimeChannel? _messagesChannel;

  List<ChatConversation> getInitialConversations() {
    return SupabaseChatRepository.initialConversationsForDisplay();
  }

  Future<List<ChatConversation>> loadRemoteConversations() async {
    final local = getInitialConversations();
    List<ChatConversation> remote = const [];

    try {
      remote = await _loadRemoteConversations();
    } catch (error, stackTrace) {
      SupabaseOperationError.classify(
        operation: 'chat_load_conversations',
        error: error,
        stackTrace: stackTrace,
      );
    }

    final merged = mergeConversations(local, remote);
    _sessionConversations = merged;
    return merged;
  }

  static List<ChatConversation> mergeConversations(
    List<ChatConversation> local,
    List<ChatConversation> remote,
  ) {
    final byParticipant = <String, ChatConversation>{
      for (final conversation in local) conversation.participantUserId: conversation,
    };

    for (final conversation in remote) {
      byParticipant[conversation.participantUserId] = conversation;
    }

    final merged = byParticipant.values.toList();
    merged.sort((a, b) {
      final aTime = a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return merged;
  }

  Future<String> ensureAuthenticatedUserId() async {
    try {
      return await AuthSessionService.ensureSupabaseSession();
    } catch (error, stackTrace) {
      throw SupabaseOperationError.classify(
        operation: 'chat_sign_in',
        action: 'ensureSupabaseSession',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'Could not start guest session',
      );
    }
  }

  Future<T> _withChatSession<T>(Future<T> Function(String uid) action) async {
    final uid = await AuthSessionService.ensureSupabaseSession();
    try {
      return await action(uid);
    } catch (error) {
      SupabaseDebugLog.database('chat operation failed, retrying once: $error');
      return await action(uid);
    }
  }

  String _conversationCacheKey(String seedUserId) => 'chat_seed_conv_$seedUserId';

  Future<String?> cachedConversationId(String seedUserId) async {
    return _prefs.getString(_conversationCacheKey(seedUserId));
  }

  Future<void> _cacheConversationId(String seedUserId, String conversationId) async {
    await _prefs.setString(_conversationCacheKey(seedUserId), conversationId);
  }

  String _mediaStoragePath({
    required String userId,
    required String conversationId,
    required String fileName,
  }) {
    return 'chat/$userId/$conversationId/$fileName';
  }

  String _safeFileName(String name) {
    final sanitized = name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return sanitized.isEmpty ? 'file' : sanitized;
  }

  Future<String> resolveCurrentUserId() async {
    return ensureAuthenticatedUserId();
  }

  bool get isAuthenticated => _client.auth.currentSession != null;

  Future<List<ChatConversation>> loadConversations() async {
    return loadRemoteConversations();
  }

  Future<List<ChatConversation>> _loadRemoteConversations() async {
    final seeded = await loadSeededConversations();
    final real = await _loadRealConversations();
    final all = [...seeded, ...real];
    all.sort((a, b) {
      final aTime = a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return all;
  }

  Future<List<ChatConversation>> loadSeededConversations() async {
    try {
      await ensureAuthenticatedUserId();
    } catch (error, stackTrace) {
      SupabaseOperationError.classify(
        operation: 'chat_load_seeded_auth',
        error: error,
        stackTrace: stackTrace,
      );
      return const [];
    }

    final results = await Future.wait(
      ChatLocalStore.conversationOrder.map((seedUserId) async {
        final user = SocialSeedRepository.userById(seedUserId);
        if (user == null) return null;

        try {
          final conversationId = await _client.rpc<String>(
            'get_or_create_seeded_conversation',
            params: {
              'p_seed_user_id': seedUserId,
              'p_display_name': user.displayName,
              'p_username': user.username,
              'p_avatar_url': user.avatarUrl,
            },
          );

          await _cacheConversationId(seedUserId, conversationId);
          return loadConversationSummary(conversationId);
        } catch (error, stackTrace) {
          SupabaseOperationError.classify(
            operation: 'chat_load_seeded_conversation',
            table: 'conversations',
            action: 'rpc:get_or_create_seeded_conversation',
            error: error,
            stackTrace: stackTrace,
          );
          return null;
        }
      }),
    );

    return results.whereType<ChatConversation>().toList();
  }

  Future<List<ChatConversation>> _loadRealConversations() async {
    try {
      await ensureAuthenticatedUserId();
    } catch (error, stackTrace) {
      SupabaseOperationError.classify(
        operation: 'chat_load_real_auth',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }

    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];

    final participantRows = await _client
        .from('conversation_participants')
        .select('conversation_id, last_read_at')
        .eq('user_id', uid);

    final conversationIds = <String>[];
    final readAtByConversation = <String, DateTime?>{};
    for (final row in participantRows) {
      final conversationId = row['conversation_id'] as String;
      try {
        final conversationRow = await _client
            .from('conversations')
            .select('is_seeded')
            .eq('id', conversationId)
            .maybeSingle();
        if (conversationRow?['is_seeded'] == true) continue;
      } catch (error, stackTrace) {
        SupabaseOperationError.classify(
          operation: 'chat_load_real_conversation_meta',
          table: 'conversations',
          action: 'select',
          error: error,
          stackTrace: stackTrace,
        );
        continue;
      }

      conversationIds.add(conversationId);
      final lastReadRaw = row['last_read_at'] as String?;
      readAtByConversation[conversationId] =
          lastReadRaw == null ? null : DateTime.parse(lastReadRaw);
    }

    if (conversationIds.isEmpty) return [];

    final conversations = <ChatConversation>[];
    for (final conversationId in conversationIds) {
      try {
        final conversation = await loadConversationSummary(
          conversationId,
          lastReadAt: readAtByConversation[conversationId],
        );
        if (conversation != null) conversations.add(conversation);
      } catch (error, stackTrace) {
        SupabaseOperationError.classify(
          operation: 'chat_load_real_conversation',
          table: 'conversations',
          action: 'select',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return conversations;
  }

  Future<ChatConversation?> loadConversationSummary(
    String conversationId, {
    DateTime? lastReadAt,
  }) async {
    final uid = await ensureAuthenticatedUserId();

    final conversationRow = await _client
        .from('conversations')
        .select()
        .eq('id', conversationId)
        .maybeSingle();
    if (conversationRow == null) return null;

    final isSeeded = conversationRow['is_seeded'] == true;
    if (isSeeded) {
      final seededContactId = conversationRow['seeded_contact_id'] as String?;
      if (seededContactId == null) return null;

      final contactRow = await _client
          .from('chat_contacts')
          .select('seed_user_id, display_name, avatar_url')
          .eq('id', seededContactId)
          .maybeSingle();
      if (contactRow == null) return null;

      final lastMessageAtRaw = conversationRow['last_message_at'] as String?;
      final lastMessageAt =
          lastMessageAtRaw == null ? null : DateTime.parse(lastMessageAtRaw);
      final lastMessageText = conversationRow['last_message_text'] as String?;

      return ChatConversation(
        id: conversationId,
        participantUserId: contactRow['seed_user_id'] as String,
        participantName: contactRow['display_name'] as String? ?? 'Athlete',
        avatarUrl: contactRow['avatar_url'] as String? ?? '',
        messages: const [],
        unreadCount: 0,
        statusText: 'Online',
        isRemote: true,
        isSeeded: true,
        cachedLastMessageText: lastMessageText,
        cachedLastMessageTime: lastMessageAt,
      );
    }

    final participantRows = await _client
        .from('conversation_participants')
        .select('user_id, last_read_at')
        .eq('conversation_id', conversationId);

    final participantIds = participantRows.map((row) => row['user_id'] as String).toList();
    final otherUserId = participantIds.firstWhere((id) => id != uid, orElse: () => uid);

    final profileRow = await _client
        .from('profiles')
        .select('id, display_name, avatar_url')
        .eq('id', otherUserId)
        .maybeSingle();

    final lastMessageAtRaw = conversationRow['last_message_at'] as String?;
    final lastMessageAt =
        lastMessageAtRaw == null ? null : DateTime.parse(lastMessageAtRaw);
    final lastMessageText = conversationRow['last_message_text'] as String?;

    final myParticipant = participantRows.cast<Map<String, dynamic>>().firstWhere(
          (row) => row['user_id'] == uid,
          orElse: () => const {},
        );
    final effectiveLastReadAt = lastReadAt ??
        (myParticipant['last_read_at'] == null
            ? null
            : DateTime.parse(myParticipant['last_read_at'] as String));

    var unreadCount = 0;
    if (lastMessageAt != null &&
        (effectiveLastReadAt == null || effectiveLastReadAt.isBefore(lastMessageAt))) {
      final latestSender = await _client
          .from('messages')
          .select('sender_id')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      final latestSenderId = latestSender?['sender_id'] as String?;
      if (latestSenderId != null && latestSenderId != uid) {
        unreadCount = 1;
      }
    }

    return ChatConversation(
      id: conversationId,
      participantUserId: otherUserId,
      participantName: profileRow?['display_name'] as String? ?? 'Athlete',
      avatarUrl: profileRow?['avatar_url'] as String? ?? '',
      messages: const [],
      unreadCount: unreadCount,
      statusText: 'Online',
      isRemote: true,
      cachedLastMessageText: lastMessageText,
      cachedLastMessageTime: lastMessageAt,
    );
  }

  Future<ChatConversation?> loadConversation(String conversationId) async {
    final summary = await loadConversationSummary(conversationId);
    if (summary == null) return null;

    final messages = await loadMessagesWithAttachments(conversationId);
    return summary.copyWith(messages: messages);
  }

  Future<List<ChatMessage>> loadMessages(String conversationId) async {
    final rows = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return rows
        .map((row) => ChatMessage.fromRow(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<List<ChatMessage>> loadMessagesWithAttachments(String conversationId) async {
    try {
      final hiddenIds = await loadHiddenMessageIds(conversationId);
      final rows = await _client
          .from('messages')
          .select('*, message_attachments(*)')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      final parsed = <ChatMessage>[];
      for (final raw in rows) {
        final row = Map<String, dynamic>.from(raw as Map);
        final messageId = row['id'] as String;
        if (hiddenIds.contains(messageId)) continue;

        final attachmentRows = row.remove('message_attachments');
        final attachments = <ChatAttachment>[];
        final inlineMediaUrl = row['media_url'] as String?;

        if (attachmentRows is List) {
          final resolved = await Future.wait(
            attachmentRows.map((attachmentRaw) async {
              final attachment = ChatAttachment.fromRow(
                Map<String, dynamic>.from(attachmentRaw as Map),
              );
              if (inlineMediaUrl != null && inlineMediaUrl.isNotEmpty) {
                return attachment.copyWith(signedUrl: inlineMediaUrl);
              }
              final signed = await _signedUrlForAttachment(attachment);
              return attachment.copyWith(signedUrl: signed);
            }),
          );
          attachments.addAll(resolved);
        }

        parsed.add(ChatMessage.fromRow(row, attachments: attachments));
      }
      SupabaseDebugLog.merge('loaded ${parsed.length} messages for $conversationId');
      return _attachReplyMetadata(parsed);
    } catch (_) {
      return loadMessages(conversationId);
    }
  }

  List<ChatMessage> _attachReplyMetadata(List<ChatMessage> messages) {
    final byId = {for (final message in messages) message.id: message};
    return messages
        .map((message) {
          final replyId = message.replyToMessageId;
          if (replyId == null) return message;
          return message.copyWith(replyToMessage: byId[replyId]);
        })
        .toList();
  }

  Future<Set<String>> loadHiddenMessageIds(String conversationId) async {
    try {
      final uid = await ensureAuthenticatedUserId();
      final rows = await _client
          .from('message_deletions')
          .select('message_id')
          .eq('user_id', uid);
      return rows.map((row) => row['message_id'] as String).toSet();
    } catch (_) {
      final key = _hiddenMessagesKey(conversationId);
      return _prefs.getStringList(key)?.toSet() ?? {};
    }
  }

  Future<void> _persistHiddenMessageId(String conversationId, String messageId) async {
    final key = _hiddenMessagesKey(conversationId);
    final ids = _prefs.getStringList(key)?.toSet() ?? {};
    ids.add(messageId);
    await _prefs.setStringList(key, ids.toList());
  }

  String _hiddenMessagesKey(String conversationId) => 'chat_hidden_$conversationId';

  Future<ChatConversation?> getOrCreateSeededConversation(String seedUserId) async {
    final user = SocialSeedRepository.userById(seedUserId);
    if (user == null) return null;

    await ensureAuthenticatedUserId();

    final conversationId = await _client.rpc<String>(
      'get_or_create_seeded_conversation',
      params: {
        'p_seed_user_id': seedUserId,
        'p_display_name': user.displayName,
        'p_username': user.username,
        'p_avatar_url': user.avatarUrl,
      },
    );

    await _cacheConversationId(seedUserId, conversationId);
    return loadConversation(conversationId);
  }

  Future<ChatConversation?> loadCachedSeededConversation(String seedUserId) async {
    final cachedId = await cachedConversationId(seedUserId);
    if (cachedId == null || cachedId.isEmpty) return null;
    try {
      await ensureAuthenticatedUserId();
      final summary = await loadConversationSummary(cachedId);
      if (summary == null) return null;
      final messages = await loadMessagesWithAttachments(cachedId);
      return summary.copyWith(messages: messages);
    } catch (_) {
      return null;
    }
  }

  Future<ChatConversation?> getOrCreateConversationWithUser(String otherUserId) async {
    await ensureAuthenticatedUserId();

    final conversationId = await _client.rpc<String>(
      'create_direct_conversation',
      params: {'other_user_id': otherUserId},
    );

    return loadConversation(conversationId);
  }

  Future<void> markConversationRead(String conversationId) async {
    try {
      final uid = await ensureAuthenticatedUserId();
      await _client.from('conversation_participants').update({
        'last_read_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('conversation_id', conversationId).eq('user_id', uid);
    } catch (error, stackTrace) {
      SupabaseOperationError.classify(
        operation: 'chat_mark_read',
        table: 'conversation_participants',
        action: 'update',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<ChatMessage> sendTextMessage({
    required String conversationId,
    required String body,
    String? clientTempId,
    String? replyToMessageId,
  }) async {
    return _withChatSession((uid) async {
      final trimmed = body.trim();
      if (trimmed.isEmpty) {
        throw ArgumentError('Message body cannot be empty');
      }

      final insert = await _client
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': uid,
            'sender_type': 'user',
            'body': trimmed,
            'message_type': 'text',
            'status': 'sent',
            'client_temp_id': ?clientTempId,
            'reply_to_message_id': ?replyToMessageId,
          })
          .select()
          .single();

      await _updateConversationPreview(conversationId, trimmed);
      return ChatMessage.fromRow(Map<String, dynamic>.from(insert));
    });
  }

  Future<String> uploadChatImage({
    required String conversationId,
    required XFile file,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final uid = await ensureAuthenticatedUserId();
    final ext = _imageExtension(mimeType, file.name);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = _mediaStoragePath(
      userId: uid,
      conversationId: conversationId,
      fileName: '${timestamp}_${_safeFileName(file.name.isEmpty ? 'photo.$ext' : file.name)}',
    );

    await _client.storage.from(bucket).uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: false),
        );

    return storagePath;
  }


  Future<ChatMessage> sendImageMessage({
    required String conversationId,
    required XFile file,
    required Uint8List bytes,
    required String caption,
    int? width,
    int? height,
    String? clientTempId,
  }) async {
    return _withChatSession((uid) async {
      final messageId = _uuid.v4();
      final trimmedCaption = caption.trim();
      final mimeType = _imageMimeType(file.name);
      final messageType = trimmedCaption.isEmpty ? 'image' : 'mixed';

      final storagePath = await uploadChatImage(
        conversationId: conversationId,
        file: file,
        bytes: bytes,
        mimeType: mimeType,
      );
      final mediaUrl = await _publicOrSignedUrl(storagePath);

      Map<String, dynamic> messageRow;
      try {
        messageRow = Map<String, dynamic>.from(await _client
            .from('messages')
            .insert({
              'id': messageId,
              'conversation_id': conversationId,
              'sender_id': uid,
              'sender_type': 'user',
              'body': trimmedCaption,
              'message_type': messageType,
              'status': 'sent',
              'media_bucket': bucket,
              'media_path': storagePath,
              'media_url': mediaUrl,
              'client_temp_id': ?clientTempId,
            })
            .select()
            .single());
      } catch (error) {
        await _client.storage.from(bucket).remove([storagePath]);
        rethrow;
      }

      Map<String, dynamic> attachmentRow;
      try {
        attachmentRow = Map<String, dynamic>.from(await _client
            .from('message_attachments')
            .insert({
              'message_id': messageId,
              'conversation_id': conversationId,
              'uploader_id': uid,
              'storage_bucket': bucket,
              'storage_path': storagePath,
              'mime_type': mimeType,
              'size_bytes': bytes.length,
              'width': ?width,
              'height': ?height,
              'original_file_name': file.name,
            })
            .select()
            .single());
      } catch (error) {
        await _client.from('messages').delete().eq('id', messageId);
        await _client.storage.from(bucket).remove([storagePath]);
        rethrow;
      }

      final attachment = ChatAttachment.fromRow(attachmentRow);
      final signedUrl = mediaUrl ?? await _signedUrlForAttachment(attachment);

      final preview = trimmedCaption.isEmpty ? 'Photo' : trimmedCaption;
      await _updateConversationPreview(conversationId, preview);

      return ChatMessage.fromRow(
        messageRow,
        attachments: [attachment.copyWith(signedUrl: signedUrl)],
      );
    });
  }

  Future<ChatMessage> sendVoiceMessage({
    required String conversationId,
    required String localFilePath,
    required int durationMs,
    required List<double> waveform,
    String? clientTempId,
  }) async {
    return _withChatSession((uid) async {
      final messageId = _uuid.v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = _mediaStoragePath(
        userId: uid,
        conversationId: conversationId,
        fileName: '${timestamp}_voice.m4a',
      );
      final file = File(localFilePath);
      final bytes = await file.readAsBytes();
      const mimeType = 'audio/m4a';

      await _client.storage.from(bucket).uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: false),
          );

      final mediaUrl = await _publicOrSignedUrl(storagePath);

      Map<String, dynamic> messageRow;
      try {
        messageRow = Map<String, dynamic>.from(await _client
            .from('messages')
            .insert({
              'id': messageId,
              'conversation_id': conversationId,
              'sender_id': uid,
              'sender_type': 'user',
              'body': '',
              'message_type': 'voice',
              'status': 'sent',
              'media_bucket': bucket,
              'media_path': storagePath,
              'media_url': mediaUrl,
              'audio_duration_ms': durationMs,
              'audio_waveform': waveform,
              'client_temp_id': ?clientTempId,
            })
            .select()
            .single());
      } catch (error) {
        await _client.storage.from(bucket).remove([storagePath]);
        rethrow;
      }

      Map<String, dynamic> attachmentRow;
      try {
        attachmentRow = Map<String, dynamic>.from(await _client
            .from('message_attachments')
            .insert({
              'message_id': messageId,
              'conversation_id': conversationId,
              'uploader_id': uid,
              'storage_bucket': bucket,
              'storage_path': storagePath,
              'mime_type': mimeType,
              'size_bytes': bytes.length,
              'duration_ms': durationMs,
              'waveform': waveform,
              'original_file_name': 'voice-$timestamp.m4a',
            })
            .select()
            .single());
      } catch (error) {
        await _client.from('messages').delete().eq('id', messageId);
        await _client.storage.from(bucket).remove([storagePath]);
        rethrow;
      }

      final attachment = ChatAttachment.fromRow(attachmentRow);
      final signedUrl = mediaUrl ?? await _signedUrlForAttachment(attachment);

      await _updateConversationPreview(conversationId, 'Voice message');

      return ChatMessage.fromRow(
        messageRow,
        attachments: [attachment.copyWith(signedUrl: signedUrl)],
      );
    });
  }

  Future<String?> _publicOrSignedUrl(String storagePath) async {
    try {
      return await _client.storage.from(bucket).createSignedUrl(storagePath, 3600);
    } catch (_) {
      return null;
    }
  }

  Future<ChatMessage?> updateMessageDeliveryStatus({
    required String messageId,
    required String conversationId,
    required ChatDeliveryStatus status,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final patch = <String, dynamic>{
      'status': ChatMessage.deliveryStatusToDb(status),
    };
    if (status == ChatDeliveryStatus.delivered) {
      patch['delivered_at'] = now;
    }
    if (status == ChatDeliveryStatus.read) {
      patch['read_at'] = now;
      patch['delivered_at'] = now;
    }

    try {
      final updated = await _client
          .from('messages')
          .update(patch)
          .eq('id', messageId)
          .eq('conversation_id', conversationId)
          .select()
          .single();
      return ChatMessage.fromRow(Map<String, dynamic>.from(updated));
    } catch (_) {
      return null;
    }
  }

  Future<void> markOutgoingMessagesRead(String conversationId) async {
    try {
      final uid = await ensureAuthenticatedUserId();
      final now = DateTime.now().toUtc().toIso8601String();
      await _client
          .from('messages')
          .update({
            'status': 'read',
            'read_at': now,
            'delivered_at': now,
          })
          .eq('conversation_id', conversationId)
          .eq('sender_id', uid)
          .neq('status', 'read');
    } catch (_) {}
  }

  Future<String?> refreshSignedUrl(ChatAttachment attachment) {
    return _signedUrlForAttachment(attachment);
  }

  Future<String?> _signedUrlForAttachment(ChatAttachment attachment) async {
    try {
      return await _client.storage
          .from(attachment.storageBucket)
          .createSignedUrl(attachment.storagePath, 3600);
    } catch (_) {
      return null;
    }
  }

  Future<ChatMessage?> fetchMessageWithAttachments(String messageId) async {
    try {
      final row = await _client
          .from('messages')
          .select('*, message_attachments(*)')
          .eq('id', messageId)
          .maybeSingle();
      if (row == null) return null;

      final map = Map<String, dynamic>.from(row);
      final attachmentRows = map.remove('message_attachments');
      final attachments = <ChatAttachment>[];
      if (attachmentRows is List) {
        for (final attachmentRaw in attachmentRows) {
          final attachment = ChatAttachment.fromRow(Map<String, dynamic>.from(attachmentRaw as Map));
          final signed = await _signedUrlForAttachment(attachment);
          attachments.add(attachment.copyWith(signedUrl: signed));
        }
      }
      return ChatMessage.fromRow(map, attachments: attachments);
    } catch (_) {
      final row = await _client.from('messages').select().eq('id', messageId).maybeSingle();
      if (row == null) return null;
      return ChatMessage.fromRow(Map<String, dynamic>.from(row));
    }
  }

  void subscribeToMessages({
    required String conversationId,
    required void Function(ChatMessage message) onInsert,
    void Function(ChatMessage message)? onUpdate,
  }) {
    unsubscribeFromMessages();
    _messagesChannel = _client
        .channel('chat_messages_$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) async {
            final record = payload.newRecord;
            if (record.isEmpty) return;
            final messageId = record['id'] as String?;
            if (messageId == null) return;
            final message = await fetchMessageWithAttachments(messageId);
            if (message != null) onInsert(message);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) async {
            if (onUpdate == null) return;
            final record = payload.newRecord;
            if (record.isEmpty) return;
            final messageId = record['id'] as String?;
            if (messageId == null) return;
            final message = await fetchMessageWithAttachments(messageId);
            if (message != null) onUpdate(message);
          },
        )
        .subscribe();
    SupabaseDebugLog.realtime('subscribed messages conversation=$conversationId');
  }

  void unsubscribeFromMessages() {
    final channel = _messagesChannel;
    if (channel != null) {
      _client.removeChannel(channel);
      _messagesChannel = null;
    }
  }

  String _imageMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }

  String _imageExtension(String mimeType, String fileName) {
    switch (mimeType) {
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/heic':
        return 'heic';
      default:
        final ext = fileName.split('.').last.toLowerCase();
        return ext.length <= 5 ? ext : 'jpg';
    }
  }

  List<double> buildWaveform({
    required int durationMs,
    String? seed,
    int barCount = 28,
  }) {
    return WaveformUtils.generateSamples(
      barCount: barCount,
      durationMs: durationMs,
      seed: seed,
    );
  }

  Future<ChatMessage> editMessage({
    required String messageId,
    required String conversationId,
    required String newBody,
  }) async {
    final trimmed = newBody.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Message body cannot be empty');
    }

    final updated = await _client
        .from('messages')
        .update({
          'body': trimmed,
          'edited_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', messageId)
        .select()
        .single();

    await _updateConversationPreviewIfLatest(conversationId, messageId, trimmed);
    return ChatMessage.fromRow(Map<String, dynamic>.from(updated));
  }

  Future<ChatMessage> softDeleteMessage({
    required String messageId,
    required String conversationId,
  }) async {
    final updated = await _client
        .from('messages')
        .update({
          'deleted_at': DateTime.now().toUtc().toIso8601String(),
          'deleted_for_everyone': true,
          'body': '',
        })
        .eq('id', messageId)
        .select()
        .single();

    await _updateConversationPreviewIfLatest(conversationId, messageId, 'This message was deleted');
    return ChatMessage.fromRow(Map<String, dynamic>.from(updated));
  }

  Future<void> deleteMessageForMe({
    required String messageId,
    required String conversationId,
  }) async {
    final uid = await ensureAuthenticatedUserId();
    try {
      await _client.from('message_deletions').insert({
        'message_id': messageId,
        'user_id': uid,
      });
    } catch (_) {
      await _persistHiddenMessageId(conversationId, messageId);
    }
  }

  Future<void> removeFailedMessage(String messageId) async {
    try {
      await _client.from('messages').delete().eq('id', messageId);
    } catch (_) {}
  }

  ChatMessage updateMessageLocally({
    required List<ChatMessage> messages,
    required ChatMessage updated,
  }) {
    return updated;
  }

  Future<void> _updateConversationPreviewIfLatest(
    String conversationId,
    String messageId,
    String preview,
  ) async {
    try {
      final latest = await _client
          .from('messages')
          .select('id')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (latest?['id'] == messageId) {
        await _updateConversationPreview(conversationId, preview);
      }
    } catch (_) {}
  }

  Future<void> _updateConversationPreview(String conversationId, String preview) async {
    await _client.from('conversations').update({
      'last_message_text': preview,
      'last_message_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);
  }
}
