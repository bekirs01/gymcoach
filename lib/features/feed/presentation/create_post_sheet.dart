import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../social/data/social_api_client.dart';

Future<bool?> showCreatePostSheet({
  required BuildContext context,
  required SocialApiClient client,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CreatePostSheet(client: client),
  );
}

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet({required this.client});

  final SocialApiClient client;

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _caption = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _images = [];
  var _saving = false;
  String? _error;

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
      _error = null;
    });
  }

  Future<void> _publish() async {
    if (_caption.text.trim().isEmpty && _images.isEmpty) {
      setState(() => _error = 'Add text or at least one photo.');
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.client.createPost(caption: _caption.text, images: _images);
      if (mounted) Navigator.pop(context, true);
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
                        'New post',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context, false),
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
                          : const Text('Publish'),
                    ),
                  ],
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

  Future<Widget> _thumb(XFile file) async {
    final bytes = await file.readAsBytes();
    return Image.memory(bytes, fit: BoxFit.cover);
  }
}
