import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../../../app/widgets/premium_image_viewer.dart';
import '../../../feed/presentation/social_avatar.dart';
import '../../../social/domain/feed_media.dart';
import '../../../social/domain/feed_post.dart';
import '../../domain/profile_media_filter.dart';

class ProfileSegmentTabs extends StatelessWidget {
  const ProfileSegmentTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final active = selected == index;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? PremiumColors.tabActive : PremiumColors.surface,
                borderRadius: BorderRadius.circular(PremiumRadii.pill),
                border: Border.all(
                  color: active
                      ? PremiumColors.accentBlue.withValues(alpha: 0.55)
                      : PremiumColors.glassBorder,
                ),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  color: active ? Colors.white : PremiumColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfileEmptyTabState extends StatelessWidget {
  const ProfileEmptyTabState({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
      child: Column(
        children: [
          Icon(
            icon,
            size: 72,
            color: PremiumColors.accentBlue.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PremiumColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePhotoGrid extends StatefulWidget {
  const ProfilePhotoGrid({
    super.key,
    required this.media,
    required this.heroTagPrefix,
  });

  final List<FeedMedia> media;
  final String heroTagPrefix;

  @override
  State<ProfilePhotoGrid> createState() => _ProfilePhotoGridState();
}

class _ProfilePhotoGridState extends State<ProfilePhotoGrid> {
  final _failedUrls = <String>{};

  List<FeedMedia> get _visibleMedia {
    return ProfileMediaFilter.visibleMedia(
      widget.media.where((item) => !_failedUrls.contains(item.url.trim())),
    );
  }

  void _markFailed(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty || _failedUrls.contains(trimmed)) return;
    setState(() => _failedUrls.add(trimmed));
  }

  @override
  Widget build(BuildContext context) {
    final media = _visibleMedia;
    if (media.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return ProfileEmptyTabState(
        icon: Icons.photo_camera_outlined,
        message: l10n.profilePhotosEmpty,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: media.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final item = media[index];
        final tag = '${widget.heroTagPrefix}-${item.id}-$index';
        return _ProfilePhotoTile(
          media: item,
          heroTag: tag,
          onFailed: () => _markFailed(item.url),
        );
      },
    );
  }
}

class _ProfilePhotoTile extends StatelessWidget {
  const _ProfilePhotoTile({
    required this.media,
    required this.heroTag,
    required this.onFailed,
  });

  final FeedMedia media;
  final String heroTag;
  final VoidCallback onFailed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPremiumImageViewer(context, imageUrl: media.url, heroTag: heroTag),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PremiumRadii.sm),
        child: Hero(
          tag: heroTag,
          child: Image.network(
            media.url,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const _ProfilePhotoPlaceholder(showSpinner: true);
            },
            errorBuilder: (context, error, stackTrace) {
              WidgetsBinding.instance.addPostFrameCallback((_) => onFailed());
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _ProfilePhotoPlaceholder extends StatelessWidget {
  const _ProfilePhotoPlaceholder({this.showSpinner = false});

  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PremiumColors.surface,
      child: Center(
        child: showSpinner
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: PremiumColors.accentBlue.withValues(alpha: 0.65),
                ),
              )
            : Icon(
                Icons.image_outlined,
                color: PremiumColors.textMuted.withValues(alpha: 0.55),
                size: 22,
              ),
      ),
    );
  }
}

class ProfileAboutSection extends StatelessWidget {
  const ProfileAboutSection({
    super.key,
    required this.bio,
    this.extraSections = const [],
  });

  final String bio;
  final List<ProfileAboutBlock> extraSections;

  @override
  Widget build(BuildContext context) {
    if (bio.trim().isEmpty && extraSections.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return ProfileEmptyTabState(
        icon: Icons.article_outlined,
        message: l10n.profileAboutEmpty,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (bio.trim().isNotEmpty)
            _AboutCard(
              title: AppLocalizations.of(context)!.profileTabAbout,
              body: bio,
              icon: Icons.person_outline_rounded,
            ),
          for (var i = 0; i < extraSections.length; i++) ...[
            if (bio.trim().isNotEmpty || i > 0) const SizedBox(height: 12),
            _AboutCard(
              title: extraSections[i].title,
              body: extraSections[i].body,
              icon: extraSections[i].icon,
            ),
          ],
        ],
      ),
    );
  }
}

class ProfileAboutBlock {
  const ProfileAboutBlock({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: PremiumColors.accentBlue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(
                    color: PremiumColors.textSecondary,
                    height: 1.45,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileFeedSection extends StatefulWidget {
  const ProfileFeedSection({
    super.key,
    required this.posts,
    required this.heroTagPrefix,
    this.emptyMessage = 'This user has not shared any posts yet.',
    this.emptyIcon = Icons.dynamic_feed_outlined,
  });

  final List<FeedPost> posts;
  final String heroTagPrefix;
  final String emptyMessage;
  final IconData emptyIcon;

  @override
  State<ProfileFeedSection> createState() => _ProfileFeedSectionState();
}

class _ProfileFeedSectionState extends State<ProfileFeedSection> {
  final _hiddenPostIds = <String>{};

  void _hidePost(String postId) {
    if (postId.isEmpty || _hiddenPostIds.contains(postId)) return;
    setState(() => _hiddenPostIds.add(postId));
  }

  @override
  Widget build(BuildContext context) {
    final visiblePosts = ProfileMediaFilter.visiblePosts(widget.posts)
        .where((post) => !_hiddenPostIds.contains(post.id))
        .toList();
    if (visiblePosts.isEmpty) {
      return ProfileEmptyTabState(
        icon: widget.emptyIcon,
        message: widget.emptyMessage,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: visiblePosts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final post = visiblePosts[index];
        return ProfileFeedPostCard(
          post: post,
          heroTagPrefix: '${widget.heroTagPrefix}-post-$index',
          onAllMediaFailed: () => _hidePost(post.id),
        );
      },
    );
  }
}

class ProfileFeedPostCard extends StatefulWidget {
  const ProfileFeedPostCard({
    super.key,
    required this.post,
    required this.heroTagPrefix,
    this.onAllMediaFailed,
  });

  final FeedPost post;
  final String heroTagPrefix;
  final VoidCallback? onAllMediaFailed;

  @override
  State<ProfileFeedPostCard> createState() => _ProfileFeedPostCardState();
}

class _ProfileFeedPostCardState extends State<ProfileFeedPostCard> {
  var _photoIndex = 0;
  final _failedUrls = <String>{};
  var _reportedAllMediaFailed = false;

  List<FeedMedia> get _visibleMedia {
    return ProfileMediaFilter.visibleMedia(
      widget.post.media.where((item) => !_failedUrls.contains(item.url.trim())),
    );
  }

  void _markFailed(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty || _failedUrls.contains(trimmed)) return;
    setState(() => _failedUrls.add(trimmed));
    if (_visibleMedia.isEmpty &&
        widget.post.media.isNotEmpty &&
        !widget.post.isWorkoutShare &&
        !_reportedAllMediaFailed) {
      _reportedAllMediaFailed = true;
      widget.onAllMediaFailed?.call();
    }
  }

  String _relative(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day.toString().padLeft(2, '0')}.${time.month.toString().padLeft(2, '0')}.${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final name = post.author.displayName.isEmpty ? 'Athlete' : post.author.displayName;
    final media = _visibleMedia;

    if (post.media.isNotEmpty && media.isEmpty && !post.isWorkoutShare) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.xl),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                SocialAvatar(name: name, imageUrl: post.author.avatarUrl, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _relative(post.createdAt),
                        style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (post.caption.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(
                post.caption,
                style: const TextStyle(color: Colors.white, height: 1.4, fontSize: 14),
              ),
            ),
          if (media.isNotEmpty) ...[
            AspectRatio(
              aspectRatio: 1.15,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: media.length,
                    onPageChanged: (i) => setState(() => _photoIndex = i),
                    itemBuilder: (context, i) {
                      final url = media[i].url;
                      final tag = '${widget.heroTagPrefix}-media-$i';
                      return GestureDetector(
                        onTap: () => showPremiumImageViewer(context, imageUrl: url, heroTag: tag),
                        child: Hero(
                          tag: tag,
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const _ProfilePhotoPlaceholder(showSpinner: true);
                            },
                            errorBuilder: (context, error, stackTrace) {
                              WidgetsBinding.instance.addPostFrameCallback((_) => _markFailed(url));
                              return const _ProfilePhotoPlaceholder();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  if (media.length > 1)
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
                          '${_photoIndex + 1}/${media.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (media.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < media.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: i == _photoIndex ? 7 : 6,
                        height: i == _photoIndex ? 7 : 6,
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
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Text(
              '${post.likeCount} likes · ${post.commentCount} comments',
              style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileAvatarButton extends StatelessWidget {
  const ProfileAvatarButton({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.size,
    this.fallbackImageUrl,
    this.defaultAssetPath,
  });

  final String name;
  final String imageUrl;
  final String? fallbackImageUrl;
  final String? defaultAssetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final avatar = SocialAvatar(
      name: name,
      imageUrl: imageUrl,
      fallbackImageUrl: fallbackImageUrl,
      defaultAssetPath: defaultAssetPath,
      size: size,
    );
    final resolvedUrl = ProfileMediaFilter.resolveImageUrl(
      primary: imageUrl,
      fallback: fallbackImageUrl ?? '',
    );
    if (resolvedUrl.isEmpty) return avatar;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => showPremiumImageViewer(context, imageUrl: resolvedUrl),
        child: avatar,
      ),
    );
  }
}
