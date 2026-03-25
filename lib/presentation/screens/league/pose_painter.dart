import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  PosePainter({
    required this.poses,
    required this.bothHandsUp,
    required this.imageSize,
    required this.rotation,
    required this.cameraLensDirection,
  });

  final List<Pose> poses;
  final bool bothHandsUp;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  static const _connections = [
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
  ];

  /// Yüz landmark'ları çizilmez.
  static const Set<PoseLandmarkType> _bodyLandmarkDots = {
    PoseLandmarkType.leftShoulder,
    PoseLandmarkType.rightShoulder,
    PoseLandmarkType.leftElbow,
    PoseLandmarkType.leftWrist,
    PoseLandmarkType.rightElbow,
    PoseLandmarkType.rightWrist,
    PoseLandmarkType.leftHip,
    PoseLandmarkType.rightHip,
    PoseLandmarkType.leftKnee,
    PoseLandmarkType.leftAnkle,
    PoseLandmarkType.rightKnee,
    PoseLandmarkType.rightAnkle,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final accent = bothHandsUp
        ? const Color(0xFF22C55E)
        : const Color(0xFF0D9488);
    final dotPaint = Paint()
      ..color = accent
      ..strokeWidth = 6
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = accent.withOpacity(0.78)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final pose in poses) {
      for (final conn in _connections) {
        final from = pose.landmarks[conn[0]];
        final to = pose.landmarks[conn[1]];
        if (from != null &&
            to != null &&
            from.likelihood > 0.3 &&
            to.likelihood > 0.3) {
          canvas.drawLine(_offset(from, size), _offset(to, size), linePaint);
        }
      }
      for (final entry in pose.landmarks.entries) {
        if (!_bodyLandmarkDots.contains(entry.key)) continue;
        final lm = entry.value;
        if (lm.likelihood > 0.3) {
          canvas.drawCircle(_offset(lm, size), 4.5, dotPaint);
        }
      }
    }
  }

  Offset _offset(PoseLandmark lm, Size canvasSize) {
    final x = _translateX(lm.x, canvasSize);
    final y = _translateY(lm.y, canvasSize);
    return Offset(x, y);
  }

  double _translateX(double x, Size canvasSize) {
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
        if (cameraLensDirection == CameraLensDirection.front) {
          return canvasSize.width - x * canvasSize.width / imageSize.width;
        }
        return x * canvasSize.width / imageSize.width;
    }
  }

  double _translateY(double y, Size canvasSize) {
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

  @override
  bool shouldRepaint(PosePainter oldDelegate) => true;
}
