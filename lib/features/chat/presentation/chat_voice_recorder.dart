import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/premium_tokens.dart';
import '../data/voice_playback_service.dart';
import '../data/voice_recorder_service.dart';
import '../data/waveform_utils.dart';
import 'voice_message_bubble.dart';

enum ChatVoiceComposerMode {
  idle,
  recording,
  preview,
}

class ChatVoiceComposer extends StatefulWidget {
  const ChatVoiceComposer({
    super.key,
    required this.recorder,
    required this.playback,
    required this.onSend,
    required this.onCancel,
    required this.onPermissionDenied,
    this.onModeChanged,
  });

  final VoiceRecorderService recorder;
  final VoicePlaybackService playback;
  final Future<void> Function(VoiceRecordingResult result) onSend;
  final VoidCallback onCancel;
  final VoidCallback onPermissionDenied;
  final ValueChanged<bool>? onModeChanged;

  @override
  State<ChatVoiceComposer> createState() => ChatVoiceComposerState();
}

class ChatVoiceComposerState extends State<ChatVoiceComposer> {
  ChatVoiceComposerMode _mode = ChatVoiceComposerMode.idle;
  VoiceRecordingResult? _preview;
  List<double> _waveform = const [];
  Duration _elapsed = Duration.zero;
  StreamSubscription<Duration>? _elapsedSub;
  var _sending = false;

  bool get isActive => _mode != ChatVoiceComposerMode.idle;

  Future<void> startRecording() async {
    if (_mode != ChatVoiceComposerMode.idle || _sending) return;

    final granted = await widget.recorder.ensurePermission();
    if (!granted) {
      widget.onPermissionDenied();
      return;
    }

    await widget.recorder.startRecording();
    _elapsedSub?.cancel();
    _elapsedSub = widget.recorder.elapsedStream.listen((value) {
      if (!mounted) return;
      setState(() => _elapsed = value);
    });

    setState(() {
      _mode = ChatVoiceComposerMode.recording;
      _preview = null;
      _waveform = const [];
      _elapsed = Duration.zero;
    });
    widget.onModeChanged?.call(true);
  }

  Future<void> stopRecording() async {
    if (_mode != ChatVoiceComposerMode.recording) return;
    _elapsedSub?.cancel();
    _elapsedSub = null;

    final result = await widget.recorder.stopRecording();
    if (!mounted) return;

    if (result == null) {
      setState(() => _mode = ChatVoiceComposerMode.idle);
      widget.onModeChanged?.call(false);
      return;
    }

    final waveform = WaveformUtils.generateSamples(
      barCount: 28,
      durationMs: result.durationMs,
      seed: result.filePath,
    );

    setState(() {
      _mode = ChatVoiceComposerMode.preview;
      _preview = result;
      _waveform = waveform;
    });
  }

  Future<void> cancelRecording() async {
    _elapsedSub?.cancel();
    _elapsedSub = null;
    await widget.recorder.cancelRecording();
    if (_preview != null) {
      await widget.recorder.deleteFile(_preview!.filePath);
    }
    if (!mounted) return;
    setState(() {
      _mode = ChatVoiceComposerMode.idle;
      _preview = null;
      _waveform = const [];
      _elapsed = Duration.zero;
    });
    widget.onModeChanged?.call(false);
    widget.onCancel();
  }

  Future<void> sendPreview() async {
    final preview = _preview;
    if (preview == null || _sending) return;

    setState(() => _sending = true);
    try {
      await widget.onSend(preview);
      if (!mounted) return;
      setState(() {
        _mode = ChatVoiceComposerMode.idle;
        _preview = null;
        _waveform = const [];
        _elapsed = Duration.zero;
        _sending = false;
      });
      widget.onModeChanged?.call(false);
    } catch (_) {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _elapsedSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_mode == ChatVoiceComposerMode.idle) {
      return const SizedBox.shrink();
    }

    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, bottomSafe + AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: PremiumColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(PremiumRadii.pill),
        border: Border.all(color: PremiumColors.accentBlue.withValues(alpha: 0.28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x266B8FC7),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: _mode == ChatVoiceComposerMode.recording
          ? _RecordingBar(
              elapsed: _elapsed,
              onCancel: cancelRecording,
              onStop: stopRecording,
            )
          : _PreviewBar(
              preview: _preview!,
              waveform: _waveform,
              playback: widget.playback,
              sending: _sending,
              onDelete: cancelRecording,
              onSend: sendPreview,
            ),
    );
  }
}

class _RecordingBar extends StatefulWidget {
  const _RecordingBar({
    required this.elapsed,
    required this.onCancel,
    required this.onStop,
  });

  final Duration elapsed;
  final VoidCallback onCancel;
  final VoidCallback onStop;

  @override
  State<_RecordingBar> createState() => _RecordingBarState();
}

class _RecordingBarState extends State<_RecordingBar> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsedLabel = WaveformUtils.formatDuration(widget.elapsed.inMilliseconds);
    final animatedSamples = WaveformUtils.generateSamples(
      barCount: 24,
      durationMs: widget.elapsed.inMilliseconds + 500,
      seed: 'recording',
    );

    return Row(
      children: [
        IconButton(
          onPressed: widget.onCancel,
          icon: const Icon(Icons.delete_outline_rounded, color: PremiumColors.textMuted),
        ),
        FadeTransition(
          opacity: Tween<double>(begin: 0.45, end: 1).animate(_pulse),
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF5A7A),
              boxShadow: [
                BoxShadow(
                  color: Color(0x66FF5A7A),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          elapsedLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: VoiceWaveformBars(
            samples: animatedSamples,
            progress: (widget.elapsed.inMilliseconds % 1200) / 1200,
            isMe: true,
            height: 24,
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onStop,
            customBorder: const CircleBorder(),
            child: Ink(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [PremiumColors.accentBlue, PremiumColors.accentBlueSoft],
                ),
                boxShadow: [
                  BoxShadow(
                    color: PremiumColors.accentBlue.withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.stop_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewBar extends StatelessWidget {
  const _PreviewBar({
    required this.preview,
    required this.waveform,
    required this.playback,
    required this.sending,
    required this.onDelete,
    required this.onSend,
  });

  final VoiceRecordingResult preview;
  final List<double> waveform;
  final VoicePlaybackService playback;
  final bool sending;
  final VoidCallback onDelete;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: playback,
      builder: (context, _) {
        final state = playback.snapshot('preview');
        final isPlaying = state.isPlaying;
        final progress = state.progress;

        return Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: sending
                    ? null
                    : () {
                        playback.toggle(
                          messageId: 'preview',
                          source: preview.filePath,
                          isLocalFile: true,
                        );
                      },
                customBorder: const CircleBorder(),
                child: Ink(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PremiumColors.accentBlue.withValues(alpha: 0.16),
                    border: Border.all(color: PremiumColors.accentBlue.withValues(alpha: 0.35)),
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: PremiumColors.accentBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: VoiceWaveformBars(
                samples: waveform,
                progress: progress,
                isMe: true,
                height: 24,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              WaveformUtils.formatDuration(preview.durationMs),
              style: const TextStyle(
                color: PremiumColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: sending ? null : onDelete,
              icon: const Icon(Icons.delete_outline_rounded, color: PremiumColors.textMuted),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: sending ? null : onSend,
                customBorder: const CircleBorder(),
                child: Ink(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: sending
                        ? null
                        : const LinearGradient(
                            colors: [PremiumColors.accentBlue, PremiumColors.accentBlueSoft],
                          ),
                    color: sending ? PremiumColors.surfaceRaised : null,
                  ),
                  child: sending
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: PremiumColors.accentBlue,
                          ),
                        )
                      : const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
