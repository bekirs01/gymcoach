import 'package:flutter/material.dart';

import '../../../app/theme/premium_tokens.dart';
import '../data/voice_playback_service.dart';
import '../data/waveform_utils.dart';

class VoiceWaveformBars extends StatelessWidget {
  const VoiceWaveformBars({
    super.key,
    required this.samples,
    required this.progress,
    required this.isMe,
    this.height = 28,
  });

  final List<double> samples;
  final double progress;
  final bool isMe;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bars = samples.isEmpty ? WaveformUtils.generateSamples(barCount: 24, durationMs: 3000) : samples;
    final activeIndex = (progress.clamp(0.0, 1.0) * bars.length).floor();

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < bars.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  height: height * bars[i],
                  decoration: BoxDecoration(
                    color: _barColor(i <= activeIndex),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _barColor(bool active) {
    if (isMe) {
      return active ? Colors.white : Colors.white.withValues(alpha: 0.42);
    }
    return active ? PremiumColors.accentBlue : PremiumColors.textMuted.withValues(alpha: 0.55);
  }
}

class VoiceMessageBubble extends StatelessWidget {
  const VoiceMessageBubble({
    super.key,
    required this.durationMs,
    required this.waveform,
    required this.isMe,
    required this.isPlaying,
    required this.progress,
    required this.isLoading,
    required this.onToggle,
  });

  final int durationMs;
  final List<double> waveform;
  final bool isMe;
  final bool isPlaying;
  final double progress;
  final bool isLoading;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final widthFactor = WaveformUtils.bubbleWidthFactor(durationMs);
    final bubbleWidth = (screenWidth * widthFactor).clamp(168.0, screenWidth * 0.72);

    return SizedBox(
      width: bubbleWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [PremiumColors.accentBlue, PremiumColors.accentBlueSoft],
                )
              : null,
          color: isMe ? null : PremiumColors.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(PremiumRadii.lg),
            topRight: const Radius.circular(PremiumRadii.lg),
            bottomLeft: Radius.circular(isMe ? PremiumRadii.lg : PremiumRadii.sm),
            bottomRight: Radius.circular(isMe ? PremiumRadii.sm : PremiumRadii.lg),
          ),
          border: isMe ? null : Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: isMe
              ? const [
                  BoxShadow(
                    color: Color(0x336B8FC7),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading ? null : onToggle,
                  customBorder: const CircleBorder(),
                  child: Ink(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isMe
                          ? Colors.white.withValues(alpha: 0.16)
                          : PremiumColors.accentBlue.withValues(alpha: 0.14),
                      border: Border.all(
                        color: isMe
                            ? Colors.white.withValues(alpha: 0.28)
                            : PremiumColors.accentBlue.withValues(alpha: 0.35),
                      ),
                    ),
                    child: isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isMe ? Colors.white : PremiumColors.accentBlue,
                            ),
                          )
                        : Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: isMe ? Colors.white : PremiumColors.accentBlue,
                            size: 22,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: VoiceWaveformBars(
                  samples: waveform,
                  progress: progress,
                  isMe: isMe,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                WaveformUtils.formatDuration(durationMs),
                style: TextStyle(
                  color: isMe ? Colors.white.withValues(alpha: 0.92) : PremiumColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VoicePlaybackScope extends InheritedNotifier<VoicePlaybackService> {
  const VoicePlaybackScope({
    super.key,
    required VoicePlaybackService playback,
    required super.child,
  }) : super(notifier: playback);

  static VoicePlaybackService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<VoicePlaybackScope>();
    assert(scope != null, 'VoicePlaybackScope not found');
    return scope!.notifier!;
  }
}
