import 'dart:async';

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

class _StoryViewerPageState extends State<StoryViewerPage> with TickerProviderStateMixin {
  static const _slideDuration = Duration(seconds: 5);
  static const _swipeThresholdRatio = 0.28;
  static const _swipeVelocityThreshold = 800.0;
  static const _transitionDuration = Duration(milliseconds: 260);

  late int _storyIndex;
  late int _slideIndex;
  late AnimationController _progressController;
  AnimationController? _dragAnimController;
  bool _isPaused = false;
  bool _isStoryDragging = false;
  bool _isTransitioning = false;
  double _dragOffset = 0;

  FeedStory get _story => widget.stories[_storyIndex];

  List<FeedStorySlide> _slidesForStory(FeedStory story) {
    return story.slides.where((slide) => slide.hasContent).toList();
  }

  List<FeedStorySlide> get _slides => _slidesForStory(_story);

  @override
  void initState() {
    super.initState();
    _storyIndex = widget.initialStoryIndex.clamp(0, widget.stories.length - 1);
    _slideIndex = 0;
    _progressController = AnimationController(vsync: this, duration: _slideDuration);
    _progressController.addStatusListener(_onProgressStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startSlideProgress();
    });
  }

  @override
  void dispose() {
    _dragAnimController?.dispose();
    _progressController
      ..removeStatusListener(_onProgressStatus)
      ..dispose();
    super.dispose();
  }

  void _onProgressStatus(AnimationStatus status) {
    if (!mounted || _isPaused || _isTransitioning || _isStoryDragging) return;
    if (status == AnimationStatus.completed) {
      _goNextSlide();
    }
  }

  void _startSlideProgress() {
    if (!mounted) return;
    _progressController
      ..stop()
      ..reset();
    _progressController.forward();
  }

  void _resetSlideProgress() {
    _startSlideProgress();
  }

  void _pauseProgress() {
    if (_isPaused) return;
    _isPaused = true;
    _progressController.stop();
  }

  void _resumeProgress() {
    if (!_isPaused || !mounted) return;
    _isPaused = false;
    if (_progressController.status == AnimationStatus.completed) {
      _goNextSlide();
      return;
    }
    _progressController.forward();
  }

  void _close() {
    _progressController.stop();
    Navigator.of(context).pop();
  }

  double _screenWidth() => MediaQuery.sizeOf(context).width;

  double _clampDragOffset(double offsetDx) {
    final width = _screenWidth();
    final maxLeft =
        _storyIndex < widget.stories.length - 1 ? width : width * 0.4;
    final maxRight = _storyIndex > 0 ? width : width * 0.4;
    return offsetDx.clamp(-maxLeft, maxRight);
  }

  Future<void> _runDragAnimation({required double target}) async {
    if (!mounted) return;
    _isTransitioning = true;
    final start = _dragOffset;
    _dragAnimController?.dispose();
    final controller = AnimationController(vsync: this, duration: _transitionDuration);
    _dragAnimController = controller;
    final animation = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
    void listener() {
      if (!mounted) return;
      setState(() {
        _dragOffset = start + (target - start) * animation.value;
      });
    }

    controller.addListener(listener);
    await controller.forward();
    controller
      ..removeListener(listener)
      ..dispose();
    if (_dragAnimController == controller) {
      _dragAnimController = null;
    }
  }

  Future<void> _completeStoryTransition({required bool isNext}) async {
    if (!mounted || _isTransitioning) return;
    final width = _screenWidth();
    final targetOffset = isNext ? -width : width;
    final targetIndex = isNext ? _storyIndex + 1 : _storyIndex - 1;

    await _runDragAnimation(target: targetOffset);
    if (!mounted) return;

    setState(() {
      _storyIndex = targetIndex;
      _dragOffset = 0;
      _isTransitioning = false;
      if (isNext) {
        _slideIndex = 0;
      } else {
        final slides = _slidesForStory(widget.stories[targetIndex]);
        _slideIndex = slides.isEmpty ? 0 : slides.length - 1;
      }
    });
    _resetSlideProgress();
  }

  Future<void> _snapStoryPageBack() async {
    if (!mounted || _isTransitioning) return;
    await _runDragAnimation(target: 0);
    if (!mounted) return;
    setState(() => _isTransitioning = false);
    _resumeProgress();
  }

  Future<void> _closeFromDrag() async {
    if (!mounted || _isTransitioning) return;
    await _runDragAnimation(target: -_screenWidth() * 0.42);
    if (mounted) _close();
  }

  void _onHoldStart() {
    if (_isTransitioning) return;
    _isStoryDragging = false;
    _pauseProgress();
  }

  void _onHoldDragUpdate(double offsetDx) {
    if (_isTransitioning || !mounted) return;
    if (offsetDx.abs() > 6) {
      _isStoryDragging = true;
    }
    setState(() {
      _dragOffset = _clampDragOffset(offsetDx);
    });
  }

  void _onHoldEnd(double offsetDx, double velocity) {
    if (_isTransitioning) return;

    if (!_isStoryDragging) {
      _resumeProgress();
      return;
    }
    _isStoryDragging = false;

    final width = _screenWidth();
    final threshold = width * _swipeThresholdRatio;
    final shouldGoNext = offsetDx < -threshold || velocity < -_swipeVelocityThreshold;
    final shouldGoPrev = offsetDx > threshold || velocity > _swipeVelocityThreshold;

    if (shouldGoNext) {
      if (_storyIndex < widget.stories.length - 1) {
        unawaited(_completeStoryTransition(isNext: true));
        return;
      }
      unawaited(_closeFromDrag());
      return;
    }

    if (shouldGoPrev && _storyIndex > 0) {
      unawaited(_completeStoryTransition(isNext: false));
      return;
    }

    unawaited(_snapStoryPageBack());
  }

  void _onHoldCancel() {
    _isStoryDragging = false;
    if (_isTransitioning) return;
    if (_dragOffset != 0) {
      unawaited(_snapStoryPageBack());
      return;
    }
    _resumeProgress();
  }

  void _goPreviousSlide() {
    if (_isTransitioning || _isStoryDragging) return;
    if (_slideIndex > 0) {
      setState(() => _slideIndex -= 1);
      _resetSlideProgress();
      return;
    }
    if (_storyIndex > 0) {
      final previousStory = widget.stories[_storyIndex - 1];
      final previousSlides = _slidesForStory(previousStory);
      setState(() {
        _storyIndex -= 1;
        _slideIndex = previousSlides.isEmpty ? 0 : previousSlides.length - 1;
        _dragOffset = 0;
      });
      _resetSlideProgress();
      return;
    }
    _resetSlideProgress();
  }

  void _goNextSlide() {
    if (_isTransitioning || _isStoryDragging) return;
    if (_slideIndex < _slides.length - 1) {
      setState(() => _slideIndex += 1);
      _resetSlideProgress();
      return;
    }
    if (_storyIndex < widget.stories.length - 1) {
      setState(() {
        _storyIndex += 1;
        _slideIndex = 0;
        _dragOffset = 0;
      });
      _resetSlideProgress();
      return;
    }
    _close();
  }

  FeedStorySlide _slideForStoryAt(int storyIndex) {
    final story = widget.stories[storyIndex];
    final slides = _slidesForStory(story);
    if (slides.isEmpty) {
      return const FeedStorySlide();
    }
    if (storyIndex == _storyIndex) {
      return slides[_slideIndex.clamp(0, slides.length - 1)];
    }
    if (storyIndex < _storyIndex) {
      return slides.last;
    }
    return slides.first;
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: StorySwipeTransition(
              stories: widget.stories,
              storyIndex: _storyIndex,
              dragOffset: _dragOffset,
              slideForStoryAt: _slideForStoryAt,
            ),
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
          Positioned.fill(
            child: StoryGestureLayer(
              enabled: !_isTransitioning,
              onTapLeft: _goPreviousSlide,
              onTapRight: _goNextSlide,
              onHoldStart: _onHoldStart,
              onHoldDragUpdate: _onHoldDragUpdate,
              onHoldEnd: _onHoldEnd,
              onHoldCancel: _onHoldCancel,
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

const _storyMaxRotationY = 0.32;

class StorySwipeTransition extends StatelessWidget {
  const StorySwipeTransition({
    super.key,
    required this.stories,
    required this.storyIndex,
    required this.dragOffset,
    required this.slideForStoryAt,
  });

  final List<FeedStory> stories;
  final int storyIndex;
  final double dragOffset;
  final FeedStorySlide Function(int storyIndex) slideForStoryAt;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width <= 0) {
      return _StorySlideImage(slide: slideForStoryAt(storyIndex));
    }

    final progress = (dragOffset / width).clamp(-1.0, 1.0);
    final hasPrevious = storyIndex > 0;
    final hasNext = storyIndex < stories.length - 1;
    final showPrevious = hasPrevious && dragOffset > 0;
    final showNext = hasNext && dragOffset < 0;

    return ClipRect(
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            if (showPrevious)
              _StoryTransitionLayer(
                slide: slideForStoryAt(storyIndex - 1),
                offsetX: dragOffset - width,
                rotationY: (progress - 1) * _storyMaxRotationY,
                pivot: Alignment.centerRight,
              ),
            if (showNext)
              _StoryTransitionLayer(
                slide: slideForStoryAt(storyIndex + 1),
                offsetX: dragOffset + width,
                rotationY: (1 + progress) * _storyMaxRotationY,
                pivot: Alignment.centerLeft,
              ),
            _StoryTransitionLayer(
              slide: slideForStoryAt(storyIndex),
              offsetX: dragOffset,
              rotationY: progress * _storyMaxRotationY,
              pivot: progress >= 0 ? Alignment.centerRight : Alignment.centerLeft,
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryTransitionLayer extends StatelessWidget {
  const _StoryTransitionLayer({
    required this.slide,
    required this.offsetX,
    required this.rotationY,
    required this.pivot,
  });

  final FeedStorySlide slide;
  final double offsetX;
  final double rotationY;
  final Alignment pivot;

  @override
  Widget build(BuildContext context) {
    final depth = rotationY.abs() / _storyMaxRotationY;
    final scale = 1.0 - depth * 0.035;
    final rotation = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateY(-rotationY);

    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: Transform(
        transform: rotation,
        alignment: pivot,
        child: Transform.scale(
          scale: scale,
          child: _StorySlideImage(slide: slide),
        ),
      ),
    );
  }
}

class StoryGestureLayer extends StatefulWidget {
  const StoryGestureLayer({
    super.key,
    required this.enabled,
    required this.onTapLeft,
    required this.onTapRight,
    required this.onHoldStart,
    required this.onHoldDragUpdate,
    required this.onHoldEnd,
    required this.onHoldCancel,
  });

  final bool enabled;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;
  final VoidCallback onHoldStart;
  final ValueChanged<double> onHoldDragUpdate;
  final void Function(double offsetDx, double velocity) onHoldEnd;
  final VoidCallback onHoldCancel;

  @override
  State<StoryGestureLayer> createState() => _StoryGestureLayerState();
}

class _StoryGestureLayerState extends State<StoryGestureLayer> {
  var _didDrag = false;
  var _lastOffsetDx = 0.0;
  DateTime? _lastMoveTime;
  var _velocity = 0.0;

  void _resetDragTracking() {
    _didDrag = false;
    _lastOffsetDx = 0.0;
    _lastMoveTime = null;
    _velocity = 0.0;
  }

  void _trackVelocity(double offsetDx) {
    final now = DateTime.now();
    if (_lastMoveTime != null) {
      final elapsedMs = now.difference(_lastMoveTime!).inMicroseconds;
      if (elapsedMs > 0) {
        _velocity = ((offsetDx - _lastOffsetDx) / elapsedMs) * 1000000;
      }
    }
    _lastOffsetDx = offsetDx;
    _lastMoveTime = now;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        if (!widget.enabled || _didDrag) return;
        final width = MediaQuery.sizeOf(context).width;
        if (details.localPosition.dx < width * 0.5) {
          widget.onTapLeft();
        } else {
          widget.onTapRight();
        }
      },
      onLongPressStart: (_) {
        if (!widget.enabled) return;
        _resetDragTracking();
        widget.onHoldStart();
      },
      onLongPressMoveUpdate: (details) {
        if (!widget.enabled) return;
        final offsetDx = details.offsetFromOrigin.dx;
        if (offsetDx.abs() > 6) {
          _didDrag = true;
        }
        _trackVelocity(offsetDx);
        widget.onHoldDragUpdate(offsetDx);
      },
      onLongPressEnd: (_) {
        if (!widget.enabled) return;
        widget.onHoldEnd(_lastOffsetDx, _velocity);
        _resetDragTracking();
      },
      onLongPressCancel: () {
        if (!widget.enabled) return;
        widget.onHoldCancel();
        _resetDragTracking();
      },
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
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    if (slideCount <= 0) {
      return const SizedBox(height: 2.5);
    }

    return Row(
      children: List.generate(slideCount, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == slideCount - 1 ? 0 : 4),
            child: StoryProgressSegment(
              isCompleted: index < activeIndex,
              isActive: index == activeIndex,
              progress: index == activeIndex ? progress : null,
            ),
          ),
        );
      }),
    );
  }
}

class StoryProgressSegment extends StatelessWidget {
  const StoryProgressSegment({
    super.key,
    required this.isCompleted,
    required this.isActive,
    this.progress,
  });

  final bool isCompleted;
  final bool isActive;
  final Animation<double>? progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(PremiumRadii.pill),
      child: SizedBox(
        height: 2.5,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            return Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: Colors.white.withValues(alpha: 0.28)),
                if (isCompleted)
                  const ColoredBox(color: Colors.white),
                if (isActive && progress != null)
                  AnimatedBuilder(
                    animation: progress!,
                    builder: (context, _) {
                      final fillWidth = maxWidth * progress!.value.clamp(0.0, 1.0);
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: fillWidth,
                          height: 2.5,
                          child: const ColoredBox(color: Colors.white),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StorySlideImage extends StatelessWidget {
  const _StorySlideImage({required this.slide});

  final FeedStorySlide slide;

  @override
  Widget build(BuildContext context) {
    if (!slide.hasContent) {
      return const _StoryImageFallback();
    }

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
