import 'dart:math' as math;

import 'package:flutter/material.dart';

class SecretMessage extends StatefulWidget {
  const SecretMessage({super.key});

  @override
  State<SecretMessage> createState() => _SecretMessageState();
}

class _SecretMessageState extends State<SecretMessage>
    with SingleTickerProviderStateMixin {
  static const String _desktopMessage = 'Pyari Bahini Renuka , Mitho Samjhana';

  static const String _mobileTopMessage = 'Pyari Bahini Renuka';
  static const String _mobileBottomMessage = 'Mitho Samjhana';

  late final AnimationController _controller;

  final math.Random _random = math.Random();

  late final List<_Particle> _particles;

  late final List<Offset> _characterOffsets;
  late final List<double> _characterRotations;
  late final List<double> _characterScales;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Background particles
    _particles = List.generate(45, (_) => _Particle.random(_random));

    // Desktop character animation data
    _characterOffsets = List.generate(_desktopMessage.length, (index) {
      final direction = index.isEven ? -1.0 : 1.0;

      return Offset(
        direction * (20 + _random.nextDouble() * 35),
        15 + _random.nextDouble() * 30,
      );
    });

    _characterRotations = List.generate(_desktopMessage.length, (index) {
      return (index.isEven ? -1 : 1) * (0.04 + _random.nextDouble() * 0.08);
    });

    _characterScales = List.generate(
      _desktopMessage.length,
      (_) => 0.85 + _random.nextDouble() * 0.1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════
  // DESKTOP CHARACTER PROGRESS
  // ═══════════════════════════════════════════════

  double _characterProgress(int index) {
    final total = _desktopMessage.length;

    final start = (index / total) * 0.42;
    final end = start + 0.55;

    final raw = ((_controller.value - start) / (end - start)).clamp(0.0, 1.0);

    return Curves.easeOutCubic.transform(raw);
  }

  // ═══════════════════════════════════════════════
  // MOBILE CHARACTER PROGRESS
  // ═══════════════════════════════════════════════

  double _mobileCharacterProgress(int index, int total, double lineDelay) {
    final start = lineDelay + (index / total) * 0.22;
    final end = start + 0.55;

    final raw = ((_controller.value - start) / (end - start)).clamp(0.0, 1.0);

    return Curves.easeOutCubic.transform(raw);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // ═════════════════════════════════════
              // Animated background
              // ═════════════════════════════════════
              CustomPaint(
                painter: _SecretBackgroundPainter(
                  progress: _controller.value,
                  particles: _particles,
                ),
              ),

              // ═════════════════════════════════════
              // Responsive message
              // ═════════════════════════════════════
              Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    if (isMobile) {
                      return _buildMobileMessage();
                    }

                    return _buildDesktopMessage();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // DESKTOP MESSAGE
  // ═══════════════════════════════════════════════

  Widget _buildDesktopMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: List.generate(_desktopMessage.length, (index) {
              return _buildDesktopCharacter(_desktopMessage[index], index);
            }),
          ),

          const SizedBox(height: 16),

          _buildHeart(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // MOBILE MESSAGE
  // ═══════════════════════════════════════════════

  Widget _buildMobileMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─────────────────────────────────────
          // First line
          // Pyari Bahini Renuka
          // ─────────────────────────────────────
          _buildMobileLine(text: _mobileTopMessage, lineDelay: 0.02),

          const SizedBox(height: 12),

          // ─────────────────────────────────────
          // Second line
          // Mitho Samjhana
          // ─────────────────────────────────────
          _buildMobileLine(text: _mobileBottomMessage, lineDelay: 0.18),

          const SizedBox(height: 20),

          _buildHeart(lineWidth: 35, iconSize: 18),
        ],
      ),
    );
  }

  Widget _buildMobileLine({required String text, required double lineDelay}) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: List.generate(text.length, (index) {
        final progress = _mobileCharacterProgress(
          index,
          text.length,
          lineDelay,
        );

        final direction = index.isEven ? -1.0 : 1.0;

        final startOffset = Offset(
          direction * (12 + _randomOffset(index)),
          12 + _randomVerticalOffset(index),
        );

        final offset = Offset.lerp(startOffset, Offset.zero, progress)!;

        final rotation = (index.isEven ? -1 : 1) * 0.035 * (1.0 - progress);

        final scale = Tween<double>(begin: 0.92, end: 1.0).transform(progress);

        final opacity = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));

        final floating =
            math.sin((_controller.value * math.pi * 2) + index * 0.32) *
            1.2 *
            progress;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(offset.dx, offset.dy + floating),
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: scale,
                child: Text(
                  text[index],
                  style: const TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.25,
                    color: Color(0xFFE8D7B0),
                    shadows: [
                      Shadow(blurRadius: 8, color: Color(0x99D6B56A)),
                      Shadow(blurRadius: 18, color: Color(0x55D6B56A)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  double _randomOffset(int index) {
    return 10 + ((index * 7) % 18);
  }

  double _randomVerticalOffset(int index) {
    return 8 + ((index * 5) % 14);
  }

  // ═══════════════════════════════════════════════
  // DESKTOP CHARACTER
  // ═══════════════════════════════════════════════

  Widget _buildDesktopCharacter(String character, int index) {
    final progress = _characterProgress(index);

    final offset = Offset.lerp(
      _characterOffsets[index],
      Offset.zero,
      progress,
    )!;

    final rotation = Tween<double>(
      begin: _characterRotations[index],
      end: 0,
    ).transform(progress);

    final scale = Tween<double>(
      begin: _characterScales[index],
      end: 1,
    ).transform(progress);

    final opacity = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));

    final floating =
        math.sin((_controller.value * math.pi * 2) + index * 0.32) *
        1.5 *
        progress;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(offset.dx, offset.dy + floating),
        child: Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale,
            child: Text(
              character,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.3,
                color: Color(0xFFE8D7B0),
                decoration: TextDecoration.none,
                shadows: [
                  Shadow(blurRadius: 8, color: Color(0x99D6B56A)),
                  Shadow(blurRadius: 18, color: Color(0x55D6B56A)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // HEART
  // ═══════════════════════════════════════════════

  Widget _buildHeart({double lineWidth = 45, double iconSize = 18}) {
    final pulse = 1.0 + math.sin(_controller.value * math.pi * 2) * 0.08;

    final opacity = 0.55 + math.sin(_controller.value * math.pi * 2) * 0.15;

    return Transform.scale(
      scale: pulse,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLine(width: lineWidth),

            const SizedBox(width: 10),

            Icon(
              Icons.favorite_border,
              size: iconSize,
              color: const Color(0xFFE8C98B),
              shadows: const [Shadow(blurRadius: 10, color: Color(0x88E8C98B))],
            ),

            const SizedBox(width: 10),

            _buildLine(width: lineWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildLine({required double width}) {
    return Container(
      width: width,
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Color(0x99E8C98B)],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// PARTICLE MODEL
// ═══════════════════════════════════════════════

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;
  final double opacity;

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.opacity,
  });

  factory _Particle.random(math.Random random) {
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: 1 + random.nextDouble() * 2.5,
      speed: 0.15 + random.nextDouble() * 0.45,
      phase: random.nextDouble() * math.pi * 2,
      opacity: 0.15 + random.nextDouble() * 0.5,
    );
  }
}

// ═══════════════════════════════════════════════
// BACKGROUND PAINTER
// ═══════════════════════════════════════════════

class _SecretBackgroundPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _SecretBackgroundPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    // ═══════════════════════════════════════════
    // Dark cinematic background
    // ═══════════════════════════════════════════

    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF05070F),
          Color(0xFF101326),
          Color(0xFF090A14),
          Color(0xFF03040A),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Offset.zero & size, backgroundPaint);

    // ═══════════════════════════════════════════
    // Moving soft glow
    // ═══════════════════════════════════════════

    final glowX = size.width * (0.5 + math.sin(progress * math.pi * 2) * 0.12);

    final glowY =
        size.height * (0.48 + math.cos(progress * math.pi * 2) * 0.08);

    final glowPaint = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0x334C3A70), Color(0x142A315F), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(glowX, glowY),
              radius: size.width * 0.55,
            ),
          );

    canvas.drawCircle(Offset(glowX, glowY), size.width * 0.55, glowPaint);

    // ═══════════════════════════════════════════
    // Floating particles
    // ═══════════════════════════════════════════

    for (final particle in particles) {
      final movement =
          (progress * particle.speed + particle.phase / (math.pi * 2)) % 1.0;

      final x =
          particle.x * size.width +
          math.sin(progress * math.pi * 2 + particle.phase) * 8;

      final y = ((particle.y + movement) % 1.0) * size.height;

      final pulse =
          0.55 + math.sin(progress * math.pi * 2 + particle.phase) * 0.45;

      final paint = Paint()
        ..color = const Color(0xFFE8C98B).withOpacity(particle.opacity * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 2);

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }

    // ═══════════════════════════════════════════
    // Subtle bottom light
    // ═══════════════════════════════════════════

    final bottomGlow = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0x225F4B6E), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.5, size.height * 0.95),
              radius: size.width * 0.55,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.95),
      size.width * 0.55,
      bottomGlow,
    );

    // ═══════════════════════════════════════════
    // Thin cinematic light line
    // ═══════════════════════════════════════════

    final wavePaint = Paint()
      ..color = const Color(0x226E638A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();

    for (double x = 0; x <= size.width; x += 4) {
      final normalized = x / size.width;

      final y =
          size.height * 0.78 +
          math.sin(normalized * math.pi * 2.2 + progress * math.pi * 2) * 12;

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _SecretBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
