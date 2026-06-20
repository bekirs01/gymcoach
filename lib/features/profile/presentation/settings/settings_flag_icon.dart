import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/profile_settings_options.dart';

class SettingsFlagIcon extends StatelessWidget {
  const SettingsFlagIcon({
    super.key,
    required this.language,
    this.size = 28,
  });

  final AppLanguageCode language;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: size,
        height: size * 0.68,
        child: switch (language) {
          AppLanguageCode.en => const _UkFlag(),
          AppLanguageCode.ru => const _RussianFlag(),
          AppLanguageCode.tr => const _TurkishFlag(),
        },
      ),
    );
  }
}

class _UkFlag extends StatelessWidget {
  const _UkFlag();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF012169),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.5),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Container(
              width: double.infinity,
              height: 2,
              color: Colors.white,
            ),
          ),
          Center(
            child: Container(
              width: 2,
              height: double.infinity,
              color: Colors.white,
            ),
          ),
          Center(
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(width: double.infinity, height: 1.2, color: const Color(0xFFC8102E)),
            ),
          ),
          Center(
            child: Transform.rotate(
              angle: -0.785398,
              child: Container(width: double.infinity, height: 1.2, color: const Color(0xFFC8102E)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RussianFlag extends StatelessWidget {
  const _RussianFlag();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RussianFlagPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _RussianFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stripeHeight = size.height / 3;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, stripeHeight),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, stripeHeight, size.width, stripeHeight),
      Paint()..color = const Color(0xFF0039A6),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, stripeHeight * 2, size.width, stripeHeight),
      Paint()..color = const Color(0xFFD52B1E),
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.white.withValues(alpha: 0.12),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TurkishFlag extends StatelessWidget {
  const _TurkishFlag();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TurkishFlagPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _TurkishFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE30A17));
    final white = Paint()..color = Colors.white;
    final center = Offset(size.width * 0.38, size.height * 0.5);
    canvas.drawCircle(center, size.height * 0.18, white);
    canvas.drawCircle(
      Offset(center.dx + size.height * 0.06, center.dy),
      size.height * 0.14,
      Paint()..color = const Color(0xFFE30A17),
    );
    final star = Path();
    final starCenter = Offset(size.width * 0.58, size.height * 0.5);
    const points = 5;
    final outer = size.height * 0.1;
    final inner = outer * 0.42;
    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = (i * math.pi / points) - math.pi / 2;
      final point = Offset(
        starCenter.dx + radius * math.cos(angle),
        starCenter.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        star.moveTo(point.dx, point.dy);
      } else {
        star.lineTo(point.dx, point.dy);
      }
    }
    star.close();
    canvas.drawPath(star, white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
