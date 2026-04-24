import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import 'camera_session_config.dart';

/// Kamera önizlemesi + manuel tekrar sayımı.
///
/// Google ML Kit kaldırıldı: iOS simülatörü (arm64) ML Kit ikilileriyle link edilemiyordu.
/// Otomatik iskelet sayımı için ileride güncel ML / cihaz hedefi eklenebilir.
class CameraRepCounterScreen extends ConsumerStatefulWidget {
  const CameraRepCounterScreen({
    super.key,
    this.exerciseType = CameraExerciseType.dumbbellShoulderPress,
    this.initialWeightKg,
  });

  final CameraExerciseType exerciseType;
  final double? initialWeightKg;

  @override
  ConsumerState<CameraRepCounterScreen> createState() => _State();
}

class _State extends ConsumerState<CameraRepCounterScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIdx = -1;

  bool _initializing = true;
  bool _cameraLoadFailed = false;
  bool _permissionChecking = true;
  PermissionStatus? _cameraPermissionStatus;

  int _reps = 0;

  double _weightKg = 10;
  double _bodyWeightKg = 70;

  /// iOS simülatör / Android emülatörde true (ML yok; manuel mod).
  bool _virtualDevice = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _weightKg = (widget.initialWeightKg ?? 10).clamp(1, 200).toDouble();
    unawaited(_loadBodyWeightFromProfile());
    unawaited(_detectVirtualDevice());
    _requestPermissionAndBoot();
  }

  Future<void> _detectVirtualDevice() async {
    if (kIsWeb) return;
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final ios = await info.iosInfo;
        if (!mounted) return;
        setState(() => _virtualDevice = !ios.isPhysicalDevice);
      } else if (Platform.isAndroid) {
        final a = await info.androidInfo;
        if (!mounted) return;
        setState(() => _virtualDevice = !a.isPhysicalDevice);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_kill());
    super.dispose();
  }

  Future<void> _loadBodyWeightFromProfile() async {
    final profile = await ref.read(userProfileProvider.future);
    if (!mounted || profile == null) return;
    setState(() {
      _bodyWeightKg = profile.weightKg;
      if (widget.initialWeightKg == null) {
        _weightKg = profile.weightKg.clamp(1, 200).toDouble();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      unawaited(_kill());
    } else if (state == AppLifecycleState.resumed) {
      _requestPermissionAndBoot();
    }
  }

  Future<void> _requestPermissionAndBoot() async {
    setState(() {
      _permissionChecking = true;
    });

    var status = await Permission.camera.status;
    if (status.isDenied || status.isRestricted) {
      status = await Permission.camera.request();
    }

    if (!mounted) return;
    setState(() {
      _cameraPermissionStatus = status;
      _permissionChecking = false;
    });

    if (status.isGranted && _controller == null) {
      await _boot();
    }
  }

  Future<void> _boot() async {
    setState(() {
      _initializing = true;
      _cameraLoadFailed = false;
    });
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _markCameraFailed();
        return;
      }
      _cameraIdx = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      if (_cameraIdx < 0) _cameraIdx = 0;
      await _startCamera();
    } on CameraException catch (_) {
      _markCameraFailed();
    } catch (_) {
      _markCameraFailed();
    }
  }

  void _markCameraFailed() {
    if (!mounted) return;
    setState(() {
      _cameraLoadFailed = true;
      _initializing = false;
    });
  }

  Future<void> _startCamera() async {
    final cam = _cameras[_cameraIdx];
    final ctrl = CameraController(
      cam,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    await ctrl.initialize();
    if (!mounted) {
      await ctrl.dispose();
      return;
    }
    _controller = ctrl;
    setState(() => _initializing = false);
  }

  Future<void> _kill() async {
    final c = _controller;
    _controller = null;
    if (c == null) return;
    try {
      if (c.value.isStreamingImages) await c.stopImageStream();
    } catch (_) {}
    await c.dispose();
  }

  void _addRep() {
    setState(() => _reps++);
    HapticFeedback.lightImpact();
  }

  double get _caloriesBurned {
    final bodyWeightFactor = (_bodyWeightKg / 70).clamp(0.7, 1.8);
    return _reps *
        _weightKg *
        widget.exerciseType.calorieFactor *
        bodyWeightFactor;
  }

  Future<void> _finish() async {
    if (_reps > 0) {
      try {
        await ref.read(leagueRepositoryProvider).addCameraScore(_reps);
      } catch (_) {}
    }
    if (mounted) {
      ref.invalidate(leagueStandingsProvider);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);

    if (_permissionChecking) {
      return _loadingView(text: 'Запрос доступа к камере…');
    }
    final status = _cameraPermissionStatus;
    if (status != null && !status.isGranted) {
      return _permissionView(status);
    }
    if (_cameraLoadFailed) return _errorView(pad);
    if (_initializing || _controller == null) {
      return _loadingView(text: 'Запуск камеры…');
    }

    final ctrl = _controller!;
    if (!ctrl.value.isInitialized) {
      return _loadingView(text: 'Подготовка камеры…');
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _cameraLayer(ctrl),
          if (_virtualDevice) _virtualDeviceBanner(pad),
          _topBar(pad),
          _statsBar(pad),
          _manualAddButton(pad),
          _bottomSheet(pad),
        ],
      ),
    );
  }

  Widget _virtualDeviceBanner(EdgeInsets pad) {
    return Positioned(
      top: pad.top + 56,
      left: 12,
      right: 12,
      child: Material(
        color: Colors.amber.shade800.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            'Симулятор: скелет не отслеживается. Нажимай «+» для повтора. '
            'На устройстве — тот же ручной режим.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }

  Widget _cameraLayer(CameraController ctrl) {
    return Positioned.fill(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: ctrl.value.previewSize!.height,
          height: ctrl.value.previewSize!.width,
          child: CameraPreview(ctrl),
        ),
      ),
    );
  }

  Widget _manualAddButton(EdgeInsets pad) {
    return Positioned(
      right: 16,
      bottom: pad.bottom + 200,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(40),
        elevation: 6,
        child: InkWell(
          onTap: _addRep,
          borderRadius: BorderRadius.circular(40),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Icon(Icons.add_rounded, color: Colors.white, size: 36),
          ),
        ),
      ),
    );
  }

  Widget _topBar(EdgeInsets pad) {
    return Positioned(
      top: pad.top + 8,
      left: 8,
      right: 8,
      child: Row(
        children: [
          _circleBtn(Icons.close_rounded, () => context.pop()),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.6)),
            ),
            child: Text(
              '$_reps',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsBar(EdgeInsets pad) {
    return Positioned(
      top: pad.top + 72,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _miniStat('Вес', '${_weightKg.toStringAsFixed(0)} кг'),
            const SizedBox(height: 4),
            _miniStat('Тело', '${_bodyWeightKg.toStringAsFixed(0)} кг'),
            const SizedBox(height: 4),
            _miniStat('ккал', _caloriesBurned.toStringAsFixed(1)),
            const SizedBox(height: 4),
            _miniStat('Режим', 'вручную'),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _bottomSheet(EdgeInsets pad) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 14, 16, pad.bottom + 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.88),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.exerciseType.title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'После каждого повтора нажимай «+» справа внизу.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _finish,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _reps > 0
                    ? 'Готово · $_reps повт. · ${_caloriesBurned.toStringAsFixed(1)} ккал'
                    : 'Готово',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _loadingView({required String text}) {
    return Scaffold(
      backgroundColor: Color(0xFF0F1419),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _permissionView(PermissionStatus status) {
    final isPermanent = status.isPermanentlyDenied;
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 56,
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              Text(
                isPermanent
                    ? 'Доступ к камере закрыт. Откройте в настройках приложения.'
                    : 'Нужен доступ к камере. После разрешения она откроется автоматически.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  if (isPermanent) {
                    await openAppSettings();
                  } else {
                    await _requestPermissionAndBoot();
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(isPermanent ? 'Настройки' : 'Разрешить камеру'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Назад'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorView(EdgeInsets pad) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.videocam_off_rounded,
                size: 56,
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              const Text(
                AppConstants.cameraGenericError,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () {
                  _cameraLoadFailed = false;
                  _boot();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Повторить'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Назад'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
