import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/premium_tokens.dart';
import '../data/chat_repository.dart';
import '../domain/chat_attachment.dart';
import '../domain/chat_message.dart';

enum ChatMessageActionType {
  reply,
  copyText,
  copyCaption,
  edit,
  delete,
  saveImage,
  saveAudio,
  share,
  details,
  retry,
  remove,
  cancel,
}

class ChatMessageActionResult {
  const ChatMessageActionResult(this.type);

  final ChatMessageActionType type;
}

class ChatMessageActionItem {
  const ChatMessageActionItem({
    required this.type,
    required this.label,
    required this.icon,
    this.destructive = false,
    this.enabled = true,
  });

  final ChatMessageActionType type;
  final String label;
  final IconData icon;
  final bool destructive;
  final bool enabled;
}

enum ChatMessageDeleteChoice {
  forEveryone,
  forMe,
}

Future<ChatMessageActionResult?> showChatMessageActionsSheet({
  required BuildContext context,
  required ChatMessage message,
  required bool isMe,
  required String senderName,
  required List<ChatMessageActionItem> actions,
}) {
  return showModalBottomSheet<ChatMessageActionResult>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return _ChatMessageActionsSheet(
        message: message,
        isMe: isMe,
        senderName: senderName,
        actions: actions,
      );
    },
  );
}

Future<ChatMessageDeleteChoice?> showChatMessageDeleteSheet({
  required BuildContext context,
  required bool isMe,
  required bool canDeleteForEveryone,
  required bool canDeleteForMe,
}) {
  return showModalBottomSheet<ChatMessageDeleteChoice>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _ChatMessageDeleteSheet(
        isMe: isMe,
        canDeleteForEveryone: canDeleteForEveryone,
        canDeleteForMe: canDeleteForMe,
      );
    },
  );
}

Future<void> showChatMessageDetailsSheet({
  required BuildContext context,
  required ChatMessage message,
  required bool isMe,
  required String senderName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _ChatMessageDetailsSheet(
        message: message,
        isMe: isMe,
        senderName: senderName,
      );
    },
  );
}

void showCopiedFeedback(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1400),
      backgroundColor: PremiumColors.surfaceRaised,
      content: Text(
        l10n.chatCopied,
        style: const TextStyle(color: PremiumColors.textPrimary, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

void showSavedFeedback(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1400),
      backgroundColor: PremiumColors.surfaceRaised,
      content: Text(
        l10n.chatSaved,
        style: const TextStyle(color: PremiumColors.textPrimary, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

String previewTextForMessage(ChatMessage message, AppLocalizations l10n) {
  if (message.isDeleted) return l10n.chatMessageDeleted;
  if (message.isVoice) return l10n.chatVoiceMessage;
  if (message.hasImage) {
    final caption = message.body.trim();
    return caption.isEmpty ? l10n.chatPhoto : caption;
  }
  return message.body;
}

List<ChatMessageActionItem> buildMessageActions({
  required ChatMessage message,
  required bool isMe,
  required String currentUserId,
  required bool canDeleteForEveryone,
  required bool canDeleteForMe,
  required AppLocalizations l10n,
}) {
  if (message.isFailed) {
    return [
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
        type: ChatMessageActionType.details,
        label: l10n.chatDetails,
        icon: Icons.info_outline_rounded,
      ),
    ];
  }

  if (message.isDeleted) {
    return [
      ChatMessageActionItem(
        type: ChatMessageActionType.details,
        label: l10n.chatDetails,
        icon: Icons.info_outline_rounded,
      ),
    ];
  }

  final actions = <ChatMessageActionItem>[
    ChatMessageActionItem(
      type: ChatMessageActionType.reply,
      label: l10n.chatReply,
      icon: Icons.reply_rounded,
    ),
  ];

  if (message.isVoice) {
    actions.addAll([
      ChatMessageActionItem(
        type: ChatMessageActionType.saveAudio,
        label: l10n.chatSave,
        icon: Icons.download_rounded,
      ),
      ChatMessageActionItem(
        type: ChatMessageActionType.share,
        label: l10n.chatShare,
        icon: Icons.ios_share_rounded,
      ),
    ]);
    if (message.hasCopyableText) {
      actions.add(
        ChatMessageActionItem(
          type: ChatMessageActionType.copyText,
          label: l10n.chatCopy,
          icon: Icons.copy_rounded,
        ),
      );
    }
  } else if (message.hasImage) {
    actions.addAll([
      ChatMessageActionItem(
        type: ChatMessageActionType.saveImage,
        label: l10n.chatSave,
        icon: Icons.download_rounded,
      ),
      ChatMessageActionItem(
        type: ChatMessageActionType.share,
        label: l10n.chatShare,
        icon: Icons.ios_share_rounded,
      ),
    ]);
    if (message.body.trim().isNotEmpty) {
      actions.add(
        ChatMessageActionItem(
          type: ChatMessageActionType.copyCaption,
          label: l10n.chatCopyCaption,
          icon: Icons.copy_rounded,
        ),
      );
    }
  } else if (message.hasCopyableText) {
    actions.addAll([
      ChatMessageActionItem(
        type: ChatMessageActionType.copyText,
        label: l10n.chatCopy,
        icon: Icons.copy_rounded,
      ),
      ChatMessageActionItem(
        type: ChatMessageActionType.share,
        label: l10n.chatShare,
        icon: Icons.ios_share_rounded,
      ),
    ]);
  }

  if (message.canEditFor(currentUserId)) {
    actions.add(
      ChatMessageActionItem(
        type: ChatMessageActionType.edit,
        label: l10n.chatEditMessage,
        icon: Icons.edit_rounded,
      ),
    );
  }

  if (canDeleteForEveryone || canDeleteForMe) {
    actions.add(
      ChatMessageActionItem(
        type: ChatMessageActionType.delete,
        label: l10n.chatDeleteMessage,
        icon: Icons.delete_outline_rounded,
        destructive: true,
      ),
    );
  }

  actions.addAll([
    ChatMessageActionItem(
      type: ChatMessageActionType.details,
      label: l10n.chatDetails,
      icon: Icons.info_outline_rounded,
    ),
    ChatMessageActionItem(
      type: ChatMessageActionType.cancel,
      label: l10n.cancel,
      icon: Icons.close_rounded,
    ),
  ]);

  return actions;
}

class _ChatMessageActionsSheet extends StatelessWidget {
  const _ChatMessageActionsSheet({
    required this.message,
    required this.isMe,
    required this.senderName,
    required this.actions,
  });

  final ChatMessage message;
  final bool isMe;
  final String senderName;
  final List<ChatMessageActionItem> actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final preview = previewTextForMessage(message, l10n);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
      decoration: BoxDecoration(
        color: PremiumColors.midnightMid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(PremiumRadii.xl)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, bottomInset + AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(PremiumRadii.pill),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: PremiumColors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(PremiumRadii.lg),
                  border: Border.all(color: PremiumColors.accentBlue.withValues(alpha: 0.22)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMe ? 'You' : senderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: PremiumColors.accentBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: PremiumColors.textPrimary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...actions.map(
                (action) => _ActionRow(
                  action: action,
                  onTap: action.enabled
                      ? () => Navigator.pop(context, ChatMessageActionResult(action.type))
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.action,
    required this.onTap,
  });

  final ChatMessageActionItem action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = !action.enabled
        ? PremiumColors.textMuted.withValues(alpha: 0.5)
        : action.destructive
            ? PremiumColors.errorRed
            : PremiumColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PremiumRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(action.icon, color: color, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  action.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessageDeleteSheet extends StatelessWidget {
  const _ChatMessageDeleteSheet({
    required this.isMe,
    required this.canDeleteForEveryone,
    required this.canDeleteForMe,
  });

  final bool isMe;
  final bool canDeleteForEveryone;
  final bool canDeleteForMe;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
      decoration: BoxDecoration(
        color: PremiumColors.midnightMid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(PremiumRadii.xl)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, bottomInset + AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.chatDeletePrompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (canDeleteForEveryone)
                _SheetButton(
                  label: l10n.chatDeleteForEveryone,
                  destructive: true,
                  onTap: () => Navigator.pop(context, ChatMessageDeleteChoice.forEveryone),
                ),
              if (canDeleteForMe)
                _SheetButton(
                  label: l10n.chatDeleteForMe,
                  destructive: canDeleteForEveryone,
                  onTap: () => Navigator.pop(context, ChatMessageDeleteChoice.forMe),
                ),
              const SizedBox(height: AppSpacing.xs),
              _SheetButton(
                label: l10n.cancel,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessageDetailsSheet extends StatelessWidget {
  const _ChatMessageDetailsSheet({
    required this.message,
    required this.isMe,
    required this.senderName,
  });

  final ChatMessage message;
  final bool isMe;
  final String senderName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final sentLabel = ChatRepository.formatMessageTime(message.sentAt);
    final typeLabel = _typeLabel(l10n, message);
    final statusLabel = _statusLabel(l10n, message);
    final voiceAttachment = message.voiceAttachment;
    ChatAttachment? imageAttachment;
    for (final attachment in message.attachments) {
      if (attachment.attachmentType == ChatAttachmentType.image) {
        imageAttachment = attachment;
        break;
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
      decoration: BoxDecoration(
        color: PremiumColors.midnightMid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(PremiumRadii.xl)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, bottomInset + AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.chatMessageDetails,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _DetailRow(label: l10n.chatDetailFrom, value: isMe ? l10n.chatYou : senderName),
              _DetailRow(label: l10n.chatDetailSent, value: sentLabel),
              _DetailRow(label: l10n.chatDetailType, value: typeLabel),
              _DetailRow(label: l10n.chatDetailStatus, value: statusLabel),
              if (message.attachments.isNotEmpty) ...[
                _DetailRow(
                  label: l10n.chatDetailFileType,
                  value: message.attachments.first.mimeType,
                ),
                if (message.attachments.first.sizeBytes > 0)
                  _DetailRow(
                    label: l10n.chatDetailSize,
                    value: _formatBytes(message.attachments.first.sizeBytes),
                  ),
              ],
              if (voiceAttachment != null && (voiceAttachment.durationMs ?? 0) > 0)
                _DetailRow(
                  label: l10n.chatDetailDuration,
                  value: _formatDuration(voiceAttachment.durationMs ?? 0),
                ),
              if (imageAttachment != null &&
                  imageAttachment.width != null &&
                  imageAttachment.height != null)
                _DetailRow(
                  label: l10n.chatDetailDimensions,
                  value: '${imageAttachment.width} × ${imageAttachment.height}',
                ),
              const SizedBox(height: AppSpacing.sm),
              _SheetButton(
                label: l10n.closeTooltip,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(AppLocalizations l10n, ChatMessage message) {
    if (message.isVoice) return l10n.chatVoiceMessage;
    if (message.hasImage && message.body.trim().isNotEmpty) return l10n.chatImageWithCaption;
    if (message.hasImage) return l10n.chatPhoto;
    return l10n.chatTypeText;
  }

  String _statusLabel(AppLocalizations l10n, ChatMessage message) {
    if (message.isDeleted) return l10n.chatMessageDeleted;
    if (message.isFailed) return l10n.chatFailedToSend;
    if (message.isEdited) return l10n.chatEdited;
    if (message.isPending) return l10n.chatStatusSending;
    return l10n.chatDetailSent;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDuration(int durationMs) {
    final totalSeconds = (durationMs / 1000).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                color: PremiumColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: PremiumColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: PremiumColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(PremiumRadii.lg),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: destructive ? PremiumColors.errorRed : PremiumColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> copyMessageText(BuildContext context, String text) async {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return;
  await Clipboard.setData(ClipboardData(text: trimmed));
  if (context.mounted) showCopiedFeedback(context);
}
