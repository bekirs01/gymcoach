import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import '../domain/pose_frame.dart';

/// Maps ML Kit image-space landmarks to the camera preview canvas.
/// Based on Google ML Kit Flutter coordinate translator (rotation + lens aware).
class PoseCoordinateMapper {
  PoseCoordinateMapper({
    required this.canvasSize,
    required this.imageSize,
    required this.rotation,
    required this.lensDirection,
  });

  final Size canvasSize;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection lensDirection;

  factory PoseCoordinateMapper.fromCamera({
    required Size canvasSize,
    required Size imageSize,
    required CameraController controller,
  }) {
    final rotation = _rotationForController(controller);
    return PoseCoordinateMapper(
      canvasSize: canvasSize,
      imageSize: imageSize,
      rotation: rotation,
      lensDirection: controller.description.lensDirection,
    );
  }

  static InputImageRotation _rotationForController(CameraController controller) {
    final sensorOrientation = controller.description.sensorOrientation;
    if (Platform.isIOS) {
      return InputImageRotationValue.fromRawValue(sensorOrientation) ??
          InputImageRotation.rotation0deg;
    }
    const orientations = {
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeLeft: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeRight: 270,
    };
    var compensation = orientations[controller.value.deviceOrientation] ?? 0;
    if (controller.description.lensDirection == CameraLensDirection.front) {
      compensation = (sensorOrientation + compensation) % 360;
    } else {
      compensation =
          (sensorOrientation - compensation + 360) % 360;
    }
    return InputImageRotationValue.fromRawValue(compensation) ??
        InputImageRotation.rotation0deg;
  }

  Offset? map(PoseLandmark landmark, PoseFrame? frame) {
    final point = frame?[landmark];
    if (point == null || !point.isReliable) return null;
    return mapPoint(point);
  }

  Offset mapPoint(PosePoint point) {
    return Offset(
      _translateX(point.x),
      _translateY(point.y),
    );
  }

  double _translateX(double x) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        return x *
            canvasSize.width /
            (Platform.isIOS ? imageSize.width : imageSize.height);
      case InputImageRotation.rotation270deg:
        return canvasSize.width -
            x *
                canvasSize.width /
                (Platform.isIOS ? imageSize.width : imageSize.height);
      case InputImageRotation.rotation0deg:
      case InputImageRotation.rotation180deg:
        if (lensDirection == CameraLensDirection.back) {
          return x * canvasSize.width / imageSize.width;
        }
        return canvasSize.width - x * canvasSize.width / imageSize.width;
    }
  }

  double _translateY(double y) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
      case InputImageRotation.rotation270deg:
        return y *
            canvasSize.height /
            (Platform.isIOS ? imageSize.height : imageSize.width);
      case InputImageRotation.rotation0deg:
      case InputImageRotation.rotation180deg:
        return y * canvasSize.height / imageSize.height;
    }
  }
}
