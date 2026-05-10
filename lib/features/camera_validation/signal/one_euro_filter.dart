import 'dart:math' as math;

/// 1€ filter — low latency during fast motion, strong jitter rejection at rest.
/// Casiez et al., CHI 2012.
class OneEuroFilter {
  OneEuroFilter({
    this.minCutoff = 1.0,
    this.beta = 0.007,
    this.dCutoff = 1.0,
  });

  final double minCutoff;
  final double beta;
  final double dCutoff;

  double _xPrev = 0;
  double _dxPrev = 0;
  var _initialized = false;

  void reset() {
    _initialized = false;
    _dxPrev = 0;
  }

  double filter(double x, double dtSeconds) {
    if (dtSeconds <= 0) return _initialized ? _xPrev : x;
    if (!_initialized) {
      _xPrev = x;
      _dxPrev = 0;
      _initialized = true;
      return x;
    }

    final dx = (x - _xPrev) / dtSeconds;
    final edx = _lowPass(dx, _dxPrev, _alpha(dtSeconds, dCutoff));
    final cutoff = minCutoff + beta * edx.abs();
    final result = _lowPass(x, _xPrev, _alpha(dtSeconds, cutoff));
    _xPrev = result;
    _dxPrev = edx;
    return result;
  }

  double _lowPass(double x, double xPrev, double a) => a * x + (1 - a) * xPrev;

  double _alpha(double dt, double cutoff) {
    final tau = 1 / (2 * math.pi * cutoff);
    return 1 / (1 + tau / dt);
  }
}

class OneEuroFilter2D {
  OneEuroFilter2D({OneEuroFilter? xFilter, OneEuroFilter? yFilter})
      : _x = xFilter ?? OneEuroFilter(),
        _y = yFilter ?? OneEuroFilter();

  final OneEuroFilter _x;
  final OneEuroFilter _y;

  void reset() {
    _x.reset();
    _y.reset();
  }

  ({double x, double y}) filter(double x, double y, double dtSeconds) {
    return (
      x: _x.filter(x, dtSeconds),
      y: _y.filter(y, dtSeconds),
    );
  }
}
