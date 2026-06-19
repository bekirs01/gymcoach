import 'package:flutter/material.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/premium_background.dart';
import '../../social/data/social_seed_data.dart';
import 'social_avatar.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  var _query = '';

  static const _conversationOrder = [
    'seed_sofia',
    'seed_maria',
    'seed_anastasia',
    'seed_ekaterina',
    'seed_alexey',
  ];

  static const _lastMessages = {
    'seed_sofia': 'See you at the gym tomorrow?',
    'seed_maria': 'Great session today 💪',
    'seed_anastasia': 'Sent a workout plan',
    'seed_ekaterina': 'Thanks for the tips!',
    'seed_alexey': 'Leg day was intense',
  };

  static const _times = {
    'seed_sofia': '2m',
    'seed_maria': '15m',
    'seed_anastasia': '1h',
    'seed_ekaterina': '3h',
    'seed_alexey': '1d',
  };

  static const _unreadIds = {'seed_sofia', 'seed_anastasia', 'seed_alexey'};

  List<SeededSocialUser> get _conversations {
    final items = <SeededSocialUser>[];
    for (final id in _conversationOrder) {
      final user = SocialSeedRepository.userById(id);
      if (user != null) items.add(user);
    }
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((user) => user.displayName.toLowerCase().contains(q)).toList();
  }

  void _onConversationTap(SeededSocialUser user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chat with ${user.displayName} coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                child: conversations.isEmpty
                    ? const Center(
                        child: Text(
                          'No conversations found',
                          style: TextStyle(color: PremiumColors.textSecondary),
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
                          final user = conversations[index];
                          final unread = _unreadIds.contains(user.id);
                          return _ConversationRow(
                            user: user,
                            lastMessage: _lastMessages[user.id] ?? '',
                            time: _times[user.id] ?? '',
                            unread: unread,
                            onTap: () => _onConversationTap(user),
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
    required this.user,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  final SeededSocialUser user;
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
                name: user.displayName,
                imageUrl: user.avatarUrl,
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
                            user.displayName,
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
