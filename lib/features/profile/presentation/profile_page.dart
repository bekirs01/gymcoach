import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/premium_tokens.dart';
import '../../../app/widgets/premium_background.dart';
import '../../feed/presentation/social_avatar.dart';
import 'widgets/profile_view_widgets.dart';
import '../../social/data/social_api_client.dart';
import '../../social/data/social_seed_data.dart';
import '../../social/domain/feed_post.dart';
import '../domain/user_profile.dart';

double? _parsePositiveMetric(String raw) {
  final normalized = raw.trim().replaceAll(' ', '').replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  final value = double.tryParse(normalized);
  if (value == null || value <= 0 || !value.isFinite) return null;
  return value;
}

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
      await client.ensureProfile(_profile);
      if (!mounted) return;
      setState(() => _client = client);
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
    if (client == null) return;
    try {
      final uid = await client.currentUserId();
      final social = await client.getCurrentProfile();
      final posts = await client.fetchUserPosts(uid);
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _savedPosts = client.loadSavedPosts();
        _loadingSocial = false;
        if (social != null) {
          _profile = _profile.copyWith(
            displayName: social.displayName.isEmpty ? _profile.displayName : social.displayName,
            bio: social.bio,
            privateNotes: social.privateNotes,
            avatarUrl: social.avatarUrl,
            coverUrl: social.coverUrl,
            isPublic: social.isPublic,
          );
        }
        _applySeedFallback();
      });
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
      _posts = seedPosts;
    }
    _profile = _profile.copyWith(
      bio: _profile.bio.trim().isEmpty ? seed.bio : _profile.bio,
      avatarUrl: _profile.avatarUrl.trim().isEmpty ? seed.avatarUrl : _profile.avatarUrl,
    );
  }

  Future<void> _editProfile() async {
    final result = await showModalBottomSheet<UserProfile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSocialProfileSheet(
        initial: _profile,
        client: _client,
        l10n: AppLocalizations.of(context)!,
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _profile = result);
    widget.onProfileChanged(result);
    final client = _client;
    if (client == null) return;
    await client.updateProfile(
      displayName: result.displayName,
      bio: result.bio,
      privateNotes: result.privateNotes,
      avatarUrl: result.avatarUrl,
      coverUrl: result.coverUrl,
      isPublic: result.isPublic,
      weightKg: result.weightKg,
      heightCm: result.heightCm,
      fitnessGoal: result.fitnessGoal,
    );
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
                                      setState(() => _savedPosts = _client?.loadSavedPosts() ?? const []);
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
        bio: _profile.bio,
        extraSections: [
          ProfileAboutBlock(
            title: 'Focus',
            body: seed.trainingFocus,
            icon: Icons.fitness_center_rounded,
          ),
          ProfileAboutBlock(
            title: 'Location',
            body: seed.city,
            icon: Icons.location_on_outlined,
          ),
          ProfileAboutBlock(
            title: l10n.profilePrivateNotes,
            body: _profile.privateNotes.isEmpty
                ? l10n.profilePrivateNotesEmpty
                : _profile.privateNotes,
            icon: Icons.lock_outline_rounded,
          ),
          ProfileAboutBlock(
            title: l10n.profileFitnessSummary,
            body: '${_profile.fitnessGoal}\n${_profile.weightKg} кг · ${_profile.heightCm} см',
            icon: Icons.monitor_heart_outlined,
          ),
        ],
      ),
    );
  }

  Widget _postsSliver(AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: ProfileFeedSection(
        posts: _posts,
        heroTagPrefix: 'own-feed',
        emptyMessage: l10n.profilePostsEmpty,
      ),
    );
  }

  Widget _savedSliver(AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: ProfileFeedSection(
        posts: _savedPosts,
        heroTagPrefix: 'own-saved',
        emptyIcon: Icons.bookmark_border_rounded,
        emptyMessage: l10n.profileSavedEmpty,
      ),
    );
  }

  Widget _photosSliver(AppLocalizations l10n) {
    final media = _posts.expand((p) => p.media).toList();
    final seedPhotos = SocialSeedRepository.photosForUser(
      SocialSeedRepository.currentUserId,
      currentProfile: _profile,
    );
    final photos = media.isNotEmpty ? media : seedPhotos;
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

class _EditSocialProfileSheet extends StatefulWidget {
  const _EditSocialProfileSheet({
    required this.initial,
    required this.client,
    required this.l10n,
  });

  final UserProfile initial;
  final SocialApiClient? client;
  final AppLocalizations l10n;

  @override
  State<_EditSocialProfileSheet> createState() => _EditSocialProfileSheetState();
}

class _EditSocialProfileSheetState extends State<_EditSocialProfileSheet> {
  final _picker = ImagePicker();
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final TextEditingController _notes;
  late final TextEditingController _weight;
  late final TextEditingController _height;
  late final TextEditingController _goal;
  late String _avatarUrl;
  late String _coverUrl;
  late bool _isPublic;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _name = TextEditingController(text: p.displayName);
    _bio = TextEditingController(text: p.bio);
    _notes = TextEditingController(text: p.privateNotes);
    _weight = TextEditingController(text: _formatMetric(p.weightKg));
    _height = TextEditingController(text: _formatMetric(p.heightCm));
    _goal = TextEditingController(text: p.fitnessGoal);
    _avatarUrl = widget.initial.avatarUrl;
    _coverUrl = widget.initial.coverUrl;
    _isPublic = widget.initial.isPublic;
  }

  static String _formatMetric(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toString();
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _notes.dispose();
    _weight.dispose();
    _height.dispose();
    _goal.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final client = widget.client;
    if (client == null) return;
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 86, maxWidth: 1200);
    if (image == null) return;
    setState(() => _saving = true);
    final url = await client.uploadImage(image, 'avatars');
    if (!mounted) return;
    setState(() {
      _avatarUrl = url;
      _saving = false;
    });
  }

  Future<void> _pickCover() async {
    final client = widget.client;
    if (client == null) return;
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 86, maxWidth: 1600);
    if (image == null) return;
    setState(() => _saving = true);
    final url = await client.uploadImage(image, 'covers');
    if (!mounted) return;
    setState(() {
      _coverUrl = url;
      _saving = false;
    });
  }

  void _save() {
    final l10n = widget.l10n;
    final name = _name.text.trim();
    final w = _parsePositiveMetric(_weight.text);
    final h = _parsePositiveMetric(_height.text);
    if (name.isEmpty) {
      setState(() => _error = l10n.validationProfileName);
      return;
    }
    if (w == null) {
      setState(() => _error = l10n.validationProfileWeight);
      return;
    }
    if (h == null) {
      setState(() => _error = l10n.validationProfileHeight);
      return;
    }
    Navigator.pop(
      context,
      widget.initial.copyWith(
        displayName: name,
        bio: _bio.text.trim(),
        privateNotes: _notes.text.trim(),
        avatarUrl: _avatarUrl,
        coverUrl: _coverUrl,
        isPublic: _isPublic,
        weightKg: w,
        heightCm: h,
        fitnessGoal: _goal.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: PremiumColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(PremiumRadii.xl)),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.profileEditSheetTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                if (widget.client != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      SocialAvatar(name: _name.text, imageUrl: _avatarUrl, size: 64),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _saving ? null : _pickAvatar,
                          icon: const Icon(Icons.person_rounded),
                          label: Text(l10n.profileAvatarButton),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _saving ? null : _pickCover,
                          icon: const Icon(Icons.image_rounded),
                          label: Text(l10n.profileCoverButton),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                _DarkField(
                  controller: _name,
                  label: l10n.labelName,
                  onChanged: (_) => setState(() => _error = null),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _DarkField(
                        controller: _weight,
                        label: l10n.labelWeightKg,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() => _error = null),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DarkField(
                        controller: _height,
                        label: l10n.labelHeightCm,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() => _error = null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _DarkField(
                  controller: _goal,
                  label: l10n.labelFitnessGoal,
                  maxLines: 2,
                  onChanged: (_) => setState(() => _error = null),
                ),
                const SizedBox(height: 10),
                _DarkField(controller: _bio, label: l10n.profilePublicBioLabel, maxLines: 3),
                const SizedBox(height: 10),
                _DarkField(controller: _notes, label: l10n.profilePrivateNotes, maxLines: 4),
                SwitchListTile(
                  value: _isPublic,
                  title: Text(l10n.profilePublicToggleTitle, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    l10n.profilePublicToggleSubtitle,
                    style: const TextStyle(color: PremiumColors.textMuted),
                  ),
                  onChanged: (v) => setState(() => _isPublic = v),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  const _DarkField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: PremiumColors.textSecondary),
        filled: true,
        fillColor: PremiumColors.midnightBottom,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PremiumRadii.lg),
          borderSide: const BorderSide(color: PremiumColors.glassBorder),
        ),
      ),
    );
  }
}
