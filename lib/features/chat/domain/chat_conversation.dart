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
  });

  final String id;
  final String participantUserId;
  final String participantName;
  final String avatarUrl;
  final List<ChatMessage> messages;
  final int unreadCount;
  final String statusText;

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;

  String get lastMessagePreview => lastMessage?.body ?? '';

  DateTime? get lastMessageTime => lastMessage?.sentAt;

  ChatConversation copyWith({
    String? id,
    String? participantUserId,
    String? participantName,
    String? avatarUrl,
    List<ChatMessage>? messages,
    int? unreadCount,
    String? statusText,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      participantUserId: participantUserId ?? this.participantUserId,
      participantName: participantName ?? this.participantName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
      statusText: statusText ?? this.statusText,
    );
  }
}
