class PoseQualityScore {
  const PoseQualityScore({
    required this.visibility,
    required this.framing,
    required this.occlusion,
    required this.stability,
    required this.bodyCompleteness,
  });

  /// Mean stabilized confidence of critical joints [0..1].
  final double visibility;

  /// Torso/limbs occupy expected image region [0..1].
  final double framing;

  /// 1 - fraction of missing critical joints [0..1].
  final double occlusion;

  /// Inverse jerk / motion consistency [0..1].
  final double stability;

  /// Required landmarks present and reliable [0..1].
  final double bodyCompleteness;

  static const _weights = (
    visibility: 0.30,
    framing: 0.15,
    occlusion: 0.20,
    stability: 0.15,
    bodyCompleteness: 0.20,
  );

  double get overall {
    final w = _weights;
    return (visibility * w.visibility +
            framing * w.framing +
            occlusion * w.occlusion +
            stability * w.stability +
            bodyCompleteness * w.bodyCompleteness)
        .clamp(0.0, 1.0);
  }

  bool get isTrackingReady => overall >= 0.55;
  bool get isRepReady => overall >= 0.45;

  PoseQualityScore merge(PoseQualityScore other, {required double alpha}) {
    double lerp(double a, double b) => a + (b - a) * alpha;
    return PoseQualityScore(
      visibility: lerp(visibility, other.visibility),
      framing: lerp(framing, other.framing),
      occlusion: lerp(occlusion, other.occlusion),
      stability: lerp(stability, other.stability),
      bodyCompleteness: lerp(bodyCompleteness, other.bodyCompleteness),
    );
  }
}
