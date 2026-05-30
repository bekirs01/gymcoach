import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/premium_background.dart';
import '../../feed/presentation/social_avatar.dart';
import '../../social/data/social_api_client.dart';
import '../../social/domain/feed_post.dart';
import '../../social/domain/social_profile.dart';
import '../domain/user_profile.dart';

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
  String? _error;
  SocialProfile? _profile;
  List<FeedPost> _posts = const [];

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

  List<String> _gridUrls() {
    final urls = <String>[];
    for (final post in _posts) {
      if (post.media.isEmpty) continue;
      for (final m in post.media) {
        urls.add(m.url);
      }
    }
    return urls;
  }

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
        child: _loading
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

    return [
      SliverToBoxAdapter(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 168 + topPad,
              decoration: BoxDecoration(
                color: PremiumColors.surface,
                image: profile.coverUrl.isEmpty
                    ? null
                    : DecorationImage(
                        image: NetworkImage(profile.coverUrl),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken),
                      ),
              ),
            ),
            Positioned(
              left: 8,
              top: topPad + 6,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
            if (!_isMine)
              Positioned(
                right: 8,
                top: topPad + 6,
                child: IconButton(
                  onPressed: _menu,
                  icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: -44,
              child: Center(
                child: SocialAvatar(name: name, imageUrl: profile.avatarUrl, size: 92),
              ),
            ),
          ],
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                profile.bio.isEmpty ? 'No public bio yet.' : profile.bio,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: PremiumColors.textSecondary, height: 1.35),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _StatChip(value: '${_posts.length}', label: 'Posts')),
                  const SizedBox(width: 10),
                  Expanded(child: _StatChip(value: '${_posts.fold(0, (s, p) => s + p.media.length)}', label: 'Photos')),
                ],
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
        sliver: SliverToBoxAdapter(
          child: Text('Posts', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
        ),
      ),
      if (_gridUrls().isEmpty)
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 48, 20, 0),
          sliver: SliverToBoxAdapter(child: _EmptyState(text: 'No posts yet.')),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          sliver: SliverGrid.builder(
            itemCount: _gridUrls().length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final url = _gridUrls()[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(PremiumRadii.sm),
                child: Image.network(url, fit: BoxFit.cover),
              );
            },
          ),
        ),
    ];
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(text, style: const TextStyle(color: PremiumColors.textMuted)),
      ),
    );
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
