import 'chat_message.dart';

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.participantUserId,
    required this.participantName,
    required this.avatarUrl,
    required this.messages,
    required this.unreadCount,
    this.statusText = 'Active now',
    this.isRemote = false,
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
  final String? cachedLastMessageText;
  final DateTime? cachedLastMessageTime;

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;

  String get lastMessagePreview {
    final cached = cachedLastMessageText?.trim();
    if (cached != null && cached.isNotEmpty) return cached;
    final message = lastMessage;
    if (message == null) return '';
    if (message.isVoice) return 'Voice message';
    if (message.hasImage) {
      final caption = message.body.trim();
      if (caption.isNotEmpty) return caption;
      return 'Photo';
    }
    return message.body;
  }

  bool get isDemo => !isRemote && participantUserId.startsWith('seed_');

  DateTime? get lastMessageTime => cachedLastMessageTime ?? lastMessage?.sentAt;

  ChatConversation copyWith({
    String? id,
    String? participantUserId,
    String? participantName,
    String? avatarUrl,
    List<ChatMessage>? messages,
    int? unreadCount,
    String? statusText,
    bool? isRemote,
    String? cachedLastMessageText,
    DateTime? cachedLastMessageTime,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      participantUserId: participantUserId ?? this.participantUserId,
      participantName: participantName ?? this.participantName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
      statusText: statusText ?? this.statusText,
      isRemote: isRemote ?? this.isRemote,
      cachedLastMessageText: cachedLastMessageText ?? this.cachedLastMessageText,
      cachedLastMessageTime: cachedLastMessageTime ?? this.cachedLastMessageTime,
    );
  }
}
