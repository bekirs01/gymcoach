import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../domain/pose_frame.dart' as domain;
import 'pose_frame_source.dart';

class MlKitPoseFrameSource implements PoseFrameSource {
  MlKitPoseFrameSource({CameraLensDirection lensDirection = CameraLensDirection.front})
      : _lensDirection = lensDirection;

  final CameraLensDirection _lensDirection;
  CameraController? _controller;
  PoseDetector? _detector;
  final _frameStream = StreamController<domain.PoseFrame>.broadcast();
  var _analysisRunning = false;
  Size? _lastImageSize;

  static const _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  CameraController? get cameraController => _controller;

  @override
  bool get isCameraReady => _controller?.value.isInitialized ?? false;

  @override
  Size? get lastImageSize => _lastImageSize;

  @override
  Stream<domain.PoseFrame> get frames => _frameStream.stream;

  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  Future<void> initializeCamera() async {
    if (!isSupported) {
      throw StateError('Camera pose tracking is only supported on Android and iOS');
    }
    if (isCameraReady) return;

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw StateError('No cameras available');
    }
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == _lensDirection,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller = controller;
    await controller.initialize();
  }

  @override
  Future<void> startAnalysis() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw StateError('Camera is not initialized');
    }
    if (_analysisRunning) return;

    _detector ??= PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
    );

    if (controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
    _analysisRunning = true;
    await controller.startImageStream(_onCameraImage);
  }

  Future<void> _onCameraImage(CameraImage image) async {
    if (!_analysisRunning) return;
    _pendingImage = image;
    if (_inferring) return;
    _inferring = true;
    try {
      while (_pendingImage != null && _analysisRunning) {
        final current = _pendingImage!;
        _pendingImage = null;
        await _processFrame(current);
      }
    } finally {
      _inferring = false;
    }
  }

  CameraImage? _pendingImage;
  var _inferring = false;

  Future<void> _processFrame(CameraImage image) async {
    try {
      final detector = _detector;
      final controller = _controller;
      if (detector == null || controller == null) return;

      final inputImage = _inputImageFromCameraImage(image, controller);
      if (inputImage == null) return;

      _lastImageSize = Size(image.width.toDouble(), image.height.toDouble());

      final poses = await detector.processImage(inputImage);
      if (poses.isEmpty) return;

      final frame = _mapPose(poses.first, DateTime.now());
      if (!_frameStream.isClosed) {
        _frameStream.add(frame);
      }
    } catch (_) {
      // Skip bad frames to keep preview responsive.
    }
  }

  InputImage? _inputImageFromCameraImage(
    CameraImage image,
    CameraController controller,
  ) {
    final camera = controller.description;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[controller.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (Platform.isAndroid) {
      if (format == InputImageFormat.nv21 && image.planes.length == 1) {
        final plane = image.planes.first;
        return InputImage.fromBytes(
          bytes: plane.bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow: plane.bytesPerRow,
          ),
        );
      }
      if (format == InputImageFormat.yuv_420_888 && image.planes.length >= 3) {
        final bytes = _concatenatePlanes(image.planes);
        return InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.yuv_420_888,
            bytesPerRow: image.planes.first.bytesPerRow,
          ),
        );
      }
      return null;
    }

    if (Platform.isIOS && format == InputImageFormat.bgra8888 && image.planes.length == 1) {
      final plane = image.planes.first;
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.bgra8888,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    }
    return null;
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final buffer = WriteBuffer();
    for (final plane in planes) {
      buffer.putUint8List(plane.bytes);
    }
    return buffer.done().buffer.asUint8List();
  }

  domain.PoseFrame _mapPose(Pose pose, DateTime timestamp) {
    final landmarks = <domain.PoseLandmark, domain.PosePoint>{};
    void put(PoseLandmarkType type, domain.PoseLandmark target) {
      final lm = pose.landmarks[type];
      if (lm == null) return;
      landmarks[target] = domain.PosePoint(
        x: lm.x,
        y: lm.y,
        visibility: lm.likelihood,
      );
    }

    put(PoseLandmarkType.nose, domain.PoseLandmark.nose);
    put(PoseLandmarkType.leftShoulder, domain.PoseLandmark.leftShoulder);
    put(PoseLandmarkType.rightShoulder, domain.PoseLandmark.rightShoulder);
    put(PoseLandmarkType.leftElbow, domain.PoseLandmark.leftElbow);
    put(PoseLandmarkType.rightElbow, domain.PoseLandmark.rightElbow);
    put(PoseLandmarkType.leftWrist, domain.PoseLandmark.leftWrist);
    put(PoseLandmarkType.rightWrist, domain.PoseLandmark.rightWrist);
    put(PoseLandmarkType.leftHip, domain.PoseLandmark.leftHip);
    put(PoseLandmarkType.rightHip, domain.PoseLandmark.rightHip);
    put(PoseLandmarkType.leftKnee, domain.PoseLandmark.leftKnee);
    put(PoseLandmarkType.rightKnee, domain.PoseLandmark.rightKnee);
    put(PoseLandmarkType.leftAnkle, domain.PoseLandmark.leftAnkle);
    put(PoseLandmarkType.rightAnkle, domain.PoseLandmark.rightAnkle);

    return domain.PoseFrame(timestamp: timestamp, landmarks: landmarks);
  }

  @override
  Future<void> stopAnalysis() async {
    _analysisRunning = false;
    final controller = _controller;
    if (controller != null && controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
  }

  @override
  void dispose() {
    _analysisRunning = false;
    _detector?.close();
    _controller?.dispose();
    _frameStream.close();
  }
}
