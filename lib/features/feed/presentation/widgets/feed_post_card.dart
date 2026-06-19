import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../../../app/widgets/premium_image_viewer.dart';
import '../../../social/data/social_api_client.dart';
import '../../../social/domain/feed_comment.dart';
import '../../../social/domain/feed_post.dart';
import '../../data/feed_demo_data.dart';
import 'network_image_with_fallback.dart';
import '../social_avatar.dart';

class DemoFeedPostCard extends StatefulWidget {
  const DemoFeedPostCard({
    super.key,
    required this.post,
    required this.onChanged,
    this.onOpenProfile,
  });

  final DemoFeedPost post;
  final ValueChanged<DemoFeedPost> onChanged;
  final VoidCallback? onOpenProfile;

  @override
  State<DemoFeedPostCard> createState() => _DemoFeedPostCardState();
}

class _DemoFeedPostCardState extends State<DemoFeedPostCard> {
  void _toggleLike() {
    final next = !widget.post.liked;
    widget.onChanged(
      widget.post.copyWith(
        liked: next,
        likeCount: (widget.post.likeCount + (next ? 1 : -1)).clamp(0, 999999),
      ),
    );
  }

  void _toggleSave() {
    widget.onChanged(widget.post.copyWith(saved: !widget.post.saved));
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return _FeedPostShell(
      userName: post.userName,
      avatarUrl: post.avatarUrl,
      timeLabel: post.timeLabel,
      imageUrl: post.imageUrl,
      caption: post.caption,
      liked: post.liked,
      saved: post.saved,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      onLike: _toggleLike,
      onSave: _toggleSave,
      onComment: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comments coming soon'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onMenu: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post options'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onCommentFieldTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comments coming soon'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onAvatarTap: widget.onOpenProfile,
      onHeaderTap: widget.onOpenProfile,
    );
  }
}

class ApiFeedPostCard extends StatefulWidget {
  const ApiFeedPostCard({
    super.key,
    required this.post,
    required this.client,
    required this.onOpenProfile,
    required this.onPostChanged,
    required this.onPostRemoved,
  });

  final FeedPost post;
  final SocialApiClient client;
  final ValueChanged<FeedPost> onOpenProfile;
  final ValueChanged<FeedPost> onPostChanged;
  final ValueChanged<String> onPostRemoved;

  @override
  State<ApiFeedPostCard> createState() => _ApiFeedPostCardState();
}

class _ApiFeedPostCardState extends State<ApiFeedPostCard> {
  var _photoIndex = 0;
  late bool _likedByMe;
  late int _likeCount;
  late int _commentCount;
  late bool _savedByMe;
  var _liking = false;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _likedByMe = widget.post.likedByMe;
    _likeCount = widget.post.likeCount;
    _commentCount = widget.post.commentCount;
    _savedByMe = widget.client.isPostSaved(widget.post.id);
  }

  void _setLiked(bool value) {
    setState(() {
      _likedByMe = value;
      _likeCount = (_likeCount + (value ? 1 : -1)).clamp(0, 999999);
    });
    widget.onPostChanged(
      widget.post.copyWith(
        likedByMe: _likedByMe,
        likeCount: _likeCount,
        commentCount: _commentCount,
      ),
    );
  }

  Future<void> _toggleLike() async {
    if (_liking) return;
    final wasLiked = _likedByMe;
    final next = !wasLiked;
    _setLiked(next);
    _liking = true;
    try {
      await widget.client.toggleLike(widget.post.copyWith(likedByMe: wasLiked));
    } catch (_) {
      _setLiked(wasLiked);
    } finally {
      _liking = false;
    }
  }

  Future<void> _toggleSave() async {
    if (_saving) return;
    final wasSaved = _savedByMe;
    final next = !wasSaved;
    setState(() {
      _savedByMe = next;
      _saving = true;
    });
    try {
      final saved = await widget.client.toggleSavePost(
        widget.post.copyWith(
          likedByMe: _likedByMe,
          likeCount: _likeCount,
          commentCount: _commentCount,
        ),
      );
      if (!mounted) return;
      setState(() => _savedByMe = saved);
    } catch (_) {
      if (mounted) setState(() => _savedByMe = wasSaved);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openComments() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(
        post: widget.post,
        client: widget.client,
        onCommentAdded: () {
          setState(() => _commentCount += 1);
          widget.onPostChanged(
            widget.post.copyWith(
              likedByMe: _likedByMe,
              likeCount: _likeCount,
              commentCount: _commentCount,
            ),
          );
        },
      ),
    );
  }

  Future<void> _menu() async {
    final current = await widget.client.currentUserId();
    if (!mounted) return;
    final isMine = current == widget.post.userId;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: PremiumColors.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMine)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                title: const Text('Delete post', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, 'delete'),
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.block_rounded, color: Colors.redAccent),
                title: const Text('Block user', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, 'block'),
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: PremiumColors.textSecondary),
                title: const Text('Report post', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, 'report'),
              ),
            ],
          ],
        ),
      ),
    );
    if (action == 'delete') {
      await widget.client.deletePost(widget.post.id);
      widget.onPostRemoved(widget.post.id);
      return;
    }
    if (action == 'block') {
      await widget.client.blockUser(widget.post.userId);
      widget.onPostRemoved(widget.post.id);
      return;
    }
    if (action == 'report') {
      await widget.client.reportPost(postId: widget.post.id, userId: widget.post.userId);
    }
  }

  String _relative(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post.copyWith(
      likedByMe: _likedByMe,
      likeCount: _likeCount,
      commentCount: _commentCount,
    );
    final displayName = post.author.displayName.isEmpty ? 'Athlete' : post.author.displayName;
    final imageUrl = post.media.isNotEmpty ? post.media[_photoIndex].url : '';

    return _FeedPostShell(
      userName: displayName,
      avatarUrl: post.author.avatarUrl,
      timeLabel: _relative(post.createdAt),
      imageUrl: imageUrl,
      caption: post.caption,
      liked: _likedByMe,
      saved: _savedByMe,
      likeCount: _likeCount,
      commentCount: _commentCount,
      onLike: _toggleLike,
      onSave: _saving ? null : _toggleSave,
      onComment: _openComments,
      onMenu: _menu,
      onCommentFieldTap: _openComments,
      onAvatarTap: () => widget.onOpenProfile(post),
      onHeaderTap: () => widget.onOpenProfile(post),
      mediaChild: post.media.isEmpty
          ? null
          : AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: post.media.length,
                    onPageChanged: (i) => setState(() => _photoIndex = i),
                    itemBuilder: (context, i) {
                      final url = post.media[i].url;
                      return GestureDetector(
                        onTap: () => showPremiumImageViewer(context, imageUrl: url),
                        child: NetworkImageWithFallback(
                          url: url,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                  if (post.media.length > 1)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(PremiumRadii.pill),
                        ),
                        child: Text(
                          '${_photoIndex + 1}/${post.media.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _FeedPostShell extends StatelessWidget {
  const _FeedPostShell({
    required this.userName,
    required this.avatarUrl,
    required this.timeLabel,
    required this.imageUrl,
    required this.caption,
    required this.liked,
    required this.saved,
    required this.likeCount,
    this.commentCount = 0,
    required this.onLike,
    required this.onSave,
    required this.onComment,
    required this.onMenu,
    required this.onCommentFieldTap,
    this.onAvatarTap,
    this.onHeaderTap,
    this.mediaChild,
  });

  final String userName;
  final String avatarUrl;
  final String timeLabel;
  final String imageUrl;
  final String caption;
  final bool liked;
  final bool saved;
  final int likeCount;
  final int commentCount;
  final VoidCallback onLike;
  final VoidCallback? onSave;
  final VoidCallback onComment;
  final VoidCallback onMenu;
  final VoidCallback onCommentFieldTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onHeaderTap;
  final Widget? mediaChild;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.xl),
        border: Border.all(color: PremiumColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: PremiumColors.accentBlue.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 4, 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onAvatarTap,
                  child: SocialAvatar(name: userName, imageUrl: avatarUrl, size: 40),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onHeaderTap,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          timeLabel,
                          style: const TextStyle(
                            color: PremiumColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onMenu,
                  icon: const Icon(Icons.more_horiz_rounded, color: PremiumColors.textSecondary),
                ),
              ],
            ),
          ),
          if (mediaChild != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(PremiumRadii.lg),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: mediaChild,
              ),
            )
          else if (imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(PremiumRadii.lg),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: NetworkImageWithFallback(
                    url: imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeedActionRow(
                  liked: liked,
                  saved: saved,
                  likeCount: likeCount,
                  commentCount: commentCount,
                  onLike: onLike,
                  onComment: onComment,
                  onSave: onSave,
                ),
                if (caption.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    caption,
                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.35,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                FeedCommentField(onTap: onCommentFieldTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeedActionRow extends StatelessWidget {
  const FeedActionRow({
    super.key,
    required this.liked,
    required this.saved,
    required this.likeCount,
    required this.onLike,
    required this.onComment,
    this.commentCount = 0,
    this.onSave,
  });

  final bool liked;
  final bool saved;
  final int likeCount;
  final int commentCount;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final likeLabel = likeCount == 1 ? '1 like' : '$likeCount likes';
    final meta = commentCount > 0 ? '$likeLabel · $commentCount comments' : likeLabel;

    return Row(
      children: [
        _ActionIcon(
          icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: liked ? const Color(0xFFFF4D6D) : Colors.white,
          onTap: onLike,
        ),
        _ActionIcon(
          icon: Icons.mode_comment_outlined,
          color: Colors.white,
          onTap: onComment,
        ),
        _ActionIcon(
          icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          color: saved ? PremiumColors.accentBlue : Colors.white,
          onTap: onSave,
        ),
        const Spacer(),
        Text(
          meta,
          style: const TextStyle(
            color: PremiumColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PremiumRadii.sm),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}

class FeedCommentField extends StatelessWidget {
  const FeedCommentField({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        decoration: BoxDecoration(
          color: PremiumColors.midnightBottom,
          borderRadius: BorderRadius.circular(PremiumRadii.pill),
          border: Border.all(color: PremiumColors.glassBorder),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Add a comment...',
                style: TextStyle(
                  color: PremiumColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumColors.accentBlue.withValues(alpha: 0.25),
                border: Border.all(
                  color: PremiumColors.accentBlue.withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                size: 16,
                color: PremiumColors.accentBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({
    required this.post,
    required this.client,
    required this.onCommentAdded,
  });

  final FeedPost post;
  final SocialApiClient client;
  final VoidCallback onCommentAdded;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();
  late final List<FeedComment> _comments = List<FeedComment>.from(widget.post.comments);
  var _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    final comment = await widget.client.addComment(widget.post.id, text);
    if (!mounted) return;
    setState(() {
      _comments.add(comment);
      _controller.clear();
      _sending = false;
    });
    widget.onCommentAdded();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Material(
          color: PremiumColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(PremiumRadii.xl)),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PremiumColors.glassBorder,
                    borderRadius: BorderRadius.circular(PremiumRadii.pill),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Comments',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _comments.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final c = _comments[i];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SocialAvatar(name: c.author.displayName, imageUrl: c.author.avatarUrl, size: 34),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.author.displayName.isEmpty ? 'Athlete' : c.author.displayName,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                                Text(c.body, style: const TextStyle(color: PremiumColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.viewInsetsOf(context).bottom + 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            hintStyle: const TextStyle(color: PremiumColors.textMuted),
                            filled: true,
                            fillColor: PremiumColors.midnightBottom,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(PremiumRadii.pill),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _sending ? null : _send,
                        icon: const Icon(Icons.send_rounded, color: PremiumColors.accentBlue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
