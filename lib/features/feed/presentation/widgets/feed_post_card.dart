import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../../../app/widgets/premium_image_viewer.dart';
import '../../../workout_share/presentation/widgets/workout_share_post_card.dart';
import '../../../social/data/social_api_client.dart';
import '../../../social/domain/feed_comment.dart';
import '../../../social/domain/feed_post.dart';
import '../../../social/domain/social_profile.dart';
import 'network_image_with_fallback.dart';
import '../social_avatar.dart';

class SeededFeedPostCard extends StatefulWidget {
  const SeededFeedPostCard({
    super.key,
    required this.post,
    required this.currentUser,
    required this.onChanged,
    this.onOpenProfile,
  });

  final FeedPost post;
  final SocialProfile currentUser;
  final ValueChanged<FeedPost> onChanged;
  final VoidCallback? onOpenProfile;

  @override
  State<SeededFeedPostCard> createState() => _SeededFeedPostCardState();
}

class _SeededFeedPostCardState extends State<SeededFeedPostCard> {
  late bool _liked;
  late int _likeCount;
  late bool _saved;

  @override
  void initState() {
    super.initState();
    _liked = widget.post.likedByMe;
    _likeCount = widget.post.likeCount;
    _saved = false;
  }

  @override
  void didUpdateWidget(covariant SeededFeedPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _liked = widget.post.likedByMe;
      _likeCount = widget.post.likeCount;
      _saved = false;
    }
  }

  void _toggleLike() {
    final next = !_liked;
    setState(() {
      _liked = next;
      _likeCount = (_likeCount + (next ? 1 : -1)).clamp(0, 999999);
    });
    widget.onChanged(
      widget.post.copyWith(
        likedByMe: _liked,
        likeCount: _likeCount,
      ),
    );
  }

  void _toggleSave() {
    setState(() => _saved = !_saved);
  }

  Future<void> _openComments() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(
        post: widget.post,
        currentUser: widget.currentUser,
        onCommentsChanged: (comments) {
          widget.onChanged(
            widget.post.copyWith(
              comments: comments,
              commentCount: comments.length,
              likedByMe: _liked,
              likeCount: _likeCount,
            ),
          );
        },
      ),
    );
  }

  String _relative(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inHours < 48) return 'yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final displayName = post.author.displayName.isEmpty ? 'Athlete' : post.author.displayName;
    final imageUrl = post.media.isNotEmpty ? post.media.first.url : '';

    return _FeedPostShell(
      userName: displayName,
      avatarUrl: post.author.avatarUrl,
      timeLabel: _relative(post.createdAt),
      imageUrl: imageUrl,
      caption: post.caption,
      liked: _liked,
      saved: _saved,
      likeCount: _likeCount,
      commentCount: post.comments.length,
      onLike: _toggleLike,
      onSave: _toggleSave,
      onComment: () => _openComments(),
      onMenu: () {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.feedPostOptions),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onCommentFieldTap: () => _openComments(),
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
    required this.currentUser,
    required this.onOpenProfile,
    required this.onPostChanged,
    required this.onPostRemoved,
    this.onCopyWorkout,
    this.checkWorkoutCopied,
  });

  final FeedPost post;
  final SocialApiClient client;
  final SocialProfile currentUser;
  final ValueChanged<FeedPost> onOpenProfile;
  final ValueChanged<FeedPost> onPostChanged;
  final ValueChanged<String> onPostRemoved;
  final Future<bool> Function(FeedPost post)? onCopyWorkout;
  final Future<bool> Function(String postId)? checkWorkoutCopied;

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
  var _copying = false;
  var _alreadyCopied = false;

  @override
  void initState() {
    super.initState();
    _likedByMe = widget.post.likedByMe;
    _likeCount = widget.post.likeCount;
    _commentCount = widget.post.comments.length;
    _savedByMe = widget.client.isPostSaved(widget.post.id);
    unawaited(_loadCopyState());
  }

  Future<void> _loadCopyState() async {
    final checker = widget.checkWorkoutCopied;
    if (checker == null || !widget.post.isWorkoutShare) return;
    final copied = await checker(widget.post.id);
    if (mounted) setState(() => _alreadyCopied = copied);
  }

  Future<void> _copyWorkout() async {
    final handler = widget.onCopyWorkout;
    if (handler == null || _copying || _alreadyCopied) return;
    setState(() => _copying = true);
    try {
      final copied = await handler(widget.post);
      if (!mounted) return;
      setState(() {
        _copying = false;
        _alreadyCopied = copied;
      });
    } catch (_) {
      if (mounted) setState(() => _copying = false);
    }
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
        currentUser: widget.currentUser,
        onCommentsChanged: (comments) {
          setState(() => _commentCount = comments.length);
          widget.onPostChanged(
            widget.post.copyWith(
              likedByMe: _likedByMe,
              likeCount: _likeCount,
              comments: comments,
              commentCount: comments.length,
            ),
          );
        },
      ),
    );
  }

  Future<void> _menu() async {
    final current = await widget.client.currentUserId();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
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
                title: Text(l10n.feedDeletePost, style: const TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, 'delete'),
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.block_rounded, color: Colors.redAccent),
                title: Text(l10n.feedBlockUser, style: const TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, 'block'),
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: PremiumColors.textSecondary),
                title: Text(l10n.feedReportPost, style: const TextStyle(color: Colors.white)),
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
    final snapshot = post.sharedWorkoutSnapshot;
    final isWorkoutShare = post.isWorkoutShare && snapshot != null;

    return _FeedPostShell(
      userName: displayName,
      avatarUrl: post.author.avatarUrl,
      timeLabel: _relative(post.createdAt),
      imageUrl: isWorkoutShare ? '' : imageUrl,
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
      captionBeforeMedia: isWorkoutShare,
      mediaChild: isWorkoutShare
          ? WorkoutSharePostCard(
              snapshot: snapshot,
              onCopy: widget.onCopyWorkout == null ? null : _copyWorkout,
              copying: _copying,
              alreadyCopied: _alreadyCopied,
            )
          : post.media.isEmpty
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
                      final media = post.media[i];
                      final url = media.url;
                      return GestureDetector(
                        onTap: url.isNotEmpty
                            ? () => showPremiumImageViewer(context, imageUrl: url)
                            : null,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            NetworkImageWithFallback(
                              url: url,
                              localPath: media.localPath,
                              fit: BoxFit.cover,
                            ),
                            if (post.isPendingUpload)
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Icon(
                                  Icons.schedule_rounded,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                          ],
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
    this.captionBeforeMedia = false,
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
  final bool captionBeforeMedia;

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
          if (captionBeforeMedia && caption.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(
                caption,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.35,
                  fontSize: 14,
                ),
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
                if (!captionBeforeMedia && caption.trim().isNotEmpty) ...[
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
          likeLabel,
          style: const TextStyle(
            color: PremiumColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        if (commentCount > 0) ...[
          const Text(
            ' · ',
            style: TextStyle(
              color: PremiumColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          GestureDetector(
            onTap: onComment,
            behavior: HitTestBehavior.opaque,
            child: Text(
              commentCount == 1 ? '1 comment' : '$commentCount comments',
              style: const TextStyle(
                color: PremiumColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
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
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.feedAddComment,
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
    this.client,
    this.currentUser,
    required this.onCommentsChanged,
  });

  final FeedPost post;
  final SocialApiClient? client;
  final SocialProfile? currentUser;
  final ValueChanged<List<FeedComment>> onCommentsChanged;

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

  String _relative(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inHours < 48) return 'yesterday';
    return '${diff.inDays}d ago';
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    final client = widget.client;
    if (client != null) {
      setState(() => _sending = true);
      final comment = await client.addComment(widget.post.id, text);
      if (!mounted) return;
      setState(() {
        _comments.add(comment);
        _controller.clear();
        _sending = false;
      });
      widget.onCommentsChanged(List<FeedComment>.from(_comments));
      return;
    }

    final author = widget.currentUser;
    if (author == null) return;

    final comment = FeedComment(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      postId: widget.post.id,
      userId: author.userId,
      body: text,
      createdAt: DateTime.now(),
      author: author,
    );
    setState(() {
      _comments.add(comment);
      _controller.clear();
    });
    widget.onCommentsChanged(List<FeedComment>.from(_comments));
  }

  @override
  Widget build(BuildContext context) {
    final inputUser = widget.currentUser;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: PremiumColors.midnightBottom,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(PremiumRadii.xl)),
            border: Border.all(color: PremiumColors.glassBorder),
          ),
          child: Material(
            color: Colors.transparent,
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
                    child: _comments.isEmpty
                        ? const Center(
                            child: Text(
                              'No comments yet',
                              style: TextStyle(
                                color: PremiumColors.textMuted,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _comments.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 14),
                            itemBuilder: (context, i) {
                              final c = _comments[i];
                              final name = c.author.displayName.isEmpty ? 'Athlete' : c.author.displayName;
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SocialAvatar(name: name, imageUrl: c.author.avatarUrl, size: 34),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _relative(c.createdAt),
                                              style: const TextStyle(
                                                color: PremiumColors.textMuted,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          c.body,
                                          style: const TextStyle(
                                            color: PremiumColors.textSecondary,
                                            height: 1.35,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 12),
                    child: Row(
                      children: [
                        if (inputUser != null) ...[
                          SocialAvatar(
                            name: inputUser.displayName.isEmpty ? 'You' : inputUser.displayName,
                            imageUrl: inputUser.avatarUrl,
                            size: 34,
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.feedAddComment,
                              hintStyle: const TextStyle(color: PremiumColors.textMuted),
                              filled: true,
                              fillColor: PremiumColors.surface.withValues(alpha: 0.65),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(PremiumRadii.pill),
                                borderSide: BorderSide(color: PremiumColors.glassBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(PremiumRadii.pill),
                                borderSide: BorderSide(
                                  color: PremiumColors.accentBlue.withValues(alpha: 0.45),
                                ),
                              ),
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        const SizedBox(width: 4),
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
          ),
        );
      },
    );
  }
}
