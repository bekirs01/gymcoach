import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/mlkit_camera_input_image.dart';
import 'pose_painter.dart';

/// Kamera: tam ekran iPhone kamerası + iskelet çizimi + tekrar sayımı.
/// `camera` paketi iOS'ta `NSCameraUsageDescription` sayesinde izni kendi sorar.
class CameraRepCounterScreen extends ConsumerStatefulWidget {
  const CameraRepCounterScreen({super.key});

  @override
  ConsumerState<CameraRepCounterScreen> createState() => _State();
}

class _State extends ConsumerState<CameraRepCounterScreen> with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIdx = -1;
  PoseDetector? _poseDetector;

  bool _initializing = true;
  String? _fatalError;
  bool _permissionChecking = true;
  PermissionStatus? _cameraPermissionStatus;

  List<Pose> _poses = [];
  Size _imageSize = Size.zero;
  InputImageRotation _rotation = InputImageRotation.rotation0deg;
  bool _processing = false;
  int _frameSkip = 0;

  int _reps = 0;
  int _phase = 0; // 0 = aşağı, 1 = yukarı
  bool _phaseInit = false;
  DateTime? _lastPhaseAt;
  double _marginFrac = 0.045;
  static const _minLikelihood = 0.30;
  static const _phaseGap = Duration(milliseconds: 320);

  double _weightKg = 10;

  static const _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        model: PoseDetectionModel.base,
        mode: PoseDetectionMode.stream,
      ),
    );
    _requestPermissionAndBoot();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _kill();
    _poseDetector?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _kill();
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
      _fatalError = null;
    });
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) throw Exception('Cihazda kamera yok');
      _cameraIdx = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
      if (_cameraIdx < 0) _cameraIdx = 0;
      await _startCamera();
    } on CameraException catch (e) {
      _setFatal('Kamera erişilemedi: ${e.description}\n\nAyarlar → GymCoach → Kamera iznini aç.');
    } catch (e) {
      _setFatal('$e');
    }
  }

  Future<void> _startCamera() async {
    final cam = _cameras[_cameraIdx];
    final ctrl = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    await ctrl.initialize();
    if (!mounted) {
      await ctrl.dispose();
      return;
    }
    _controller = ctrl;
    await ctrl.startImageStream(_onFrame);
    setState(() => _initializing = false);
  }

  void _setFatal(String msg) {
    if (mounted) {
      setState(() {
        _fatalError = msg;
        _initializing = false;
      });
    }
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

  InputImageRotation _computeRotation(CameraDescription cam) {
    final sensor = cam.sensorOrientation;
    if (Platform.isIOS) {
      return InputImageRotationValue.fromRawValue(sensor) ?? InputImageRotation.rotation0deg;
    }
    var comp = _orientations[_controller!.value.deviceOrientation] ?? 0;
    if (cam.lensDirection == CameraLensDirection.front) {
      comp = (sensor + comp) % 360;
    } else {
      comp = (sensor - comp + 360) % 360;
    }
    return InputImageRotationValue.fromRawValue(comp) ?? InputImageRotation.rotation0deg;
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_processing) return;
    _frameSkip++;
    if (_frameSkip % 2 != 0) return;

    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    final input = inputImageFromCameraImage(
      image: image,
      controller: ctrl,
      camera: ctrl.description,
    );
    if (input == null) return;

    _processing = true;
    try {
      final poses = await _poseDetector!.processImage(input);
      if (!mounted) return;
      final rot = _computeRotation(ctrl.description);
      final sz = Size(image.width.toDouble(), image.height.toDouble());
      _countReps(poses, sz.height);
      setState(() {
        _poses = poses;
        _imageSize = sz;
        _rotation = rot;
      });
    } catch (_) {
    } finally {
      _processing = false;
    }
  }

  void _countReps(List<Pose> poses, double imgH) {
    if (poses.isEmpty) return;
    final p = poses.first;
    final ls = p.landmarks[PoseLandmarkType.leftShoulder];
    final rs = p.landmarks[PoseLandmarkType.rightShoulder];
    final lw = p.landmarks[PoseLandmarkType.leftWrist];
    final rw = p.landmarks[PoseLandmarkType.rightWrist];
    if (ls == null || rs == null || lw == null || rw == null) return;
    if ([ls, rs, lw, rw].any((l) => l.likelihood < _minLikelihood)) return;

    final m = imgH * _marginFrac;
    final bothUp = lw.y < ls.y - m && rw.y < rs.y - m;
    final bothDown = lw.y > ls.y + m && rw.y > rs.y + m;

    if (!_phaseInit) {
      _phaseInit = true;
      _phase = bothUp ? 1 : 0;
      _lastPhaseAt = DateTime.now();
    }

    final now = DateTime.now();
    final ok = _lastPhaseAt == null || now.difference(_lastPhaseAt!) >= _phaseGap;
    if (!ok) return;

    if (_phase == 0 && bothUp) {
      _phase = 1;
      _lastPhaseAt = now;
    } else if (_phase == 1 && bothDown) {
      _phase = 0;
      _reps++;
      _lastPhaseAt = now;
    }
  }

  double get _caloriesBurned => _reps * _weightKg * 0.0035;

  Future<void> _finish() async {
    if (_reps > 0) {
      await ref.read(leagueRepositoryProvider).addCameraScore(_reps);
    }
    if (mounted) {
      ref.invalidate(leagueStandingsProvider);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);

    if (_permissionChecking) return _loadingView(text: 'Kamera izni isteniyor…');
    final status = _cameraPermissionStatus;
    if (status != null && !status.isGranted) {
      return _permissionView(status);
    }
    if (_fatalError != null) return _errorView(pad);
    if (_initializing || _controller == null) return _loadingView(text: 'Kamera açılıyor…');

    final ctrl = _controller!;
    if (!ctrl.value.isInitialized) return _loadingView(text: 'Kamera hazırlanıyor…');

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _cameraLayer(ctrl),
          _skeletonOverlay(ctrl),
          _topBar(pad),
          _statsBar(pad),
          _bottomSheet(pad),
        ],
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

  Widget _skeletonOverlay(CameraController ctrl) {
    if (_poses.isEmpty || _imageSize == Size.zero) return const SizedBox.shrink();
    return Positioned.fill(
      child: CustomPaint(
        painter: PosePainter(
          poses: _poses,
          imageSize: _imageSize,
          rotation: _rotation,
          cameraLensDirection: ctrl.description.lensDirection,
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
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primary.withOpacity(0.6)),
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
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _miniStat('Ağırlık', '${_weightKg.toStringAsFixed(0)} kg'),
            const SizedBox(height: 4),
            _miniStat('Kalori', '${_caloriesBurned.toStringAsFixed(1)} kcal'),
            const SizedBox(height: 4),
            _miniStat('Faz', _phase == 0 ? 'Aşağı ↓' : 'Yukarı ↑'),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
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
            colors: [Colors.transparent, Colors.black.withOpacity(0.88)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Ağırlık (kg)', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _weightKg.clamp(1, 200),
                    min: 1,
                    max: 200,
                    divisions: 199,
                    label: '${_weightKg.round()} kg',
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _weightKg = v.roundToDouble()),
                  ),
                ),
                SizedBox(
                  width: 54,
                  child: Text(
                    '${_weightKg.round()} kg',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Hassasiyet', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _marginFrac.clamp(0.02, 0.12),
                    min: 0.02,
                    max: 0.12,
                    divisions: 10,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _marginFrac = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'İki kolu birden omuz üstüne kaldır → indir = +1',
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _finish,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _reps > 0
                    ? 'Bitir  ·  $_reps tekrar  ·  ${_caloriesBurned.toStringAsFixed(1)} kcal'
                    : 'Bitir',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black.withOpacity(0.5),
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
            Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
              const Icon(Icons.camera_alt_outlined, size: 56, color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                isPermanent
                    ? 'Kamera izni kapalı. Ayarlar -> GymCoach -> Kamera kısmından aç.'
                    : 'Bu ekran için kamera izni gerekiyor. İzin verince kamera otomatik açılacak.',
                style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
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
                child: Text(isPermanent ? 'Ayarlara git' : 'Kamera izni ver'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Geri'),
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
              const Icon(Icons.videocam_off_rounded, size: 56, color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                _fatalError ?? 'Bilinmeyen hata',
                style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () {
                  _fatalError = null;
                  _boot();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Yeniden dene'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Geri'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
