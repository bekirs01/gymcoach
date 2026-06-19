class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.body,
    required this.sentAt,
  });

  final String id;
  final String senderId;
  final String body;
  final DateTime sentAt;

  bool isFromCurrentUser(String currentUserId) => senderId == currentUserId;

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? body,
    DateTime? sentAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      body: body ?? this.body,
      sentAt: sentAt ?? this.sentAt,
    );
  }
}
