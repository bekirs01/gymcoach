import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/premium_background.dart';
import '../../../core/supabase_operation_error.dart';
import '../../feed/presentation/social_avatar.dart';
import '../data/chat_local_store.dart';
import '../data/chat_repository.dart';
import '../../social/data/social_seed_data.dart';
import '../data/supabase_chat_repository.dart';
import '../data/voice_playback_service.dart';
import '../data/voice_recorder_service.dart';
import '../data/waveform_utils.dart';
import '../domain/chat_attachment.dart';
import '../domain/chat_conversation.dart';
import '../domain/chat_message.dart';
import 'chat_attachment_picker_sheet.dart';
import 'chat_image_viewer_screen.dart';
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
  var _loading = true;
  var _loadFailed = false;
  String? _loadErrorMessage;
  var _sendingImage = false;
  var _voiceComposerActive = false;
  final _pendingTempIds = <String>{};
  final _messageIds = <String>{};
  XFile? _pendingImage;
  Uint8List? _pendingImageBytes;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadRemoteConversation();
  }

  Future<void> _loadRemoteConversation() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
      _loadErrorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final repository = SupabaseChatRepository(prefs: prefs);
      final currentUserId = await repository.ensureAuthenticatedUserId();
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
        final local = _loadLocalConversation();
        if (local != null) {
          _repository = repository;
          _currentUserId = await repository.resolveCurrentUserId();
          _conversation = local;
          _seedMessageIds(local.messages);
          setState(() => _loading = false);
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animated: false));
          return;
        }
        setState(() {
          _loading = false;
          _loadFailed = true;
          _loadErrorMessage = 'Could not load conversation';
        });
        return;
      }

      _repository = repository;
      _currentUserId = currentUserId;
      _conversation = conversation;
      _seedMessageIds(conversation.messages);

      repository.subscribeToMessages(
        conversationId: conversation.id,
        onInsert: _onRemoteMessageInserted,
      );

      await repository.markConversationRead(conversation.id);

      setState(() => _loading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animated: false));
    } catch (error, stackTrace) {
      final local = _loadLocalConversation();
      if (local != null) {
        final prefs = await SharedPreferences.getInstance();
        final repository = SupabaseChatRepository(prefs: prefs);
        if (!mounted) return;
        _repository = repository;
        _currentUserId = SocialSeedRepository.currentUserId;
        _conversation = local;
        _seedMessageIds(local.messages);
        setState(() {
          _loading = false;
          _loadFailed = false;
          _loadErrorMessage = null;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animated: false));
        return;
      }

      final mapped = SupabaseOperationError.classify(
        operation: 'chat_load_conversation',
        error: error,
        stackTrace: stackTrace,
        fallbackMessage: 'Could not load conversation',
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
        _loadErrorMessage = mapped.userMessage;
      });
    }
  }

  ChatConversation? _loadLocalConversation() {
    if (!ChatRepository.isDemoParticipant(widget.participantUserId)) return null;
    ChatLocalStore.ensureInitialized();
    return ChatLocalStore.conversationForUser(widget.participantUserId);
  }

  void _seedMessageIds(List<ChatMessage> messages) {
    _messageIds
      ..clear()
      ..addAll(messages.map((message) => message.id));
  }

  String _previewForMessage(ChatMessage message) {
    if (message.isVoice) return 'Voice message';
    if (message.hasImage) {
      final caption = message.body.trim();
      return caption.isEmpty ? 'Photo' : caption;
    }
    return message.body;
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
          messages: messages,
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
      _conversation = current.copyWith(messages: [...current.messages, message]);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
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

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final repository = _repository;
    final conversation = _conversation;
    final currentUserId = _currentUserId;
    if (repository == null || conversation == null || currentUserId == null) return;

    final clientTempId = _uuid.v4();
    final optimistic = ChatMessage(
      id: 'pending_$clientTempId',
      senderId: currentUserId,
      body: text,
      sentAt: DateTime.now(),
      clientTempId: clientTempId,
      isPending: true,
    );

    _pendingTempIds.add(clientTempId);
    _textController.clear();
    setState(() {
      _conversation = conversation.copyWith(messages: [...conversation.messages, optimistic]);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      if (conversation.isDemo && !conversation.isRemote) {
        final updated = ChatLocalStore.sendMessage(
          participantUserId: conversation.participantUserId,
          body: text,
        );
        if (!mounted) return;
        setState(() {
          _pendingTempIds.remove(clientTempId);
          if (updated != null) {
            _conversation = updated;
            _messageIds.add(updated.messages.last.id);
          } else {
            final current = _conversation;
            if (current == null) return;
            _conversation = current.copyWith(
              messages: current.messages
                  .map(
                    (message) => message.clientTempId == clientTempId
                        ? message.copyWith(isPending: false, hasFailed: true)
                        : message,
                  )
                  .toList(),
            );
          }
        });
        return;
      }

      final sent = await repository.sendTextMessage(
        conversationId: conversation.id,
        body: text,
        clientTempId: clientTempId,
      );
      if (!mounted) return;

      setState(() {
        _pendingTempIds.remove(clientTempId);
        _messageIds.add(sent.id);
        final current = _conversation;
        if (current == null) return;

        final messages = current.messages.map((message) {
          if (message.clientTempId == clientTempId) return sent;
          return message;
        }).toList();

        if (!messages.any((message) => message.id == sent.id)) {
          messages.add(sent);
        }

        _conversation = current.copyWith(
          messages: messages,
          cachedLastMessageText: sent.body,
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
                (message) => message.clientTempId == clientTempId
                    ? message.copyWith(isPending: false, hasFailed: true)
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
    } catch (error) {
      _showError(error.toString());
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
    final repository = _repository;
    final conversation = _conversation;
    final currentUserId = _currentUserId;
    final file = _pendingImage;
    final bytes = _pendingImageBytes;
    if (repository == null ||
        conversation == null ||
        currentUserId == null ||
        file == null ||
        bytes == null ||
        _sendingImage) {
      return;
    }

    final caption = _textController.text.trim();
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

    _pendingTempIds.add(clientTempId);
    setState(() {
      _sendingImage = true;
      _conversation = conversation.copyWith(messages: [...conversation.messages, optimistic]);
      _pendingImage = null;
      _pendingImageBytes = null;
    });
    _textController.clear();
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
        _messageIds.add(sent.id);
        final current = _conversation;
        if (current == null) return;

        final messages = current.messages.map((message) {
          if (message.clientTempId == clientTempId) return sent;
          return message;
        }).toList();

        if (!messages.any((message) => message.id == sent.id)) {
          messages.add(sent);
        }

        _conversation = current.copyWith(
          messages: messages,
          cachedLastMessageText: _previewForMessage(sent),
          cachedLastMessageTime: sent.sentAt,
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _pendingTempIds.remove(clientTempId);
        final current = _conversation;
        if (current == null) return;
        _conversation = current.copyWith(
          messages: current.messages
              .map(
                (message) => message.clientTempId == clientTempId
                    ? message.copyWith(isPending: false, hasFailed: true, clearLocalPreviewBytes: true)
                    : message,
              )
              .toList(),
        );
      });
      _showError(error.toString());
    } finally {
      if (mounted) setState(() => _sendingImage = false);
    }
  }

  Future<void> _sendVoiceMessage(VoiceRecordingResult result) async {
    final repository = _repository;
    final conversation = _conversation;
    final currentUserId = _currentUserId;
    if (repository == null || conversation == null || currentUserId == null) return;

    final waveform = WaveformUtils.generateSamples(
      barCount: 28,
      durationMs: result.durationMs,
      seed: result.filePath,
    );
    final clientTempId = _uuid.v4();
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
      localVoicePath: result.filePath,
      isPending: true,
    );

    _pendingTempIds.add(clientTempId);
    setState(() {
      _conversation = conversation.copyWith(messages: [...conversation.messages, optimistic]);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      final sent = await repository.sendVoiceMessage(
        conversationId: conversation.id,
        localFilePath: result.filePath,
        durationMs: result.durationMs,
        waveform: waveform,
        clientTempId: clientTempId,
      );
      await _voiceRecorder.deleteFile(result.filePath);
      if (!mounted) return;

      setState(() {
        _pendingTempIds.remove(clientTempId);
        _messageIds.add(sent.id);
        final current = _conversation;
        if (current == null) return;

        final messages = current.messages.map((message) {
          if (message.clientTempId == clientTempId) return sent;
          return message;
        }).toList();

        if (!messages.any((message) => message.id == sent.id)) {
          messages.add(sent);
        }

        _conversation = current.copyWith(
          messages: messages,
          cachedLastMessageText: _previewForMessage(sent),
          cachedLastMessageTime: sent.sentAt,
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _pendingTempIds.remove(clientTempId);
        final current = _conversation;
        if (current == null) return;
        _conversation = current.copyWith(
          messages: current.messages
              .map(
                (message) => message.clientTempId == clientTempId
                    ? message.copyWith(
                        isPending: false,
                        hasFailed: true,
                        clearLocalVoicePath: true,
                      )
                    : message,
              )
              .toList(),
        );
      });
      _showError('Failed to send voice message');
      rethrow;
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

    final attachment = message.voiceAttachment;
    if (attachment == null) return;

    var url = attachment.signedUrl;
    if (url == null || url.isEmpty) {
      final repository = _repository;
      if (repository == null) return;
      url = await repository.refreshSignedUrl(attachment);
    }
    if (url == null || url.isEmpty) return;

    await _voicePlayback.toggle(messageId: message.id, source: url);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
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
                      if (!_voiceComposerActive)
                        _ChatInputBar(
                          controller: _textController,
                          hasText: _hasText,
                          hasPendingImage: _pendingImageBytes != null,
                          enabled: !_loading && !_loadFailed && conversation != null,
                          onAttachment: _pickAttachment,
                          onMicrophone: _startVoiceRecording,
                          onSend: _pendingImageBytes != null ? _sendPendingImage : _sendMessage,
                        ),
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
            Text(
              _loadErrorMessage ?? 'Could not load conversation',
              style: const TextStyle(color: PremiumColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: _loadRemoteConversation,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (conversation.messages.isEmpty) {
      return const Center(
        child: Text(
          'Start the conversation',
          style: TextStyle(color: PremiumColors.textSecondary),
        ),
      );
    }

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
          onImageTap: message.hasImage ? () => _openImageViewer(message) : null,
          onVoiceToggle: message.isVoice ? () => _toggleVoicePlayback(message) : null,
        );
      },
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
    this.onImageTap,
    this.onVoiceToggle,
  });

  final ChatMessage message;
  final bool isMe;
  final VoidCallback? onImageTap;
  final VoidCallback? onVoiceToggle;

  @override
  Widget build(BuildContext context) {
    final timeLabel = ChatRepository.formatMessageTime(message.sentAt);
    final maxWidth = MediaQuery.sizeOf(context).width * 0.7;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: message.isVoice
                  ? _VoiceBubble(
                      message: message,
                      isMe: isMe,
                      onToggle: onVoiceToggle,
                    )
                  : message.hasImage
                      ? _ImageBubble(message: message, isMe: isMe, onTap: onImageTap)
                      : _TextBubble(message: message, isMe: isMe),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(
              left: isMe ? 0 : AppSpacing.xs,
              right: isMe ? AppSpacing.xs : 0,
            ),
            child: Text(
              message.hasFailed ? 'Failed to send' : timeLabel,
              style: TextStyle(
                color: message.hasFailed ? PremiumColors.bannerOrange : PremiumColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
            onTap: message.isPending ? null : onTap,
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
                      if (message.isPending)
                        Container(
                          color: Colors.black.withValues(alpha: 0.35),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: PremiumColors.accentBlue,
                          ),
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
  });

  final TextEditingController controller;
  final bool hasText;
  final bool hasPendingImage;
  final bool enabled;
  final VoidCallback onAttachment;
  final VoidCallback onMicrophone;
  final VoidCallback onSend;

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
                    Icons.arrow_upward_rounded,
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
