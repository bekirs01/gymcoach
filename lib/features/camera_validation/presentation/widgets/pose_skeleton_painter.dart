import 'package:flutter/material.dart';

import '../../domain/pose_frame.dart';
import '../pose_coordinate_mapper.dart';

class PoseSkeletonPainter extends CustomPainter {
  PoseSkeletonPainter({
    required this.frame,
    required this.mapper,
    this.boneColor = const Color(0xFF2DD4BF),
    this.jointColor = Colors.white,
    this.lowConfidenceColor = const Color(0x66FFFFFF),
  });

  final PoseFrame? frame;
  final PoseCoordinateMapper mapper;
  final Color boneColor;
  final Color jointColor;
  final Color lowConfidenceColor;

  static const _bones = [
    (PoseLandmark.leftShoulder, PoseLandmark.rightShoulder),
    (PoseLandmark.leftShoulder, PoseLandmark.leftElbow),
    (PoseLandmark.leftElbow, PoseLandmark.leftWrist),
    (PoseLandmark.rightShoulder, PoseLandmark.rightElbow),
    (PoseLandmark.rightElbow, PoseLandmark.rightWrist),
    (PoseLandmark.leftShoulder, PoseLandmark.leftHip),
    (PoseLandmark.rightShoulder, PoseLandmark.rightHip),
    (PoseLandmark.leftHip, PoseLandmark.rightHip),
    (PoseLandmark.leftHip, PoseLandmark.leftKnee),
    (PoseLandmark.leftKnee, PoseLandmark.leftAnkle),
    (PoseLandmark.rightHip, PoseLandmark.rightKnee),
    (PoseLandmark.rightKnee, PoseLandmark.rightAnkle),
  ];

  static const _joints = [
    PoseLandmark.nose,
    PoseLandmark.leftShoulder,
    PoseLandmark.rightShoulder,
    PoseLandmark.leftElbow,
    PoseLandmark.rightElbow,
    PoseLandmark.leftWrist,
    PoseLandmark.rightWrist,
    PoseLandmark.leftHip,
    PoseLandmark.rightHip,
    PoseLandmark.leftKnee,
    PoseLandmark.rightKnee,
    PoseLandmark.leftAnkle,
    PoseLandmark.rightAnkle,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final current = frame;
    if (current == null) return;

    final bonePaint = Paint()
      ..color = boneColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final faintBone = Paint()
      ..color = boneColor.withValues(alpha: 0.35)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final (a, b) in _bones) {
      final pa = mapper.map(a, current);
      final pb = mapper.map(b, current);
      if (pa == null || pb == null) continue;
      final reliable = current.hasReliable(a) && current.hasReliable(b);
      canvas.drawLine(pa, pb, reliable ? bonePaint : faintBone);
    }

    final nose = mapper.map(PoseLandmark.nose, current);
    final ls = mapper.map(PoseLandmark.leftShoulder, current);
    final rs = mapper.map(PoseLandmark.rightShoulder, current);
    if (nose != null && ls != null) {
      canvas.drawLine(nose, ls, bonePaint..strokeWidth = 2.5);
    }
    if (nose != null && rs != null) {
      canvas.drawLine(nose, rs, bonePaint..strokeWidth = 2.5);
    }

    for (final joint in _joints) {
      final p = mapper.map(joint, current);
      if (p == null) continue;
      final reliable = current.hasReliable(joint);
      canvas.drawCircle(
        p,
        reliable ? 6 : 4,
        Paint()..color = reliable ? jointColor : lowConfidenceColor,
      );
      canvas.drawCircle(
        p,
        reliable ? 6 : 4,
        Paint()
          ..color = boneColor.withValues(alpha: reliable ? 0.45 : 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PoseSkeletonPainter oldDelegate) {
    return oldDelegate.frame != frame ||
        oldDelegate.mapper.canvasSize != mapper.canvasSize;
  }
}
