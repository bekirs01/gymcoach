import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/app_theme.dart';
import 'training_app_state.dart';
import '../data/local/shared_prefs_training_persistence.dart';
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
      persistence: SharedPrefsTrainingPersistence(prefs),
    );
    if (!mounted) return;
    setState(() {
      _locale = code == 'ru' ? const Locale('ru') : const Locale('en');
      _training = training;
      _prefsReady = true;
    });
  }

  Future<void> _setLocale(Locale locale) async {
    final next = locale.languageCode == 'ru' ? const Locale('ru') : const Locale('en');
    setState(() => _locale = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefKey, next.languageCode);
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
      supportedLocales: const [Locale('en'), Locale('ru')],
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
