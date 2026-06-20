import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../domain/profile_settings_options.dart';
import 'settings_flag_icon.dart';
import 'settings_widgets.dart';

Future<AppLanguageCode?> showLanguagePickerSheet({
  required BuildContext context,
  required AppLanguageCode selected,
}) {
  return showModalBottomSheet<AppLanguageCode>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: PremiumColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SettingsSheetShell(
          title: 'Choose language',
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final language in AppLanguageCode.values)
                SettingsPickerTile(
                  leading: SettingsFlagIcon(language: language),
                  title: language.nativeLabel,
                  subtitle: language.subtitle,
                  selected: language == selected,
                  onTap: () => Navigator.pop(sheetContext, language),
                ),
              SizedBox(height: MediaQuery.paddingOf(sheetContext).bottom + 12),
            ],
          ),
        ),
      );
    },
  );
}

Future<MeasurementUnits?> showUnitsPickerSheet({
  required BuildContext context,
  required MeasurementUnits selected,
}) {
  return showModalBottomSheet<MeasurementUnits>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: PremiumColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SettingsSheetShell(
          title: 'Measurement units',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final units in MeasurementUnits.values)
                SettingsPickerTile(
                  leading: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: PremiumColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: PremiumColors.glassBorder),
                    ),
                    child: Icon(
                      units == MeasurementUnits.metric ? Icons.straighten_rounded : Icons.square_foot_rounded,
                      color: PremiumColors.accentBlue,
                      size: 18,
                    ),
                  ),
                  title: units.label,
                  subtitle: units.subtitle,
                  selected: units == selected,
                  onTap: () => Navigator.pop(sheetContext, units),
                ),
              SizedBox(height: MediaQuery.paddingOf(sheetContext).bottom + 12),
            ],
          ),
        ),
      );
    },
  );
}

Future<TimeOfDay?> showReminderTimePickerSheet({
  required BuildContext context,
  required TimeOfDay initial,
}) {
  var selected = initial;
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: PremiumColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SettingsSheetShell(
          title: 'Reminder time',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 220,
                child: CupertinoTheme(
                  data: const CupertinoThemeData(brightness: Brightness.dark),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(2024, 1, 1, initial.hour, initial.minute),
                    use24hFormat: false,
                    onDateTimeChanged: (value) {
                      selected = TimeOfDay(hour: value.hour, minute: value.minute);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetContext, selected),
                    style: FilledButton.styleFrom(
                      backgroundColor: PremiumColors.accentBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.paddingOf(sheetContext).bottom + 8),
            ],
          ),
        ),
      );
    },
  );
}

Future<({ReminderDaysMode mode, Set<int> customDays})?> showReminderDaysPickerSheet({
  required BuildContext context,
  required ReminderDaysMode selectedMode,
  required Set<int> customDays,
}) {
  var mode = selectedMode;
  var days = Set<int>.from(customDays);
  return showModalBottomSheet<({ReminderDaysMode mode, Set<int> customDays})>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              color: PremiumColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SettingsSheetShell(
              title: 'Reminder days',
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final option in ReminderDaysMode.values)
                    SettingsPickerTile(
                      leading: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: PremiumColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: PremiumColors.glassBorder),
                        ),
                        child: const Icon(Icons.event_repeat_rounded, color: PremiumColors.accentBlue, size: 18),
                      ),
                      title: option.label,
                      subtitle: option == ReminderDaysMode.custom ? 'Pick specific days' : 'Recommended schedule',
                      selected: mode == option,
                      onTap: () => setSheetState(() => mode = option),
                    ),
                  if (mode == ReminderDaysMode.custom) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                      child: Text(
                        'Select days',
                        style: TextStyle(color: PremiumColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(7, (index) {
                          final day = index + 1;
                          const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final active = days.contains(day);
                          return FilterChip(
                            label: Text(names[index]),
                            selected: active,
                            onSelected: (value) {
                              setSheetState(() {
                                if (value) {
                                  days.add(day);
                                } else {
                                  days.remove(day);
                                }
                                if (days.isEmpty) days.add(day);
                              });
                            },
                            backgroundColor: PremiumColors.surfaceRaised,
                            selectedColor: PremiumColors.tabActive,
                            labelStyle: TextStyle(
                              color: active ? Colors.white : PremiumColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(color: active ? PremiumColors.accentBlue.withValues(alpha: 0.5) : PremiumColors.glassBorder),
                            showCheckmark: false,
                          );
                        }),
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(sheetContext, (mode: mode, customDays: days)),
                        style: FilledButton.styleFrom(
                          backgroundColor: PremiumColors.accentBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.paddingOf(sheetContext).bottom + 8),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<bool?> showLogoutConfirmationSheet({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: PremiumColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(color: PremiumColors.textSecondary, fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PremiumColors.textSecondary,
                          side: const BorderSide(color: PremiumColors.glassBorder),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(sheetContext, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: PremiumColors.errorRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(confirmLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
