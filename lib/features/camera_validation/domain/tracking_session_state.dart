class TrackingSessionState {
  const TrackingSessionState({
    this.repCount = 0,
    this.invalidAttempts = 0,
    this.holdSeconds = 0,
    this.phaseLabel = 'idle',
    this.bodyDetected = false,
    this.lastFeedbackCode,
    this.cooldownUntil,
  });

  final int repCount;
  final int invalidAttempts;
  final int holdSeconds;
  final String phaseLabel;
  final bool bodyDetected;
  final String? lastFeedbackCode;
  final DateTime? cooldownUntil;

  TrackingSessionState copyWith({
    int? repCount,
    int? invalidAttempts,
    int? holdSeconds,
    String? phaseLabel,
    bool? bodyDetected,
    String? lastFeedbackCode,
    DateTime? cooldownUntil,
    bool clearFeedback = false,
    bool clearCooldown = false,
  }) {
    return TrackingSessionState(
      repCount: repCount ?? this.repCount,
      invalidAttempts: invalidAttempts ?? this.invalidAttempts,
      holdSeconds: holdSeconds ?? this.holdSeconds,
      phaseLabel: phaseLabel ?? this.phaseLabel,
      bodyDetected: bodyDetected ?? this.bodyDetected,
      lastFeedbackCode: clearFeedback ? null : (lastFeedbackCode ?? this.lastFeedbackCode),
      cooldownUntil: clearCooldown ? null : (cooldownUntil ?? this.cooldownUntil),
    );
  }
}
