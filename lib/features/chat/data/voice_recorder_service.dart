import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class VoiceRecordingResult {
  const VoiceRecordingResult({
    required this.filePath,
    required this.durationMs,
    required this.mimeType,
  });

  final String filePath;
  final int durationMs;
  final String mimeType;
}

class VoiceRecorderService {
  VoiceRecorderService({AudioRecorder? recorder}) : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  DateTime? _startedAt;
  String? _activePath;
  Timer? _timer;
  final _elapsedController = StreamController<Duration>.broadcast();

  Stream<Duration> get elapsedStream => _elapsedController.stream;

  Future<bool> ensurePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startRecording() async {
    if (await _recorder.isRecording()) return;

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _activePath = path;
    _startedAt = DateTime.now();

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final startedAt = _startedAt;
      if (startedAt == null) return;
      _elapsedController.add(DateTime.now().difference(startedAt));
    });
  }

  Future<VoiceRecordingResult?> stopRecording() async {
    final path = await _recorder.stop();
    _timer?.cancel();
    _timer = null;

    final resolvedPath = path ?? _activePath;
    _activePath = null;

    final startedAt = _startedAt;
    _startedAt = null;

    if (resolvedPath == null || startedAt == null) return null;
    final file = File(resolvedPath);
    if (!await file.exists()) return null;

    final durationMs = DateTime.now().difference(startedAt).inMilliseconds;
    return VoiceRecordingResult(
      filePath: resolvedPath,
      durationMs: maxDuration(durationMs),
      mimeType: 'audio/m4a',
    );
  }

  Future<void> cancelRecording() async {
    if (await _recorder.isRecording()) {
      final path = await _recorder.stop();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    _timer?.cancel();
    _timer = null;
    _startedAt = null;
    _activePath = null;
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  int maxDuration(int durationMs) => durationMs < 500 ? 500 : durationMs;

  Future<void> dispose() async {
    await cancelRecording();
    await _elapsedController.close();
    await _recorder.dispose();
  }
}
