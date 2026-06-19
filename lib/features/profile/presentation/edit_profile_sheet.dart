import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/premium_tokens.dart';
import '../../feed/presentation/social_avatar.dart';
import '../../social/data/social_api_client.dart';
import '../data/profile_repository.dart';
import '../domain/profile_defaults.dart';
import '../domain/user_profile.dart';
import 'widgets/edit_profile_widgets.dart';

abstract final class ProfileFieldOptions {
  static const fitnessGoals = [
    'Build muscle',
    'Lose fat',
    'Improve strength',
    'Improve endurance',
    'Stay consistent',
    'Mobility and recovery',
    'Strength and conditioning',
  ];

  static const experienceLevels = ['Beginner', 'Intermediate', 'Advanced'];
  static const activityLevels = ['Low', 'Moderate', 'High', 'Athlete'];
  static const weeklyTargets = [
    '1 workout / week',
    '2 workouts / week',
    '3 workouts / week',
    '4 workouts / week',
    '5 workouts / week',
    '6 workouts / week',
    '7 workouts / week',
  ];

  static String experienceLabel(String value) {
    switch (value) {
      case 'beginner':
        return 'Beginner';
      case 'advanced':
        return 'Advanced';
      default:
        return 'Intermediate';
    }
  }

  static String experienceValue(String label) {
    switch (label) {
      case 'Beginner':
        return 'beginner';
      case 'Advanced':
        return 'advanced';
      default:
        return 'intermediate';
    }
  }

  static String activityLabel(String value) {
    switch (value) {
      case 'low':
        return 'Low';
      case 'high':
        return 'High';
      case 'athlete':
        return 'Athlete';
      default:
        return 'Moderate';
    }
  }

  static String activityValue(String label) {
    switch (label) {
      case 'Low':
        return 'low';
      case 'High':
        return 'high';
      case 'Athlete':
        return 'athlete';
      default:
        return 'moderate';
    }
  }

  static String weeklyTargetLabel(int value) {
    if (value < 1 || value > 7) return weeklyTargets[3];
    return weeklyTargets[value - 1];
  }

  static int weeklyTargetValue(String label) {
    final index = weeklyTargets.indexOf(label);
    return index >= 0 ? index + 1 : ProfileDefaults.weeklyWorkoutTarget;
  }
}

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({
    super.key,
    required this.initial,
    required this.repository,
    required this.socialClient,
    required this.l10n,
  });

  final UserProfile initial;
  final ProfileRepository? repository;
  final SocialApiClient? socialClient;
  final AppLocalizations l10n;

  static Future<UserProfile?> show(
    BuildContext context, {
    required UserProfile initial,
    required ProfileRepository? repository,
    required SocialApiClient? socialClient,
    required AppLocalizations l10n,
  }) {
    return showModalBottomSheet<UserProfile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSheet(
        initial: initial,
        repository: repository,
        socialClient: socialClient,
        l10n: l10n,
      ),
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _picker = ImagePicker();
  late final TextEditingController _name;
  late final TextEditingController _location;
  late final TextEditingController _trainingFocus;
  late final TextEditingController _bio;
  late final TextEditingController _notes;

  late double _weightKg;
  late double _heightCm;
  double? _targetWeightKg;
  late String _fitnessGoal;
  late String _experienceLevel;
  late String _activityLevel;
  late int _weeklyTarget;
  late String _avatarUrl;
  late String _coverUrl;
  late bool _isPublic;
  var _saving = false;
  var _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = UserProfile.withDefaults(membershipLevel: widget.initial.membershipLevel, seed: widget.initial);
    _name = TextEditingController(text: p.displayName);
    _location = TextEditingController(text: p.locationText);
    _trainingFocus = TextEditingController(text: p.trainingFocus);
    _bio = TextEditingController(text: p.publicBio);
    _notes = TextEditingController(text: p.privateNotes);
    _weightKg = p.weightKg;
    _heightCm = p.heightCm;
    _targetWeightKg = p.targetWeightKg;
    _fitnessGoal = p.fitnessGoal;
    _experienceLevel = p.experienceLevel;
    _activityLevel = p.activityLevel;
    _weeklyTarget = p.weeklyWorkoutTarget;
    _avatarUrl = p.avatarUrl;
    _coverUrl = p.coverUrl;
    _isPublic = p.isPublicProfile;
    _loadRemote();
  }

  Future<void> _loadRemote() async {
    final repo = widget.repository;
    if (repo == null) return;
    setState(() => _loading = true);
    try {
      final loaded = await repo.loadCurrentProfile(widget.initial);
      if (!mounted) return;
      setState(() {
        _name.text = loaded.displayName;
        _location.text = loaded.locationText;
        _trainingFocus.text = loaded.trainingFocus;
        _bio.text = loaded.publicBio;
        _notes.text = loaded.privateNotes;
        _weightKg = loaded.weightKg;
        _heightCm = loaded.heightCm;
        _targetWeightKg = loaded.targetWeightKg;
        _fitnessGoal = loaded.fitnessGoal;
        _experienceLevel = loaded.experienceLevel;
        _activityLevel = loaded.activityLevel;
        _weeklyTarget = loaded.weeklyWorkoutTarget;
        _avatarUrl = loaded.avatarUrl;
        _coverUrl = loaded.coverUrl;
        _isPublic = loaded.isPublicProfile;
        _loading = false;
      });
    } catch (e) {
      debugPrint('EditProfileSheet load failed: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _trainingFocus.dispose();
    _bio.dispose();
    _notes.dispose();
    super.dispose();
  }

  UserProfile _buildProfile() {
    return widget.initial.copyWith(
      displayName: ProfileDefaults.normalizeDisplayName(_name.text.trim()),
      locationText: _location.text.trim(),
      trainingFocus: _trainingFocus.text.trim(),
      publicBio: _bio.text.trim(),
      privateNotes: _notes.text.trim(),
      weightKg: _weightKg,
      heightCm: _heightCm,
      targetWeightKg: _targetWeightKg,
      clearTargetWeightKg: _targetWeightKg == null,
      fitnessGoal: _fitnessGoal,
      experienceLevel: _experienceLevel,
      activityLevel: _activityLevel,
      weeklyWorkoutTarget: _weeklyTarget,
      avatarUrl: _avatarUrl,
      coverUrl: _coverUrl,
      isPublicProfile: _isPublic,
    );
  }

  Future<void> _pickAvatar() async {
    final client = widget.socialClient;
    if (client == null) {
      _showComingSoon('Avatar upload coming soon');
      return;
    }
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 86, maxWidth: 1200);
    if (image == null) return;
    setState(() => _saving = true);
    try {
      final url = await client.uploadImage(image, 'avatars');
      if (!mounted) return;
      setState(() {
        _avatarUrl = url;
        _saving = false;
      });
    } catch (e) {
      debugPrint('Avatar upload failed: $e');
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickCover() async {
    final client = widget.socialClient;
    if (client == null) {
      _showComingSoon('Cover upload coming soon');
      return;
    }
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 86, maxWidth: 1600);
    if (image == null) return;
    setState(() => _saving = true);
    try {
      final url = await client.uploadImage(image, 'covers');
      if (!mounted) return;
      setState(() {
        _coverUrl = url;
        _saving = false;
      });
    } catch (e) {
      debugPrint('Cover upload failed: $e');
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  Future<void> _pickWeight({required bool target}) async {
    final result = await ProfileNumberPickerSheet.showWeight(
      context,
      title: target ? 'Target weight' : 'Weight',
      initialValue: target ? (_targetWeightKg ?? _weightKg) : _weightKg,
      allowClear: target,
      initialNullable: target ? _targetWeightKg : null,
    );
    if (!mounted || result == null) return;
    if (target && result < 0) {
      setState(() => _targetWeightKg = null);
      return;
    }
    setState(() {
      if (target) {
        _targetWeightKg = result;
      } else {
        _weightKg = result;
      }
    });
  }

  Future<void> _pickHeight() async {
    final result = await ProfileNumberPickerSheet.showHeight(
      context,
      title: 'Height',
      initialValue: _heightCm,
    );
    if (!mounted || result == null) return;
    setState(() => _heightCm = result);
  }

  Future<void> _pickFitnessGoal() async {
    final result = await ProfileOptionPickerSheet.show(
      context,
      title: widget.l10n.labelFitnessGoal,
      options: ProfileFieldOptions.fitnessGoals,
      selected: _fitnessGoal,
    );
    if (result != null) setState(() => _fitnessGoal = result);
  }

  Future<void> _pickExperience() async {
    final result = await ProfileOptionPickerSheet.show(
      context,
      title: 'Experience level',
      options: ProfileFieldOptions.experienceLevels,
      selected: ProfileFieldOptions.experienceLabel(_experienceLevel),
    );
    if (result != null) setState(() => _experienceLevel = ProfileFieldOptions.experienceValue(result));
  }

  Future<void> _pickActivity() async {
    final result = await ProfileOptionPickerSheet.show(
      context,
      title: 'Activity level',
      options: ProfileFieldOptions.activityLevels,
      selected: ProfileFieldOptions.activityLabel(_activityLevel),
    );
    if (result != null) setState(() => _activityLevel = ProfileFieldOptions.activityValue(result));
  }

  Future<void> _pickWeeklyTarget() async {
    final result = await ProfileOptionPickerSheet.show(
      context,
      title: 'Weekly target',
      options: ProfileFieldOptions.weeklyTargets,
      selected: ProfileFieldOptions.weeklyTargetLabel(_weeklyTarget),
    );
    if (result != null) setState(() => _weeklyTarget = ProfileFieldOptions.weeklyTargetValue(result));
  }

  Future<void> _save() async {
    final l10n = widget.l10n;
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l10n.validationProfileName);
      return;
    }
    final profile = _buildProfile();
    final repo = widget.repository;
    setState(() {
      _saving = true;
      _error = null;
    });
    if (repo != null) {
      try {
        await repo.saveProfile(profile);
      } catch (e) {
        debugPrint('Could not save profile: $e');
        if (!mounted) return;
        setState(() {
          _saving = false;
          _error = 'Could not save profile';
        });
        return;
      }
    }
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(behavior: SnackBarBehavior.floating, content: Text('Profile updated')),
    );
    Navigator.pop(context, profile);
  }

  String _weightLabel(double value) => '${value.toStringAsFixed(1)} kg';

  String _heightLabel(double value) => '${value.round()} cm';

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.94),
        decoration: const BoxDecoration(
          color: PremiumColors.midnightMid,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
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
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: PremiumColors.textSecondary),
                    ),
                    Expanded(
                      child: Text(
                        l10n.profileEditSheetTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              if (_loading)
                const LinearProgressIndicator(minHeight: 2, color: PremiumColors.accentBlue, backgroundColor: Colors.transparent),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileSectionCard(
                        title: 'Avatar',
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                SocialAvatar(name: _name.text, imageUrl: _avatarUrl, size: 72),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ProfileOutlineButton(
                                    icon: Icons.person_rounded,
                                    label: l10n.profileAvatarButton,
                                    onPressed: _saving ? null : _pickAvatar,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ProfileOutlineButton(
                                    icon: Icons.image_rounded,
                                    label: l10n.profileCoverButton,
                                    onPressed: _saving ? null : _pickCover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ProfileSectionCard(
                        title: 'Basic info',
                        children: [
                          ProfileTextField(controller: _name, label: l10n.labelName, onChanged: (_) => setState(() => _error = null)),
                          ProfileTextField(controller: _location, label: 'Location'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ProfileSectionCard(
                        title: 'Body metrics',
                        children: [
                          ProfileMetricTile(
                            label: l10n.labelWeightKg,
                            value: _weightLabel(_weightKg),
                            onTap: _saving ? null : () => _pickWeight(target: false),
                          ),
                          ProfileMetricTile(
                            label: l10n.labelHeightCm,
                            value: _heightLabel(_heightCm),
                            onTap: _saving ? null : _pickHeight,
                          ),
                          ProfileMetricTile(
                            label: 'Target weight',
                            value: _targetWeightKg == null ? '' : _weightLabel(_targetWeightKg!),
                            placeholder: 'Optional',
                            onTap: _saving ? null : () => _pickWeight(target: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ProfileSectionCard(
                        title: 'Goals',
                        children: [
                          ProfileMetricTile(
                            label: l10n.labelFitnessGoal,
                            value: _fitnessGoal,
                            onTap: _saving ? null : _pickFitnessGoal,
                          ),
                          ProfileTextField(controller: _trainingFocus, label: 'Training focus', maxLines: 2),
                          ProfileMetricTile(
                            label: 'Experience level',
                            value: ProfileFieldOptions.experienceLabel(_experienceLevel),
                            onTap: _saving ? null : _pickExperience,
                          ),
                          ProfileMetricTile(
                            label: 'Activity level',
                            value: ProfileFieldOptions.activityLabel(_activityLevel),
                            onTap: _saving ? null : _pickActivity,
                          ),
                          ProfileMetricTile(
                            label: 'Weekly workout target',
                            value: ProfileFieldOptions.weeklyTargetLabel(_weeklyTarget),
                            onTap: _saving ? null : _pickWeeklyTarget,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ProfileSectionCard(
                        title: 'Profile visibility',
                        children: [
                          ProfileTextField(controller: _bio, label: l10n.profilePublicBioLabel, maxLines: 3),
                          ProfileTextField(
                            controller: _notes,
                            label: l10n.profilePrivateNotes,
                            maxLines: 4,
                            helperText: 'Only you can see this.',
                          ),
                          SwitchListTile(
                            value: _isPublic,
                            activeThumbColor: PremiumColors.accentBlue,
                            title: Text(l10n.profilePublicToggleTitle, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(
                              l10n.profilePublicToggleSubtitle,
                              style: const TextStyle(color: PremiumColors.textMuted, fontSize: 12),
                            ),
                            onChanged: _saving ? null : (v) => setState(() => _isPublic = v),
                          ),
                        ],
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!, style: const TextStyle(color: PremiumColors.errorRed, fontSize: 13)),
                      ],
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: PremiumColors.accentBlue,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PremiumRadii.lg)),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: PremiumColors.accentBlue),
                              )
                            : Text(l10n.save, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
