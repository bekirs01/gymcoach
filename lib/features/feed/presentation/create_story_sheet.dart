import 'dart:typed_data';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../core/offline/offline_sync_service.dart';
import '../../../core/offline/outbox_media_store.dart';
import '../../social/data/social_api_client.dart';
import '../domain/feed_story.dart';

Future<FeedStory?> showCreateStorySheet({
  required BuildContext context,
  required SocialApiClient client,
  required StoryUser ownStoryUser,
  OfflineSyncService? offlineSync,
}) {
  return showModalBottomSheet<FeedStory>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CreateStorySheet(
      client: client,
      ownStoryUser: ownStoryUser,
      offlineSync: offlineSync,
    ),
  );
}

class _CreateStorySheet extends StatefulWidget {
  const _CreateStorySheet({
    required this.client,
    required this.ownStoryUser,
    this.offlineSync,
  });

  final SocialApiClient client;
  final StoryUser ownStoryUser;
  final OfflineSyncService? offlineSync;

  @override
  State<_CreateStorySheet> createState() => _CreateStorySheetState();
}

class _CreateStorySheetState extends State<_CreateStorySheet> {
  static const _uuid = Uuid();

  final _picker = ImagePicker();
  XFile? _image;
  Uint8List? _previewBytes;
  var _picking = false;
  var _saving = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _picking = true);
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 86,
        maxWidth: 1400,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _image = picked;
        _previewBytes = bytes;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _publish() async {
    final image = _image;
    final bytes = _previewBytes;
    if (image == null || bytes == null) return;
    setState(() => _saving = true);

    try {
      final localId = _uuid.v4();
      final mediaStore = OutboxMediaStore.instance;
      final localPath = await mediaStore.saveBytes(
        bytes: bytes,
        extension: mediaStore.extensionFromName(image.name, fallback: 'jpg'),
      );

      final story = FeedStory(
        id: 'story_${widget.ownStoryUser.id}',
        localId: localId,
        user: widget.ownStoryUser,
        slides: [FeedStorySlide(imageBytes: bytes, localPath: localPath)],
        latestAt: DateTime.now(),
        isPendingUpload: true,
      );

      final sync = widget.offlineSync ?? OfflineSyncService.instance;
      if (sync != null) {
        await sync.enqueueStory(story: story, localMediaPath: localPath);
        if (mounted) Navigator.pop(context, story);
        return;
      }

      final remoteStory = await widget.client.createStory(
        image: image,
        ownStoryUser: widget.ownStoryUser,
      );
      if (mounted) Navigator.pop(context, remoteStory);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  double _previewHeight(BuildContext context) {
    final media = MediaQuery.of(context);
    final sheetHeight = media.size.height * 0.92;
    const controlsHeight = 200.0;
    final available = sheetHeight - media.padding.bottom - controlsHeight;
    return available.clamp(160.0, media.size.height * 0.48);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom;
    final sheetHeight = media.size.height * 0.92;
    final hasImage = _previewBytes != null;
    final previewHeight = hasImage ? _previewHeight(context) : 176.0;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: sheetHeight,
        child: Material(
          color: PremiumColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(PremiumRadii.xl)),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.feedStoryTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: _saving ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: PremiumColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.feedStoryHint,
                    style: const TextStyle(color: PremiumColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _picking || _saving ? null : () => _pickImage(ImageSource.gallery),
                    child: SizedBox(
                      height: previewHeight,
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: PremiumColors.midnightBottom,
                          borderRadius: BorderRadius.circular(PremiumRadii.lg),
                          border: Border.all(color: PremiumColors.glassBorder),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(PremiumRadii.lg),
                          child: _previewBytes == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 42,
                                      color: PremiumColors.accentBlue.withValues(alpha: 0.85),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _picking ? l10n.feedOpeningGallery : l10n.feedTapAddPhoto,
                                      style: const TextStyle(color: PremiumColors.textMuted),
                                    ),
                                  ],
                                )
                              : _StoryPreviewImage(bytes: _previewBytes!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _picking || _saving ? null : () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined, size: 18),
                          label: Text(l10n.feedGallery, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _picking || _saving ? null : () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.photo_camera_outlined, size: 18),
                          label: Text(l10n.feedCamera, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: _picking || _saving ? null : _publish,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.feedShareStory),
                  ),
                  SizedBox(height: bottomInset > 0 ? 8 : 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryPreviewImage extends StatelessWidget {
  const _StoryPreviewImage({required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Transform.scale(
            scale: 1.12,
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                PremiumColors.midnightTop.withValues(alpha: 0.68),
                Colors.black.withValues(alpha: 0.52),
              ],
            ),
          ),
        ),
        Center(
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
