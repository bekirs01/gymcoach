import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/premium_tokens.dart';

/// Full-screen dark gradient with very subtle particles.
class PremiumBackground extends StatefulWidget {
  const PremiumBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<PremiumBackground> createState() => _PremiumBackgroundState();
}

class _PremiumBackgroundState extends State<PremiumBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final random = math.Random(7);
    _particles = List.generate(18, (_) => _Particle.random(random));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 32),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(decoration: BoxDecoration(gradient: PremiumColors.backgroundGradient)),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                progress: _controller.value,
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });

  final double x;
  final double y;
  final double radius;
  final double speed;
  final double opacity;

  factory _Particle.random(math.Random random) {
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      radius: random.nextDouble() * 1.2 + 0.4,
      speed: random.nextDouble() * 0.2 + 0.08,
      opacity: random.nextDouble() * 0.12 + 0.04,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final y = ((particle.y + progress * particle.speed) % 1.2) - 0.1;
      paint.color = Colors.white.withValues(alpha: particle.opacity);
      canvas.drawCircle(
        Offset(particle.x * size.width, y * size.height),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
