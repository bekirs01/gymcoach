import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/premium_tokens.dart';

enum ChatAttachmentSource {
  gallery,
  camera,
}

Future<ChatAttachmentSource?> showChatAttachmentPickerSheet(BuildContext context) {
  return showModalBottomSheet<ChatAttachmentSource>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
          child: Material(
            color: PremiumColors.surface,
            borderRadius: BorderRadius.circular(PremiumRadii.xl),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(PremiumRadii.pill),
                    ),
                  ),
                  _AttachmentActionTile(
                    icon: Icons.photo_library_rounded,
                    label: l10n.chatChooseGallery,
                    onTap: () => Navigator.pop(context, ChatAttachmentSource.gallery),
                  ),
                  _AttachmentActionTile(
                    icon: Icons.photo_camera_rounded,
                    label: l10n.chatTakePhoto,
                    onTap: () => Navigator.pop(context, ChatAttachmentSource.camera),
                  ),
                  const Divider(height: 1, color: Color(0x14FFFFFF)),
                  _AttachmentActionTile(
                    icon: Icons.close_rounded,
                    label: l10n.cancel,
                    muted: true,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<XFile?> pickChatImage(ImagePicker picker, ChatAttachmentSource source) {
  final imageSource = source == ChatAttachmentSource.camera ? ImageSource.camera : ImageSource.gallery;
  return picker.pickImage(
    source: imageSource,
    imageQuality: 86,
    maxWidth: 1600,
  );
}

class _AttachmentActionTile extends StatelessWidget {
  const _AttachmentActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: muted
                      ? PremiumColors.surfaceRaised
                      : PremiumColors.accentBlue.withValues(alpha: 0.16),
                  border: Border.all(
                    color: muted
                        ? Colors.white.withValues(alpha: 0.08)
                        : PremiumColors.accentBlue.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  icon,
                  color: muted ? PremiumColors.textMuted : PremiumColors.accentBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: muted ? PremiumColors.textSecondary : Colors.white,
                    fontSize: 16,
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
