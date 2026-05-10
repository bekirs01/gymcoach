class RepCounterConfig {
  const RepCounterConfig({
    required this.bottomThreshold,
    required this.topThreshold,
    this.minBottomDwellMs = 120,
    this.minTopDwellMs = 80,
    this.repCooldownMs = 400,
    this.inverted = false,
  });

  final double bottomThreshold;
  final double topThreshold;
  final int minBottomDwellMs;
  final int minTopDwellMs;
  final int repCooldownMs;
  final bool inverted;
}

enum _RepPhase { top, descending, bottom, ascending }

class RepCounter {
  RepCounter(this.config);

  final RepCounterConfig config;
  _RepPhase _phase = _RepPhase.top;
  DateTime? _phaseEnteredAt;
  DateTime? _cooldownUntil;

  void reset() {
    _phase = _RepPhase.top;
    _phaseEnteredAt = null;
    _cooldownUntil = null;
  }

  bool get inCooldown {
    final until = _cooldownUntil;
    if (until == null) return false;
    return DateTime.now().isBefore(until);
  }

  bool updateMetric(double metric, DateTime now) {
    if (inCooldown) return false;

    final isBottom = config.inverted ? metric >= config.bottomThreshold : metric <= config.bottomThreshold;
    final isTop = config.inverted ? metric <= config.topThreshold : metric >= config.topThreshold;

    switch (_phase) {
      case _RepPhase.top:
        if (isBottom) {
          _enterPhase(_RepPhase.descending, now);
        }
      case _RepPhase.descending:
        if (isBottom && _dwellMs(now) >= config.minBottomDwellMs) {
          _enterPhase(_RepPhase.bottom, now);
        } else if (isTop) {
          _enterPhase(_RepPhase.top, now);
        }
      case _RepPhase.bottom:
        if (!isBottom) {
          _enterPhase(_RepPhase.ascending, now);
        }
      case _RepPhase.ascending:
        if (isTop && _dwellMs(now) >= config.minTopDwellMs) {
          _enterPhase(_RepPhase.top, now);
          _cooldownUntil = now.add(Duration(milliseconds: config.repCooldownMs));
          return true;
        } else if (isBottom) {
          _enterPhase(_RepPhase.bottom, now);
        }
    }
    return false;
  }

  int _dwellMs(DateTime now) {
    final entered = _phaseEnteredAt;
    if (entered == null) return 0;
    return now.difference(entered).inMilliseconds;
  }

  void _enterPhase(_RepPhase phase, DateTime now) {
    _phase = phase;
    _phaseEnteredAt = now;
  }

  String get phaseLabel => switch (_phase) {
        _RepPhase.top => 'top',
        _RepPhase.descending => 'down',
        _RepPhase.bottom => 'bottom',
        _RepPhase.ascending => 'up',
      };
}
