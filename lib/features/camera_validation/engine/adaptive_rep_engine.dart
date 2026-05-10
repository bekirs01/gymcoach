import '../domain/pose_quality.dart';

class AdaptiveRepEngineConfig {
  const AdaptiveRepEngineConfig({
    required this.defaultBottom,
    required this.defaultTop,
    this.higherIsBottom = false,
    this.hysteresisBand = 8.0,
    this.minEccentricVelocity = 15.0,
    this.minConcentricVelocity = 12.0,
    this.minBottomDwellMs = 120,
    this.minTopDwellMs = 80,
    this.repCooldownMs = 450,
    this.calibrationMs = 3500,
    this.minRomSpan = 25.0,
    this.minRomFraction = 0.60,
    this.bodyLostGraceMs = 600,
  });

  final double defaultBottom;
  final double defaultTop;
  final bool higherIsBottom;
  final double hysteresisBand;
  final double minEccentricVelocity;
  final double minConcentricVelocity;
  final int minBottomDwellMs;
  final int minTopDwellMs;
  final int repCooldownMs;
  final int calibrationMs;
  final double minRomSpan;
  final double minRomFraction;
  final int bodyLostGraceMs;
}

enum RepEnginePhase {
  calibrating,
  top,
  eccentric,
  bottom,
  concentric,
  cooldown,
  bodyLost,
}

enum RepEngineEvent { none, repCompleted, invalidPartial, invalidCheating }

class RepEngineUpdate {
  const RepEngineUpdate({
    required this.phase,
    required this.event,
    this.romAchieved = 0,
    this.calibrated = false,
  });

  final RepEnginePhase phase;
  final RepEngineEvent event;
  final double romAchieved;
  final bool calibrated;
}

class AdaptiveRepEngine {
  AdaptiveRepEngine(this.config) {
    _applyDefaults();
  }

  final AdaptiveRepEngineConfig config;

  RepEnginePhase _phase = RepEnginePhase.calibrating;
  DateTime? _phaseEntered;
  DateTime? _cooldownUntil;
  DateTime? _calibrationStarted;
  DateTime? _bodyLostAt;

  double _runningMin = double.infinity;
  double _runningMax = double.negativeInfinity;
  var _calibrated = false;

  double _bottomEnter = 0;
  double _bottomExit = 0;
  double _topEnter = 0;
  double _topExit = 0;

  double _prevMetric = 0;
  DateTime? _prevTime;
  double _velocity = 0;
  double _peakEccentricVelocity = 0;
  double _metricAtBottom = 0;

  void reset() {
    _phase = RepEnginePhase.calibrating;
    _phaseEntered = null;
    _cooldownUntil = null;
    _calibrationStarted = null;
    _bodyLostAt = null;
    _runningMin = double.infinity;
    _runningMax = double.negativeInfinity;
    _calibrated = false;
    _applyDefaults();
    _prevTime = null;
    _velocity = 0;
    _peakEccentricVelocity = 0;
  }

  RepEnginePhase get phase => _phase;

  String get phaseLabel => switch (_phase) {
        RepEnginePhase.calibrating => 'calibrating',
        RepEnginePhase.top => 'top',
        RepEnginePhase.eccentric => 'down',
        RepEnginePhase.bottom => 'bottom',
        RepEnginePhase.concentric => 'up',
        RepEnginePhase.cooldown => 'cooldown',
        RepEnginePhase.bodyLost => 'lost',
      };

  RepEngineUpdate update({
    required double metric,
    required DateTime now,
    required PoseQualityScore quality,
    required bool bodyPresent,
  }) {
    if (!bodyPresent || !quality.isRepReady) {
      return _handleBodyLost(now);
    }
    _bodyLostAt = null;

    if (_inCooldown(now)) {
      return RepEngineUpdate(phase: _phase, event: RepEngineEvent.none, calibrated: _calibrated);
    }

    _updateVelocity(metric, now);
    _updateCalibration(metric, now, quality);

    final bottomEnter = _bottomEnter;
    final bottomExit = _bottomExit;
    final topEnter = _topEnter;
    final topExit = _topExit;

    final atBottom = config.higherIsBottom ? metric >= bottomEnter : metric <= bottomEnter;
    final leftBottom = config.higherIsBottom ? metric <= bottomExit : metric >= bottomExit;
    final atTop = config.higherIsBottom ? metric <= topEnter : metric >= topEnter;
    final leftTop = config.higherIsBottom ? metric >= topExit : metric <= topExit;

    final eccSign = config.higherIsBottom ? 1.0 : -1.0;
    final conSign = -eccSign;
    final eccOk = _velocity * eccSign >= config.minEccentricVelocity;
    final conOk = _velocity * conSign >= config.minConcentricVelocity;

    var event = RepEngineEvent.none;

    switch (_phase) {
      case RepEnginePhase.calibrating:
        if (_calibrated) {
          _enterPhase(RepEnginePhase.top, now);
        } else if (atBottom && eccOk) {
          _enterPhase(RepEnginePhase.eccentric, now);
        }
      case RepEnginePhase.top:
        if (leftTop && eccOk) {
          _peakEccentricVelocity = 0;
          _enterPhase(RepEnginePhase.eccentric, now);
        }
      case RepEnginePhase.eccentric:
        _peakEccentricVelocity = mathMax(_peakEccentricVelocity, (_velocity * eccSign).abs());
        if (atBottom && _dwellMs(now) >= config.minBottomDwellMs) {
          _metricAtBottom = metric;
          _enterPhase(RepEnginePhase.bottom, now);
        } else if (atTop && !eccOk) {
          _enterPhase(RepEnginePhase.top, now);
        }
      case RepEnginePhase.bottom:
        if (leftBottom && conOk) {
          _enterPhase(RepEnginePhase.concentric, now);
        }
      case RepEnginePhase.concentric:
        if (atTop && _dwellMs(now) >= config.minTopDwellMs) {
          final rom = (_runningMax - _runningMin).abs();
          final depthFraction = rom <= 0
              ? 1.0
              : config.higherIsBottom
                  ? (_metricAtBottom - _runningMin).abs() / rom
                  : (_runningMax - _metricAtBottom).abs() / rom;
          final romOk = depthFraction >= config.minRomFraction;

          if (!romOk || _peakEccentricVelocity < config.minEccentricVelocity * 0.5) {
            event = RepEngineEvent.invalidPartial;
          } else {
            event = RepEngineEvent.repCompleted;
            _cooldownUntil = now.add(Duration(milliseconds: config.repCooldownMs));
          }
          _enterPhase(RepEnginePhase.cooldown, now);
        } else if (atBottom) {
          _enterPhase(RepEnginePhase.bottom, now);
        }
      case RepEnginePhase.cooldown:
        if (!_inCooldown(now)) {
          _enterPhase(RepEnginePhase.top, now);
        }
      case RepEnginePhase.bodyLost:
        _enterPhase(_calibrated ? RepEnginePhase.top : RepEnginePhase.calibrating, now);
    }

    return RepEngineUpdate(
      phase: _phase,
      event: event,
      calibrated: _calibrated,
      romAchieved: (_runningMax - _runningMin).abs(),
    );
  }

  RepEngineUpdate _handleBodyLost(DateTime now) {
    _bodyLostAt ??= now;
    if (_bodyLostAt != null &&
        now.difference(_bodyLostAt!).inMilliseconds >= config.bodyLostGraceMs) {
      if (_phase != RepEnginePhase.bodyLost) {
        _enterPhase(RepEnginePhase.bodyLost, now);
      }
    }
    return RepEngineUpdate(phase: _phase, event: RepEngineEvent.none, calibrated: _calibrated);
  }

  void _updateCalibration(double metric, DateTime now, PoseQualityScore quality) {
    _calibrationStarted ??= now;
    if (quality.overall >= 0.5) {
      _runningMin = mathMin(_runningMin, metric);
      _runningMax = mathMax(_runningMax, metric);
    }
    final elapsed = now.difference(_calibrationStarted!).inMilliseconds;
    final span = (_runningMax - _runningMin).abs();
    if (elapsed >= config.calibrationMs && span >= config.minRomSpan) {
      _applyCalibrationFromRange(_runningMin, _runningMax);
    }
  }

  void _applyCalibrationFromRange(double min, double max) {
    final span = (max - min).abs();
    final margin = mathMax(config.hysteresisBand, span * 0.12);
    if (config.higherIsBottom) {
      _bottomEnter = max - margin * 0.4;
      _bottomExit = max - margin;
      _topEnter = min + margin * 0.4;
      _topExit = min + margin;
    } else {
      _bottomEnter = min + margin * 0.4;
      _bottomExit = min + margin;
      _topEnter = max - margin * 0.4;
      _topExit = max - margin;
    }
    _calibrated = true;
  }

  void _applyDefaults() {
    final h = config.hysteresisBand;
    if (config.higherIsBottom) {
      _bottomEnter = config.defaultBottom;
      _bottomExit = config.defaultBottom - h;
      _topEnter = config.defaultTop;
      _topExit = config.defaultTop + h;
    } else {
      _bottomEnter = config.defaultBottom;
      _bottomExit = config.defaultBottom + h;
      _topEnter = config.defaultTop;
      _topExit = config.defaultTop - h;
    }
  }

  void _updateVelocity(double metric, DateTime now) {
    final prev = _prevTime;
    if (prev != null) {
      final dt = now.difference(prev).inMicroseconds / 1e6;
      if (dt > 0.001) {
        final raw = (metric - _prevMetric) / dt;
        _velocity = _velocity * 0.65 + raw * 0.35;
      }
    }
    _prevMetric = metric;
    _prevTime = now;
  }

  bool _inCooldown(DateTime now) {
    final until = _cooldownUntil;
    return until != null && now.isBefore(until);
  }

  int _dwellMs(DateTime now) {
    final entered = _phaseEntered;
    if (entered == null) return 0;
    return now.difference(entered).inMilliseconds;
  }

  void _enterPhase(RepEnginePhase phase, DateTime now) {
    _phase = phase;
    _phaseEntered = now;
  }

  static double mathMin(double a, double b) => a < b ? a : b;
  static double mathMax(double a, double b) => a > b ? a : b;
}
