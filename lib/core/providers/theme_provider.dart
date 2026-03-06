import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tema modu - varsayılan koyu
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
