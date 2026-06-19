import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class VoicePlaybackState {
  const VoicePlaybackState({
    required this.messageId,
    required this.isPlaying,
    required this.progress,
    required this.durationMs,
  });

  final String? messageId;
  final bool isPlaying;
  final double progress;
  final int durationMs;
}

class VoicePlaybackService extends ChangeNotifier {
  VoicePlaybackService({AudioPlayer? player}) : _player = player ?? AudioPlayer() {
    _positionSub = _player.positionStream.listen((position) {
      final duration = _player.duration;
      if (duration == null || duration.inMilliseconds <= 0) return;
      _progress = position.inMilliseconds / duration.inMilliseconds;
      _durationMs = duration.inMilliseconds;
      notifyListeners();
    });
    _playerStateSub = _player.playerStateStream.listen((state) {
      _isPlaying = state.playing && state.processingState != ProcessingState.completed;
      if (state.processingState == ProcessingState.completed) {
        _progress = 0;
        _activeMessageId = null;
      }
      notifyListeners();
    });
  }

  final AudioPlayer _player;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  String? _activeMessageId;
  var _isPlaying = false;
  var _progress = 0.0;
  var _durationMs = 0;

  String? get activeMessageId => _activeMessageId;
  bool get isPlaying => _isPlaying;
  double get progress => _progress;
  int get durationMs => _durationMs;

  VoicePlaybackState snapshot(String? messageId) {
    final active = messageId != null && messageId == _activeMessageId;
    return VoicePlaybackState(
      messageId: active ? _activeMessageId : null,
      isPlaying: active && _isPlaying,
      progress: active ? _progress : 0,
      durationMs: active ? _durationMs : 0,
    );
  }

  Future<void> play({
    required String messageId,
    required String source,
    bool isLocalFile = false,
  }) async {
    try {
      if (_activeMessageId != messageId) {
        await _player.stop();
        _progress = 0;
        if (isLocalFile) {
          await _player.setFilePath(source);
        } else {
          await _player.setUrl(source);
        }
        _activeMessageId = messageId;
      } else if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }

      await _player.play();
      _isPlaying = true;
      notifyListeners();
    } catch (_) {
      _activeMessageId = null;
      _isPlaying = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> toggle({
    required String messageId,
    required String source,
    bool isLocalFile = false,
  }) async {
    if (_activeMessageId == messageId && _isPlaying) {
      await pause();
      return;
    }
    await play(messageId: messageId, source: source, isLocalFile: isLocalFile);
  }

  Future<void> stop() async {
    await _player.stop();
    _activeMessageId = null;
    _isPlaying = false;
    _progress = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}
