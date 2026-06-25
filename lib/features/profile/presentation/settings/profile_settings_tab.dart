import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../data/profile_repository.dart';
import '../../data/settings_permission_service.dart';
import '../../domain/profile_settings_options.dart';
import '../../domain/user_profile.dart';
import 'settings_flag_icon.dart';
import 'settings_info_content_l10n.dart';
import 'settings_info_pages.dart';
import 'settings_sheets.dart';
import 'settings_widgets.dart';

class ProfileSettingsTab extends StatefulWidget {
  const ProfileSettingsTab({
    super.key,
    required this.profile,
    required this.repository,
    required this.onProfileChanged,
    required this.onLocaleChanged,
    required this.onLogout,
  });

  final UserProfile profile;
  final ProfileRepository? repository;
  final ValueChanged<UserProfile> onProfileChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback onLogout;

  @override
  State<ProfileSettingsTab> createState() => _ProfileSettingsTabState();
}

class _ProfileSettingsTabState extends State<ProfileSettingsTab> with WidgetsBindingObserver {
  final _permissionService = SettingsPermissionService();
  late UserProfile _profile;
  var _saving = false;
  final _permissionSnapshots = <SettingsPermissionKind, SettingsPermissionSnapshot>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _profile = widget.profile;
    unawaited(_refreshPermissions());
  }

  @override
  void didUpdateWidget(covariant ProfileSettingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _profile = widget.profile;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshPermissions());
    }
  }

  Future<void> _refreshPermissions() async {
    final results = await Future.wait(
      SettingsPermissionKind.values.map((kind) async {
        final snapshot = await _permissionService.read(kind);
        return MapEntry(kind, snapshot);
      }),
    );
    if (!mounted) return;
    setState(() {
      _permissionSnapshots
        ..clear()
        ..addEntries(results);
    });
  }

  Future<void> _persist(UserProfile next) async {
    setState(() {
      _profile = next;
      _saving = true;
    });
    widget.onProfileChanged(next);
    final repository = widget.repository;
    if (repository != null) {
      try {
        await repository.saveProfile(next);
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() => _saving = false);
  }

  AppLanguageCode get _language => AppLanguageCode.fromCode(_profile.preferredLanguage);

  MeasurementUnits get _units => MeasurementUnits.fromCode(_profile.preferredUnits);

  Set<int> get _customReminderDays => ReminderDaysCodec.decodeCustomDays(_profile.trainingReminderDays);

  ReminderDaysMode get _reminderDaysMode => ReminderDaysMode.fromStorage(_profile.trainingReminderDays);

  Future<void> _pickLanguage() async {
    final picked = await showLanguagePickerSheet(context: context, selected: _language);
    if (picked == null || picked == _language) return;
    final next = _profile.copyWith(preferredLanguage: picked.storageCode);
    await _persist(next);
    widget.onLocaleChanged(picked.locale);
  }

  Future<void> _pickUnits() async {
    final picked = await showUnitsPickerSheet(context: context, selected: _units);
    if (picked == null || picked == _units) return;
    await _persist(_profile.copyWith(preferredUnits: picked.storageCode));
  }

  Future<void> _openSystemSettings() async {
    final opened = await _permissionService.openSystemSettings();
    if (!opened && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsCouldNotOpenSettings),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggleReminders(bool enabled) async {
    if (enabled) {
      final snapshot = await _permissionService.read(SettingsPermissionKind.notifications);
      if (!snapshot.isGranted) {
        if (snapshot.canRequest) {
          final requested = await _permissionService.request(SettingsPermissionKind.notifications);
          await _refreshPermissions();
          if (!requested.isGranted) {
            await _openSystemSettings();
            return;
          }
        } else {
          await _openSystemSettings();
          return;
        }
      }
    }
    await _persist(_profile.copyWith(notificationsEnabled: enabled));
  }

  Future<void> _pickReminderTime() async {
    if (!_profile.notificationsEnabled) return;
    final initial = ReminderTimeCodec.decode(_profile.trainingReminderTime);
    final picked = await showReminderTimePickerSheet(context: context, initial: initial);
    if (picked == null) return;
    await _persist(_profile.copyWith(trainingReminderTime: ReminderTimeCodec.encode(picked)));
  }

  Future<void> _pickReminderDays() async {
    if (!_profile.notificationsEnabled) return;
    final picked = await showReminderDaysPickerSheet(
      context: context,
      selectedMode: _reminderDaysMode,
      customDays: _customReminderDays,
    );
    if (picked == null) return;
    final encoded = ReminderDaysCodec.encode(picked.mode, picked.customDays);
    await _persist(_profile.copyWith(trainingReminderDays: encoded));
  }

  Future<void> _handlePermissionToggle(SettingsPermissionKind kind, bool enable) async {
    final current = _permissionSnapshots[kind];
    if (current == null) return;

    if (enable) {
      if (current.isGranted) return;
      if (current.canRequest) {
        final result = await _permissionService.request(kind);
        await _refreshPermissions();
        if (!result.isGranted) {
          await _openSystemSettings();
        }
      } else {
        await _openSystemSettings();
      }
      return;
    }

    if (!current.isGranted) return;
    await _openSystemSettings();
  }

  Future<void> _confirmLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showLogoutConfirmationSheet(
      context: context,
      title: l10n.profileLogOut,
      message: l10n.profileLogoutSnack,
      confirmLabel: l10n.profileLogOut,
    );
    if (confirmed == true && mounted) {
      widget.onLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_saving)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: LinearProgressIndicator(
              minHeight: 2,
              color: PremiumColors.accentBlue,
              backgroundColor: PremiumColors.surfaceRaised,
            ),
          ),
        SettingsSectionCard(
          title: l10n.settingsPreferences,
          children: [
            SettingsRow(
              icon: Icons.language_rounded,
              title: l10n.languageTitle,
              subtitle: _language.nativeLabel,
              leading: SettingsFlagIcon(language: _language, size: 34),
              showChevron: true,
              onTap: _pickLanguage,
            ),
            SettingsRow(
              icon: Icons.straighten_rounded,
              title: l10n.settingsUnits,
              subtitle: _units.localizedLabel(l10n),
              showChevron: true,
              onTap: _pickUnits,
            ),
            SettingsRow(
              icon: Icons.dark_mode_rounded,
              title: l10n.settingsTheme,
              subtitle: l10n.settingsThemeDark,
            ),
          ],
        ),
        const SizedBox(height: 18),
        SettingsSectionCard(
          title: l10n.settingsPermissions,
          footer: l10n.settingsPermissionsFooter,
          children: [
            for (final kind in SettingsPermissionKind.values) _permissionRow(kind, l10n),
          ],
        ),
        const SizedBox(height: 18),
        SettingsSectionCard(
          title: l10n.settingsNotificationsSection,
          children: [
            SettingsSwitchRow(
              icon: Icons.notifications_active_outlined,
              title: l10n.profileRemindersTitle,
              subtitle: l10n.profileRemindersSubtitle,
              value: _profile.notificationsEnabled,
              onChanged: _toggleReminders,
            ),
            SettingsRow(
              icon: Icons.schedule_rounded,
              title: l10n.settingsReminderTime,
              subtitle: ReminderTimeCodec.localizedDisplay(l10n, _profile.trainingReminderTime),
              showChevron: true,
              enabled: _profile.notificationsEnabled,
              onTap: _pickReminderTime,
            ),
            SettingsRow(
              icon: Icons.date_range_rounded,
              title: l10n.settingsReminderDays,
              subtitle: ReminderDaysCodec.localizedDisplayLabel(l10n, _profile.trainingReminderDays),
              showChevron: true,
              enabled: _profile.notificationsEnabled,
              onTap: _pickReminderDays,
            ),
          ],
        ),
        const SizedBox(height: 18),
        SettingsSectionCard(
          title: l10n.settingsPrivacySupport,
          children: [
            SettingsRow(
              icon: Icons.privacy_tip_outlined,
              title: l10n.settingsPrivacyPolicy,
              showChevron: true,
              onTap: () => SettingsInfoPage.open(
                context,
                title: l10n.settingsPrivacyPolicy,
                body: SettingsInfoContentL10n.privacyPolicy(l10n),
              ),
            ),
            SettingsRow(
              icon: Icons.description_outlined,
              title: l10n.settingsTermsOfService,
              showChevron: true,
              onTap: () => SettingsInfoPage.open(
                context,
                title: l10n.settingsTermsOfService,
                body: SettingsInfoContentL10n.termsOfService(l10n),
              ),
            ),
            SettingsRow(
              icon: Icons.support_agent_rounded,
              title: l10n.settingsContactSupport,
              showChevron: true,
              onTap: () => SettingsInfoPage.open(
                context,
                title: l10n.settingsContactSupport,
                body: SettingsInfoContentL10n.contactSupport(l10n),
              ),
            ),
            SettingsRow(
              icon: Icons.info_outline_rounded,
              title: l10n.settingsAboutApp,
              showChevron: true,
              onTap: () => SettingsInfoPage.open(
                context,
                title: l10n.settingsAboutApp,
                body: SettingsInfoContentL10n.aboutApp(l10n),
              ),
            ),
            SettingsRow(
              icon: Icons.shield_outlined,
              title: l10n.settingsDataPermissions,
              showChevron: true,
              onTap: () => SettingsInfoPage.open(
                context,
                title: l10n.settingsDataPermissions,
                body: SettingsInfoContentL10n.dataAndPermissions(l10n),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SettingsSectionCard(
          title: l10n.settingsAccountSection,
          children: [
            SettingsRow(
              icon: Icons.logout_rounded,
              title: l10n.profileLogOut,
              subtitle: l10n.settingsSignOutSubtitle,
              destructiveTitle: true,
              onTap: _confirmLogout,
              trailing: const Icon(Icons.chevron_right_rounded, color: PremiumColors.errorRed, size: 22),
            ),
          ],
        ),
      ],
    );
  }

  Widget _permissionRow(SettingsPermissionKind kind, AppLocalizations l10n) {
    final snapshot = _permissionSnapshots[kind];
    final granted = snapshot?.isGranted ?? false;
    final statusText = snapshot?.localizedLabelText(l10n) ?? l10n.settingsChecking;

    return SettingsSwitchRow(
      icon: _permissionIcon(kind),
      title: _permissionTitle(kind, l10n),
      subtitle: _permissionSubtitle(kind, l10n),
      statusText: statusText,
      value: granted,
      onChanged: (value) => unawaited(_handlePermissionToggle(kind, value)),
    );
  }

  IconData _permissionIcon(SettingsPermissionKind kind) {
    return switch (kind) {
      SettingsPermissionKind.notifications => Icons.notifications_outlined,
      SettingsPermissionKind.camera => Icons.photo_camera_outlined,
      SettingsPermissionKind.microphone => Icons.mic_none_rounded,
      SettingsPermissionKind.photos => Icons.photo_library_outlined,
      SettingsPermissionKind.location => Icons.location_on_outlined,
    };
  }

  String _permissionTitle(SettingsPermissionKind kind, AppLocalizations l10n) {
    return switch (kind) {
      SettingsPermissionKind.notifications => l10n.settingsPermissionNotifications,
      SettingsPermissionKind.camera => l10n.settingsPermissionCamera,
      SettingsPermissionKind.microphone => l10n.settingsPermissionMicrophone,
      SettingsPermissionKind.photos => l10n.settingsPermissionPhotos,
      SettingsPermissionKind.location => l10n.settingsPermissionLocation,
    };
  }

  String _permissionSubtitle(SettingsPermissionKind kind, AppLocalizations l10n) {
    return switch (kind) {
      SettingsPermissionKind.notifications => l10n.settingsPermissionNotificationsDesc,
      SettingsPermissionKind.camera => l10n.settingsPermissionCameraDesc,
      SettingsPermissionKind.microphone => l10n.settingsPermissionMicrophoneDesc,
      SettingsPermissionKind.photos => l10n.settingsPermissionPhotosDesc,
      SettingsPermissionKind.location => l10n.settingsPermissionLocationDesc,
    };
  }
}
