import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:gym/features/camera_validation/domain/pose_frame.dart';
import 'package:gym/features/camera_validation/engine/adaptive_rep_engine.dart';
import 'package:gym/features/camera_validation/domain/pose_quality.dart';
import 'package:gym/features/camera_validation/pose_analysis_engine.dart';
import 'package:gym/features/camera_validation/signal/one_euro_filter.dart';
import 'package:gym/features/camera_validation/tracking/pose_geometry.dart';
import 'package:gym/features/camera_validation/tracking/rep_counter.dart';
import 'package:gym/features/camera_validation/tracking/trackers/push_up_tracker.dart';
import 'package:gym/features/camera_validation/tracking/trackers/shoulder_press_tracker.dart';
import 'package:gym/features/camera_validation/tracking/trackers/squat_tracker.dart';

const _quality = PoseQualityScore(
  visibility: 0.9,
  framing: 0.9,
  occlusion: 0.9,
  stability: 0.9,
  bodyCompleteness: 1.0,
);

PoseFrame bilateralKneeFrame(DateTime time, double kneeAngleDeg) {
  const legLen = 0.12;
  const y = 0.5;
  const leftX = 0.42;
  const rightX = 0.58;
  final alpha = (180 - kneeAngleDeg) * math.pi / 180;

  ({PosePoint hip, PosePoint knee, PosePoint ankle}) leg(double cx) {
    final knee = PosePoint(x: cx, y: y);
    final hip = PosePoint(x: cx, y: y - legLen);
    final ankle = PosePoint(
      x: cx + legLen * math.sin(alpha),
      y: y + legLen * math.cos(alpha),
    );
    return (hip: hip, knee: knee, ankle: ankle);
  }

  final left = leg(leftX);
  final right = leg(rightX);

  return PoseFrame(
    timestamp: time,
    landmarks: {
      PoseLandmark.leftShoulder: PosePoint(x: leftX, y: y - legLen - 0.1),
      PoseLandmark.rightShoulder: PosePoint(x: rightX, y: y - legLen - 0.1),
      PoseLandmark.leftHip: left.hip,
      PoseLandmark.rightHip: right.hip,
      PoseLandmark.leftKnee: left.knee,
      PoseLandmark.rightKnee: right.knee,
      PoseLandmark.leftAnkle: left.ankle,
      PoseLandmark.rightAnkle: right.ankle,
    },
  );
}

PoseFrame pushUpFrame({
  required DateTime time,
  required double elbowAngleDeg,
}) {
  final rad = elbowAngleDeg * math.pi / 180;
  const shoulder = PosePoint(x: 0.4, y: 0.4);
  const elbow = PosePoint(x: 0.38, y: 0.48);
  final wrist = PosePoint(
    x: 0.36 + 0.08 * math.cos(rad),
    y: 0.48 + 0.08 * math.sin(rad),
  );
  return PoseFrame(
    timestamp: time,
    landmarks: {
      PoseLandmark.leftShoulder: shoulder,
      PoseLandmark.rightShoulder: PosePoint(x: 0.6, y: 0.4),
      PoseLandmark.leftElbow: elbow,
      PoseLandmark.rightElbow: PosePoint(x: 0.62, y: 0.48),
      PoseLandmark.leftWrist: wrist,
      PoseLandmark.rightWrist: PosePoint(x: 0.64, y: wrist.y),
      PoseLandmark.leftHip: PosePoint(x: 0.42, y: 0.55),
      PoseLandmark.rightHip: PosePoint(x: 0.58, y: 0.55),
      PoseLandmark.leftKnee: PosePoint(x: 0.43, y: 0.62),
      PoseLandmark.rightKnee: PosePoint(x: 0.57, y: 0.62),
      PoseLandmark.leftAnkle: PosePoint(x: 0.44, y: 0.7),
      PoseLandmark.rightAnkle: PosePoint(x: 0.56, y: 0.7),
    },
  );
}

void main() {
  test('one euro filter reduces jitter at rest', () {
    final f = OneEuroFilter(minCutoff: 1.0, beta: 0.007);
    const dt = 1 / 15;
    var y = 100.0;
    for (var i = 0; i < 10; i++) {
      y = f.filter(100 + (i.isEven ? 3 : -3), dt);
    }
    expect(y, closeTo(100, 2.5));
  });

  test('adaptive rep engine counts rep after calibration', () {
    final engine = AdaptiveRepEngine(
      const AdaptiveRepEngineConfig(
        defaultBottom: 95,
        defaultTop: 155,
        calibrationMs: 500,
        minRomSpan: 30,
        minBottomDwellMs: 80,
        minTopDwellMs: 60,
        repCooldownMs: 200,
      ),
    );
    var t = DateTime(2026, 1, 1);
    for (var i = 0; i < 8; i++) {
      engine.update(metric: i.isEven ? 160 : 90, now: t, quality: _quality, bodyPresent: true);
      t = t.add(const Duration(milliseconds: 100));
    }
    var counted = false;
    for (var i = 0; i < 6; i++) {
      engine.update(metric: 160, now: t, quality: _quality, bodyPresent: true);
      t = t.add(const Duration(milliseconds: 80));
    }
    for (var i = 0; i < 8; i++) {
      engine.update(metric: 85, now: t, quality: _quality, bodyPresent: true);
      t = t.add(const Duration(milliseconds: 80));
    }
    for (var i = 0; i < 8; i++) {
      final r = engine.update(metric: 165, now: t, quality: _quality, bodyPresent: true);
      counted = r.event == RepEngineEvent.repCompleted || counted;
      t = t.add(const Duration(milliseconds: 80));
    }
    expect(counted, isTrue);
  });

  test('legacy rep counter completes cycle', () {
    final counter = RepCounter(
      const RepCounterConfig(bottomThreshold: 105, topThreshold: 155, minBottomDwellMs: 100),
    );
    var t = DateTime(2026, 1, 1);
    for (var i = 0; i < 5; i++) {
      counter.updateMetric(165, t);
      t = t.add(const Duration(milliseconds: 50));
    }
    for (var i = 0; i < 6; i++) {
      counter.updateMetric(85, t);
      t = t.add(const Duration(milliseconds: 50));
    }
    var counted = false;
    for (var i = 0; i < 6; i++) {
      counted = counter.updateMetric(165, t) || counted;
      t = t.add(const Duration(milliseconds: 50));
    }
    expect(counted, isTrue);
  });

  test('squat tracker counts rep through signal pipeline', () {
    final engine = PoseAnalysisEngine(SquatTracker());
    var t = DateTime(2026, 1, 1);
    for (var i = 0; i < 40; i++) {
      engine.process(bilateralKneeFrame(t, 165));
      t = t.add(const Duration(milliseconds: 100));
    }
    for (var i = 0; i < 8; i++) {
      engine.process(bilateralKneeFrame(t, 165));
      t = t.add(const Duration(milliseconds: 120));
    }
    for (var i = 0; i < 10; i++) {
      engine.process(bilateralKneeFrame(t, 85));
      t = t.add(const Duration(milliseconds: 120));
    }
    for (var i = 0; i < 10; i++) {
      engine.process(bilateralKneeFrame(t, 165));
      t = t.add(const Duration(milliseconds: 120));
    }
    expect(engine.state.repCount, 1);
  });

  test('shoulder press tracker counts rep when overhead criteria met', () {
    final engine = PoseAnalysisEngine(ShoulderPressTracker());
    var t = DateTime(2026, 1, 1, 12);

    PoseFrame frame({required bool overhead}) {
      final wristY = overhead ? 0.18 : 0.44;
      final elbowY = overhead ? 0.28 : 0.52;
      return PoseFrame(
        timestamp: t,
        landmarks: {
          PoseLandmark.leftShoulder: PosePoint(x: 0.4, y: 0.45),
          PoseLandmark.rightShoulder: PosePoint(x: 0.6, y: 0.45),
          PoseLandmark.leftElbow: PosePoint(x: 0.38, y: elbowY),
          PoseLandmark.rightElbow: PosePoint(x: 0.62, y: elbowY),
          PoseLandmark.leftWrist: PosePoint(x: 0.36, y: wristY),
          PoseLandmark.rightWrist: PosePoint(x: 0.64, y: wristY),
          PoseLandmark.leftHip: PosePoint(x: 0.42, y: 0.7),
          PoseLandmark.rightHip: PosePoint(x: 0.58, y: 0.7),
        },
      );
    }

    for (var i = 0; i < 40; i++) {
      engine.process(frame(overhead: i.isEven));
      t = t.add(const Duration(milliseconds: 100));
    }
    for (var i = 0; i < 8; i++) {
      engine.process(frame(overhead: false));
      t = t.add(const Duration(milliseconds: 120));
    }
    for (var i = 0; i < 10; i++) {
      engine.process(frame(overhead: true));
      t = t.add(const Duration(milliseconds: 120));
    }
    for (var i = 0; i < 10; i++) {
      engine.process(frame(overhead: false));
      t = t.add(const Duration(milliseconds: 120));
    }

    expect(engine.state.repCount, 1);
  });

  test('push up tracker detects body in frame', () {
    final engine = PoseAnalysisEngine(PushUpTracker());
    engine.process(pushUpFrame(time: DateTime.now(), elbowAngleDeg: 160));
    expect(engine.state.bodyDetected, isTrue);
  });

  test('squat knee angle geometry', () {
    final frame = bilateralKneeFrame(DateTime.now(), 90);
    final angle = PoseGeometry.averageAngle(
      frame,
      PoseLandmark.leftHip,
      PoseLandmark.leftKnee,
      PoseLandmark.leftAnkle,
      PoseLandmark.rightHip,
      PoseLandmark.rightKnee,
      PoseLandmark.rightAnkle,
    );
    expect(angle, isNotNull);
    expect(angle!, lessThan(105));
  });
}
