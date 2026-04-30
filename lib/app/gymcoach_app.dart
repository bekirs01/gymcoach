import 'package:flutter/material.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/app_theme.dart';
import '../features/shell/main_shell.dart';

const _kLocalePref = 'app_locale_code';

class GymCoachApp extends StatefulWidget {
  const GymCoachApp({super.key});

  @override
  State<GymCoachApp> createState() => _GymCoachAppState();
}

class _GymCoachAppState extends State<GymCoachApp> {
  Locale _locale = const Locale('en');
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    _restoreLocale();
  }

  Future<void> _restoreLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocalePref);
    if (!mounted) return;
    setState(() {
      if (code == 'ru') {
        _locale = const Locale('ru');
      } else if (code == 'en') {
        _locale = const Locale('en');
      } else {
        final sys = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
        _locale = sys == 'ru' ? const Locale('ru') : const Locale('en');
      }
      _loaded = true;
    });
  }

  Future<void> _persistLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocalePref, locale.languageCode);
  }

  void _setLocale(Locale locale) {
    setState(() => _locale = locale);
    _persistLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
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
      supportedLocales: AppLocalizations.supportedLocales,
      home: MainShell(onLocaleChanged: _setLocale),
    );
  }
}
