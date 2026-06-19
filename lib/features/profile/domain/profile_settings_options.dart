import 'package:flutter/material.dart';

enum AppLanguageCode {
  en,
  ru,
  tr;

  String get storageCode => name;

  static AppLanguageCode fromCode(String? code) {
    return switch (code?.toLowerCase()) {
      'ru' => AppLanguageCode.ru,
      'tr' => AppLanguageCode.tr,
      _ => AppLanguageCode.en,
    };
  }

  Locale get locale => switch (this) {
        AppLanguageCode.ru => const Locale('ru'),
        AppLanguageCode.tr => const Locale('tr'),
        AppLanguageCode.en => const Locale('en'),
      };

  String get nativeLabel => switch (this) {
        AppLanguageCode.en => 'English',
        AppLanguageCode.ru => 'Русский',
        AppLanguageCode.tr => 'Türkçe',
      };

  String get subtitle => switch (this) {
        AppLanguageCode.en => 'United States',
        AppLanguageCode.ru => 'Россия',
        AppLanguageCode.tr => 'Türkiye',
      };
}

enum MeasurementUnits {
  metric,
  imperial;

  String get storageCode => name;

  static MeasurementUnits fromCode(String? code) {
    return code?.toLowerCase() == 'imperial' ? MeasurementUnits.imperial : MeasurementUnits.metric;
  }

  String get label => switch (this) {
        MeasurementUnits.metric => 'Metric',
        MeasurementUnits.imperial => 'Imperial',
      };

  String get subtitle => switch (this) {
        MeasurementUnits.metric => 'Kilograms, centimeters',
        MeasurementUnits.imperial => 'Pounds, feet and inches',
      };
}

enum ReminderDaysMode {
  everyDay,
  weekdays,
  custom;

  String get storageCode => switch (this) {
        ReminderDaysMode.everyDay => 'every_day',
        ReminderDaysMode.weekdays => 'weekdays',
        ReminderDaysMode.custom => 'custom',
      };

  static ReminderDaysMode fromStorage(String? value) {
    if (value == null || value.isEmpty) return ReminderDaysMode.everyDay;
    if (value == 'weekdays') return ReminderDaysMode.weekdays;
    if (value.startsWith('custom')) return ReminderDaysMode.custom;
    return ReminderDaysMode.everyDay;
  }

  String get label => switch (this) {
        ReminderDaysMode.everyDay => 'Every day',
        ReminderDaysMode.weekdays => 'Weekdays',
        ReminderDaysMode.custom => 'Custom',
      };
}

abstract final class ReminderDaysCodec {
  static const weekdayIndices = {1, 2, 3, 4, 5};

  static Set<int> decodeCustomDays(String? value) {
    if (value == null || !value.startsWith('custom:')) return {1, 3, 5};
    final raw = value.substring('custom:'.length).split(',');
    final days = raw.map(int.tryParse).whereType<int>().where((d) => d >= 1 && d <= 7).toSet();
    return days.isEmpty ? {1, 3, 5} : days;
  }

  static String encode(ReminderDaysMode mode, Set<int> customDays) {
    return switch (mode) {
      ReminderDaysMode.everyDay => 'every_day',
      ReminderDaysMode.weekdays => 'weekdays',
      ReminderDaysMode.custom => 'custom:${(customDays.toList()..sort()).join(',')}',
    };
  }

  static String displayLabel(String? value) {
    final mode = ReminderDaysMode.fromStorage(value);
    return switch (mode) {
      ReminderDaysMode.everyDay => 'Every day',
      ReminderDaysMode.weekdays => 'Weekdays',
      ReminderDaysMode.custom => _customLabel(decodeCustomDays(value)),
    };
  }

  static String _customLabel(Set<int> days) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sorted = days.toList()..sort();
    return sorted.map((d) => names[d - 1]).join(', ');
  }
}

abstract final class ReminderTimeCodec {
  static TimeOfDay decode(String? value) {
    if (value == null || value.isEmpty) return const TimeOfDay(hour: 19, minute: 0);
    final parts = value.split(':');
    if (parts.length != 2) return const TimeOfDay(hour: 19, minute: 0);
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return const TimeOfDay(hour: 19, minute: 0);
    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }

  static String encode(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String display(String? value) {
    final time = decode(value);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
