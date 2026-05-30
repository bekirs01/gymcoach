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
    final prefs = await SharedPreferences.getInstance();
    final client = SocialApiClient(prefs: prefs);
    await client.ensureProfile(_profile);
    if (!mounted) return;
    setState(() => _client = client);
    await _loadSocial();
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
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingSocial = false);
    }
  }

  Future<void> _editProfile() async {
    final client = _client;
    if (client == null) return;
    final result = await showModalBottomSheet<UserProfile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSocialProfileSheet(initial: _profile, client: client),
    );
    if (!mounted || result == null) return;
    setState(() => _profile = result);
    widget.onProfileChanged(result);
    await client.updateProfile(
      displayName: result.displayName,
      bio: result.bio,
      privateNotes: result.privateNotes,
      avatarUrl: result.avatarUrl,
      coverUrl: result.coverUrl,
      isPublic: result.isPublic,
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
                                  _profile.bio.isEmpty ? 'No public bio yet.' : _profile.bio,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: PremiumColors.textSecondary, height: 1.35),
                                ),
                                const SizedBox(height: 18),
                                ProfileSegmentTabs(
                                  labels: const ['Photos', 'About', 'Feed', 'Saved', 'Settings'],
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
                      ..._tabSlivers(langLabel),
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

  List<Widget> _tabSlivers(String langLabel) {
    switch (_tab) {
      case 0:
        return [_photosSliver()];
      case 1:
        return [_aboutSliver()];
      case 2:
        return [_postsSliver()];
      case 3:
        return [_savedSliver()];
      default:
        return [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _SettingsCard(
                langLabel: langLabel,
                notifications: _profile.notificationsEnabled,
                onEdit: _editProfile,
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

  Widget _aboutSliver() {
    return SliverToBoxAdapter(
      child: ProfileAboutSection(
        bio: _profile.bio,
        extraSections: [
          ProfileAboutBlock(
            title: 'Private notes',
            body: _profile.privateNotes.isEmpty
                ? 'Add private notes only you can see.'
                : _profile.privateNotes,
            icon: Icons.lock_outline_rounded,
          ),
          ProfileAboutBlock(
            title: 'Fitness',
            body: '${_profile.fitnessGoal}\n${_profile.weightKg} kg · ${_profile.heightCm} cm',
            icon: Icons.fitness_center_rounded,
          ),
        ],
      ),
    );
  }

  Widget _postsSliver() {
    return SliverToBoxAdapter(
      child: ProfileFeedSection(
        posts: _posts,
        heroTagPrefix: 'own-feed',
      ),
    );
  }

  Widget _savedSliver() {
    return SliverToBoxAdapter(
      child: ProfileFeedSection(
        posts: _savedPosts,
        heroTagPrefix: 'own-saved',
        emptyIcon: Icons.bookmark_border_rounded,
        emptyMessage: 'No saved posts yet. Tap bookmark on a feed post to save it here.',
      ),
    );
  }

  Widget _photosSliver() {
    final media = _posts.expand((p) => p.media).toList();
    return SliverToBoxAdapter(
      child: ProfilePhotoGrid(
        media: media,
        heroTagPrefix: 'own-photo',
      ),
    );
  }
}

class _ProfileSheetChrome extends StatelessWidget {
  const _ProfileSheetChrome({
    required this.onClose,
    required this.onEdit,
  });

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
                tooltip: 'Close',
              ),
              const Expanded(
                child: Text(
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
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit'),
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
    required this.langLabel,
    required this.notifications,
    required this.onEdit,
    required this.onLanguage,
    required this.onNotifications,
    required this.onLogout,
  });

  final String langLabel;
  final bool notifications;
  final VoidCallback onEdit;
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
                    leading: const Icon(Icons.edit_rounded, color: PremiumColors.accentBlue),
                    title: const Text('Edit profile', style: TextStyle(color: Colors.white)),
                    onTap: onEdit,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Icon(Icons.language_rounded, color: PremiumColors.accentBlue),
                    title: const Text('Language', style: TextStyle(color: Colors.white)),
                    subtitle: Text(langLabel, style: const TextStyle(color: PremiumColors.textMuted)),
                    onTap: onLanguage,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    value: notifications,
                    activeThumbColor: PremiumColors.accentBlue,
                    title: const Text('Workout reminders', style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Keep training notifications enabled', style: TextStyle(color: PremiumColors.textMuted)),
                    onChanged: onNotifications,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    title: const Text('Log out', style: TextStyle(color: Colors.white)),
                    onTap: onLogout,
                  ),
                ),
              ],
            ),
    );
  }
}

class _EditSocialProfileSheet extends StatefulWidget {
  const _EditSocialProfileSheet({required this.initial, required this.client});

  final UserProfile initial;
  final SocialApiClient client;

  @override
  State<_EditSocialProfileSheet> createState() => _EditSocialProfileSheetState();
}

class _EditSocialProfileSheetState extends State<_EditSocialProfileSheet> {
  final _picker = ImagePicker();
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final TextEditingController _notes;
  late String _avatarUrl;
  late String _coverUrl;
  late bool _isPublic;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial.displayName);
    _bio = TextEditingController(text: widget.initial.bio);
    _notes = TextEditingController(text: widget.initial.privateNotes);
    _avatarUrl = widget.initial.avatarUrl;
    _coverUrl = widget.initial.coverUrl;
    _isPublic = widget.initial.isPublic;
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 86, maxWidth: 1200);
    if (image == null) return;
    setState(() => _saving = true);
    final url = await widget.client.uploadImage(image, 'avatars');
    if (!mounted) return;
    setState(() {
      _avatarUrl = url;
      _saving = false;
    });
  }

  Future<void> _pickCover() async {
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 86, maxWidth: 1600);
    if (image == null) return;
    setState(() => _saving = true);
    final url = await widget.client.uploadImage(image, 'covers');
    if (!mounted) return;
    setState(() {
      _coverUrl = url;
      _saving = false;
    });
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(
      context,
      widget.initial.copyWith(
        displayName: name,
        bio: _bio.text.trim(),
        privateNotes: _notes.text.trim(),
        avatarUrl: _avatarUrl,
        coverUrl: _coverUrl,
        isPublic: _isPublic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Edit profile',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    SocialAvatar(name: _name.text, imageUrl: _avatarUrl, size: 64),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saving ? null : _pickAvatar,
                        icon: const Icon(Icons.person_rounded),
                        label: const Text('Avatar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saving ? null : _pickCover,
                        icon: const Icon(Icons.image_rounded),
                        label: const Text('Cover'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DarkField(controller: _name, label: 'Name'),
                const SizedBox(height: 10),
                _DarkField(controller: _bio, label: 'Public bio', maxLines: 3),
                const SizedBox(height: 10),
                _DarkField(controller: _notes, label: 'Private notes', maxLines: 4),
                SwitchListTile(
                  value: _isPublic,
                  title: const Text('Public profile', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Visible in Feed and Leaderboard', style: TextStyle(color: PremiumColors.textMuted)),
                  onChanged: (v) => setState(() => _isPublic = v),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save'),
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
  const _DarkField({required this.controller, required this.label, this.maxLines = 1});

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.initial, required this.l10n});

  final UserProfile initial;
  final AppLocalizations l10n;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _goalController;
  late String _membership;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _nameController = TextEditingController(text: p.displayName);
    _weightController = TextEditingController(text: p.weightKg.toString());
    _heightController = TextEditingController(text: p.heightCm.toString());
    _goalController = TextEditingController(text: p.fitnessGoal);
    _membership = p.membershipLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = widget.l10n;
    final name = _nameController.text.trim();
    final w = _parsePositiveMetric(_weightController.text);
    final h = _parsePositiveMetric(_heightController.text);
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
    final next = widget.initial.copyWith(
      displayName: name,
      weightKg: w,
      heightCm: h,
      fitnessGoal: _goalController.text.trim(),
      membershipLevel: _membership,
    );
    Navigator.of(context).pop(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final tiers = [l10n.membershipFree, l10n.membershipPlus, l10n.membershipPremium];

    return AlertDialog(
      title: Text(l10n.profileEditSheetTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.labelName),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() => _error = null),
            ),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(labelText: l10n.labelWeightKg),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
              onChanged: (_) => setState(() => _error = null),
            ),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(labelText: l10n.labelHeightCm),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
              onChanged: (_) => setState(() => _error = null),
            ),
            TextField(
              controller: _goalController,
              decoration: InputDecoration(labelText: l10n.labelFitnessGoal),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.labelMembership,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in tiers)
                  ChoiceChip(
                    label: Text(m),
                    selected: _membership == m,
                    onSelected: (_) => setState(() => _membership = m),
                    selectedColor: AppColors.successTint,
                    checkmarkColor: AppColors.primaryDark,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _membership == m ? AppColors.primaryDark : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                      color: _membership == m ? AppColors.primary : AppColors.borderSubtle,
                    ),
                  ),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
