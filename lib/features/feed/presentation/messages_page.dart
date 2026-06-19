import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/premium_background.dart';
import '../../chat/data/chat_local_store.dart';
import '../../chat/data/chat_repository.dart';
import '../../chat/data/supabase_chat_repository.dart';
import '../../chat/domain/chat_conversation.dart';
import '../../chat/presentation/chat_conversation_screen.dart';
import 'social_avatar.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  var _query = '';
  var _loading = true;
  var _loadFailed = false;
  List<ChatConversation> _remoteConversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final repository = SupabaseChatRepository(prefs: prefs);
      final conversations = await repository.loadConversations();
      if (!mounted) return;
      setState(() {
        _remoteConversations = conversations;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  List<ChatConversation> get _conversations {
    final source = _remoteConversations.isNotEmpty
        ? _remoteConversations
        : ChatLocalStore.orderedConversations();
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return source;
    return source.where((conversation) => conversation.participantName.toLowerCase().contains(q)).toList();
  }

  Future<void> _onConversationTap(ChatConversation conversation) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ChatConversationScreen(
          participantUserId: conversation.participantUserId,
          conversationId: conversation.isRemote ? conversation.id : null,
        ),
      ),
    );
    if (!mounted) return;
    await _loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    final conversations = _conversations;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.xs, AppSpacing.md, AppSpacing.sm),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    ),
                    const Expanded(
                      child: Text(
                        'Messages',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: const TextStyle(color: PremiumColors.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, color: PremiumColors.textMuted, size: 22),
                    filled: true,
                    fillColor: PremiumColors.surface.withValues(alpha: 0.85),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PremiumRadii.lg),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PremiumRadii.lg),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PremiumRadii.lg),
                      borderSide: BorderSide(color: PremiumColors.accentBlue.withValues(alpha: 0.6)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: PremiumColors.accentBlue),
                      )
                    : conversations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _loadFailed && _remoteConversations.isEmpty
                                      ? 'Could not load conversations'
                                      : 'No conversations found',
                                  style: const TextStyle(color: PremiumColors.textSecondary),
                                ),
                                if (_loadFailed) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  TextButton(
                                    onPressed: _loadConversations,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.xl),
                            itemCount: conversations.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                            itemBuilder: (context, index) {
                              final conversation = conversations[index];
                              final unread = conversation.unreadCount > 0;
                              return _ConversationRow(
                                name: conversation.participantName,
                                avatarUrl: conversation.avatarUrl,
                                lastMessage: conversation.lastMessagePreview,
                                time: ChatRepository.formatRelativeTime(conversation.lastMessageTime),
                                unread: unread,
                                onTap: () => _onConversationTap(conversation),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  final String name;
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final bool unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              SocialAvatar(
                name: name,
                imageUrl: avatarUrl,
                size: 52,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            color: unread ? PremiumColors.accentBlue : PremiumColors.textMuted,
                            fontSize: 13,
                            fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: unread ? PremiumColors.textPrimary : PremiumColors.textSecondary,
                              fontSize: 14,
                              fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 9,
                            height: 9,
                            margin: const EdgeInsets.only(left: AppSpacing.xs),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: PremiumColors.accentBlue,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x406B8FC7),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
