import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/user_profile.dart';

double? _parsePositiveMetric(String raw) {
  final normalized = raw.trim().replaceAll(' ', '').replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  final value = double.tryParse(normalized);
  if (value == null || value <= 0 || !value.isFinite) return null;
  return value;
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

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _profile = widget.profile;
    }
  }

  Future<void> _editProfile() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<UserProfile>(
      context: context,
      builder: (dialogContext) => _EditProfileDialog(initial: _profile, l10n: l10n),
    );
    if (!mounted || result == null) return;
    setState(() => _profile = result);
    widget.onProfileChanged(result);
  }

  void _preferences() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(l10n.profilePreferencesSnack),
      ),
    );
  }

  void _pickLanguage() {
    final l10n = AppLocalizations.of(context)!;
    final code = Localizations.localeOf(context).languageCode;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.languagePickerTitle,
                    style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              RadioListTile<String>(
                title: Text(l10n.languageEnglish),
                value: 'en',
                groupValue: code,
                onChanged: (v) {
                  if (v == null) return;
                  Navigator.pop(sheetContext);
                  widget.onLocaleChanged(Locale(v));
                },
              ),
              RadioListTile<String>(
                title: Text(l10n.languageRussian),
                value: 'ru',
                groupValue: code,
                onChanged: (v) {
                  if (v == null) return;
                  Navigator.pop(sheetContext);
                  widget.onLocaleChanged(Locale(v));
                },
              ),
            ],
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
    final theme = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;
    final l10n = AppLocalizations.of(context)!;
    final langLabel =
        Localizations.localeOf(context).languageCode == 'ru' ? l10n.languageRussian : l10n.languageEnglish;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.profileTitle,
              style: theme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.heroGradientStart, AppColors.heroGradientEnd],
                        ),
                      ),
                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 34),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _profile.displayName,
                            style: theme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _profile.membershipLevel,
                            style: theme.titleSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _profile.fitnessGoal,
                            style: theme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: _MetricChip(label: l10n.profileWeight, value: '${_profile.weightKg} kg'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricChip(label: l10n.profileHeight, value: '${_profile.heightCm} cm'),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.profileAccount,
              style: theme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_rounded, color: AppColors.primary),
                    title: Text(l10n.profileEditProfile),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    onTap: _editProfile,
                  ),
                  const Divider(height: 1, color: AppColors.borderSubtle),
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                    title: Text(l10n.languageTitle),
                    subtitle: Text(l10n.languageSubtitle),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(langLabel, style: theme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      ],
                    ),
                    onTap: _pickLanguage,
                  ),
                  const Divider(height: 1, color: AppColors.borderSubtle),
                  ListTile(
                    leading: const Icon(Icons.tune_rounded, color: AppColors.primary),
                    title: Text(l10n.profileAppPreferences),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    onTap: _preferences,
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.profileNotificationsSection,
              style: theme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
              child: SwitchListTile(
                title: Text(l10n.profileRemindersTitle),
                subtitle: Text(l10n.profileRemindersSubtitle),
                value: _profile.notificationsEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: (v) {
                  final next = _profile.copyWith(notificationsEnabled: v);
                  setState(() => _profile = next);
                  widget.onProfileChanged(next);
                },
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  side: const BorderSide(color: AppColors.borderSubtle),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.profileLogOut, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ),
      ],
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

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.labelSmall?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
