import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/premium_background.dart';
import '../../social/data/social_api_client.dart';
import '../../social/data/social_seed_data.dart';
import '../../social/domain/feed_post.dart';
import '../data/profile_repository.dart';
import '../domain/profile_defaults.dart';
import '../domain/profile_media_filter.dart';
import '../domain/user_profile.dart';
import 'edit_profile_sheet.dart';
import 'widgets/profile_view_widgets.dart';

Future<void> showProfileSheet({
  required BuildContext context,
  required UserProfile profile,
  required ValueChanged<UserProfile> onProfileChanged,
  required ValueChanged<Locale> onLocaleChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    isDismissible: true,
    enableDrag: true,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: ProfilePage(
          profile: profile,
          onProfileChanged: onProfileChanged,
          onLocaleChanged: onLocaleChanged,
        ),
      );
    },
  );
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.profile,
    required this.onProfileChanged,
    required this.onLocaleChanged,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileChanged;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserProfile _profile;
  SocialApiClient? _client;
  ProfileRepository? _profileRepository;
  List<FeedPost> _posts = const [];
  List<FeedPost> _savedPosts = const [];
  var _loadingSocial = true;
  var _tab = 0;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    unawaited(_bootstrapSocial());
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _profile = widget.profile;
    }
  }

  Future<void> _bootstrapSocial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final client = SocialApiClient(prefs: prefs);
      final profileRepo = ProfileRepository(prefs: prefs);
      await profileRepo.ensureProfile(_profile);
      if (!mounted) return;
      setState(() {
        _client = client;
        _profileRepository = profileRepo;
      });
      await _loadSocial();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingSocial = false;
        _applySeedFallback();
      });
    }
  }

  Future<void> _loadSocial() async {
    final client = _client;
    final profileRepo = _profileRepository;
    if (client == null || profileRepo == null) return;
    try {
      final uid = await client.currentUserId();
      final remoteProfile = await profileRepo.loadCurrentProfile(_profile);
      final posts = await client.fetchUserPosts(uid);
      if (!mounted) return;
      setState(() {
        _posts = ProfileMediaFilter.visiblePosts(posts);
        _savedPosts = ProfileMediaFilter.visiblePosts(client.loadSavedPosts());
        _loadingSocial = false;
        _profile = remoteProfile;
        _applySeedFallback();
      });
      widget.onProfileChanged(_profile);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingSocial = false;
        _applySeedFallback();
      });
    }
  }

  void _applySeedFallback() {
    final seed = SocialSeedRepository.currentUserSeed(_profile);
    final seedPosts = SocialSeedRepository.postsForUser(
      SocialSeedRepository.currentUserId,
      currentProfile: _profile,
    );
    if (_posts.isEmpty && seedPosts.isNotEmpty) {
      _posts = ProfileMediaFilter.visiblePosts(seedPosts);
    }
    _profile = _profile.copyWith(
      displayName: _profile.displayName.trim().isEmpty ? seed.displayName : _profile.displayName,
      username: _profile.username.trim().isEmpty ? seed.username : _profile.username,
      publicBio: _profile.publicBio.trim().isEmpty ? seed.bio : _profile.publicBio,
      avatarUrl: ProfileMediaFilter.resolveImageUrl(
        primary: _profile.avatarUrl,
        fallback: seed.avatarUrl,
      ),
      coverUrl: ProfileMediaFilter.resolveImageUrl(
        primary: _profile.coverUrl,
        fallback: seed.coverUrl,
      ),
      fitnessGoal: _profile.fitnessGoal.trim().isEmpty ? seed.goal : _profile.fitnessGoal,
      trainingFocus: _profile.trainingFocus.trim().isEmpty ? seed.trainingFocus : _profile.trainingFocus,
      locationText: _profile.locationText.trim().isEmpty ? seed.city : _profile.locationText,
      experienceLevel: _profile.experienceLevel.trim().isEmpty ? seed.experience : _profile.experienceLevel,
      weeklyWorkoutTarget: _profile.weeklyWorkoutTarget <= 0 ? ProfileDefaults.weeklyWorkoutTarget : _profile.weeklyWorkoutTarget,
    );
  }

  Future<void> _editProfile() async {
    final result = await EditProfileSheet.show(
      context,
      initial: _profile,
      repository: _profileRepository,
      socialClient: _client,
      l10n: AppLocalizations.of(context)!,
    );
    if (!mounted || result == null) return;
    setState(() => _profile = result);
    widget.onProfileChanged(result);
    await _loadSocial();
  }

  void _pickLanguage() {
    final l10n = AppLocalizations.of(context)!;
    final code = Localizations.localeOf(context).languageCode;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: PremiumColors.surface,
      builder: (sheetContext) {
        return Material(
          color: PremiumColors.surface,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Text(l10n.languagePickerTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                ListTile(
                  title: Text(l10n.languageEnglish, style: const TextStyle(color: Colors.white)),
                  trailing: code == 'en' ? const Icon(Icons.check_rounded, color: PremiumColors.accentBlue) : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    widget.onLocaleChanged(const Locale('en'));
                  },
                ),
                ListTile(
                  title: Text(l10n.languageRussian, style: const TextStyle(color: Colors.white)),
                  trailing: code == 'ru' ? const Icon(Icons.check_rounded, color: PremiumColors.accentBlue) : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    widget.onLocaleChanged(const Locale('ru'));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _logout() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(l10n.profileLogoutSnack),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langLabel =
        Localizations.localeOf(context).languageCode == 'ru' ? l10n.languageRussian : l10n.languageEnglish;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.94,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: PremiumColors.midnightMid,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: Column(
          children: [
            _ProfileSheetChrome(
              l10n: l10n,
              onClose: () => Navigator.of(context).pop(),
              onEdit: _editProfile,
            ),
            Expanded(
              child: PremiumBackground(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _ProfileCover(profile: _profile),
                          Transform.translate(
                            offset: const Offset(0, -48),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: PremiumColors.midnightMid, width: 4),
                              ),
                              child: ProfileAvatarButton(
                                name: _profile.displayName,
                                imageUrl: _profile.avatarUrl,
                                fallbackImageUrl: SocialSeedRepository.currentUserAvatarFallback,
                                size: 96,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                Text(
                                  _profile.displayName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _profile.bio.isEmpty ? l10n.profileNoBio : _profile.bio,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: PremiumColors.textSecondary, height: 1.35),
                                ),
                                const SizedBox(height: 18),
                                ProfileSegmentTabs(
                                  labels: [
                                    l10n.profileTabPhotos,
                                    l10n.profileTabAbout,
                                    l10n.profileTabFeed,
                                    l10n.profileTabSaved,
                                    l10n.profileTabSettings,
                                  ],
                                  selected: _tab,
                                  onSelected: (v) {
                                    setState(() => _tab = v);
                                    if (v == 3) {
                                      setState(
                                        () => _savedPosts = ProfileMediaFilter.visiblePosts(
                                          _client?.loadSavedPosts() ?? const [],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_loadingSocial)
                      const SliverPadding(
                        padding: EdgeInsets.all(24),
                        sliver: SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator(color: PremiumColors.accentBlue)),
                        ),
                      )
                    else
                      ..._tabSlivers(l10n, langLabel),
                    SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 24)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _tabSlivers(AppLocalizations l10n, String langLabel) {
    switch (_tab) {
      case 0:
        return [_photosSliver(l10n)];
      case 1:
        return [_aboutSliver(l10n)];
      case 2:
        return [_postsSliver(l10n)];
      case 3:
        return [_savedSliver(l10n)];
      default:
        return [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _SettingsCard(
                l10n: l10n,
                langLabel: langLabel,
                notifications: _profile.notificationsEnabled,
                onLanguage: _pickLanguage,
                onNotifications: (v) {
                  final next = _profile.copyWith(notificationsEnabled: v);
                  setState(() => _profile = next);
                  widget.onProfileChanged(next);
                },
                onLogout: _logout,
              ),
            ),
          ),
        ];
    }
  }

  Widget _aboutSliver(AppLocalizations l10n) {
    final seed = SocialSeedRepository.currentUserSeed(_profile);
    return SliverToBoxAdapter(
      child: ProfileAboutSection(
        bio: _profile.bio.trim().isEmpty ? seed.bio : _profile.bio,
        extraSections: [
          ProfileAboutBlock(
            title: 'Location',
            body: _profile.locationText.trim().isEmpty ? seed.city : _profile.locationText,
            icon: Icons.location_on_outlined,
          ),
          ProfileAboutBlock(
            title: 'Training focus',
            body: _profile.trainingFocus.trim().isEmpty ? seed.trainingFocus : _profile.trainingFocus,
            icon: Icons.fitness_center_rounded,
          ),
          ProfileAboutBlock(
            title: 'Goal',
            body: _profile.fitnessGoal.trim().isEmpty ? seed.goal : _profile.fitnessGoal,
            icon: Icons.flag_outlined,
          ),
          ProfileAboutBlock(
            title: 'Experience',
            body: _profile.experienceLevel.trim().isEmpty ? seed.experience : _profile.experienceLevel,
            icon: Icons.trending_up_rounded,
          ),
          ProfileAboutBlock(
            title: 'Joined',
            body: seed.joinedLabel,
            icon: Icons.calendar_month_outlined,
          ),
          ProfileAboutBlock(
            title: 'Weekly target',
            body: _profile.weeklyWorkoutTarget > 0
                ? ProfileDefaults.weeklyTargetLabel(_profile.weeklyWorkoutTarget)
                : seed.weeklyTarget,
            icon: Icons.event_repeat_rounded,
          ),
          ProfileAboutBlock(
            title: 'Favorite training',
            body: seed.favoriteTrainingType,
            icon: Icons.star_outline_rounded,
          ),
          if (seed.age > 0)
            ProfileAboutBlock(
              title: 'Age',
              body: '${seed.age}',
              icon: Icons.person_outline_rounded,
            ),
          if (_profile.privateNotes.trim().isNotEmpty)
            ProfileAboutBlock(
              title: l10n.profilePrivateNotes,
              body: _profile.privateNotes,
              icon: Icons.lock_outline_rounded,
            ),
          ProfileAboutBlock(
            title: l10n.profileFitnessSummary,
            body: '${_profile.fitnessGoal}\n${_profile.weightKg} kg · ${_profile.heightCm} cm',
            icon: Icons.monitor_heart_outlined,
          ),
        ],
      ),
    );
  }

  Widget _postsSliver(AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: ProfileFeedSection(
        posts: ProfileMediaFilter.visiblePosts(_posts),
        heroTagPrefix: 'own-feed',
        emptyMessage: l10n.profilePostsEmpty,
      ),
    );
  }

  Widget _savedSliver(AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: ProfileFeedSection(
        posts: ProfileMediaFilter.visiblePosts(_savedPosts),
        heroTagPrefix: 'own-saved',
        emptyIcon: Icons.bookmark_border_rounded,
        emptyMessage: l10n.profileSavedEmpty,
      ),
    );
  }

  Widget _photosSliver(AppLocalizations l10n) {
    final seedPhotos = SocialSeedRepository.photosForUser(
      SocialSeedRepository.currentUserId,
      currentProfile: _profile,
    );
    final postMedia = ProfileMediaFilter.visibleMedia(
      _posts.expand((post) => post.media),
    );
    final photos = ProfileMediaFilter.profileGallery(
      apiMedia: postMedia,
      seedMedia: seedPhotos,
    );
    return SliverToBoxAdapter(
      child: ProfilePhotoGrid(
        media: photos,
        heroTagPrefix: 'own-photo',
      ),
    );
  }
}

class _ProfileSheetChrome extends StatelessWidget {
  const _ProfileSheetChrome({
    required this.l10n,
    required this.onClose,
    required this.onEdit,
  });

  final AppLocalizations l10n;
  final VoidCallback onClose;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(PremiumRadii.pill),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                color: PremiumColors.textSecondary,
                tooltip: l10n.profileClose,
              ),
              Expanded(
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
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text(l10n.profileEditShort),
                style: TextButton.styleFrom(
                  foregroundColor: PremiumColors.accentBlue,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileCover extends StatelessWidget {
  const _ProfileCover({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      width: double.infinity,
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        image: profile.coverUrl.isEmpty
            ? null
            : DecorationImage(
                image: NetworkImage(profile.coverUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.25),
                  BlendMode.darken,
                ),
              ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.l10n,
    required this.langLabel,
    required this.notifications,
    required this.onLanguage,
    required this.onNotifications,
    required this.onLogout,
  });

  final AppLocalizations l10n;
  final String langLabel;
  final bool notifications;
  final VoidCallback onLanguage;
  final ValueChanged<bool> onNotifications;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PremiumColors.surface,
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        border: Border.all(color: PremiumColors.glassBorder),
      ),
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Icon(Icons.language_rounded, color: PremiumColors.accentBlue),
                    title: Text(l10n.languageTitle, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(langLabel, style: const TextStyle(color: PremiumColors.textMuted)),
                    onTap: onLanguage,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    value: notifications,
                    activeThumbColor: PremiumColors.accentBlue,
                    title: Text(l10n.profileRemindersTitle, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(l10n.profileRemindersSubtitle, style: const TextStyle(color: PremiumColors.textMuted)),
                    onChanged: onNotifications,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    title: Text(l10n.profileLogOut, style: const TextStyle(color: Colors.white)),
                    onTap: onLogout,
                  ),
                ),
              ],
            ),
    );
  }
}

