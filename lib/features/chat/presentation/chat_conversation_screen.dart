import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/premium_background.dart';
import '../../../core/auth_session_service.dart';
import '../../../core/offline/local_chat_cache.dart';
import '../../../core/offline/offline_sync_service.dart';
import '../../../core/offline/outbox_media_store.dart';
import '../../../core/supabase_operation_error.dart';
import '../../feed/presentation/social_avatar.dart';
import '../../social/data/social_seed_data.dart';
import '../data/chat_local_store.dart';
import '../data/chat_repository.dart';
import '../data/supabase_chat_repository.dart';
import '../data/voice_playback_service.dart';
import '../data/voice_recorder_service.dart';
import '../data/waveform_utils.dart';
import '../domain/chat_attachment.dart';
import '../domain/chat_conversation.dart';
import '../domain/chat_message.dart';
import 'chat_attachment_picker_sheet.dart';
import 'chat_image_viewer_screen.dart';
import 'chat_media_actions.dart';
import 'chat_message_actions_sheet.dart';
import 'chat_message_status_tick.dart';
import 'chat_voice_recorder.dart';
import 'voice_message_bubble.dart';

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({
    super.key,
    required this.participantUserId,
    this.conversationId,
  });

  final String participantUserId;
  final String? conversationId;

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  static const _uuid = Uuid();

  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  final _picker = ImagePicker();
  final _voiceRecorder = VoiceRecorderService();
  final _voicePlayback = VoicePlaybackService();
  final _voiceComposerKey = GlobalKey<ChatVoiceComposerState>();
  SupabaseChatRepository? _repository;
  ChatConversation? _conversation;
  String? _currentUserId;
  var _hasText = false;
  var _loading = false;
  var _syncingRemote = false;
  var _loadFailed = false;
  var _sendingImage = false;
  var _voiceComposerActive = false;
  final _pendingTempIds = <String>{};
  final _messageIds = <String>{};
  final _failedImageMimeTypes = <String, String>{};
  XFile? _pendingImage;
  Uint8List? _pendingImageBytes;
  ChatMessage? _replyTarget;
  ChatMessage? _editingMessage;
  String? _highlightedMessageId;
  OfflineSyncService? _offlineSync;
  ChatSyncListener? _chatSyncListener;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _showLocalConversationFirst();
    _initOfflineSync();
    _syncRemoteConversation();
  }

  Future<void> _initOfflineSync() async {
    final prefs = await SharedPreferences.getInstance();
    final sync = await OfflineSyncService.ensureInitialized(prefs);
    if (!mounted) return;
    _offlineSync = sync;
    _chatSyncListener = (conversationId) {
      if (widget.conversationId != null) {
        if (widget.conversationId == conversationId) {
          _reloadMessagesFromCache(conversationId);
        }
      } else {
        final conversation = _conversation;
        if (conversation != null &&
            !conversation.id.startsWith('conv_') &&
            conversation.id == conversationId) {
          _reloadMessagesFromCache(conversationId);
        }
      }
    };
    sync.addChatListener(_chatSyncListener!);
    sync.start();
  }

  void _reloadMessagesFromCache(String conversationId) {
    final cached = LocalChatCache.instance.conversationFor(conversationId);
    if (cached == null || !mounted) return;
    final current = _conversation;
    if (current == null) return;
    setState(() {
      _conversation = current.copyWith(
        messages: _attachReplyMetadata(cached.messages),
        cachedLastMessageText: cached.cachedLastMessageText ?? current.cachedLastMessageText,
        cachedLastMessageTime: cached.cachedLastMessageTime ?? current.cachedLastMessageTime,
      );
      _seedMessageIds(cached.messages);
    });
  }

  void _showLocalConversationFirst() {
    ChatLocalStore.ensureInitialized();
    ChatConversation? local;

    if (widget.conversationId != null) {
      local = LocalChatCache.instance.conversationFor(widget.conversationId!);
    }
    local ??= ChatLocalStore.conversationForUser(widget.participantUserId);

    if (local == null) {
      setState(() => _loading = true);
      return;
    }

    _currentUserId = Supabase.instance.client.auth.currentUser?.id ??
        SocialSeedRepository.currentUserId;
    _conversation = local.copyWith(messages: _attachReplyMetadata(local.messages));
    _seedMessageIds(local.messages);
    setState(() => _loading = false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animated: false));
  }

  Future<void> _syncRemoteConversation() async {
    if (_syncingRemote) return;
    _syncingRemote = true;

    final hadLocal = _conversation != null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final repository = SupabaseChatRepository(prefs: prefs);
      _repository = repository;

      await AuthSessionService.ensureSupabaseSession();
      final currentUserId = await repository.ensureAuthenticatedUserId();
      _currentUserId = currentUserId;

      if (ChatRepository.isDemoParticipant(widget.participantUserId) &&
          widget.conversationId == null) {
        final cachedId = await repository.cachedConversationId(widget.participantUserId);
        if (cachedId != null && cachedId.isNotEmpty) {
          final local = ChatLocalStore.conversationForUser(widget.participantUserId);
          if (local != null && mounted) {
            setState(() {
              _conversation = local.copyWith(
                id: cachedId,
                isRemote: true,
                isSeeded: true,
              );
              _loading = false;
              _loadFailed = false;
            });
          }
        }
        final cachedConversation =
            await repository.loadCachedSeededConversation(widget.participantUserId);
        if (cachedConversation != null && mounted) {
          _applyRemoteConversation(repository, cachedConversation, currentUserId);
        }
      }

      ChatConversation? conversation;
      if (widget.conversationId != null) {
        conversation = await repository.loadConversation(widget.conversationId!);
      } else if (ChatRepository.isDemoParticipant(widget.participantUserId)) {
        conversation = await repository.getOrCreateSeededConversation(widget.participantUserId);
      } else {
        conversation = await repository.getOrCreateConversationWithUser(widget.participantUserId);
      }

      if (!mounted) return;

      if (conversation == null) {
        if (!hadLocal && _conversation == null) {
          setState(() {
            _loading = false;
            _loadFailed = true;
          });
        }
        return;
      }

      _applyRemoteConversation(repository, conversation, currentUserId);
    } catch (error, stackTrace) {
      SupabaseOperationError.classify(
        operation: 'chat_load_conversation',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'Could not start guest session',
      );
      if (!mounted) return;
      if (!hadLocal && _conversation == null) {
        setState(() {
          _loading = false;
          _loadFailed = true;
        });
      }
    } finally {
      _syncingRemote = false;
    }
  }

  void _applyRemoteConversation(
    SupabaseChatRepository repository,
    ChatConversation conversation,
    String currentUserId,
  ) {
    final local = ChatLocalStore.conversationForUser(widget.participantUserId);
    final cached = LocalChatCache.instance.conversationFor(conversation.id);
    final mergedMessages = LocalChatCache.mergeMessages(
      remote: conversation.messages,
      local: [
        ...?local?.messages,
        ...?cached?.messages,
        ...?_conversation?.messages,
      ],
    );

    _repository = repository;
    _currentUserId = currentUserId;
    _conversation = conversation.copyWith(
      messages: _attachReplyMetadata(mergedMessages),
    );
    _seedMessageIds(mergedMessages);
    unawaited(LocalChatCache.instance.saveConversation(_conversation!));

    repository.subscribeToMessages(
      conversationId: conversation.id,
      onInsert: _onRemoteMessageInserted,
      onUpdate: _onRemoteMessageUpdated,
    );

    unawaited(repository.markConversationRead(conversation.id));
    unawaited(repository.markOutgoingMessagesRead(conversation.id));

    if (!mounted) return;
    setState(() {
      _loading = false;
      _loadFailed = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animated: false));
  }

  void _seedMessageIds(List<ChatMessage> messages) {
    _messageIds
      ..clear()
      ..addAll(messages.map((message) => message.id));
  }

  AppLocalizations _l10n(BuildContext context) => AppLocalizations.of(context)!;

  String _previewForMessage(ChatMessage message, [BuildContext? context]) {
    final l10n = context == null ? null : _l10n(context);
    if (message.isDeleted) return l10n?.chatMessageDeleted ?? 'Message deleted';
    if (message.isVoice) return l10n?.chatVoiceMessage ?? 'Voice message';
    if (message.hasImage) {
      final caption = message.body.trim();
      return caption.isEmpty ? (l10n?.chatPhoto ?? 'Photo') : caption;
    }
    return message.body;
  }

  void _scheduleDeliveryUpdates(ChatMessage message) {
    final repository = _repository;
    final conversation = _conversation;
    if (repository == null || conversation == null) return;
    if (message.id.startsWith('pending_')) return;

    Future<void>.delayed(const Duration(milliseconds: 900), () async {
      final delivered = await repository.updateMessageDeliveryStatus(
        messageId: message.id,
        conversationId: conversation.id,
        status: ChatDeliveryStatus.delivered,
      );
      if (!mounted || delivered == null) return;
      _replaceMessageInState(delivered);
    });

    Future<void>.delayed(const Duration(seconds: 2), () async {
      final read = await repository.updateMessageDeliveryStatus(
        messageId: message.id,
        conversationId: conversation.id,
        status: ChatDeliveryStatus.read,
      );
      if (!mounted || read == null) return;
      _replaceMessageInState(read);
    });
  }

  void _applySentMessage(ChatMessage sent, {bool preserveLocalPreview = false}) {
    setState(() {
      final current = _conversation;
      if (current == null) return;

      final messages = current.messages.map((message) {
        if (message.clientTempId != null && message.clientTempId == sent.clientTempId) {
          return sent.copyWith(
            localPreviewBytes: preserveLocalPreview ? message.localPreviewBytes : sent.localPreviewBytes,
            localVoicePath: preserveLocalPreview ? message.localVoicePath : sent.localVoicePath,
          );
        }
        return message;
      }).toList();

      if (sent.clientTempId == null || !messages.any((message) => message.id == sent.id)) {
        messages.add(sent);
      }

      _conversation = current.copyWith(
        messages: _attachReplyMetadata(messages),
        cachedLastMessageText: _previewForMessage(sent),
        cachedLastMessageTime: sent.sentAt,
      );
    });
    _scheduleDeliveryUpdates(sent);
  }

  void _onRemoteMessageUpdated(ChatMessage message) {
    if (!mounted) return;
    _replaceMessageInState(message);
  }

  void _replaceMessageInState(ChatMessage message) {
    final current = _conversation;
    if (current == null) return;

    final messages = current.messages.map((item) {
      if (item.id == message.id) {
        return message.copyWith(
          replyToMessage: item.replyToMessage ?? message.replyToMessage,
          localPreviewBytes: item.localPreviewBytes,
          localVoicePath: item.localVoicePath,
        );
      }
      return item;
    }).toList();

    final preview = _previewForMessage(message);
    setState(() {
      _conversation = current.copyWith(
        messages: _attachReplyMetadata(messages),
        cachedLastMessageText: messages.isNotEmpty && messages.last.id == message.id
            ? preview
            : current.cachedLastMessageText,
      );
    });
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

  String _senderNameForMessage(ChatMessage message, String currentUserId) {
    if (message.isFromCurrentUser(currentUserId)) return 'You';
    return _conversation?.participantName ?? 'Athlete';
  }

  void _clearComposerContext({bool clearText = false}) {
    setState(() {
      _replyTarget = null;
      _editingMessage = null;
    });
    if (clearText) _textController.clear();
  }

  void _setReplyTarget(ChatMessage message) {
    setState(() {
      _editingMessage = null;
      _replyTarget = message;
    });
  }

  void _setEditingTarget(ChatMessage message) {
    setState(() {
      _replyTarget = null;
      _editingMessage = message;
      _textController.text = message.body;
      _textController.selection = TextSelection.collapsed(offset: message.body.length);
    });
  }

  Future<void> _handleMessageLongPress(ChatMessage message, String currentUserId) async {
    if (message.isPending && !message.hasFailed) {
      HapticFeedback.mediumImpact();
      setState(() => _highlightedMessageId = message.id);
      final l10n = _l10n(context);
      final result = await showChatMessageActionsSheet(
        context: context,
        message: message,
        isMe: message.isFromCurrentUser(currentUserId),
        senderName: _senderNameForMessage(message, currentUserId),
        actions: [
          ChatMessageActionItem(
            type: ChatMessageActionType.retry,
            label: l10n.chatRetry,
            icon: Icons.refresh_rounded,
          ),
          ChatMessageActionItem(
            type: ChatMessageActionType.remove,
            label: l10n.chatRemove,
            icon: Icons.delete_outline_rounded,
            destructive: true,
          ),
          ChatMessageActionItem(
            type: ChatMessageActionType.cancel,
            label: l10n.cancel,
            icon: Icons.close_rounded,
          ),
        ],
      );
      if (mounted) setState(() => _highlightedMessageId = null);
      if (!mounted || result == null) return;
      switch (result.type) {
        case ChatMessageActionType.retry:
          await _retryFailedMessage(message);
        case ChatMessageActionType.remove:
          await _removeFailedMessage(message);
        case ChatMessageActionType.cancel:
          break;
        default:
          break;
      }
      return;
    }

    if (message.isPending) return;

    HapticFeedback.mediumImpact();
    setState(() => _highlightedMessageId = message.id);

    final isMe = message.isFromCurrentUser(currentUserId);
    final canDeleteForEveryone = isMe && !message.isDeleted && !message.id.startsWith('pending_');
    final canDeleteForMe = !message.isDeleted && !message.id.startsWith('pending_');

    final l10n = _l10n(context);
    final actions = buildMessageActions(
      message: message,
      isMe: isMe,
      currentUserId: currentUserId,
      canDeleteForEveryone: canDeleteForEveryone,
      canDeleteForMe: canDeleteForMe,
      l10n: l10n,
    );

    final result = await showChatMessageActionsSheet(
      context: context,
      message: message,
      isMe: isMe,
      senderName: _senderNameForMessage(message, currentUserId),
      actions: actions,
    );

    if (mounted) setState(() => _highlightedMessageId = null);
    if (!mounted || result == null) return;

    switch (result.type) {
      case ChatMessageActionType.reply:
        _setReplyTarget(message);
      case ChatMessageActionType.copyText:
      case ChatMessageActionType.copyCaption:
        await copyMessageText(context, message.body);
      case ChatMessageActionType.edit:
        _setEditingTarget(message);
      case ChatMessageActionType.delete:
        await _confirmAndDeleteMessage(message, isMe, canDeleteForEveryone, canDeleteForMe);
      case ChatMessageActionType.details:
        await showChatMessageDetailsSheet(
          context: context,
          message: message,
          isMe: isMe,
          senderName: _senderNameForMessage(message, currentUserId),
        );
      case ChatMessageActionType.retry:
        await _retryFailedMessage(message);
      case ChatMessageActionType.remove:
        _removeFailedMessage(message);
      case ChatMessageActionType.saveImage:
      case ChatMessageActionType.saveAudio:
        try {
          await saveChatMediaLocally(
            message: message,
            fallbackFileName: attachmentFileName(message, message.voiceAttachment),
          );
          if (mounted) showSavedFeedback(context);
        } catch (_) {}
      case ChatMessageActionType.share:
        await shareChatMessage(message: message);
        if (mounted) showCopiedFeedback(context);
      case ChatMessageActionType.cancel:
        break;
    }
  }

  Future<void> _confirmAndDeleteMessage(
    ChatMessage message,
    bool isMe,
    bool canDeleteForEveryone,
    bool canDeleteForMe,
  ) async {
    final choice = await showChatMessageDeleteSheet(
      context: context,
      isMe: isMe,
      canDeleteForEveryone: canDeleteForEveryone,
      canDeleteForMe: canDeleteForMe,
    );
    if (!mounted || choice == null) return;

    if (choice == ChatMessageDeleteChoice.forEveryone) {
      await _softDeleteMessage(message);
    } else {
      await _deleteMessageForMe(message);
    }
  }

  Future<void> _softDeleteMessage(ChatMessage message) async {
    final repository = _repository;
    final conversation = _conversation;
    if (conversation == null) return;

    final deleted = message.copyWith(
      body: '',
      deletedAt: DateTime.now(),
      clearAttachments: true,
      clearLocalPreviewBytes: true,
      clearLocalVoicePath: true,
    );

    setState(() {
      _conversation = conversation.copyWith(
        messages: conversation.messages
            .map((item) => item.id == message.id ? deleted : item)
            .toList(),
        cachedLastMessageText: conversation.messages.isNotEmpty &&
                conversation.messages.last.id == message.id
            ? 'This message was deleted'
            : conversation.cachedLastMessageText,
      );
    });

    if (conversation.isDemo && !conversation.isRemote) {
      ChatLocalStore.softDeleteMessage(
        participantUserId: conversation.participantUserId,
        messageId: message.id,
      );
      return;
    }

    if (repository == null || message.id.startsWith('pending_')) return;

    try {
      final updated = await repository.softDeleteMessage(
        messageId: message.id,
        conversationId: conversation.id,
      );
      if (!mounted) return;
      _replaceMessageInState(updated.copyWith(clearAttachments: true));
    } catch (error, stackTrace) {
      debugPrint('softDeleteMessage failed: $error\n$stackTrace');
      if (!mounted) return;
      _showError('Could not delete message');
    }
  }

  Future<void> _deleteMessageForMe(ChatMessage message) async {
    final repository = _repository;
    final conversation = _conversation;
    if (conversation == null) return;

    setState(() {
      _conversation = conversation.copyWith(
        messages: conversation.messages.where((item) => item.id != message.id).toList(),
      );
    });

    if (conversation.isDemo && !conversation.isRemote) {
      ChatLocalStore.hideMessageForMe(
        participantUserId: conversation.participantUserId,
        messageId: message.id,
      );
      return;
    }

    if (repository == null) return;

    try {
      await repository.deleteMessageForMe(
        messageId: message.id,
        conversationId: conversation.id,
      );
    } catch (error, stackTrace) {
      debugPrint('deleteMessageForMe failed: $error\n$stackTrace');
      if (!mounted) return;
      _showError('Could not delete message');
    }
  }

  Future<void> _saveEditedMessage() async {
    final editing = _editingMessage;
    final repository = _repository;
    final conversation = _conversation;
    if (editing == null || conversation == null) return;

    final newBody = _textController.text.trim();
    if (newBody.isEmpty) return;

    final optimistic = editing.copyWith(
      body: newBody,
      editedAt: DateTime.now(),
    );

    _textController.clear();
    _clearComposerContext();

    setState(() {
      _conversation = conversation.copyWith(
        messages: conversation.messages
            .map((item) => item.id == editing.id ? optimistic : item)
            .toList(),
        cachedLastMessageText: conversation.messages.isNotEmpty &&
                conversation.messages.last.id == editing.id
            ? newBody
            : conversation.cachedLastMessageText,
      );
    });

    if (conversation.isDemo && !conversation.isRemote) {
      ChatLocalStore.editMessage(
        participantUserId: conversation.participantUserId,
        messageId: editing.id,
        newBody: newBody,
      );
      return;
    }

    if (repository == null) return;

    try {
      final updated = await repository.editMessage(
        messageId: editing.id,
        conversationId: conversation.id,
        newBody: newBody,
      );
      if (!mounted) return;
      _replaceMessageInState(updated);
    } catch (error, stackTrace) {
      debugPrint('editMessage failed: $error\n$stackTrace');
      if (!mounted) return;
      _showError('Could not update message');
    }
  }


  void _onRemoteMessageInserted(ChatMessage message) {
    if (!mounted) return;

    final current = _conversation;
    if (current == null) return;

    if (message.clientTempId != null && _pendingTempIds.contains(message.clientTempId!)) {
      setState(() {
        _pendingTempIds.remove(message.clientTempId!);
        _messageIds.add(message.id);
        final messages = current.messages.map((item) {
          if (item.clientTempId == message.clientTempId) return message;
          return item;
        }).toList();
        if (!messages.any((item) => item.id == message.id)) {
          messages.add(message);
        }
        _conversation = current.copyWith(
          messages: _attachReplyMetadata(messages),
          cachedLastMessageText: _previewForMessage(message),
          cachedLastMessageTime: message.sentAt,
        );
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      return;
    }

    if (_messageIds.contains(message.id)) return;

    setState(() {
      _messageIds.add(message.id);
      _conversation = current.copyWith(
        messages: _attachReplyMetadata([...current.messages, message]),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    final listener = _chatSyncListener;
    final sync = _offlineSync;
    if (listener != null && sync != null) {
      sync.removeChatListener(listener);
    }
    _repository?.unsubscribeFromMessages();
    _voicePlayback.stop();
    _voiceRecorder.dispose();
    _voicePlayback.dispose();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  Future<bool> _ensureSendReady() async {
    final conversation = _conversation;
    if (conversation == null) return false;

    if (conversation.id.startsWith('conv_')) {
      if (_currentUserId != null) return true;
      await _syncRemoteConversation();
      return _conversation != null && _currentUserId != null;
    }

    _currentUserId ??= Supabase.instance.client.auth.currentUser?.id;
    if (_currentUserId != null && !conversation.id.startsWith('conv_')) {
      return true;
    }

    if (!_syncingRemote) {
      await _syncRemoteConversation();
    } else {
      while (_syncingRemote && mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 40));
      }
    }

    _currentUserId ??= Supabase.instance.client.auth.currentUser?.id;
    final readyConversation = _conversation;
    return readyConversation != null &&
        _currentUserId != null &&
        !readyConversation.id.startsWith('conv_');
  }

  bool get _usesOfflineOutbound {
    final conversation = _conversation;
    return conversation != null && !conversation.id.startsWith('conv_');
  }

  ChatMessage _failedMessage(ChatMessage optimistic) {
    return optimistic.copyWith(
      isPending: false,
      hasFailed: true,
      sendState: ChatMessageSendState.failed,
      deliveryStatus: ChatDeliveryStatus.failed,
    );
  }

  Future<void> _sendMessage() async {
    if (_editingMessage != null) {
      await _saveEditedMessage();
      return;
    }

    final text = _textController.text.trim();
    if (text.isEmpty) return;

    if (!await _ensureSendReady()) return;

    final conversation = _conversation;
    final currentUserId = _currentUserId;
    if (conversation == null || currentUserId == null) return;

    final replyTarget = _replyTarget;
    final replyToMessageId = replyTarget?.id.startsWith('pending_') == true ? null : replyTarget?.id;
    final clientTempId = _uuid.v4();
    final optimistic = ChatMessage(
      id: 'pending_$clientTempId',
      senderId: currentUserId,
      body: text,
      sentAt: DateTime.now(),
      clientTempId: clientTempId,
      isPending: true,
      deliveryStatus: ChatDeliveryStatus.sending,
      replyToMessageId: replyToMessageId,
      replyToMessage: replyTarget,
    );

    _pendingTempIds.add(clientTempId);
    _textController.clear();
    _clearComposerContext();
    final updatedConversation = conversation.copyWith(
      messages: [...conversation.messages, optimistic],
      cachedLastMessageText: _previewForMessage(optimistic),
      cachedLastMessageTime: optimistic.sentAt,
    );
    setState(() => _conversation = updatedConversation);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    if (_usesOfflineOutbound) {
      await LocalChatCache.instance.saveConversation(updatedConversation);
      await _offlineSync?.enqueueChatText(
        conversationId: conversation.id,
        senderId: currentUserId,
        body: text,
        clientTempId: clientTempId,
        replyToMessageId: replyToMessageId,
      );
      return;
    }

    final repository = _repository;
    if (repository == null) return;

    try {
      final sent = await repository.sendTextMessage(
        conversationId: conversation.id,
        body: text,
        clientTempId: clientTempId,
        replyToMessageId: replyToMessageId,
      );
      if (!mounted) return;

      _pendingTempIds.remove(clientTempId);
      _messageIds.add(sent.id);
      _applySentMessage(sent);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pendingTempIds.remove(clientTempId);
        final current = _conversation;
        if (current == null) return;
        _conversation = current.copyWith(
          messages: current.messages
              .map(
                (message) => message.clientTempId == clientTempId
                    ? _failedMessage(message)
                    : message,
              )
              .toList(),
        );
      });
    }
  }

  Future<void> _startVoiceRecording() async {
    if (_pendingImageBytes != null || _voiceComposerActive) return;
    await _voiceComposerKey.currentState?.startRecording();
  }

  Future<void> _pickAttachment() async {
    if (_voiceComposerActive) return;

    final source = await showChatAttachmentPickerSheet(context);
    if (source == null || !mounted) return;

    try {
      final picked = await pickChatImage(_picker, source);
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _pendingImage = picked;
        _pendingImageBytes = bytes;
      });
    } catch (_) {
    }
  }

  void _clearPendingImage() {
    setState(() {
      _pendingImage = null;
      _pendingImageBytes = null;
    });
  }

  Future<({int width, int height})?> _readImageSize(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return (width: frame.image.width, height: frame.image.height);
    } catch (_) {
      return null;
    }
  }

  Future<void> _sendPendingImage() async {
    final file = _pendingImage;
    final bytes = _pendingImageBytes;
    if (file == null || bytes == null || _sendingImage) return;
    if (!await _ensureSendReady()) return;

    final conversation = _conversation;
    final currentUserId = _currentUserId;
    if (conversation == null || currentUserId == null) return;

    final caption = _textController.text.trim();
    final clientTempId = _uuid.v4();
    final mimeType = _imageMimeType(file.name);
    String? localImagePath;
    if (_usesOfflineOutbound) {
      final mediaStore = OutboxMediaStore.instance;
      localImagePath = await mediaStore.saveBytes(
        bytes: bytes,
        extension: mediaStore.extensionFromName(file.name, fallback: 'jpg'),
      );
    }

    final optimistic = ChatMessage(
      id: 'pending_$clientTempId',
      senderId: currentUserId,
      body: caption,
      sentAt: DateTime.now(),
      messageType: caption.isEmpty ? ChatMessageType.image : ChatMessageType.mixed,
      clientTempId: clientTempId,
      localPreviewBytes: bytes,
      localImagePath: localImagePath,
      isPending: true,
      deliveryStatus: ChatDeliveryStatus.sending,
    );

    _pendingTempIds.add(clientTempId);
    _failedImageMimeTypes[clientTempId] = mimeType;
    final updatedConversation = conversation.copyWith(
      messages: [...conversation.messages, optimistic],
      cachedLastMessageText: _previewForMessage(optimistic),
      cachedLastMessageTime: optimistic.sentAt,
    );
    setState(() {
      _sendingImage = true;
      _conversation = updatedConversation;
      _pendingImage = null;
      _pendingImageBytes = null;
    });
    _textController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    if (_usesOfflineOutbound && localImagePath != null) {
      final size = await _readImageSize(bytes);
      await LocalChatCache.instance.saveConversation(updatedConversation);
      await _offlineSync?.enqueueChatImage(
        conversationId: conversation.id,
        senderId: currentUserId,
        clientTempId: clientTempId,
        localMediaPath: localImagePath,
        caption: caption,
        mimeType: mimeType,
        width: size?.width,
        height: size?.height,
        originalFileName: file.name,
      );
      if (mounted) setState(() => _sendingImage = false);
      return;
    }

    final repository = _repository;
    if (repository == null) {
      if (mounted) setState(() => _sendingImage = false);
      return;
    }

    try {
      final size = await _readImageSize(bytes);
      final sent = await repository.sendImageMessage(
        conversationId: conversation.id,
        file: file,
        bytes: bytes,
        caption: caption,
        width: size?.width,
        height: size?.height,
        clientTempId: clientTempId,
      );
      if (!mounted) return;

      _pendingTempIds.remove(clientTempId);
      _messageIds.add(sent.id);
      _applySentMessage(
        sent.copyWith(localPreviewBytes: bytes, localImagePath: localImagePath),
        preserveLocalPreview: true,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pendingTempIds.remove(clientTempId);
        final current = _conversation;
        if (current == null) return;
        _conversation = current.copyWith(
          messages: current.messages
              .map(
                (message) => message.clientTempId == clientTempId
                    ? _failedMessage(message)
                    : message,
              )
              .toList(),
        );
      });
    } finally {
      if (mounted) setState(() => _sendingImage = false);
    }
  }

  Future<void> _sendVoiceMessage(VoiceRecordingResult result) async {
    if (!await _ensureSendReady()) return;

    final conversation = _conversation;
    final currentUserId = _currentUserId;
    if (conversation == null || currentUserId == null) return;

    final waveform = WaveformUtils.generateSamples(
      barCount: 28,
      durationMs: result.durationMs,
      seed: result.filePath,
    );
    final clientTempId = _uuid.v4();
    String voicePath = result.filePath;
    if (_usesOfflineOutbound) {
      voicePath = await OutboxMediaStore.instance.copyFromPath(
        sourcePath: result.filePath,
        extension: 'm4a',
      );
      await _voiceRecorder.deleteFile(result.filePath);
    }

    final placeholderAttachment = ChatAttachment(
      id: 'pending',
      messageId: 'pending_$clientTempId',
      conversationId: conversation.id,
      uploaderId: currentUserId,
      storageBucket: SupabaseChatRepository.bucket,
      storagePath: '',
      mimeType: result.mimeType,
      sizeBytes: 0,
      attachmentType: ChatAttachmentType.voice,
      durationMs: result.durationMs,
      waveform: waveform,
    );
    final optimistic = ChatMessage(
      id: 'pending_$clientTempId',
      senderId: currentUserId,
      body: '',
      sentAt: DateTime.now(),
      messageType: ChatMessageType.voice,
      attachments: [placeholderAttachment],
      clientTempId: clientTempId,
      localVoicePath: voicePath,
      isPending: true,
      deliveryStatus: ChatDeliveryStatus.sending,
    );

    _pendingTempIds.add(clientTempId);
    final updatedConversation = conversation.copyWith(
      messages: [...conversation.messages, optimistic],
      cachedLastMessageText: _previewForMessage(optimistic),
      cachedLastMessageTime: optimistic.sentAt,
    );
    setState(() => _conversation = updatedConversation);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    if (_usesOfflineOutbound) {
      await LocalChatCache.instance.saveConversation(updatedConversation);
      await _offlineSync?.enqueueChatAudio(
        conversationId: conversation.id,
        senderId: currentUserId,
        clientTempId: clientTempId,
        localMediaPath: voicePath,
        durationMs: result.durationMs,
        waveform: waveform,
        mimeType: result.mimeType,
      );
      return;
    }

    final repository = _repository;
    if (repository == null) return;

    try {
      final sent = await repository.sendVoiceMessage(
        conversationId: conversation.id,
        localFilePath: voicePath,
        durationMs: result.durationMs,
        waveform: waveform,
        clientTempId: clientTempId,
      );
      if (!_usesOfflineOutbound) {
        await _voiceRecorder.deleteFile(voicePath);
      }
      if (!mounted) return;

      _pendingTempIds.remove(clientTempId);
      _messageIds.add(sent.id);
      _applySentMessage(
        sent.copyWith(localVoicePath: voicePath),
        preserveLocalPreview: true,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pendingTempIds.remove(clientTempId);
        final current = _conversation;
        if (current == null) return;
        _conversation = current.copyWith(
          messages: current.messages
              .map(
                (message) => message.clientTempId == clientTempId
                    ? _failedMessage(message.copyWith(localVoicePath: voicePath))
                    : message,
              )
              .toList(),
        );
      });
    }
  }

  Future<void> _removeFailedMessage(ChatMessage message) async {
    final tempId = message.clientTempId;
    final conversation = _conversation;
    if (conversation == null) return;

    if (tempId != null && _usesOfflineOutbound) {
      await _offlineSync?.cancelItem(tempId);
    }

    final updated = conversation.copyWith(
      messages: conversation.messages.where((item) => item.id != message.id).toList(),
    );
    setState(() {
      _conversation = updated;
      if (tempId != null) {
        _failedImageMimeTypes.remove(tempId);
      }
    });
    if (_usesOfflineOutbound) {
      await LocalChatCache.instance.saveConversation(updated);
    }
  }

  Future<void> _retryFailedMessage(ChatMessage message) async {
    final tempId = message.clientTempId;
    if (tempId != null && _usesOfflineOutbound) {
      final optimistic = message.copyWith(
        isPending: true,
        hasFailed: false,
        clearSendState: true,
        deliveryStatus: ChatDeliveryStatus.sending,
      );
      final conversation = _conversation;
      if (conversation == null) return;
      final updated = conversation.copyWith(
        messages: conversation.messages
            .map((item) => item.id == message.id ? optimistic : item)
            .toList(),
      );
      setState(() => _conversation = updated);
      await LocalChatCache.instance.saveConversation(updated);
      await _offlineSync?.retryItem(tempId);
      return;
    }

    if (message.isVoice) {
      final localPath = message.localVoicePath;
      final attachment = message.voiceAttachment;
      if (localPath == null || localPath.isEmpty) return;
      await _removeFailedMessage(message);
      await _sendVoiceMessage(
        VoiceRecordingResult(
          filePath: localPath,
          durationMs: attachment?.durationMs ?? 0,
          mimeType: attachment?.mimeType ?? 'audio/m4a',
        ),
      );
      return;
    }

    if (message.hasImage) {
      final bytes = message.localPreviewBytes;
      final tempId = message.clientTempId;
      if (bytes == null || tempId == null) return;
      final mimeType = _failedImageMimeTypes[tempId] ?? 'image/jpeg';
      final file = XFile.fromData(bytes, name: 'retry.jpg', mimeType: mimeType);
      final repository = _repository;
      final conversation = _conversation;
      final currentUserId = _currentUserId;
      if (repository == null || conversation == null || currentUserId == null) return;

      final caption = message.body.trim();
      final clientTempId = _uuid.v4();
      final optimistic = ChatMessage(
        id: 'pending_$clientTempId',
        senderId: currentUserId,
        body: caption,
        sentAt: DateTime.now(),
        messageType: caption.isEmpty ? ChatMessageType.image : ChatMessageType.mixed,
        clientTempId: clientTempId,
        localPreviewBytes: bytes,
        isPending: true,
      );

      _removeFailedMessage(message);
      _pendingTempIds.add(clientTempId);
      _failedImageMimeTypes[clientTempId] = mimeType;
      setState(() {
        _conversation = conversation.copyWith(messages: [...conversation.messages, optimistic]);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

      try {
        final size = await _readImageSize(bytes);
        final sent = await repository.sendImageMessage(
          conversationId: conversation.id,
          file: file,
          bytes: bytes,
          caption: caption,
          width: size?.width,
          height: size?.height,
          clientTempId: clientTempId,
        );
        if (!mounted) return;
        setState(() {
          _pendingTempIds.remove(clientTempId);
          _failedImageMimeTypes.remove(clientTempId);
          _messageIds.add(sent.id);
          final current = _conversation;
          if (current == null) return;
          final messages = current.messages.map((item) {
            if (item.clientTempId == clientTempId) return sent;
            return item;
          }).toList();
          _conversation = current.copyWith(
            messages: messages,
            cachedLastMessageText: _previewForMessage(sent),
            cachedLastMessageTime: sent.sentAt,
          );
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _pendingTempIds.remove(clientTempId);
          final current = _conversation;
          if (current == null) return;
          _conversation = current.copyWith(
            messages: current.messages
                .map(
                  (item) => item.clientTempId == clientTempId
                      ? item.copyWith(isPending: false, hasFailed: true)
                      : item,
                )
                .toList(),
          );
        });
      }
      return;
    }

    final text = message.body.trim();
    if (text.isEmpty) return;
    _removeFailedMessage(message);
    _textController.text = text;
    await _sendMessage();
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

  Future<void> _toggleVoicePlayback(ChatMessage message) async {
    if (message.isPending) return;

    final localPath = message.localVoicePath;
    if (localPath != null && localPath.isNotEmpty) {
      await _voicePlayback.toggle(
        messageId: message.id,
        source: localPath,
        isLocalFile: true,
      );
      return;
    }

    var url = message.primaryVoiceUrl;
    if (url == null || url.isEmpty) {
      final attachment = message.voiceAttachment;
      if (attachment == null) return;
      final repository = _repository;
      if (repository == null) return;
      url = await repository.refreshSignedUrl(attachment);
    }
    if (url == null || url.isEmpty) return;

    await _voicePlayback.toggle(messageId: message.id, source: url);
  }

  void _showError(String message) {
    debugPrint('[ChatConversation] $message');
  }

  Future<void> _openImageViewer(ChatMessage message) async {
    final repository = _repository;
    var imageUrl = message.primaryImageUrl;
    if ((imageUrl == null || imageUrl.isEmpty) &&
        message.attachments.isNotEmpty &&
        repository != null) {
      imageUrl = await repository.refreshSignedUrl(message.attachments.first);
    }

    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ChatImageViewerScreen(
          imageUrl: imageUrl,
          imageBytes: message.localPreviewBytes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversation = _conversation;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final currentUserId = _currentUserId ?? '';

    return VoicePlaybackScope(
      playback: _voicePlayback,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: PremiumBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _ChatHeader(
                  name: conversation?.participantName ?? '',
                  avatarUrl: conversation?.avatarUrl ?? '',
                  statusText: conversation?.statusText ?? 'Online',
                  onBack: () => Navigator.pop(context),
                ),
                Expanded(
                  child: _buildMessageArea(conversation, currentUserId),
                ),
                if (_pendingImageBytes != null && !_voiceComposerActive)
                  _ImagePreviewComposer(
                    imageBytes: _pendingImageBytes!,
                    captionController: _textController,
                    sending: _sendingImage,
                    onRemove: _clearPendingImage,
                    onSend: _sendPendingImage,
                  ),
                Padding(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChatVoiceComposer(
                        key: _voiceComposerKey,
                        recorder: _voiceRecorder,
                        playback: _voicePlayback,
                        onSend: _sendVoiceMessage,
                        onCancel: () {},
                        onPermissionDenied: () =>
                            _showError('Microphone permission is required'),
                        onModeChanged: (active) {
                          if (!mounted) return;
                          setState(() => _voiceComposerActive = active);
                        },
                      ),
                      if (!_voiceComposerActive) ...[
                        if (_replyTarget != null)
                          _ComposerContextBanner(
                            title: _senderNameForMessage(_replyTarget!, currentUserId),
                            subtitle: previewTextForMessage(_replyTarget!, _l10n(context)),
                            onClose: _clearComposerContext,
                          ),
                        if (_editingMessage != null)
                          _ComposerContextBanner(
                            title: 'Editing message',
                            subtitle: _editingMessage!.body,
                            onClose: () => _clearComposerContext(clearText: true),
                            accentColor: PremiumColors.bannerOrange,
                          ),
                        _ChatInputBar(
                          controller: _textController,
                          hasText: _hasText,
                          hasPendingImage: _pendingImageBytes != null,
                          enabled: conversation != null && _repository != null,
                          isEditing: _editingMessage != null,
                          onAttachment: _pickAttachment,
                          onMicrophone: _startVoiceRecording,
                          onSend: _pendingImageBytes != null ? _sendPendingImage : _sendMessage,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageArea(ChatConversation? conversation, String currentUserId) {
    if (conversation != null && conversation.messages.isNotEmpty) {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        itemCount: conversation.messages.length,
        itemBuilder: (context, index) {
          final message = conversation.messages[index];
          final isMe = message.isFromCurrentUser(currentUserId);
          return _MessageBubble(
            message: message,
            isMe: isMe,
            isHighlighted: _highlightedMessageId == message.id,
            participantName: conversation.participantName,
            currentUserId: currentUserId,
            onLongPress: () => _handleMessageLongPress(message, currentUserId),
            onImageTap: message.hasImage && !message.hasFailed && !message.isDeleted
                ? () => _openImageViewer(message)
                : null,
            onVoiceToggle: message.isVoice && !message.isDeleted ? () => _toggleVoicePlayback(message) : null,
            onRetry: message.hasFailed && isMe ? () => _retryFailedMessage(message) : null,
            onDelete: message.hasFailed && isMe ? () => _removeFailedMessage(message) : null,
          );
        },
      );
    }

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: PremiumColors.accentBlue),
      );
    }

    if (_loadFailed || conversation == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Could not load conversation',
              style: TextStyle(color: PremiumColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: _syncRemoteConversation,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return const Center(
      child: Text(
        'Start the conversation',
        style: TextStyle(color: PremiumColors.textSecondary),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.name,
    required this.avatarUrl,
    required this.statusText,
    required this.onBack,
  });

  final String name;
  final String avatarUrl;
  final String statusText;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.xs, AppSpacing.md, AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          ),
          SocialAvatar(name: name, imageUrl: avatarUrl, size: 40),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: const TextStyle(
                    color: PremiumColors.successGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.participantName,
    required this.currentUserId,
    this.isHighlighted = false,
    this.onLongPress,
    this.onImageTap,
    this.onVoiceToggle,
    this.onRetry,
    this.onDelete,
  });

  final ChatMessage message;
  final bool isMe;
  final String participantName;
  final String currentUserId;
  final bool isHighlighted;
  final VoidCallback? onLongPress;
  final VoidCallback? onImageTap;
  final VoidCallback? onVoiceToggle;
  final VoidCallback? onRetry;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeLabel = ChatRepository.formatMessageTime(message.sentAt);
    final maxWidth = MediaQuery.sizeOf(context).width * 0.7;

    Widget bubble;
    if (message.isDeleted) {
      bubble = _DeletedBubble(isMe: isMe);
    } else if (message.isFailed && isMe) {
      bubble = _FailedMediaBubble(
        message: message,
        isMe: isMe,
        onRetry: onRetry,
        onDelete: onDelete,
        onImageTap: onImageTap,
        onVoiceToggle: onVoiceToggle,
      );
    } else if (message.isVoice) {
      bubble = _VoiceBubble(
        message: message,
        isMe: isMe,
        onToggle: onVoiceToggle,
      );
    } else if (message.hasImage) {
      bubble = _ImageBubble(message: message, isMe: isMe, onTap: onImageTap);
    } else {
      bubble = _TextBubble(message: message, isMe: isMe);
    }

    if (message.replyToMessage != null && !message.isDeleted) {
      bubble = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ReplyPreviewChip(
            replyTo: message.replyToMessage!,
            participantName: participantName,
            currentUserId: currentUserId,
            isMe: isMe,
          ),
          const SizedBox(height: 6),
          bubble,
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: onLongPress,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PremiumRadii.lg),
                border: isHighlighted
                    ? Border.all(color: PremiumColors.accentBlue.withValues(alpha: 0.55), width: 1.5)
                    : null,
                boxShadow: isHighlighted
                    ? [
                        BoxShadow(
                          color: PremiumColors.accentBlue.withValues(alpha: 0.18),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              child: Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: bubble,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(
              left: isMe ? 0 : AppSpacing.xs,
              right: isMe ? AppSpacing.xs : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.hasFailed)
                  Text(
                    l10n.chatFailedToSend,
                    style: const TextStyle(
                      color: PremiumColors.bannerOrange,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else ...[
                  Text(
                    timeLabel,
                    style: const TextStyle(
                      color: PremiumColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (message.isEdited) ...[
                    const Text(
                      ' · ',
                      style: TextStyle(color: PremiumColors.textMuted, fontSize: 11),
                    ),
                    Text(
                      l10n.chatEdited,
                      style: const TextStyle(
                        color: PremiumColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    ChatMessageStatusTick(message: message, isMe: isMe, size: 13),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeletedBubble extends StatelessWidget {
  const _DeletedBubble({required this.isMe});

  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PremiumColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(PremiumRadii.lg),
          topRight: const Radius.circular(PremiumRadii.lg),
          bottomLeft: Radius.circular(isMe ? PremiumRadii.lg : PremiumRadii.sm),
          bottomRight: Radius.circular(isMe ? PremiumRadii.sm : PremiumRadii.lg),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.block_rounded,
              size: 16,
              color: PremiumColors.textMuted.withValues(alpha: 0.85),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.chatMessageDeleted,
              style: TextStyle(
                color: PremiumColors.textMuted.withValues(alpha: 0.9),
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplyPreviewChip extends StatelessWidget {
  const _ReplyPreviewChip({
    required this.replyTo,
    required this.participantName,
    required this.currentUserId,
    required this.isMe,
  });

  final ChatMessage replyTo;
  final String participantName;
  final String currentUserId;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final senderLabel = replyTo.isFromCurrentUser(currentUserId) ? 'You' : participantName;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white.withValues(alpha: 0.55) : PremiumColors.accentBlue,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            senderLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isMe ? Colors.white.withValues(alpha: 0.92) : PremiumColors.accentBlue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            previewTextForMessage(replyTo, AppLocalizations.of(context)!),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isMe ? Colors.white.withValues(alpha: 0.78) : PremiumColors.textSecondary,
              fontSize: 12,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerContextBanner extends StatelessWidget {
  const _ComposerContextBanner({
    required this.title,
    required this.subtitle,
    required this.onClose,
    this.accentColor = PremiumColors.accentBlue,
  });

  final String title;
  final String subtitle;
  final VoidCallback onClose;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.xs, AppSpacing.sm),
      decoration: BoxDecoration(
        color: PremiumColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(PremiumRadii.pill),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PremiumColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, color: PremiumColors.textMuted, size: 20),
          ),
        ],
      ),
    );
  }
}

class _FailedMediaBubble extends StatelessWidget {
  const _FailedMediaBubble({
    required this.message,
    required this.isMe,
    this.onRetry,
    this.onDelete,
    this.onImageTap,
    this.onVoiceToggle,
  });

  final ChatMessage message;
  final bool isMe;
  final VoidCallback? onRetry;
  final VoidCallback? onDelete;
  final VoidCallback? onImageTap;
  final VoidCallback? onVoiceToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PremiumColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.bannerOrange.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(PremiumRadii.sm),
                child: message.localPreviewBytes != null
                    ? Image.memory(
                        message.localPreviewBytes!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 44,
                        height: 44,
                        color: PremiumColors.surfaceRaised,
                        child: const Icon(Icons.image_outlined, color: PremiumColors.textMuted, size: 20),
                      ),
              )
            else if (message.isVoice)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PremiumColors.accentBlue.withValues(alpha: 0.14),
                ),
                child: const Icon(Icons.mic_rounded, color: PremiumColors.accentBlue, size: 20),
              )
            else
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PremiumColors.surfaceRaised,
                ),
                child: const Icon(Icons.error_outline_rounded, color: PremiumColors.bannerOrange, size: 20),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.chatFailedToSend,
                style: const TextStyle(
                  color: PremiumColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: onRetry,
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: const Icon(Icons.refresh_rounded, color: PremiumColors.accentBlue),
            ),
            IconButton(
              onPressed: onDelete,
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: const Icon(Icons.close_rounded, color: PremiumColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceBubble extends StatelessWidget {
  const _VoiceBubble({
    required this.message,
    required this.isMe,
    this.onToggle,
  });

  final ChatMessage message;
  final bool isMe;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final playback = VoicePlaybackScope.of(context);
    final attachment = message.voiceAttachment;
    final durationMs = attachment?.durationMs ?? 0;
    final waveform = attachment?.waveform.isNotEmpty == true
        ? attachment!.waveform
        : WaveformUtils.generateSamples(barCount: 28, durationMs: durationMs);

    return AnimatedBuilder(
      animation: playback,
      builder: (context, _) {
        final state = playback.snapshot(message.id);
        return VoiceMessageBubble(
          durationMs: durationMs,
          waveform: waveform,
          isMe: isMe,
          isPlaying: state.isPlaying,
          progress: state.progress,
          isLoading: message.isPending,
          onToggle: onToggle ?? () {},
        );
      },
    );
  }
}

class _TextBubble extends StatelessWidget {
  const _TextBubble({
    required this.message,
    required this.isMe,
  });

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = message.hasFailed
        ? PremiumColors.surface.withValues(alpha: 0.95)
        : PremiumColors.surface.withValues(alpha: 0.95);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isMe && !message.hasFailed
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [PremiumColors.accentBlue, PremiumColors.accentBlueSoft],
              )
            : null,
        color: isMe && !message.hasFailed ? null : bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(PremiumRadii.lg),
          topRight: const Radius.circular(PremiumRadii.lg),
          bottomLeft: Radius.circular(isMe ? PremiumRadii.lg : PremiumRadii.sm),
          bottomRight: Radius.circular(isMe ? PremiumRadii.sm : PremiumRadii.lg),
        ),
        border: isMe && !message.hasFailed
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: isMe && !message.hasFailed
            ? const [
                BoxShadow(
                  color: Color(0x336B8FC7),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          message.body,
          style: TextStyle(
            color: isMe ? Colors.white : PremiumColors.textPrimary,
            fontSize: 15,
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ImageBubble extends StatelessWidget {
  const _ImageBubble({
    required this.message,
    required this.isMe,
    this.onTap,
  });

  final ChatMessage message;
  final bool isMe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final caption = message.body.trim();
    final imageUrl = message.primaryImageUrl;
    final localBytes = message.localPreviewBytes;
    final localImagePath = message.localImagePath;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: PremiumColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(PremiumRadii.lg),
          topRight: const Radius.circular(PremiumRadii.lg),
          bottomLeft: Radius.circular(isMe ? PremiumRadii.lg : PremiumRadii.sm),
          bottomRight: Radius.circular(isMe ? PremiumRadii.sm : PremiumRadii.lg),
        ),
        border: Border.all(
          color: isMe ? PremiumColors.accentBlue.withValues(alpha: 0.28) : Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: isMe
            ? const [
                BoxShadow(
                  color: Color(0x266B8FC7),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(PremiumRadii.lg),
          topRight: const Radius.circular(PremiumRadii.lg),
          bottomLeft: Radius.circular(isMe ? PremiumRadii.lg : PremiumRadii.sm),
          bottomRight: Radius.circular(isMe ? PremiumRadii.sm : PremiumRadii.lg),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (localBytes != null)
                        Image.memory(localBytes, fit: BoxFit.cover)
                      else if (localImagePath != null && localImagePath.isNotEmpty)
                        Image.file(File(localImagePath), fit: BoxFit.cover)
                      else if (imageUrl != null && imageUrl.isNotEmpty)
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: PremiumColors.surfaceRaised,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: PremiumColors.accentBlue,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: PremiumColors.surfaceRaised,
                              alignment: Alignment.center,
                              child: const Icon(Icons.broken_image_outlined, color: PremiumColors.textMuted),
                            );
                          },
                        )
                      else
                        Container(
                          color: PremiumColors.surfaceRaised,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_outlined, color: PremiumColors.textMuted),
                        ),
                    ],
                  ),
                ),
                if (caption.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    color: isMe
                        ? PremiumColors.accentBlue.withValues(alpha: 0.18)
                        : Colors.black.withValues(alpha: 0.18),
                    child: Text(
                      caption,
                      style: TextStyle(
                        color: isMe ? Colors.white : PremiumColors.textPrimary,
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePreviewComposer extends StatelessWidget {
  const _ImagePreviewComposer({
    required this.imageBytes,
    required this.captionController,
    required this.sending,
    required this.onRemove,
    required this.onSend,
  });

  final Uint8List imageBytes;
  final TextEditingController captionController;
  final bool sending;
  final VoidCallback onRemove;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: PremiumColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.accentBlue.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(PremiumRadii.md),
            child: Image.memory(imageBytes, width: 72, height: 72, fit: BoxFit.cover),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: captionController,
              enabled: !sending,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add a caption...',
                hintStyle: const TextStyle(color: PremiumColors.textMuted),
                isDense: true,
                filled: true,
                fillColor: PremiumColors.midnightMid.withValues(alpha: 0.65),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PremiumRadii.md),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PremiumRadii.md),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PremiumRadii.md),
                  borderSide: BorderSide(color: PremiumColors.accentBlue.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: sending ? null : onRemove,
            icon: const Icon(Icons.close_rounded, color: PremiumColors.textMuted),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: sending ? null : onSend,
              borderRadius: BorderRadius.circular(PremiumRadii.pill),
              child: Ink(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: sending
                      ? null
                      : const LinearGradient(
                          colors: [PremiumColors.accentBlue, PremiumColors.accentBlueSoft],
                        ),
                  color: sending ? PremiumColors.surfaceRaised : null,
                ),
                child: sending
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 2, color: PremiumColors.accentBlue),
                      )
                    : const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.hasText,
    required this.hasPendingImage,
    required this.enabled,
    required this.onAttachment,
    required this.onMicrophone,
    required this.onSend,
    this.isEditing = false,
  });

  final TextEditingController controller;
  final bool hasText;
  final bool hasPendingImage;
  final bool enabled;
  final VoidCallback onAttachment;
  final VoidCallback onMicrophone;
  final VoidCallback onSend;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final canSend = enabled && (hasText || hasPendingImage);
    final canRecord = enabled && !hasText && !hasPendingImage;

    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, bottomSafe + AppSpacing.sm),
      decoration: BoxDecoration(
        color: PremiumColors.midnightMid.withValues(alpha: 0.92),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onAttachment : null,
              customBorder: const CircleBorder(),
              child: Ink(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PremiumColors.surface.withValues(alpha: 0.95),
                  border: Border.all(color: PremiumColors.accentBlue.withValues(alpha: 0.35)),
                ),
                child: const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: PremiumColors.accentBlue,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Message...',
                hintStyle: const TextStyle(color: PremiumColors.textMuted),
                filled: true,
                fillColor: PremiumColors.surface.withValues(alpha: 0.9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PremiumRadii.pill),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PremiumRadii.pill),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PremiumRadii.pill),
                  borderSide: BorderSide(color: PremiumColors.accentBlue.withValues(alpha: 0.55)),
                ),
              ),
              onSubmitted: canSend ? (_) => onSend() : null,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AnimatedOpacity(
            opacity: canRecord ? 1 : 0.35,
            duration: const Duration(milliseconds: 150),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canRecord ? onMicrophone : null,
                customBorder: const CircleBorder(),
                child: Ink(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PremiumColors.surface.withValues(alpha: 0.95),
                    border: Border.all(
                      color: canRecord
                          ? PremiumColors.accentBlue.withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Icon(
                    Icons.mic_rounded,
                    color: canRecord ? PremiumColors.accentBlue : PremiumColors.textMuted,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AnimatedOpacity(
            opacity: canSend ? 1 : 0.35,
            duration: const Duration(milliseconds: 150),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canSend ? onSend : null,
                borderRadius: BorderRadius.circular(PremiumRadii.pill),
                child: Ink(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: canSend
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [PremiumColors.accentBlue, PremiumColors.accentBlueSoft],
                          )
                        : null,
                    color: canSend ? null : PremiumColors.surface,
                    boxShadow: canSend
                        ? const [
                            BoxShadow(
                              color: Color(0x406B8FC7),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isEditing ? Icons.check_rounded : Icons.arrow_upward_rounded,
                    color: canSend ? Colors.white : PremiumColors.textMuted,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
