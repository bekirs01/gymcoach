enum FeedPostType {
  normal,
  workoutShare;

  String get wireValue => switch (this) {
        FeedPostType.normal => 'normal',
        FeedPostType.workoutShare => 'workout_share',
      };

  static FeedPostType fromWire(String? value) {
    return switch (value) {
      'workout_share' => FeedPostType.workoutShare,
      _ => FeedPostType.normal,
    };
  }
}
