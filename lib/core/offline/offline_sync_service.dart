import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../features/chat/data/supabase_chat_repository.dart';
import '../../features/chat/domain/chat_message.dart';
import '../../features/feed/domain/feed_story.dart';
import '../../features/social/data/social_api_client.dart';
import '../../features/social/domain/feed_post.dart';
import '../supabase_operation_error.dart';
import 'local_chat_cache.dart';
import 'local_feed_cache.dart';
import 'outbox_item.dart';
import 'outbox_media_store.dart';
import 'outbox_store.dart';

typedef ChatSyncListener = void Function(String conversationId);
typedef FeedSyncListener = void Function();

final class OfflineSyncService {
  OfflineSyncService._(this._prefs);

  static OfflineSyncService? _instance;
  static const _uuid = Uuid();
  static const _maxAutoRetries = 12;

  final SharedPreferences _prefs;
  final _chatListeners = <ChatSyncListener>{};
  final _feedListeners = <FeedSyncListener>{};
  var _processing = false;
  var _started = false;
  Timer? _retryTimer;

  static Future<OfflineSyncService> ensureInitialized(SharedPreferences prefs) async {
    _instance ??= OfflineSyncService._(prefs);
    await OutboxStore.instance.ensureLoaded();
    await LocalChatCache.instance.ensureLoaded();
    await LocalFeedCache.instance.ensureLoaded();
    return _instance!;
  }

  static OfflineSyncService? get instance => _instance;

  void addChatListener(ChatSyncListener listener) => _chatListeners.add(listener);

  void removeChatListener(ChatSyncListener listener) => _chatListeners.remove(listener);

  void addFeedListener(FeedSyncListener listener) => _feedListeners.add(listener);

  void removeFeedListener(FeedSyncListener listener) => _feedListeners.remove(listener);

  void start() {
    if (_started) {
      scheduleSync();
      return;
    }
    _started = true;
    scheduleSync(immediate: true);
  }

  void scheduleSync({bool immediate = false}) {
    if (immediate) {
      unawaited(_processQueue());
      return;
    }
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 2), () {
      unawaited(_processQueue());
    });
  }

  Future<void> retryItem(String localId) async {
    final item = OutboxStore.instance.findByLocalId(localId);
    if (item == null) return;
    await OutboxStore.instance.upsert(
      item.copyWith(
        status: OutboxItemStatus.pending,
        nextRetryAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    scheduleSync(immediate: true);
  }

  Future<void> cancelItem(String localId) async {
    final item = OutboxStore.instance.findByLocalId(localId);
    if (item == null) return;
    await OutboxMediaStore.instance.deleteIfExists(item.localMediaPath);
    final mediaPaths = item.payload['media_paths'];
    if (mediaPaths is List) {
      for (final path in mediaPaths) {
        await OutboxMediaStore.instance.deleteIfExists(path.toString());
      }
    }
    await OutboxStore.instance.remove(localId);
    await _refreshCachesAfterCancel(item);
    _notify(item);
  }

  Future<OutboxItem> enqueueChatText({
    required String conversationId,
    required String senderId,
    required String body,
    required String clientTempId,
    String? replyToMessageId,
  }) async {
    final now = DateTime.now();
    final item = OutboxItem(
      localId: clientTempId,
      type: OutboxItemType.chatTextMessage,
      createdAt: now,
      updatedAt: now,
      retryCount: 0,
      nextRetryAt: now,
      status: OutboxItemStatus.pending,
      payload: {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'body': body,
        'client_temp_id': clientTempId,
        'reply_to_message_id': replyToMessageId,
      },
    );
    await OutboxStore.instance.enqueue(item);
    scheduleSync(immediate: true);
    return item;
  }

  Future<OutboxItem> enqueueChatImage({
    required String conversationId,
    required String senderId,
    required String clientTempId,
    required String localMediaPath,
    required String caption,
    required String mimeType,
    int? width,
    int? height,
    String? originalFileName,
  }) async {
    final now = DateTime.now();
    final item = OutboxItem(
      localId: clientTempId,
      type: OutboxItemType.chatImageMessage,
      createdAt: now,
      updatedAt: now,
      retryCount: 0,
      nextRetryAt: now,
      status: OutboxItemStatus.pending,
      localMediaPath: localMediaPath,
      payload: {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'client_temp_id': clientTempId,
        'caption': caption,
        'mime_type': mimeType,
        'width': width,
        'height': height,
        'original_file_name': originalFileName ?? 'photo.jpg',
      },
    );
    await OutboxStore.instance.enqueue(item);
    scheduleSync(immediate: true);
    return item;
  }

  Future<OutboxItem> enqueueChatAudio({
    required String conversationId,
    required String senderId,
    required String clientTempId,
    required String localMediaPath,
    required int durationMs,
    required List<double> waveform,
    String mimeType = 'audio/m4a',
  }) async {
    final now = DateTime.now();
    final item = OutboxItem(
      localId: clientTempId,
      type: OutboxItemType.chatAudioMessage,
      createdAt: now,
      updatedAt: now,
      retryCount: 0,
      nextRetryAt: now,
      status: OutboxItemStatus.pending,
      localMediaPath: localMediaPath,
      payload: {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'client_temp_id': clientTempId,
        'duration_ms': durationMs,
        'waveform': waveform,
        'mime_type': mimeType,
      },
    );
    await OutboxStore.instance.enqueue(item);
    scheduleSync(immediate: true);
    return item;
  }

  Future<OutboxItem> enqueueFeedPost({
    required FeedPost post,
    required List<String> localMediaPaths,
  }) async {
    final localId = post.localId ?? _uuid.v4();
    final now = DateTime.now();
    final item = OutboxItem(
      localId: localId,
      type: OutboxItemType.feedPost,
      createdAt: now,
      updatedAt: now,
      retryCount: 0,
      nextRetryAt: now,
      status: OutboxItemStatus.pending,
      payload: {
        'post_id': post.id,
        'post_local_id': localId,
        'user_id': post.userId,
        'caption': post.caption,
        'created_at': post.createdAt.toIso8601String(),
        'media_paths': localMediaPaths,
        'author': {
          'id': post.author.userId,
          'display_name': post.author.displayName,
          'avatar_url': post.author.avatarUrl,
          'cover_url': post.author.coverUrl,
        },
      },
    );
    await OutboxStore.instance.enqueue(item);
    await LocalFeedCache.instance.upsertPost(post.copyWith(localId: localId, isPendingUpload: true));
    scheduleSync(immediate: true);
    return item;
  }

  Future<OutboxItem> enqueueStory({
    required FeedStory story,
    required String localMediaPath,
  }) async {
    final localId = story.localId ?? _uuid.v4();
    final now = DateTime.now();
    final item = OutboxItem(
      localId: localId,
      type: OutboxItemType.story,
      createdAt: now,
      updatedAt: now,
      retryCount: 0,
      nextRetryAt: now,
      status: OutboxItemStatus.pending,
      localMediaPath: localMediaPath,
      payload: {
        'story_id': story.id,
        'story_local_id': localId,
        'user_id': story.user.id,
        'caption': '',
        'created_at': story.latestAt?.toIso8601String() ?? now.toIso8601String(),
        'user': {
          'id': story.user.id,
          'display_name': story.user.displayName,
          'avatar_url': story.user.avatarUrl,
          'fallback_name': story.user.fallbackName,
          'is_current_user': story.user.isCurrentUser,
        },
      },
    );
    await OutboxStore.instance.enqueue(item);
    await LocalFeedCache.instance.upsertStory(
      story.copyWith(localId: localId, isPendingUpload: true),
    );
    scheduleSync(immediate: true);
    return item;
  }

  Future<void> _processQueue() async {
    if (_processing) return;
    _processing = true;
    try {
      while (true) {
        final pending = OutboxStore.instance.pendingItems();
        if (pending.isEmpty) break;

        final next = pending.first;
        await OutboxStore.instance.upsert(
          next.copyWith(
            status: OutboxItemStatus.syncing,
            updatedAt: DateTime.now(),
          ),
        );

        try {
          await _syncItem(next);
          await OutboxStore.instance.remove(next.localId);
        } catch (error, stackTrace) {
          await _handleSyncFailure(next, error, stackTrace);
        }
      }
    } finally {
      _processing = false;
      _scheduleNextRetry();
    }
  }

  void _scheduleNextRetry() {
    final pending = OutboxStore.instance.pendingItems();
    if (pending.isEmpty) return;
    pending.sort((a, b) => a.nextRetryAt.compareTo(b.nextRetryAt));
    final nextAt = pending.first.nextRetryAt;
    final delay = nextAt.difference(DateTime.now());
    _retryTimer?.cancel();
    _retryTimer = Timer(
      delay.isNegative ? const Duration(seconds: 2) : delay,
      () => unawaited(_processQueue()),
    );
  }

  Future<void> _syncItem(OutboxItem item) async {
    switch (item.type) {
      case OutboxItemType.chatTextMessage:
        await _syncChatText(item);
      case OutboxItemType.chatImageMessage:
        await _syncChatImage(item);
      case OutboxItemType.chatAudioMessage:
        await _syncChatAudio(item);
      case OutboxItemType.feedPost:
        await _syncFeedPost(item);
      case OutboxItemType.story:
        await _syncStory(item);
    }
  }

  Future<void> _syncChatText(OutboxItem item) async {
    final repository = SupabaseChatRepository(prefs: _prefs);
    final conversationId = item.payload['conversation_id'] as String? ?? '';
    final body = item.payload['body'] as String? ?? '';
    final clientTempId = item.payload['client_temp_id'] as String? ?? item.localId;
    final replyToMessageId = item.payload['reply_to_message_id'] as String?;

    final sent = await repository.sendTextMessage(
      conversationId: conversationId,
      body: body,
      clientTempId: clientTempId,
      replyToMessageId: replyToMessageId,
    );

    await _updateCachedChatMessage(
      conversationId: conversationId,
      clientTempId: clientTempId,
      sent: sent,
    );
    _notifyChat(conversationId);
  }

  Future<void> _syncChatImage(OutboxItem item) async {
    final repository = SupabaseChatRepository(prefs: _prefs);
    final conversationId = item.payload['conversation_id'] as String? ?? '';
    final clientTempId = item.payload['client_temp_id'] as String? ?? item.localId;
    final localPath = item.localMediaPath;
    if (localPath == null || localPath.isEmpty) {
      throw StateError('Missing local media for image message');
    }

    final file = File(localPath);
    final bytes = await file.readAsBytes();
    final mimeType = item.payload['mime_type'] as String? ?? 'image/jpeg';
    final caption = item.payload['caption'] as String? ?? '';
    final originalFileName = item.payload['original_file_name'] as String? ?? 'photo.jpg';
    final width = (item.payload['width'] as num?)?.toInt();
    final height = (item.payload['height'] as num?)?.toInt();

    final sent = await repository.sendImageMessage(
      conversationId: conversationId,
      file: XFile(localPath, name: originalFileName, mimeType: mimeType),
      bytes: bytes,
      caption: caption,
      width: width,
      height: height,
      clientTempId: clientTempId,
    );

    await _updateCachedChatMessage(
      conversationId: conversationId,
      clientTempId: clientTempId,
      sent: sent.copyWith(localImagePath: localPath),
    );
    await OutboxMediaStore.instance.deleteIfExists(localPath);
    _notifyChat(conversationId);
  }

  Future<void> _syncChatAudio(OutboxItem item) async {
    final repository = SupabaseChatRepository(prefs: _prefs);
    final conversationId = item.payload['conversation_id'] as String? ?? '';
    final clientTempId = item.payload['client_temp_id'] as String? ?? item.localId;
    final localPath = item.localMediaPath;
    if (localPath == null || localPath.isEmpty) {
      throw StateError('Missing local media for voice message');
    }

    final durationMs = (item.payload['duration_ms'] as num?)?.toInt() ?? 0;
    final waveformRaw = item.payload['waveform'] as List<dynamic>? ?? const [];
    final waveform = waveformRaw
        .map((value) => (value as num).toDouble().clamp(0.0, 1.0))
        .toList();

    final sent = await repository.sendVoiceMessage(
      conversationId: conversationId,
      localFilePath: localPath,
      durationMs: durationMs,
      waveform: waveform,
      clientTempId: clientTempId,
    );

    await _updateCachedChatMessage(
      conversationId: conversationId,
      clientTempId: clientTempId,
      sent: sent.copyWith(localVoicePath: localPath),
    );
    await OutboxMediaStore.instance.deleteIfExists(localPath);
    _notifyChat(conversationId);
  }

  Future<void> _syncFeedPost(OutboxItem item) async {
    final client = SocialApiClient(prefs: _prefs);
    final postId = item.payload['post_id'] as String? ?? 'post_${item.localId}';
    final caption = item.payload['caption'] as String? ?? '';
    final mediaPaths = (item.payload['media_paths'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();

    final images = <XFile>[];
    for (final path in mediaPaths) {
      images.add(XFile(path));
    }

    await _clientInsertPost(client: client, postId: postId, caption: caption, images: images);

    final localId = item.payload['post_local_id'] as String? ?? item.localId;
    await LocalFeedCache.instance.removePost(localId: localId);
    _notifyFeed();
  }

  Future<void> _clientInsertPost({
    required SocialApiClient client,
    required String postId,
    required String caption,
    required List<XFile> images,
  }) async {
    final uid = await client.currentUserId();
    await Supabase.instance.client.from('feed_posts').insert({
      'id': postId,
      'user_id': uid,
      'caption': caption.trim(),
      'visibility': 'public',
    });

    final mediaRows = <Map<String, dynamic>>[];
    for (var i = 0; i < images.length; i++) {
      final url = await client.uploadImage(images[i], 'posts/$postId');
      mediaRows.add({
        'id': '${postId}_media_$i',
        'post_id': postId,
        'media_url': url,
        'media_path': url,
        'sort_order': i,
      });
    }
    if (mediaRows.isNotEmpty) {
      await Supabase.instance.client.from('feed_post_media').insert(mediaRows);
    }
  }

  Future<void> _syncStory(OutboxItem item) async {
    final client = SocialApiClient(prefs: _prefs);
    final localPath = item.localMediaPath;
    if (localPath == null || localPath.isEmpty) {
      throw StateError('Missing local media for story');
    }

    final userJson = item.payload['user'] as Map<String, dynamic>? ?? const {};
    final ownStoryUser = StoryUser(
      id: userJson['id'] as String? ?? '',
      displayName: userJson['display_name'] as String? ?? 'Your story',
      avatarUrl: userJson['avatar_url'] as String? ?? '',
      fallbackName: userJson['fallback_name'] as String? ?? '',
      isCurrentUser: userJson['is_current_user'] as bool? ?? true,
    );

    await client.createStory(
      image: XFile(localPath),
      ownStoryUser: ownStoryUser,
    );

    final localId = item.payload['story_local_id'] as String? ?? item.localId;
    await LocalFeedCache.instance.removeStory(localId: localId);
    await OutboxMediaStore.instance.deleteIfExists(localPath);
    _notifyFeed();
  }

  Future<void> _updateCachedChatMessage({
    required String conversationId,
    required String clientTempId,
    required ChatMessage sent,
  }) async {
    final cached = LocalChatCache.instance.conversationFor(conversationId);
    if (cached == null) return;

    final messages = cached.messages.map((message) {
      if (message.clientTempId == clientTempId) {
        return sent.copyWith(
          isPending: false,
          hasFailed: false,
          clearSendState: true,
          deliveryStatus: ChatDeliveryStatus.sent,
          localImagePath: message.localImagePath ?? sent.localImagePath,
          localVoicePath: message.localVoicePath ?? sent.localVoicePath,
        );
      }
      return message;
    }).toList();

    if (!messages.any((message) => message.id == sent.id)) {
      messages.add(sent);
    }

    await LocalChatCache.instance.saveMessages(
      conversationId: conversationId,
      messages: messages,
      meta: cached,
    );
  }

  Future<void> _handleSyncFailure(
    OutboxItem item,
    Object error,
    StackTrace stackTrace,
  ) async {
    final classified = SupabaseOperationError.classify(
      operation: 'offline_sync_${OutboxItem.typeToWire(item.type)}',
      error: error,
      stackTrace: stackTrace,
    );

    final retryCount = item.retryCount + 1;
    final isPermanent = classified.category == SupabaseErrorCategory.schema ||
        classified.category == SupabaseErrorCategory.permission;
    final shouldFail = isPermanent || retryCount >= _maxAutoRetries;

    final updated = item.copyWith(
      status: shouldFail ? OutboxItemStatus.failed : OutboxItemStatus.pending,
      retryCount: retryCount,
      nextRetryAt: shouldFail ? DateTime.now().add(const Duration(hours: 1)) : _nextRetryAt(retryCount),
      updatedAt: DateTime.now(),
    );
    await OutboxStore.instance.upsert(updated);
    await _markLocalItemFailed(item, shouldFail);
    _notify(item);
  }

  DateTime _nextRetryAt(int retryCount) {
    final delay = switch (retryCount) {
      <= 1 => const Duration(seconds: 2),
      2 => const Duration(seconds: 5),
      3 => const Duration(seconds: 15),
      4 => const Duration(seconds: 30),
      5 => const Duration(seconds: 60),
      _ => const Duration(seconds: 120),
    };
    return DateTime.now().add(delay);
  }

  Future<void> _markLocalItemFailed(OutboxItem item, bool failed) async {
    if (!failed) return;

    switch (item.type) {
      case OutboxItemType.chatTextMessage:
      case OutboxItemType.chatImageMessage:
      case OutboxItemType.chatAudioMessage:
        final conversationId = item.payload['conversation_id'] as String? ?? '';
        final clientTempId = item.payload['client_temp_id'] as String? ?? item.localId;
        final cached = LocalChatCache.instance.conversationFor(conversationId);
        if (cached == null) return;
        final messages = cached.messages.map((message) {
          if (message.clientTempId == clientTempId) {
            return message.copyWith(
              isPending: false,
              hasFailed: true,
              sendState: ChatMessageSendState.failed,
              deliveryStatus: ChatDeliveryStatus.failed,
            );
          }
          return message;
        }).toList();
        await LocalChatCache.instance.saveMessages(
          conversationId: conversationId,
          messages: messages,
          meta: cached,
        );
      case OutboxItemType.feedPost:
        final localId = item.payload['post_local_id'] as String? ?? item.localId;
        final posts = LocalFeedCache.instance.pendingPosts();
        for (final post in posts) {
          if (post.localId == localId) {
            await LocalFeedCache.instance.upsertPost(
              post.copyWith(isPendingUpload: false, uploadFailed: true),
            );
            break;
          }
        }
      case OutboxItemType.story:
        final localId = item.payload['story_local_id'] as String? ?? item.localId;
        final stories = LocalFeedCache.instance.pendingStories();
        for (final story in stories) {
          if (story.localId == localId) {
            await LocalFeedCache.instance.upsertStory(
              story.copyWith(isPendingUpload: false, uploadFailed: true),
            );
            break;
          }
        }
    }
  }

  Future<void> _refreshCachesAfterCancel(OutboxItem item) async {
    switch (item.type) {
      case OutboxItemType.chatTextMessage:
      case OutboxItemType.chatImageMessage:
      case OutboxItemType.chatAudioMessage:
        final conversationId = item.payload['conversation_id'] as String? ?? '';
        final clientTempId = item.payload['client_temp_id'] as String? ?? item.localId;
        await LocalChatCache.instance.removeMessage(
          conversationId: conversationId,
          messageId: 'pending_$clientTempId',
          clientTempId: clientTempId,
        );
      case OutboxItemType.feedPost:
        final localId = item.payload['post_local_id'] as String? ?? item.localId;
        await LocalFeedCache.instance.removePost(localId: localId);
      case OutboxItemType.story:
        final localId = item.payload['story_local_id'] as String? ?? item.localId;
        await LocalFeedCache.instance.removeStory(localId: localId);
    }
  }

  void _notify(OutboxItem item) {
    switch (item.type) {
      case OutboxItemType.chatTextMessage:
      case OutboxItemType.chatImageMessage:
      case OutboxItemType.chatAudioMessage:
        final conversationId = item.payload['conversation_id'] as String? ?? '';
        _notifyChat(conversationId);
      case OutboxItemType.feedPost:
      case OutboxItemType.story:
        _notifyFeed();
    }
  }

  void _notifyChat(String conversationId) {
    for (final listener in _chatListeners) {
      listener(conversationId);
    }
  }

  void _notifyFeed() {
    for (final listener in _feedListeners) {
      listener();
    }
  }
}
