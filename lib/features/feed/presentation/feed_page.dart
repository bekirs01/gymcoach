import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/floating_tab_bar.dart';
import '../../../app/widgets/premium_background.dart';
import '../../profile/domain/user_profile.dart';
import '../../profile/presentation/public_profile_page.dart';
import '../../social/data/social_api_client.dart';
import '../../social/domain/feed_post.dart';
import '../data/feed_demo_data.dart';
import 'create_post_sheet.dart';
import 'widgets/feed_post_card.dart';
import 'widgets/story_avatar.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  SocialApiClient? _client;
  var _loading = true;
  var _refreshing = false;
  String? _error;
  List<FeedPost> _posts = const [];
  var _usingDemo = false;
  List<DemoFeedPost> _demoPosts = FeedDemoData.initialPosts();

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
      await _load(showSpinner: true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _usingDemo = true;
        _loading = false;
        _error = null;
      });
    }
  }

  Future<void> _load({bool showSpinner = false}) async {
    final client = _client;
    if (client == null) return;
    if (showSpinner) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final posts = await client.fetchFeed();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _usingDemo = posts.isEmpty;
        if (_usingDemo) {
          _demoPosts = FeedDemoData.initialPosts();
        }
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _usingDemo = true;
        _demoPosts = FeedDemoData.initialPosts();
        _loading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    if (_usingDemo || _client == null) {
      setState(() => _refreshing = true);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() {
        _demoPosts = FeedDemoData.refreshPosts(_demoPosts);
        _refreshing = false;
      });
      return;
    }
    await _load();
  }

  Future<void> _createPost() async {
    final client = _client;
    if (client != null) {
      final created = await showCreatePostSheet(context: context, client: client);
      if (created == true) {
        await _load(showSpinner: true);
      }
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post creation coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  void _onDemoPostChanged(int index, DemoFeedPost post) {
    if (index < 0 || index >= _demoPosts.length) return;
    setState(() => _demoPosts[index] = post);
  }

  void _onStoryTap(DemoStory story) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${story.label} story'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPad = MediaQuery.viewPaddingOf(context).top;
    final bottomPad = FloatingTabBar.reservedBottomSpace(context) + AppSpacing.lg;
    final hasApiPosts = !_usingDemo && _posts.isNotEmpty && _client != null;
    final waitingForApi = _loading && _client != null && !_usingDemo;

    return PremiumBackground(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: PremiumColors.accentBlue,
        backgroundColor: PremiumColors.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: topPad + AppSpacing.xs),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 14,
                            color: PremiumColors.textMuted.withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pull to refresh',
                            style: TextStyle(
                              color: PremiumColors.textMuted.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _PostButton(label: l10n.feedPost, onPressed: _createPost),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _StoriesRow(onStoryTap: _onStoryTap),
            ),
            if (waitingForApi)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: PremiumColors.accentBlue),
                ),
              )
            else if (hasApiPosts)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, bottomPad),
                sliver: SliverList.separated(
                  itemCount: _posts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (context, i) {
                    return ApiFeedPostCard(
                      post: _posts[i],
                      client: _client!,
                      onOpenProfile: _openProfile,
                      onPostChanged: (p) => _onPostChanged(i, p),
                      onPostRemoved: _onPostRemoved,
                    );
                  },
                ),
              )
            else if (_error != null && _client != null && !_usingDemo)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _FeedMessage(
                  icon: Icons.error_outline_rounded,
                  title: 'Feed error',
                  body: _error!,
                  actionLabel: 'Retry',
                  onAction: () => _load(showSpinner: true),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, bottomPad),
                sliver: SliverList.separated(
                  itemCount: _demoPosts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (context, i) {
                    return DemoFeedPostCard(
                      post: _demoPosts[i],
                      onChanged: (p) => _onDemoPostChanged(i, p),
                    );
                  },
                ),
              ),
            if (_refreshing)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: PremiumColors.accentBlue,
                      ),
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

class _PostButton extends StatelessWidget {
  const _PostButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PremiumRadii.pill),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(PremiumRadii.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 18,
                  color: PremiumColors.accentBlueSoft,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: PremiumColors.midnightTop,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoriesRow extends StatelessWidget {
  const _StoriesRow({required this.onStoryTap});

  final ValueChanged<DemoStory> onStoryTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
        itemCount: FeedDemoData.stories.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final story = FeedDemoData.stories[index];
          return StoryAvatar(
            label: story.label,
            avatarUrl: story.avatarUrl,
            isOwnStory: story.isOwnStory,
            onTap: () => onStoryTap(story),
          );
        },
      ),
    );
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
