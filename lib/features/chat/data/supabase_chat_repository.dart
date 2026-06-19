import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/device_user_id.dart';
import '../../../core/supabase_operation_error.dart';
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

  final SharedPreferences _prefs;
  final SupabaseClient _client;
  RealtimeChannel? _messagesChannel;

  Future<String> ensureAuthenticatedUserId() async {
    final session = _client.auth.currentSession;
    if (session == null) {
      try {
        await _client.auth.signInAnonymously();
      } catch (error, stackTrace) {
        throw SupabaseOperationError.classify(
          operation: 'chat_sign_in',
          action: 'signInAnonymously',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    final authId = _client.auth.currentUser?.id;
    if (authId == null) {
      throw SupabaseOperationError.classify(
        operation: 'chat_auth',
        action: 'currentUser',
        error: StateError('Unable to authenticate chat user'),
      );
    }

    try {
      await _client.from('profiles').upsert({
        'id': authId,
        'display_name': 'Athlete',
      });
    } catch (error, stackTrace) {
      SupabaseOperationError.classify(
        operation: 'chat_ensure_profile',
        table: 'profiles',
        action: 'upsert',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return authId;
  }

  Future<String> resolveCurrentUserId() async {
    try {
      return await ensureAuthenticatedUserId();
    } catch (_) {
      return DeviceUserId.resolve(_prefs);
    }
  }

  bool get isAuthenticated => _client.auth.currentSession != null;

  Future<List<ChatConversation>> loadConversations() async {
    final local = ChatLocalStore.orderedConversations();
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

    return _mergeConversations(local, remote);
  }

  List<ChatConversation> _mergeConversations(
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

    final conversations = <ChatConversation>[];

    for (final seedUserId in ChatLocalStore.conversationOrder) {
      final user = SocialSeedRepository.userById(seedUserId);
      if (user == null) continue;

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

        final summary = await loadConversationSummary(conversationId);
        if (summary != null) conversations.add(summary);
      } catch (error, stackTrace) {
        SupabaseOperationError.classify(
          operation: 'chat_load_seeded_conversation',
          table: 'conversations',
          action: 'rpc:get_or_create_seeded_conversation',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    return conversations;
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
      final rows = await _client
          .from('messages')
          .select('*, message_attachments(*)')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      final messages = <ChatMessage>[];
      for (final raw in rows) {
        final row = Map<String, dynamic>.from(raw as Map);
        final attachmentRows = row.remove('message_attachments');
        final attachments = <ChatAttachment>[];

        if (attachmentRows is List) {
          for (final attachmentRaw in attachmentRows) {
            final attachment = ChatAttachment.fromRow(Map<String, dynamic>.from(attachmentRaw as Map));
            final signed = await _signedUrlForAttachment(attachment);
            attachments.add(attachment.copyWith(signedUrl: signed));
          }
        }

        messages.add(ChatMessage.fromRow(row, attachments: attachments));
      }
      return messages;
    } catch (_) {
      return loadMessages(conversationId);
    }
  }

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

    return loadConversation(conversationId);
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
    final uid = await ensureAuthenticatedUserId();
    await _client.from('conversation_participants').update({
      'last_read_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('conversation_id', conversationId).eq('user_id', uid);
  }

  Future<ChatMessage> sendTextMessage({
    required String conversationId,
    required String body,
    String? clientTempId,
  }) async {
    final uid = await ensureAuthenticatedUserId();
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
          'client_temp_id': ?clientTempId,
        })
        .select()
        .single();

    await _updateConversationPreview(conversationId, trimmed);
    return ChatMessage.fromRow(Map<String, dynamic>.from(insert));
  }

  Future<String> uploadChatImage({
    required String conversationId,
    required String messageId,
    required XFile file,
    required Uint8List bytes,
    required String mimeType,
    bool isSeeded = false,
  }) async {
    final uid = await ensureAuthenticatedUserId();
    final ext = _imageExtension(mimeType, file.name);
    final storagePath = isSeeded
        ? 'seeded/$uid/$conversationId/$messageId/${DateTime.now().millisecondsSinceEpoch}.$ext'
        : '$conversationId/$uid/$messageId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _client.storage.from(bucket).uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: false),
        );

    return storagePath;
  }

  Future<bool> _isSeededConversation(String conversationId) async {
    final row = await _client
        .from('conversations')
        .select('is_seeded')
        .eq('id', conversationId)
        .maybeSingle();
    return row?['is_seeded'] == true;
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
    final uid = await ensureAuthenticatedUserId();
    final messageId = _uuid.v4();
    final trimmedCaption = caption.trim();
    final mimeType = _imageMimeType(file.name);
    final messageType = trimmedCaption.isEmpty ? 'image' : 'mixed';
    final isSeeded = await _isSeededConversation(conversationId);

    final storagePath = await uploadChatImage(
      conversationId: conversationId,
      messageId: messageId,
      file: file,
      bytes: bytes,
      mimeType: mimeType,
      isSeeded: isSeeded,
    );

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
    final signedUrl = await _signedUrlForAttachment(attachment);

    final preview = trimmedCaption.isEmpty ? 'Photo' : trimmedCaption;
    await _updateConversationPreview(conversationId, preview);

    return ChatMessage.fromRow(
      messageRow,
      attachments: [attachment.copyWith(signedUrl: signedUrl)],
    );
  }

  Future<ChatMessage> sendVoiceMessage({
    required String conversationId,
    required String localFilePath,
    required int durationMs,
    required List<double> waveform,
    String? clientTempId,
  }) async {
    final uid = await ensureAuthenticatedUserId();
    final messageId = _uuid.v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final isSeeded = await _isSeededConversation(conversationId);
    final storagePath = isSeeded
        ? 'seeded/$uid/$conversationId/$messageId/audio-$timestamp.m4a'
        : '$conversationId/$uid/$messageId/audio-$timestamp.m4a';
    final file = File(localFilePath);
    final bytes = await file.readAsBytes();
    const mimeType = 'audio/m4a';

    await _client.storage.from(bucket).uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: false),
        );

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
            'client_temp_id': clientTempId,
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
    final signedUrl = await _signedUrlForAttachment(attachment);

    await _updateConversationPreview(conversationId, 'Voice message');

    return ChatMessage.fromRow(
      messageRow,
      attachments: [attachment.copyWith(signedUrl: signedUrl)],
    );
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
        .subscribe();
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

  Future<void> _updateConversationPreview(String conversationId, String preview) async {
    await _client.from('conversations').update({
      'last_message_text': preview,
      'last_message_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);
  }
}
