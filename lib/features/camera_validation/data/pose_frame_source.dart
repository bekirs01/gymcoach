import 'dart:async';

import 'dart:ui';

import 'package:camera/camera.dart';

import '../domain/pose_frame.dart';

abstract class PoseFrameSource {
  Stream<PoseFrame> get frames;
  CameraController? get cameraController;
  bool get isCameraReady;
  Size? get lastImageSize;

  Future<void> initializeCamera();
  Future<void> startAnalysis();
  Future<void> stopAnalysis();
  void dispose();
}

class ManualPoseFrameSource implements PoseFrameSource {
  ManualPoseFrameSource();

  final _controller = StreamController<PoseFrame>.broadcast();

  @override
  Stream<PoseFrame> get frames => _controller.stream;

  @override
  CameraController? get cameraController => null;

  @override
  bool get isCameraReady => true;

  @override
  Size? get lastImageSize => null;

  void emit(PoseFrame frame) {
    if (!_controller.isClosed) {
      _controller.add(frame);
    }
  }

  @override
  Future<void> initializeCamera() async {}

  @override
  Future<void> startAnalysis() async {}

  @override
  Future<void> stopAnalysis() async {}

  @override
  void dispose() {
    _controller.close();
  }
}
