import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/providers/theme_provider.dart';

/// Ayarlar ekranı - tema, vb.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with WidgetsBindingObserver {
  PermissionStatus? _cameraStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshCameraPermission();
    }
  }

  Future<void> _refreshCameraPermission() async {
    final status = await Permission.camera.status;
    if (!mounted) return;
    setState(() => _cameraStatus = status);
  }

  Future<void> _handleCameraPermissionTap() async {
    final status = _cameraStatus ?? await Permission.camera.status;
    if (status.isGranted) return;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      await Permission.camera.request();
    }
    await _refreshCameraPermission();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final cameraSubtitle = switch (_cameraStatus) {
      null => 'Проверяется...',
      PermissionStatus.granted => 'Камера: Разрешено',
      PermissionStatus.permanentlyDenied => 'Камера: Отключено (нажмите и откройте настройки)',
      _ => 'Камера: Не разрешено',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Тёмная тема'),
            subtitle: const Text('Включить/выключить тёмный режим'),
            value: isDark,
            onChanged: (v) {
              ref.read(themeModeProvider.notifier).state =
                  v ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const ListTile(
            title: Text('О приложении'),
            subtitle: Text('GymCoach v1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Разрешение камеры'),
            subtitle: Text(cameraSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: _handleCameraPermissionTap,
          ),
        ],
      ),
    );
  }
}
