import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/gymcoach_app.dart';
import 'core/app_bootstrap.dart';
import 'data/local/local_first_training_persistence.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final trainingPersistence = LocalFirstTrainingPersistence(prefs: prefs);

  runApp(GymCoachApp(
    prefs: prefs,
    trainingPersistence: trainingPersistence,
  ));

  unawaited(bootstrapAppServices(
    prefs: prefs,
    trainingPersistence: trainingPersistence,
  ));
}
