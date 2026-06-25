import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/local_first_training_persistence.dart';
import 'theme/app_theme.dart';
import 'training_app_state.dart';
import '../features/shell/main_shell.dart';

const _localePrefKey = 'app_locale_code';

class GymCoachApp extends StatefulWidget {
  const GymCoachApp({
    super.key,
    required this.prefs,
    required this.trainingPersistence,
  });

  final SharedPreferences prefs;
  final LocalFirstTrainingPersistence trainingPersistence;

  @override
  State<GymCoachApp> createState() => _GymCoachAppState();
}

class _GymCoachAppState extends State<GymCoachApp> {
  late final TrainingAppState _training;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    final code = widget.prefs.getString(_localePrefKey);
    _locale = _localeFromCode(code);
    _training = TrainingAppState(persistence: widget.trainingPersistence);
  }

  Locale _localeFromCode(String? code) {
    return switch (code) {
      'ru' => const Locale('ru'),
      'tr' => const Locale('tr'),
      _ => const Locale('en'),
    };
  }

  String _storageCodeFor(Locale locale) {
    return switch (locale.languageCode) {
      'ru' => 'ru',
      'tr' => 'tr',
      _ => 'en',
    };
  }

  Future<void> _setLocale(Locale locale) async {
    final code = _storageCodeFor(locale);
    setState(() => _locale = _localeFromCode(code));
    await widget.prefs.setString(_localePrefKey, code);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymCoach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('en'), Locale('ru'), Locale('tr')],
      home: _AppHome(
        training: _training,
        onLocaleChanged: _setLocale,
      ),
    );
  }
}

final class _AppHome extends StatefulWidget {
  const _AppHome({
    required this.training,
    required this.onLocaleChanged,
  });

  final TrainingAppState training;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<_AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<_AppHome> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    unawaited(widget.training.ensureBootstrapped(l10n));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.training,
      builder: (context, _) {
        return MainShell(
          training: widget.training,
          onLocaleChanged: widget.onLocaleChanged,
        );
      },
    );
  }
}
