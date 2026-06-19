import 'package:flutter/material.dart';

import '../../../../app/theme/premium_tokens.dart';
import '../../domain/feed_story.dart';
import '../social_avatar.dart';
import 'network_image_with_fallback.dart';

class StoryViewerPage extends StatefulWidget {
  const StoryViewerPage({
    super.key,
    required this.stories,
    required this.initialStoryIndex,
    this.onOwnerTap,
  });

  final List<FeedStory> stories;
  final int initialStoryIndex;
  final void Function(FeedStory story)? onOwnerTap;

  static Future<void> open({
    required BuildContext context,
    required List<FeedStory> stories,
    required int initialStoryIndex,
    void Function(FeedStory story)? onOwnerTap,
  }) {
    final playable = stories.where((story) => story.hasSlides).toList();
    if (playable.isEmpty) return Future.value();

    var playableIndex = 0;
    if (initialStoryIndex >= 0 && initialStoryIndex < stories.length) {
      final targetId = stories[initialStoryIndex].id;
      final found = playable.indexWhere((story) => story.id == targetId);
      if (found >= 0) playableIndex = found;
    }

    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return StoryViewerPage(
            stories: playable,
            initialStoryIndex: playableIndex,
            onOwnerTap: onOwnerTap,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> with SingleTickerProviderStateMixin {
  static const _slideDuration = Duration(seconds: 5);

  late int _storyIndex;
  late int _slideIndex;
  late AnimationController _progressController;

  FeedStory get _story => widget.stories[_storyIndex];
  List<FeedStorySlide> get _slides => _story.slides.where((slide) => slide.hasContent).toList();
  FeedStorySlide get _slide => _slides[_slideIndex];

  @override
  void initState() {
    super.initState();
    _storyIndex = widget.initialStoryIndex.clamp(0, widget.stories.length - 1);
    _slideIndex = 0;
    _progressController = AnimationController(vsync: this, duration: _slideDuration);
    _progressController.addStatusListener(_onProgressStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSlideTimer());
  }

  @override
  void dispose() {
    _progressController
      ..removeStatusListener(_onProgressStatus)
      ..dispose();
    super.dispose();
  }

  void _onProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _goNextSlide();
    }
  }

  void _startSlideTimer() {
    _progressController
      ..stop()
      ..reset();
    _progressController.forward();
  }

  void _resetSlideTimer() {
    _startSlideTimer();
  }

  void _close() {
    Navigator.of(context).pop();
  }

  void _goPreviousSlide() {
    if (_slideIndex > 0) {
      setState(() => _slideIndex -= 1);
      _resetSlideTimer();
      return;
    }
    if (_storyIndex > 0) {
      setState(() {
        _storyIndex -= 1;
        _slideIndex = widget.stories[_storyIndex].slides.where((slide) => slide.hasContent).length - 1;
      });
      _resetSlideTimer();
      return;
    }
    _resetSlideTimer();
  }

  void _goNextSlide() {
    if (_slideIndex < _slides.length - 1) {
      setState(() => _slideIndex += 1);
      _resetSlideTimer();
      return;
    }
    if (_storyIndex < widget.stories.length - 1) {
      setState(() {
        _storyIndex += 1;
        _slideIndex = 0;
      });
      _resetSlideTimer();
      return;
    }
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final headerHeight = topInset + 72;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: _StorySlideImage(slide: _slide),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.58),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.22),
                    ],
                    stops: const [0.0, 0.32, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: headerHeight,
            bottom: 0,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _goPreviousSlide,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _goNextSlide,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            right: 8,
            top: topInset + 8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StoryProgressBar(
                  key: ValueKey('progress_${_story.id}_$_slideIndex'),
                  slideCount: _slides.length,
                  activeIndex: _slideIndex,
                  progress: _progressController,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => widget.onOwnerTap?.call(_story),
                      child: Row(
                        children: [
                          SocialAvatar(
                            name: _story.user.avatarLabel,
                            imageUrl: _story.user.avatarUrl,
                            size: 34,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _story.user.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _close,
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StoryProgressBar extends StatelessWidget {
  const StoryProgressBar({
    super.key,
    required this.slideCount,
    required this.activeIndex,
    required this.progress,
  });

  final int slideCount;
  final int activeIndex;
  final AnimationController progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(slideCount, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == slideCount - 1 ? 0 : 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(PremiumRadii.pill),
              child: SizedBox(
                height: 2.5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: Colors.white.withValues(alpha: 0.28)),
                    if (index < activeIndex)
                      const ColoredBox(color: Colors.white),
                    if (index == activeIndex)
                      AnimatedBuilder(
                        animation: progress,
                        builder: (context, child) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress.value.clamp(0.0, 1.0),
                            child: child,
                          );
                        },
                        child: const ColoredBox(color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StorySlideImage extends StatelessWidget {
  const _StorySlideImage({required this.slide});

  final FeedStorySlide slide;

  @override
  Widget build(BuildContext context) {
    if (slide.imageBytes != null) {
      return Image.memory(
        slide.imageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => const _StoryImageFallback(),
      );
    }

    return NetworkImageWithFallback(
      url: slide.imageUrl ?? '',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

class _StoryImageFallback extends StatelessWidget {
  const _StoryImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PremiumColors.midnightBottom,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined, color: PremiumColors.textMuted, size: 42),
    );
  }
}
