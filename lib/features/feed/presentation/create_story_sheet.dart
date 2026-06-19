import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/premium_tokens.dart';
import '../domain/feed_story.dart';

Future<FeedStory?> showCreateStorySheet({
  required BuildContext context,
  required StoryUser ownStoryUser,
}) {
  return showModalBottomSheet<FeedStory>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CreateStorySheet(ownStoryUser: ownStoryUser),
  );
}

class _CreateStorySheet extends StatefulWidget {
  const _CreateStorySheet({required this.ownStoryUser});

  final StoryUser ownStoryUser;

  @override
  State<_CreateStorySheet> createState() => _CreateStorySheetState();
}

class _CreateStorySheetState extends State<_CreateStorySheet> {
  final _picker = ImagePicker();
  Uint8List? _imageBytes;
  var _picking = false;

  Future<void> _pickImage() async {
    setState(() => _picking = true);
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 86, maxWidth: 1400);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() => _imageBytes = bytes);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _publish() {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a photo for your story'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      FeedStory(
        id: 'own_${DateTime.now().millisecondsSinceEpoch}',
        user: widget.ownStoryUser,
        slides: [FeedStorySlide(imageBytes: _imageBytes)],
      ),
    );
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
                        'New story',
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
                const Text(
                  'Pick one photo to share as your story.',
                  style: TextStyle(color: PremiumColors.textSecondary),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _picking ? null : _pickImage,
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: PremiumColors.midnightBottom,
                        borderRadius: BorderRadius.circular(PremiumRadii.lg),
                        border: Border.all(color: PremiumColors.glassBorder),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _imageBytes == null
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
                                  _picking ? 'Opening gallery...' : 'Tap to add photo',
                                  style: const TextStyle(color: PremiumColors.textMuted),
                                ),
                              ],
                            )
                          : Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _picking ? null : _publish,
                  child: const Text('Share story'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
