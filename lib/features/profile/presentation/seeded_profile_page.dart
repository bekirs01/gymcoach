import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/premium_background.dart';
import '../../social/data/social_seed_data.dart';
import '../../social/domain/feed_media.dart';
import '../../social/domain/feed_post.dart';
import '../domain/user_profile.dart';
import 'widgets/profile_view_widgets.dart';

class SeededProfilePage extends StatefulWidget {
  const SeededProfilePage({
    super.key,
    required this.userId,
    required this.currentProfile,
  });

  final String userId;
  final UserProfile currentProfile;

  @override
  State<SeededProfilePage> createState() => _SeededProfilePageState();
}

class _SeededProfilePageState extends State<SeededProfilePage> {
  var _tab = 0;

  SeededSocialUser? get _user =>
      SocialSeedRepository.seededUserFor(widget.userId, currentProfile: widget.currentProfile);

  List<FeedPost> get _posts =>
      SocialSeedRepository.postsForUser(widget.userId, currentProfile: widget.currentProfile);

  List<FeedMedia> get _photos =>
      SocialSeedRepository.photosForUser(widget.userId, currentProfile: widget.currentProfile);

  bool get _isCurrentUser => widget.userId == SocialSeedRepository.currentUserId;

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: PremiumBackground(
          child: Center(
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            ),
          ),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
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
                          image: user.coverUrl.isEmpty
                              ? null
                              : DecorationImage(
                                  image: NetworkImage(user.coverUrl),
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
                        child: Text(
                          l10n.profileTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
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
                        name: user.displayName,
                        imageUrl: user.avatarUrl,
                        size: 96,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.displayName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.username}',
                    style: const TextStyle(
                      color: PremiumColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      user.bio,
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
                  const SizedBox(height: 14),
                  _StatsRow(
                    posts: user.postCount > 0 ? user.postCount : _posts.length,
                    stories: user.storyCount,
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ProfileSegmentTabs(
                      labels: [l10n.profileTabPhotos, l10n.profileTabAbout, l10n.profileTabFeed],
                      selected: _tab,
                      onSelected: (v) => setState(() => _tab = v),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(child: _tabContent(l10n, user)),
          ],
        ),
      ),
    );
  }

  Widget _tabContent(AppLocalizations l10n, SeededSocialUser user) {
    switch (_tab) {
      case 0:
        return ProfilePhotoGrid(
          media: _photos,
          heroTagPrefix: 'seeded-photo-${widget.userId}',
        );
      case 1:
        return ProfileAboutSection(
          bio: user.bio,
          extraSections: [
            ProfileAboutBlock(
              title: 'Focus',
              body: user.trainingFocus,
              icon: Icons.fitness_center_rounded,
            ),
            ProfileAboutBlock(
              title: 'Location',
              body: user.city,
              icon: Icons.location_on_outlined,
            ),
            if (_isCurrentUser)
              ProfileAboutBlock(
                title: l10n.profileFitnessSummary,
                body:
                    '${widget.currentProfile.fitnessGoal}\n${widget.currentProfile.weightKg} кг · ${widget.currentProfile.heightCm} см',
                icon: Icons.monitor_heart_outlined,
              ),
          ],
        );
      case 2:
      default:
        return ProfileFeedSection(
          posts: _posts,
          heroTagPrefix: 'seeded-feed-${widget.userId}',
          emptyMessage: l10n.profilePostsEmpty,
        );
    }
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.posts,
    required this.stories,
  });

  final int posts;
  final int stories;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StatItem(label: 'Posts', value: '$posts'),
          const SizedBox(width: 28),
          _StatItem(label: 'Stories', value: '$stories'),
          const SizedBox(width: 28),
          const _StatItem(label: 'Streak', value: '12'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: PremiumColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
