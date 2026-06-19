import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/floating_tab_bar.dart';
import '../../../app/widgets/premium_background.dart';
import '../../profile/domain/user_profile.dart';
import '../../profile/presentation/public_profile_page.dart';
import '../../profile/presentation/seeded_profile_page.dart';
import '../../social/data/social_api_client.dart';
import '../../social/data/social_seed_data.dart';
import '../../social/domain/feed_post.dart';
import '../data/feed_demo_data.dart';
import '../domain/feed_story.dart';
import 'create_choice_sheet.dart';
import 'create_post_sheet.dart';
import 'create_story_sheet.dart';
import 'messages_page.dart';
import 'widgets/feed_post_card.dart';
import 'widgets/story_avatar.dart';
import 'widgets/story_viewer.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({
    super.key,
    required this.profile,
    this.onOpenOwnProfile,
  });

  final UserProfile profile;
  final VoidCallback? onOpenOwnProfile;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  SocialApiClient? _client;
  var _refreshing = false;
  List<FeedPost> _feedPosts = const [];
  final List<FeedStory> _demoStories = FeedDemoData.demoStories();
  FeedStory? _userStory;
  List<FeedStory> _apiStories = const [];
  String? _deviceUserId;
  String? _avatarUrlOverride;

  StoryUser get _ownStoryUser => SocialSeedRepository.ownStoryUser(
        widget.profile,
        userId: _deviceUserId,
        avatarUrlOverride: _avatarUrlOverride,
      );

  List<FeedStory> get _rowStories {
    if (_apiStories.isNotEmpty) return _apiStories;
    return _demoStories;
  }

  List<FeedStory> get _playableStories {
    final items = <FeedStory>[];
    if (_userStory != null && _userStory!.hasSlides) {
      items.add(_userStory!);
    }
    if (_apiStories.isNotEmpty) {
      items.addAll(_apiStories.where((story) => story.hasSlides));
    } else {
      items.addAll(_demoStories.where((story) => story.hasSlides));
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    _feedPosts = SocialSeedRepository.allFeedPosts(currentProfile: widget.profile);
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final client = SocialApiClient(prefs: prefs);
      await client.ensureProfile(widget.profile);
      final deviceUserId = await client.currentUserId();
      final apiProfile = await client.getCurrentProfile();
      if (!mounted) return;
      setState(() {
        _client = client;
        _deviceUserId = deviceUserId;
        if (apiProfile != null && apiProfile.avatarUrl.trim().isNotEmpty) {
          _avatarUrlOverride = apiProfile.avatarUrl.trim();
        }
      });
      await _syncApiPosts();
      await _syncStories();
    } catch (_) {
      if (!mounted) return;
    }
  }

  Future<void> _syncApiPosts({bool allowNewPosts = false}) async {
    final client = _client;
    if (client == null) return;
    try {
      final apiPosts = await client.fetchFeed();
      if (!mounted) return;
      final merged = SocialSeedRepository.mergeWithApiPosts(
        apiPosts,
        currentProfile: widget.profile,
      );
      setState(() {
        if (allowNewPosts) {
          _feedPosts = merged;
          return;
        }
        final byId = {for (final post in merged) post.id: post};
        _feedPosts = _feedPosts.map((post) => byId[post.id] ?? post).toList();
      });
    } catch (_) {
      if (!mounted) return;
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    await _syncApiPosts(allowNewPosts: true);
    await _syncStories();
    if (!mounted) return;
    setState(() => _refreshing = false);
  }

  Future<void> _syncStories() async {
    final client = _client;
    if (client == null) return;
    try {
      final stories = await client.fetchActiveStories();
      if (!mounted) return;
      final uid = _deviceUserId ?? await client.currentUserId();
      FeedStory? own;
      final others = <FeedStory>[];
      for (final story in stories) {
        if (story.user.id == uid) {
          own = story.copyWithUser(_ownStoryUser);
        } else {
          others.add(story);
        }
      }
      setState(() {
        _userStory = own;
        _apiStories = others;
      });
    } catch (_) {
      if (!mounted) return;
    }
  }

  Future<void> _openCreateChoice({bool storyOnly = false}) async {
    if (storyOnly) {
      await _openCreateStory();
      return;
    }

    final choice = await showCreateChoiceSheet(context: context);
    if (!mounted || choice == null) return;

    if (choice == CreateChoice.post) {
      await _createPost();
    } else {
      await _openCreateStory();
    }
  }

  Future<void> _createPost() async {
    final client = _client;
    if (client != null) {
      final created = await showCreatePostSheet(context: context, client: client);
      if (created == true) {
        await _syncApiPosts(allowNewPosts: true);
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

  Future<void> _openCreateStory() async {
    final client = _client;
    if (client == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Story upload is unavailable right now. Check your connection and try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final story = await showCreateStorySheet(
      context: context,
      client: client,
      ownStoryUser: _ownStoryUser,
    );
    if (!mounted || story == null) return;
    setState(() => _userStory = story);
    await _syncStories();
  }

  void _openSeededProfile(String userId) {
    if (userId == SocialSeedRepository.currentUserId) {
      widget.onOpenOwnProfile?.call();
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SeededProfilePage(
          userId: userId,
          currentProfile: widget.profile,
        ),
      ),
    );
  }

  void _openProfile(FeedPost post) {
    if (SocialSeedRepository.isSeededUser(post.userId)) {
      _openSeededProfile(post.userId);
      return;
    }
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

  void _onStoryOwnerTap(FeedStory story) {
    if (story.user.isCurrentUser || story.user.id == _deviceUserId) {
      widget.onOpenOwnProfile?.call();
      return;
    }
    if (SocialSeedRepository.isSeededUser(story.user.id)) {
      _openSeededProfile(story.user.id);
      return;
    }
    final client = _client;
    if (client == null) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PublicProfilePage(
          userId: story.user.id,
          client: client,
          currentProfile: widget.profile,
        ),
      ),
    );
  }

  void _onStoryRowTap(int rowIndex) {
    if (rowIndex == 0) {
      if (_userStory != null && _userStory!.hasSlides) {
        unawaited(
          StoryViewerPage.open(
            context: context,
            stories: _playableStories,
            initialStoryIndex: 0,
            onOwnerTap: _onStoryOwnerTap,
          ),
        );
      } else {
        unawaited(_openCreateStory());
      }
      return;
    }

    final rowStories = _rowStories;
    final storyIndex = rowIndex - 1;
    if (storyIndex < 0 || storyIndex >= rowStories.length) return;
    final target = rowStories[storyIndex];
    final initialIndex = _playableStories.indexWhere((story) => story.id == target.id);
    unawaited(
      StoryViewerPage.open(
        context: context,
        stories: _playableStories,
        initialStoryIndex: initialIndex >= 0 ? initialIndex : 0,
        onOwnerTap: _onStoryOwnerTap,
      ),
    );
  }

  void _onSeededPostChanged(int index, FeedPost post) {
    if (index < 0 || index >= _feedPosts.length) return;
    setState(() => _feedPosts[index] = post);
  }

  void _onApiPostChanged(int index, FeedPost post) {
    if (index < 0 || index >= _feedPosts.length) return;
    setState(() => _feedPosts[index] = post);
  }

  void _onApiPostRemoved(String postId) {
    setState(() => _feedPosts.removeWhere((post) => post.id == postId));
  }

  void _openMessages() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const MessagesPage(),
      ),
    );
  }

  bool _isSeededPost(FeedPost post) {
    return post.id.startsWith('seed_') || SocialSeedRepository.isSeededUser(post.userId);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = FloatingTabBar.reservedBottomSpace(context) + AppSpacing.lg;
    final ownUser = _ownStoryUser;
    final rowStories = _rowStories;
    final rowCount = 1 + rowStories.length;

    return PremiumBackground(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: PremiumColors.accentBlue,
        backgroundColor: PremiumColors.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.xs, AppSpacing.sm, 0),
                      child: _FeedTopHeader(
                        onCreateTap: () => unawaited(_openCreateChoice()),
                        onMessagesTap: _openMessages,
                      ),
                    ),
                    SizedBox(
                      height: StoryAvatar.itemHeight,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
                        itemCount: rowCount,
                        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.xs),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return StoryAvatar(
                              label: ownUser.displayName,
                              avatarUrl: ownUser.avatarUrl,
                              fallbackName: ownUser.avatarLabel,
                              isOwnStory: true,
                              hasUnseenStory: _userStory?.hasSlides ?? false,
                              onTap: () => _onStoryRowTap(0),
                            );
                          }

                          final story = rowStories[index - 1];
                          return StoryAvatar(
                            label: story.user.displayName,
                            avatarUrl: story.user.avatarUrl,
                            hasUnseenStory: true,
                            onTap: () => _onStoryRowTap(index),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_feedPosts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _FeedMessage(
                  icon: Icons.photo_library_outlined,
                  title: 'No posts yet',
                  body: 'Check back soon for new workouts and updates.',
                  actionLabel: 'Refresh',
                  onAction: () => unawaited(_onRefresh()),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, bottomPad),
                sliver: SliverList.separated(
                  itemCount: _feedPosts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (context, index) {
                    final post = _feedPosts[index];
                    if (_isSeededPost(post)) {
                      return SeededFeedPostCard(
                        post: post,
                        currentUser: SocialSeedRepository.socialProfileFor(
                          SocialSeedRepository.currentUserId,
                          currentProfile: widget.profile,
                        ),
                        onChanged: (updated) => _onSeededPostChanged(index, updated),
                        onOpenProfile: () => _openSeededProfile(post.userId),
                      );
                    }
                    final client = _client;
                    if (client == null) {
                      return SeededFeedPostCard(
                        post: post,
                        currentUser: SocialSeedRepository.socialProfileFor(
                          SocialSeedRepository.currentUserId,
                          currentProfile: widget.profile,
                        ),
                        onChanged: (updated) => _onSeededPostChanged(index, updated),
                        onOpenProfile: () => _openProfile(post),
                      );
                    }
                    return ApiFeedPostCard(
                      post: post,
                      client: client,
                      currentUser: SocialSeedRepository.socialProfileFor(
                        SocialSeedRepository.currentUserId,
                        currentProfile: widget.profile,
                      ),
                      onOpenProfile: _openProfile,
                      onPostChanged: (updated) => _onApiPostChanged(index, updated),
                      onPostRemoved: _onApiPostRemoved,
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

class _FeedTopHeader extends StatelessWidget {
  const _FeedTopHeader({
    required this.onCreateTap,
    required this.onMessagesTap,
  });

  final VoidCallback onCreateTap;
  final VoidCallback onMessagesTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _FeedHeaderIconButton(
                icon: Icons.add_rounded,
                onTap: onCreateTap,
              ),
              _FeedHeaderIconButton(
                icon: Icons.send_rounded,
                onTap: onMessagesTap,
              ),
            ],
          ),
          const _GymCoachBrandLogo(),
        ],
      ),
    );
  }
}

class _GymCoachBrandLogo extends StatelessWidget {
  const _GymCoachBrandLogo();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white, PremiumColors.accentBlueSoft],
      ).createShader(bounds),
      child: const Text(
        'Gym Coach',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
      ),
    );
  }
}

class _FeedHeaderIconButton extends StatelessWidget {
  const _FeedHeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: PremiumColors.surface.withValues(alpha: 0.55),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: PremiumColors.accentBlue.withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 21, color: Colors.white),
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
