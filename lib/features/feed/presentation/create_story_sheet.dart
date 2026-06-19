import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../social/data/social_api_client.dart';
import '../domain/feed_story.dart';

Future<FeedStory?> showCreateStorySheet({
  required BuildContext context,
  required SocialApiClient client,
  required StoryUser ownStoryUser,
}) {
  return showModalBottomSheet<FeedStory>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CreateStorySheet(
      client: client,
      ownStoryUser: ownStoryUser,
    ),
  );
}

class _CreateStorySheet extends StatefulWidget {
  const _CreateStorySheet({
    required this.client,
    required this.ownStoryUser,
  });

  final SocialApiClient client;
  final StoryUser ownStoryUser;

  @override
  State<_CreateStorySheet> createState() => _CreateStorySheetState();
}

class _CreateStorySheetState extends State<_CreateStorySheet> {
  final _caption = TextEditingController();
  final _picker = ImagePicker();
  XFile? _image;
  Uint8List? _previewBytes;
  var _picking = false;
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _picking = true;
      _error = null;
    });
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _publish() async {
    final image = _image;
    if (image == null) {
      setState(() => _error = 'Add a photo for your story.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final story = await widget.client.createStory(
        image: image,
        caption: _caption.text,
        ownStoryUser: widget.ownStoryUser,
      );
      if (mounted) Navigator.pop(context, story);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString();
      });
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
                        'New story',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
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
                  onTap: _picking || _saving ? null : () => _pickImage(ImageSource.gallery),
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: PremiumColors.midnightBottom,
                        borderRadius: BorderRadius.circular(PremiumRadii.lg),
                        border: Border.all(color: PremiumColors.glassBorder),
                      ),
                      clipBehavior: Clip.antiAlias,
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
                                  _picking ? 'Opening gallery...' : 'Tap to add photo',
                                  style: const TextStyle(color: PremiumColors.textMuted),
                                ),
                              ],
                            )
                          : Image.memory(_previewBytes!, fit: BoxFit.cover, width: double.infinity),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _picking || _saving ? null : () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Gallery'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _picking || _saving ? null : () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Camera'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _caption,
                  maxLines: 2,
                  minLines: 1,
                  enabled: !_saving,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a caption (optional)',
                    hintStyle: const TextStyle(color: PremiumColors.textMuted),
                    filled: true,
                    fillColor: PremiumColors.midnightBottom,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PremiumRadii.lg),
                      borderSide: const BorderSide(color: PremiumColors.glassBorder),
                    ),
                  ),
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
                      : const Text('Share story'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
