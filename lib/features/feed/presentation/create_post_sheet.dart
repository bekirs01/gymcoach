import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../core/offline/offline_sync_service.dart';
import '../../../core/offline/outbox_media_store.dart';
import '../../profile/domain/user_profile.dart';
import '../../social/data/social_api_client.dart';
import '../../social/domain/feed_media.dart';
import '../../social/domain/feed_post.dart';
import '../../social/domain/social_profile.dart';

Future<FeedPost?> showCreatePostSheet({
  required BuildContext context,
  required SocialApiClient client,
  required UserProfile profile,
  OfflineSyncService? offlineSync,
}) {
  return showModalBottomSheet<FeedPost>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CreatePostSheet(
      client: client,
      profile: profile,
      offlineSync: offlineSync,
    ),
  );
}

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet({
    required this.client,
    required this.profile,
    this.offlineSync,
  });

  final SocialApiClient client;
  final UserProfile profile;
  final OfflineSyncService? offlineSync;

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  static const _uuid = Uuid();

  final _caption = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _images = [];
  var _saving = false;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 86, maxWidth: 1600);
    if (picked.isEmpty) return;
    setState(() {
      _images
        ..clear()
        ..addAll(picked.take(8));
    });
  }

  Future<void> _publish() async {
    if (_caption.text.trim().isEmpty && _images.isEmpty) return;
    setState(() => _saving = true);

    try {
      final userId = await widget.client.currentUserId();
      final localId = _uuid.v4();
      final postId = 'post_$localId';
      final author = SocialProfile(
        userId: userId,
        displayName: widget.profile.displayName,
        bio: widget.profile.publicBio,
        privateNotes: widget.profile.privateNotes,
        avatarUrl: widget.profile.avatarUrl,
        coverUrl: widget.profile.coverUrl,
        isPublic: widget.profile.isPublicProfile,
      );

      final localMediaPaths = <String>[];
      final media = <FeedMedia>[];
      final mediaStore = OutboxMediaStore.instance;
      for (var i = 0; i < _images.length; i++) {
        final image = _images[i];
        final bytes = await image.readAsBytes();
        final path = await mediaStore.saveBytes(
          bytes: bytes,
          extension: mediaStore.extensionFromName(image.name, fallback: 'jpg'),
        );
        localMediaPaths.add(path);
        media.add(
          FeedMedia(
            id: '${postId}_media_$i',
            postId: postId,
            url: '',
            path: path,
            sortOrder: i,
            localPath: path,
          ),
        );
      }

      final post = FeedPost(
        id: postId,
        localId: localId,
        userId: userId,
        caption: _caption.text.trim(),
        createdAt: DateTime.now(),
        author: author,
        media: media,
        comments: const [],
        likeCount: 0,
        commentCount: 0,
        likedByMe: false,
        isPendingUpload: true,
        localMediaPaths: localMediaPaths,
      );

      final sync = widget.offlineSync ?? OfflineSyncService.instance;
      if (sync != null) {
        await sync.enqueueFeedPost(post: post, localMediaPaths: localMediaPaths);
      } else {
        await widget.client.createPost(caption: _caption.text, images: _images);
      }

      if (mounted) Navigator.pop(context, post);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Material(
        color: PremiumColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(PremiumRadii.xl)),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'New post',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: PremiumColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _caption,
                  maxLines: 4,
                  minLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Share your workout, progress or thoughts...',
                    hintStyle: const TextStyle(color: PremiumColors.textMuted),
                    filled: true,
                    fillColor: PremiumColors.midnightBottom,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PremiumRadii.lg),
                      borderSide: const BorderSide(color: PremiumColors.glassBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_images.isNotEmpty)
                  SizedBox(
                    height: 86,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        return FutureBuilder<Widget>(
                          future: _thumb(_images[i]),
                          builder: (context, snap) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(PremiumRadii.md),
                              child: SizedBox(
                                width: 86,
                                height: 86,
                                child: snap.data ?? const ColoredBox(color: PremiumColors.midnightBottom),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _pickImages,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(_images.isEmpty ? 'Add photos' : '${_images.length} selected'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: _saving ? null : _publish,
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(AppLocalizations.of(context)!.feedPublish),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Widget> _thumb(XFile file) async {
    final bytes = await file.readAsBytes();
    return Image.memory(bytes, fit: BoxFit.cover);
  }
}
