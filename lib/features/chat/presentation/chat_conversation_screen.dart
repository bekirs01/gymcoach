import 'package:flutter/material.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/premium_background.dart';
import '../../feed/presentation/social_avatar.dart';
import '../../social/data/social_seed_data.dart';
import '../data/chat_local_store.dart';
import '../domain/chat_conversation.dart';
import '../domain/chat_message.dart';

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({
    super.key,
    required this.participantUserId,
  });

  final String participantUserId;

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  ChatConversation? _conversation;
  var _hasText = false;

  @override
  void initState() {
    super.initState();
    ChatLocalStore.ensureInitialized();
    _conversation = ChatLocalStore.conversationForUser(widget.participantUserId);
    ChatLocalStore.markAsRead(widget.participantUserId);
    _textController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animated: false));
  }

  @override
  void dispose() {
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

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final updated = ChatLocalStore.sendMessage(
      participantUserId: widget.participantUserId,
      body: text,
    );
    if (updated == null) return;

    _textController.clear();
    setState(() => _conversation = updated);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final conversation = _conversation;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
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
                child: conversation == null
                    ? const Center(
                        child: Text(
                          'Conversation not found',
                          style: TextStyle(color: PremiumColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
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
                          final isMe = message.isFromCurrentUser(SocialSeedRepository.currentUserId);
                          return _MessageBubble(
                            message: message,
                            isMe: isMe,
                          );
                        },
                      ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: _ChatInputBar(
                  controller: _textController,
                  hasText: _hasText,
                  onSend: _sendMessage,
                ),
              ),
            ],
          ),
        ),
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
  });

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final timeLabel = ChatLocalStore.formatMessageTime(message.sentAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.72,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: isMe
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [PremiumColors.accentBlue, PremiumColors.accentBlueSoft],
                        )
                      : null,
                  color: isMe ? null : PremiumColors.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(PremiumRadii.lg),
                    topRight: const Radius.circular(PremiumRadii.lg),
                    bottomLeft: Radius.circular(isMe ? PremiumRadii.lg : PremiumRadii.sm),
                    bottomRight: Radius.circular(isMe ? PremiumRadii.sm : PremiumRadii.lg),
                  ),
                  border: isMe
                      ? null
                      : Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  boxShadow: isMe
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
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(
              left: isMe ? 0 : AppSpacing.xs,
              right: isMe ? AppSpacing.xs : 0,
            ),
            child: Text(
              timeLabel,
              style: const TextStyle(
                color: PremiumColors.textMuted,
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

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.hasText,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool hasText;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

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
          Expanded(
            child: TextField(
              controller: controller,
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
              onSubmitted: hasText ? (_) => onSend() : null,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AnimatedOpacity(
            opacity: hasText ? 1 : 0.35,
            duration: const Duration(milliseconds: 150),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasText ? onSend : null,
                borderRadius: BorderRadius.circular(PremiumRadii.pill),
                child: Ink(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasText
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [PremiumColors.accentBlue, PremiumColors.accentBlueSoft],
                          )
                        : null,
                    color: hasText ? null : PremiumColors.surface,
                    boxShadow: hasText
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
                    color: hasText ? Colors.white : PremiumColors.textMuted,
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
