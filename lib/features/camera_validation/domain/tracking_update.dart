import 'tracking_session_state.dart';

enum TrackingEventKind {
  none,
  repCompleted,
  invalidAttempt,
  holdTick,
  bodyLost,
  bodyFound,
}

class TrackingUpdate {
  const TrackingUpdate({
    required this.state,
    this.event = TrackingEventKind.none,
    this.feedbackCode,
  });

  final TrackingSessionState state;
  final TrackingEventKind event;
  final String? feedbackCode;

  bool get repCompleted => event == TrackingEventKind.repCompleted;
  bool get invalidAttempt => event == TrackingEventKind.invalidAttempt;
}
