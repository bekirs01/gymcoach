import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/floating_tab_bar.dart';
import '../../../app/widgets/premium_background.dart';
import '../../profile/domain/user_profile.dart';
import '../../profile/presentation/public_profile_page.dart';
import '../../social/data/social_api_client.dart';
import '../../social/domain/feed_comment.dart';
import '../../social/domain/feed_post.dart';
import 'create_post_sheet.dart';
import 'social_avatar.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  SocialApiClient? _client;
  var _loading = true;
  String? _error;
  List<FeedPost> _posts = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final client = SocialApiClient(prefs: prefs);
      await client.ensureProfile(widget.profile);
      if (!mounted) return;
      setState(() => _client = client);
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _load() async {
    final client = _client;
    if (client == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final posts = await client.fetchFeed();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _createPost() async {
    final client = _client;
    if (client == null) return;
    final created = await showCreatePostSheet(context: context, client: client);
    if (created == true) await _load();
  }

  void _openProfile(FeedPost post) {
    final client = _client;
    if (client == null) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PublicProfilePage(
          userId: post.userId,
          client: client,
          currentProfile: widget.profile,
          initialProfile: post.author,
        ),
      ),
    );
  }

  void _onPostChanged(int index, FeedPost post) {
    if (index < 0 || index >= _posts.length) return;
    setState(() => _posts[index] = post);
  }

  void _onPostRemoved(String postId) {
    setState(() => _posts.removeWhere((p) => p.id == postId));
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.viewPaddingOf(context).top;
    final bottomPad = FloatingTabBar.reservedBottomSpace(context) + AppSpacing.lg;

    return PremiumBackground(
      child: RefreshIndicator(
        onRefresh: _load,
        color: PremiumColors.accentBlue,
        backgroundColor: PremiumColors.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(AppSpacing.md, topPad + AppSpacing.sm, AppSpacing.md, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Feed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Progress photos and training updates',
                            style: TextStyle(color: PremiumColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _client == null ? null : _createPost,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Post'),
                    ),
                  ],
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator(color: PremiumColors.accentBlue)),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _FeedMessage(
                  icon: Icons.error_outline_rounded,
                  title: 'Feed error',
                  body: _error!,
                  actionLabel: 'Retry',
                  onAction: _load,
                ),
              )
            else if (_posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _FeedMessage(
                  icon: Icons.dynamic_feed_outlined,
                  title: 'No posts yet',
                  body: 'Be first to share a workout photo.',
                  actionLabel: 'Create post',
                  onAction: _createPost,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, bottomPad),
                sliver: SliverList.separated(
                  itemCount: _posts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (context, i) {
                    return _FeedPostCard(
                      post: _posts[i],
                      client: _client!,
                      onOpenProfile: _openProfile,
                      onPostChanged: (p) => _onPostChanged(i, p),
                      onPostRemoved: _onPostRemoved,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeedPostCard extends StatefulWidget {
  const _FeedPostCard({
    required this.post,
    required this.client,
    required this.onOpenProfile,
    required this.onPostChanged,
    required this.onPostRemoved,
  });

  final FeedPost post;
  final SocialApiClient client;
  final ValueChanged<FeedPost> onPostChanged;
  final ValueChanged<String> onPostRemoved;
  final ValueChanged<FeedPost> onOpenProfile;

  @override
  State<_FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<_FeedPostCard> {
  var _photoIndex = 0;
  late bool _likedByMe;
  late int _likeCount;
  late int _commentCount;
  var _liking = false;

  @override
  void initState() {
    super.initState();
    _likedByMe = widget.post.likedByMe;
    _likeCount = widget.post.likeCount;
    _commentCount = widget.post.commentCount;
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

  @override
  Widget build(BuildContext context) {
    final post = widget.post.copyWith(
      likedByMe: _likedByMe,
      likeCount: _likeCount,
      commentCount: _commentCount,
    );
    return Container(
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.xl),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => widget.onOpenProfile(post),
                  child: SocialAvatar(
                    name: post.author.displayName,
                    imageUrl: post.author.avatarUrl,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onOpenProfile(post),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author.displayName.isEmpty ? 'Athlete' : post.author.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          _relative(post.createdAt),
                          style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _menu,
                  icon: const Icon(Icons.more_horiz_rounded, color: PremiumColors.textSecondary),
                ),
              ],
            ),
          ),
          if (post.media.isNotEmpty) ...[
            AspectRatio(
              aspectRatio: 1,
              child: PageView.builder(
                itemCount: post.media.length,
                onPageChanged: (i) => setState(() => _photoIndex = i),
                itemBuilder: (context, i) => Image.network(
                  post.media[i].url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const ColoredBox(
                    color: PremiumColors.midnightBottom,
                    child: Icon(Icons.broken_image_outlined, color: PremiumColors.textMuted),
                  ),
                ),
              ),
            ),
            if (post.media.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < post.media.length; i++)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _photoIndex ? PremiumColors.accentBlue : PremiumColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _toggleLike,
                      icon: Icon(
                        _likedByMe ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: _likedByMe ? Colors.redAccent : Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: _openComments,
                      icon: const Icon(Icons.mode_comment_outlined, color: Colors.white),
                    ),
                    const Spacer(),
                    Text(
                      '$_likeCount likes',
                      style: const TextStyle(color: PremiumColors.textSecondary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                if (post.caption.trim().isNotEmpty)
                  Text(
                    post.caption,
                    style: const TextStyle(color: Colors.white, height: 1.35),
                  ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _openComments,
                  child: Text(
                    _commentCount == 0 ? 'Add a comment' : 'View $_commentCount comments',
                    style: const TextStyle(color: PremiumColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _relative(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }
}

class _FeedMessage extends StatelessWidget {
  const _FeedMessage({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: PremiumColors.textMuted, size: 44),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: PremiumColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
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
