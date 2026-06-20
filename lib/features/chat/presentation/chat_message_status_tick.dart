import 'package:flutter/material.dart';

import '../../../app/theme/premium_tokens.dart';
import '../domain/chat_message.dart';

class ChatMessageStatusTick extends StatelessWidget {
  const ChatMessageStatusTick({
    super.key,
    required this.message,
    required this.isMe,
    this.size = 14,
  });

  final ChatMessage message;
  final bool isMe;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (!isMe) return const SizedBox.shrink();

    if (message.isFailed) {
      return Icon(
        Icons.error_outline_rounded,
        size: size,
        color: PremiumColors.bannerOrange,
      );
    }

    if (message.isUploading || message.deliveryStatus == ChatDeliveryStatus.sending) {
      return Icon(
        Icons.schedule_rounded,
        size: size,
        color: Colors.white.withValues(alpha: 0.72),
      );
    }

    switch (message.deliveryStatus) {
      case ChatDeliveryStatus.read:
        return Icon(
          Icons.done_all_rounded,
          size: size,
          color: PremiumColors.accentBlueSoft,
        );
      case ChatDeliveryStatus.delivered:
        return Icon(
          Icons.done_all_rounded,
          size: size,
          color: Colors.white.withValues(alpha: 0.55),
        );
      case ChatDeliveryStatus.sent:
      case ChatDeliveryStatus.failed:
      case ChatDeliveryStatus.sending:
        return Icon(
          Icons.done_rounded,
          size: size,
          color: Colors.white.withValues(alpha: 0.72),
        );
    }
  }
}
