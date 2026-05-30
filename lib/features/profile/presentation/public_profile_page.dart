import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/premium_background.dart';
import '../../social/data/social_api_client.dart';
import '../../social/domain/feed_media.dart';
import '../../social/domain/feed_post.dart';
import '../../social/domain/social_profile.dart';
import '../domain/user_profile.dart';
import 'widgets/profile_view_widgets.dart';

class PublicProfilePage extends StatefulWidget {
  const PublicProfilePage({
    super.key,
    required this.userId,
    required this.client,
    required this.currentProfile,
    this.initialProfile,
  });

  final String userId;
  final SocialApiClient client;
  final UserProfile currentProfile;
  final SocialProfile? initialProfile;

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  var _loading = true;
  var _isMine = false;
  var _tab = 0;
  String? _error;
  SocialProfile? _profile;
  List<FeedPost> _posts = const [];

  static const _tabLabels = ['Photos', 'About', 'Feed'];

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final current = await widget.client.currentUserId();
      final profile = await widget.client.getProfile(widget.userId);
      final posts = await widget.client.fetchUserPosts(widget.userId);
      if (!mounted) return;
      setState(() {
        _isMine = current == widget.userId;
        _profile = profile ?? widget.initialProfile;
        _posts = posts;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
        _profile ??= widget.initialProfile;
      });
    }
  }

  List<FeedMedia> get _allMedia => _posts.expand((p) => p.media).toList();

  Future<void> _menu() async {
    if (_isMine) return;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: PremiumColors.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.block_rounded, color: Colors.redAccent),
              title: const Text('Block user', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, 'block'),
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: PremiumColors.textSecondary),
              title: const Text('Report profile', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, 'report'),
            ),
          ],
        ),
      ),
    );
    if (action == 'block') {
      await widget.client.blockUser(widget.userId);
      if (mounted) Navigator.pop(context);
    }
    if (action == 'report') {
      await widget.client.reportPost(postId: '', userId: widget.userId, reason: 'profile');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report sent')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: _loading && _profile == null
            ? const Center(child: CircularProgressIndicator(color: PremiumColors.accentBlue))
            : _error != null && _profile == null
                ? _ErrorView(message: _error!, onRetry: _load)
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: _buildSlivers(),
                  ),
      ),
    );
  }

  List<Widget> _buildSlivers() {
    final profile = _profile!;
    final topPad = MediaQuery.of(context).padding.top;
    final name = profile.displayName.isEmpty ? 'Athlete' : profile.displayName;
    final bio = profile.bio.trim().isEmpty ? '' : profile.bio;

    return [
      SliverToBoxAdapter(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 156 + topPad,
                  decoration: BoxDecoration(
                    color: PremiumColors.surface,
                    image: profile.coverUrl.isEmpty
                        ? null
                        : DecorationImage(
                            image: NetworkImage(profile.coverUrl),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha: 0.35),
                              BlendMode.darken,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  left: 4,
                  top: topPad + 2,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: topPad + 6,
                  child: const Text(
                    'Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (!_isMine)
                  Positioned(
                    right: 4,
                    top: topPad + 2,
                    child: IconButton(
                      onPressed: _menu,
                      icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
                    ),
                  ),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -48),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: PremiumColors.midnightMid, width: 4),
                ),
                child: ProfileAvatarButton(
                  name: name,
                  imageUrl: profile.avatarUrl,
                  size: 96,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            if (bio.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  bio,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PremiumColors.textSecondary,
                    height: 1.4,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ProfileSegmentTabs(
                labels: _tabLabels,
                selected: _tab,
                onSelected: (v) => setState(() => _tab = v),
              ),
            ),
          ],
        ),
      ),
      if (_loading)
        const SliverPadding(
          padding: EdgeInsets.all(32),
          sliver: SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator(color: PremiumColors.accentBlue)),
          ),
        )
      else
        SliverToBoxAdapter(child: _tabContent(profile)),
    ];
  }

  Widget _tabContent(SocialProfile profile) {
    switch (_tab) {
      case 0:
        return ProfilePhotoGrid(
          media: _allMedia,
          heroTagPrefix: 'public-photo-${widget.userId}',
        );
      case 1:
        return ProfileAboutSection(bio: profile.bio);
      case 2:
      default:
        return ProfileFeedSection(
          posts: _posts,
          heroTagPrefix: 'public-feed-${widget.userId}',
        );
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: PremiumColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: PremiumColors.textSecondary)),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
