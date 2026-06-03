import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/workout_exercise_l10n.dart';
import '../data/exercise_name_resolver.dart';
import '../l10n/exercise_camera_guidance_l10n.dart';
import '../data/mlkit_pose_frame_source.dart';
import '../data/pose_frame_source.dart';
import '../domain/camera_tracking_result.dart';
import '../domain/exercise_tracking_mode.dart';
import '../domain/pose_frame.dart';
import '../exercise_tracker_registry.dart';
import '../pose_analysis_engine.dart';
import 'widgets/camera_stats_rail.dart';
import 'widgets/pose_skeleton_overlay.dart';

export '../domain/camera_tracking_result.dart';

class CameraTrackingPage extends StatefulWidget {
  const CameraTrackingPage({
    super.key,
    required this.exerciseName,
    this.poseSource,
  });

  final String exerciseName;
  final PoseFrameSource? poseSource;

  @override
  State<CameraTrackingPage> createState() => _CameraTrackingPageState();
}

class _CameraTrackingPageState extends State<CameraTrackingPage> with WidgetsBindingObserver {
  PoseFrameSource? _source;
  PoseAnalysisEngine? _engine;
  StreamSubscription? _sub;
  VoidCallback? _cameraListener;

  PoseFrame? _latestFrame;
  var _loading = true;
  var _permissionDenied = false;
  var _unsupportedPlatform = false;
  String? _error;
  var _sessionStarted = false;
  var _analysisStarting = false;
  var _repHighlight = false;
  var _uiDirty = false;
  Timer? _uiRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _source?.stopAnalysis();
    }
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final canonical = ExerciseNameResolver.canonicalIdForName(widget.exerciseName, l10n);
    final tracker = ExerciseTrackerRegistry.resolve(canonical ?? 'unknown');
    _engine = PoseAnalysisEngine(tracker);

    if (tracker.mode == ExerciseTrackingMode.unsupported) {
      setState(() {
        _loading = false;
        _error = l10n.cameraUnsupportedExercise;
      });
      return;
    }

    if (widget.poseSource != null) {
      _source = widget.poseSource;
      setState(() => _loading = false);
      return;
    }

    if (!MlKitPoseFrameSource.isSupported) {
      setState(() {
        _loading = false;
        _unsupportedPlatform = true;
      });
      return;
    }

    await _initializeCamera(showErrors: true);
  }

  Future<void> _initializeCamera({required bool showErrors}) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
      _permissionDenied = false;
      _latestFrame = null;
    });

    _detachCameraListener();
    _source?.dispose();
    final lens = _engine?.tracker.preferredLens ?? CameraLensDirection.front;
    _source = MlKitPoseFrameSource(lensDirection: lens);

    try {
      await _source!.initializeCamera();
      _attachCameraListener();
      if (!mounted) return;
      setState(() => _loading = false);
    } on CameraException catch (e) {
      if (!mounted) return;
      final denied = e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt' ||
          e.description?.toLowerCase().contains('permission') == true;
      setState(() {
        _loading = false;
        if (denied) {
          _permissionDenied = true;
        } else if (showErrors) {
          _error = kDebugMode ? '${l10n.cameraInitFailed}\n${e.code}: ${e.description}' : l10n.cameraInitFailed;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = kDebugMode ? '${l10n.cameraInitFailed}\n$e' : l10n.cameraInitFailed;
      });
    }
  }

  void _attachCameraListener() {
    final controller = _source?.cameraController;
    if (controller == null) return;
    _cameraListener = () {
      if (mounted) setState(() {});
    };
    controller.addListener(_cameraListener!);
  }

  void _detachCameraListener() {
    final controller = _source?.cameraController;
    final listener = _cameraListener;
    if (controller != null && listener != null) {
      controller.removeListener(listener);
    }
    _cameraListener = null;
  }

  void _listenFrames() {
    final source = _source;
    final engine = _engine;
    if (source == null || engine == null) return;
    _sub?.cancel();
    _uiRefreshTimer?.cancel();
    _uiRefreshTimer = Timer.periodic(const Duration(milliseconds: 66), (_) {
      if (_uiDirty && mounted) {
        setState(() => _uiDirty = false);
      }
    });
    _sub = source.frames.listen((frame) {
      if (!_sessionStarted) return;
      final update = engine.process(frame);
      final obs = engine.lastObservation;
      if (obs != null) {
        _latestFrame = PoseFrame(timestamp: obs.timestamp, landmarks: obs.landmarks);
      }
      _uiDirty = true;
      if (update.repCompleted && mounted) {
        setState(() => _repHighlight = true);
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) setState(() => _repHighlight = false);
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _sub?.cancel();
    _uiRefreshTimer?.cancel();
    _detachCameraListener();
    _source?.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    if (_analysisStarting) return;
    setState(() {
      _analysisStarting = true;
      _sessionStarted = true;
      _latestFrame = null;
      _engine?.reset();
    });

    try {
      await _source?.startAnalysis();
      _listenFrames();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(kDebugMode ? '$e' : l10n.cameraInitFailed),
        ),
      );
      setState(() => _sessionStarted = false);
    } finally {
      if (mounted) setState(() => _analysisStarting = false);
    }
  }

  void _finish(CameraTrackingResult result) {
    Navigator.of(context).pop(result);
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  String? _feedbackText(AppLocalizations l10n, String? code) {
    if (code == null) return null;
    return switch (code) {
      'sagging_hips' => l10n.cameraFeedbackSaggingHips,
      'raise_higher' => l10n.cameraFeedbackRaiseHigher,
      'incomplete_press' => l10n.cameraFeedbackIncompletePress,
      'pull_higher' => l10n.cameraFeedbackPullHigher,
      'hips_sagging' => l10n.cameraFeedbackHipsSagging,
      _ => l10n.cameraFeedbackAdjustForm,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_permissionDenied) {
      return _messagePanel(
        l10n.cameraPermissionDenied,
        l10n.cameraManualFallback,
        primaryLabel: l10n.cameraOpenSettings,
        onPrimary: _openSettings,
        secondaryLabel: l10n.cameraUseManual,
        onSecondary: () => _finish(const CameraTrackingResult(
          validReps: 0,
          invalidAttempts: 0,
          mode: ExerciseTrackingMode.unsupported,
          usedCamera: false,
        )),
      );
    }
    if (_unsupportedPlatform) {
      return _messagePanel(
        l10n.cameraPlatformUnsupported,
        l10n.cameraManualFallback,
        primaryLabel: l10n.cameraUseManual,
        onPrimary: () => _finish(const CameraTrackingResult(
          validReps: 0,
          invalidAttempts: 0,
          mode: ExerciseTrackingMode.unsupported,
          usedCamera: false,
        )),
      );
    }
    if (_error != null) {
      return _messagePanel(
        _error!,
        l10n.cameraManualFallback,
        primaryLabel: l10n.cameraRetry,
        onPrimary: () => _initializeCamera(showErrors: true),
        secondaryLabel: l10n.cameraUseManual,
        onSecondary: () => _finish(const CameraTrackingResult(
          validReps: 0,
          invalidAttempts: 0,
          mode: ExerciseTrackingMode.unsupported,
          usedCamera: false,
        )),
      );
    }

    return _buildTrackingView(l10n);
  }

  Widget _buildTrackingView(AppLocalizations l10n) {
    final theme = Theme.of(context).textTheme;
    final tracker = _engine!.tracker;
    final state = _engine!.state;
    final preview = _source?.cameraController;
    final previewReady = preview != null && preview.value.isInitialized;
    final imageSize = _source?.lastImageSize;
    final isHold = tracker.mode == ExerciseTrackingMode.holdBased;
    final count = isHold ? state.holdSeconds : state.repCount;
    final feedback = _feedbackText(l10n, state.lastFeedbackCode);
    final guidance = ExerciseCameraGuidanceL10n.localized(l10n, tracker.profile);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (previewReady)
          _FullScreenCameraPreview(
            controller: preview,
            overlay: _sessionStarted && imageSize != null
                ? PoseSkeletonOverlay(
                    frame: _latestFrame,
                    controller: preview,
                    imageSize: imageSize,
                  )
                : null,
          )
        else
          Center(
            child: Text(
              l10n.cameraPreviewLoading,
              style: theme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.72),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 28),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            WorkoutExerciseL10n.name(l10n, widget.exerciseName),
                            style: theme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            guidance.framingHint,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodySmall?.copyWith(
                              color: Colors.white70,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_sessionStarted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.cameraTrackingLive,
                              style: theme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_sessionStarted)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 72,
            right: 0,
            bottom: 140,
            child: Align(
              alignment: Alignment.topRight,
              child: CameraStatsRail(
                primaryLabel: isHold ? l10n.cameraHoldSeconds : l10n.cameraRepCount,
                primaryValue: '$count',
                secondaryLabel: state.invalidAttempts > 0 ? l10n.cameraInvalidAttempts : null,
                secondaryValue: state.invalidAttempts > 0 ? '${state.invalidAttempts}' : null,
                highlight: _repHighlight,
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.88),
                  Colors.black.withValues(alpha: 0.45),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_sessionStarted) ...[
                      _StatusBanner(
                        bodyDetected: state.bodyDetected,
                        feedback: feedback,
                        waitingText: l10n.cameraBodyNotVisible,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => _finish(CameraTrackingResult(
                          validReps: state.repCount,
                          invalidAttempts: state.invalidAttempts,
                          mode: tracker.mode,
                          usedCamera: true,
                          holdSeconds: state.holdSeconds,
                        )),
                        icon: const Icon(Icons.check_rounded),
                        label: Text(l10n.cameraApplyCount),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ] else ...[
                      _CameraSetupCard(guidance: guidance, l10n: l10n),
                      const SizedBox(height: 12),
                      Text(
                        l10n.cameraSafetyDisclaimer,
                        style: theme.bodySmall?.copyWith(
                          color: Colors.white60,
                          height: 1.35,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: previewReady && !_analysisStarting ? _startSession : null,
                        icon: Icon(_analysisStarting ? Icons.hourglass_top_rounded : Icons.play_arrow_rounded),
                        label: Text(
                          _analysisStarting ? l10n.cameraPreviewLoading : l10n.cameraStartTracking,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _messagePanel(
    String title,
    String body, {
    required VoidCallback onPrimary,
    required String primaryLabel,
    VoidCallback? onSecondary,
    String? secondaryLabel,
  }) {
    final theme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Text(title, style: theme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(body, style: theme.bodyMedium?.copyWith(height: 1.4)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
            ),
            if (onSecondary != null && secondaryLabel != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FullScreenCameraPreview extends StatelessWidget {
  const _FullScreenCameraPreview({
    required this.controller,
    this.overlay,
  });

  final CameraController controller;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return CameraPreview(controller);
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: previewSize.height,
        height: previewSize.width,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(controller),
            if (overlay != null) overlay!,
          ],
        ),
      ),
    );
  }
}

class _CameraSetupCard extends StatelessWidget {
  const _CameraSetupCard({required this.guidance, required this.l10n});

  final CameraGuidance guidance;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                guidance.orientation == CameraOrientationHint.side
                    ? Icons.switch_access_shortcut_rounded
                    : Icons.center_focus_strong_rounded,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                ExerciseCameraGuidanceL10n.orientationLabel(l10n, guidance.orientation),
                style: theme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (guidance.placementHint.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              guidance.placementHint,
              style: theme.bodySmall?.copyWith(color: Colors.white70, height: 1.35),
            ),
          ],
          if (guidance.setupSteps.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (var i = 0; i < guidance.setupSteps.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}.',
                    style: theme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      guidance.setupSteps[i],
                      style: theme.bodySmall?.copyWith(color: Colors.white, height: 1.35),
                    ),
                  ),
                ],
              ),
              if (i < guidance.setupSteps.length - 1) const SizedBox(height: 6),
            ],
          ],
          const SizedBox(height: 8),
          Text(
            guidance.safetyNote,
            style: theme.bodySmall?.copyWith(
              color: Colors.white54,
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.bodyDetected,
    required this.waitingText,
    this.feedback,
  });

  final bool bodyDetected;
  final String waitingText;
  final String? feedback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final hasFeedback = feedback != null;
    final color = hasFeedback
        ? Colors.amber.withValues(alpha: 0.18)
        : bodyDetected
            ? AppColors.primary.withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.1);
    final borderColor = hasFeedback
        ? Colors.amber.withValues(alpha: 0.5)
        : bodyDetected
            ? AppColors.accent.withValues(alpha: 0.5)
            : Colors.white24;
    final icon = hasFeedback
        ? Icons.info_outline_rounded
        : bodyDetected
            ? Icons.check_circle_outline_rounded
            : Icons.person_search_rounded;
    final text = feedback ?? (bodyDetected ? '' : waitingText);

    if (bodyDetected && !hasFeedback) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
