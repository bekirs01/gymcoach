import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/app_theme.dart';
import 'training_app_state.dart';
import '../data/remote/supabase_training_persistence.dart';
import '../features/shell/main_shell.dart';

const _localePrefKey = 'app_locale_code';

class GymCoachApp extends StatefulWidget {
  const GymCoachApp({super.key});

  @override
  State<GymCoachApp> createState() => _GymCoachAppState();
}

class _GymCoachAppState extends State<GymCoachApp> {
  TrainingAppState? _training;
  Locale _locale = const Locale('en');
  var _prefsReady = false;

  @override
  void initState() {
    super.initState();
    _initTraining();
  }

  Future<void> _initTraining() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localePrefKey);
    final training = TrainingAppState(
      persistence: SupabaseTrainingPersistence(prefs: prefs),
    );
    if (!mounted) return;
    setState(() {
      _locale = _localeFromCode(code);
      _training = training;
      _prefsReady = true;
    });
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefKey, code);
  }

  @override
  Widget build(BuildContext context) {
    if (!_prefsReady || _training == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'GymCoach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('en'), Locale('ru'), Locale('tr')],
      home: _TrainingBootstrap(
        training: _training!,
        onLocaleChanged: _setLocale,
      ),
    );
  }
}

final class _TrainingBootstrap extends StatefulWidget {
  const _TrainingBootstrap({
    required this.training,
    required this.onLocaleChanged,
  });

  final TrainingAppState training;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<_TrainingBootstrap> createState() => _TrainingBootstrapState();
}

class _TrainingBootstrapState extends State<_TrainingBootstrap> {
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
        if (!widget.training.isReady) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return MainShell(
          training: widget.training,
          onLocaleChanged: widget.onLocaleChanged,
        );
      },
    );
  }
}
