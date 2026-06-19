import '../../social/data/social_seed_data.dart';
import '../domain/chat_conversation.dart';
import '../domain/chat_message.dart';

abstract final class ChatLocalStore {
  static final Map<String, ChatConversation> _conversations = {};
  static var _initialized = false;

  static const conversationOrder = [
    'seed_sofia',
    'seed_maria',
    'seed_anastasia',
    'seed_ekaterina',
    'seed_alexey',
  ];

  static void ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    final now = DateTime.now();
    _conversations.addAll({
      'seed_sofia': _buildConversation(
        userId: 'seed_sofia',
        unreadCount: 1,
        statusText: 'Active now',
        messages: [
          _msg('seed_sofia', 'Hey, did you train today?', now.subtract(const Duration(minutes: 18))),
          _msg(SocialSeedRepository.currentUserId, 'Yes, just finished shoulders.', now.subtract(const Duration(minutes: 16))),
          _msg('seed_sofia', 'Nice, I\'m going to the gym later.', now.subtract(const Duration(minutes: 14))),
          _msg(SocialSeedRepository.currentUserId, 'Send your workout after.', now.subtract(const Duration(minutes: 12))),
          _msg('seed_sofia', 'Sure 😄', now.subtract(const Duration(minutes: 2))),
        ],
      ),
      'seed_maria': _buildConversation(
        userId: 'seed_maria',
        unreadCount: 0,
        statusText: 'Online',
        messages: [
          _msg('seed_maria', 'How was your leg day?', now.subtract(const Duration(minutes: 45))),
          _msg(SocialSeedRepository.currentUserId, 'Hard but good.', now.subtract(const Duration(minutes: 40))),
          _msg('seed_maria', 'Same here, I\'m still tired.', now.subtract(const Duration(minutes: 30))),
          _msg(SocialSeedRepository.currentUserId, 'Recovery day tomorrow.', now.subtract(const Duration(minutes: 15))),
        ],
      ),
      'seed_anastasia': _buildConversation(
        userId: 'seed_anastasia',
        unreadCount: 2,
        statusText: 'Active now',
        messages: [
          _msg('seed_anastasia', 'Did you try the new stretch routine?', now.subtract(const Duration(hours: 1, minutes: 10))),
          _msg(SocialSeedRepository.currentUserId, 'Not yet, sending it now.', now.subtract(const Duration(hours: 1))),
          _msg('seed_anastasia', 'Sent a workout plan', now.subtract(const Duration(minutes: 55))),
        ],
      ),
      'seed_ekaterina': _buildConversation(
        userId: 'seed_ekaterina',
        unreadCount: 0,
        statusText: 'Online',
        messages: [
          _msg('seed_ekaterina', 'Any tips for pacing on long runs?', now.subtract(const Duration(hours: 3, minutes: 20))),
          _msg(SocialSeedRepository.currentUserId, 'Start slow, finish strong.', now.subtract(const Duration(hours: 3, minutes: 10))),
          _msg('seed_ekaterina', 'Thanks for the tips!', now.subtract(const Duration(hours: 3))),
        ],
      ),
      'seed_alexey': _buildConversation(
        userId: 'seed_alexey',
        unreadCount: 1,
        statusText: 'Active now',
        messages: [
          _msg('seed_alexey', 'Squats felt heavy today.', now.subtract(const Duration(days: 1, minutes: 30))),
          _msg(SocialSeedRepository.currentUserId, 'Same, deload week maybe?', now.subtract(const Duration(days: 1, minutes: 20))),
          _msg('seed_alexey', 'Leg day was intense', now.subtract(const Duration(days: 1))),
        ],
      ),
    });
  }

  static List<ChatConversation> orderedConversations() {
    ensureInitialized();
    return conversationOrder
        .map((id) => _conversations[id])
        .whereType<ChatConversation>()
        .toList();
  }

  static ChatConversation? conversationForUser(String participantUserId) {
    ensureInitialized();
    return _conversations[participantUserId];
  }

  static ChatConversation? sendMessage({
    required String participantUserId,
    required String body,
  }) {
    ensureInitialized();
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;

    final existing = _conversations[participantUserId];
    if (existing == null) return null;

    final message = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: SocialSeedRepository.currentUserId,
      body: trimmed,
      sentAt: DateTime.now(),
    );

    final updated = existing.copyWith(
      messages: [...existing.messages, message],
    );
    _conversations[participantUserId] = updated;
    return updated;
  }

  static ChatConversation? markAsRead(String participantUserId) {
    ensureInitialized();
    final existing = _conversations[participantUserId];
    if (existing == null || existing.unreadCount == 0) return existing;
    final updated = existing.copyWith(unreadCount: 0);
    _conversations[participantUserId] = updated;
    return updated;
  }

  static String formatRelativeTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${time.day}/${time.month}';
  }

  static String formatMessageTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static ChatConversation _buildConversation({
    required String userId,
    required int unreadCount,
    required String statusText,
    required List<ChatMessage> messages,
  }) {
    final user = SocialSeedRepository.userById(userId)!;
    return ChatConversation(
      id: 'conv_$userId',
      participantUserId: userId,
      participantName: user.displayName,
      avatarUrl: user.avatarUrl,
      messages: messages,
      unreadCount: unreadCount,
      statusText: statusText,
    );
  }

  static ChatMessage _msg(String senderId, String body, DateTime sentAt) {
    return ChatMessage(
      id: 'msg_${senderId}_${sentAt.millisecondsSinceEpoch}',
      senderId: senderId,
      body: body,
      sentAt: sentAt,
    );
  }
}
