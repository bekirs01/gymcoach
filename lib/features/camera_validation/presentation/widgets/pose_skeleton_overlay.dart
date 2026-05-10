import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../domain/pose_frame.dart';
import '../pose_coordinate_mapper.dart';
import 'pose_skeleton_painter.dart';

class PoseSkeletonOverlay extends StatelessWidget {
  const PoseSkeletonOverlay({
    super.key,
    required this.frame,
    required this.controller,
    required this.imageSize,
  });

  final PoseFrame? frame;
  final CameraController controller;
  final Size imageSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        if (frame == null || imageSize.width <= 0) {
          return const SizedBox.expand();
        }
        final mapper = PoseCoordinateMapper.fromCamera(
          canvasSize: canvasSize,
          imageSize: imageSize,
          controller: controller,
        );
        return CustomPaint(
          painter: PoseSkeletonPainter(frame: frame, mapper: mapper),
          size: canvasSize,
        );
      },
    );
  }
}
