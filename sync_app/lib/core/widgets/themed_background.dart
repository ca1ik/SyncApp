import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../di/injection.dart';
import '../../data/models/relationship_mode_model.dart';

/// Adaptive background widget that renders different particle systems
/// based on the user's selected RelationshipMode:
///   - couple  → slow-motion floating hearts
///   - friend  → galaxy with drifting star particles
///   - solo    → floating bubbles with hybrid colour blend
class ThemedBackground extends StatefulWidget {
  const ThemedBackground({super.key, this.child, this.modeOverride});
  final Widget? child;
  final RelationshipMode? modeOverride;

  @override
  State<ThemedBackground> createState() => _ThemedBackgroundState();
}

class _ThemedBackgroundState extends State<ThemedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  RelationshipMode _mode = RelationshipMode.couple;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _loadMode();
  }

  void _loadMode() {
    if (widget.modeOverride != null) {
      _mode = widget.modeOverride!;
      return;
    }
    final prefs = getIt<SharedPreferences>();
    final raw = prefs.getString(AppConstants.prefRelationshipModeKey);
    if (raw != null) {
      try {
        _mode = RelationshipMode.values.firstWhere((e) => e.name == raw);
      } catch (_) {}
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.modeOverride ?? _mode;
    final primary = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        // Mode-specific particle layer
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) => CustomPaint(
              painter: switch (mode) {
                RelationshipMode.couple => _HeartParticlePainter(
                    progress: _ctrl.value,
                    baseColor: primary,
                  ),
                RelationshipMode.friend => _GalaxyStarPainter(
                    progress: _ctrl.value,
                  ),
                RelationshipMode.solo => _BubbleParticlePainter(
                    progress: _ctrl.value,
                    baseColor: primary,
                  ),
              },
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// COUPLE MODE: Slow-motion floating hearts
// ═══════════════════════════════════════════════════════════════════

class _HeartParticlePainter extends CustomPainter {
  _HeartParticlePainter({required this.progress, required this.baseColor});
  final double progress;
  final Color baseColor;

  static const int _count = 15;
  static final List<_HeartData> _hearts = List.generate(_count, (i) {
    final rng = Random(i * 37);
    return _HeartData(
      startX: rng.nextDouble(),
      speed: 0.15 + rng.nextDouble() * 0.35, // slow motion
      size: 8.0 + rng.nextDouble() * 14.0,
      phase: rng.nextDouble(),
      wobble: 12.0 + rng.nextDouble() * 25.0,
      rotation: rng.nextDouble() * 2 * pi,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final h in _hearts) {
      final t = (progress * h.speed + h.phase) % 1.0;
      final y = size.height * (1.0 - t);
      final x =
          size.width * h.startX + sin(t * 2 * pi + h.phase * 6) * h.wobble;
      final alpha = (sin(t * pi) * 0.10).clamp(0.0, 0.10);
      final paint = Paint()..color = baseColor.withValues(alpha: alpha);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(sin(progress * 2 * pi + h.rotation) * 0.15);
      _drawHeart(canvas, paint, 0, 0, h.size);
      canvas.restore();
    }
  }

  void _drawHeart(Canvas canvas, Paint paint, double cx, double cy, double s) {
    final path = Path();
    path.moveTo(cx, cy + s * 0.35);
    path.cubicTo(cx - s * 0.7, cy - s * 0.15, cx - s * 0.35, cy - s * 0.7, cx,
        cy - s * 0.25);
    path.cubicTo(cx + s * 0.35, cy - s * 0.7, cx + s * 0.7, cy - s * 0.15, cx,
        cy + s * 0.35);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartParticlePainter old) => true;
}

class _HeartData {
  const _HeartData({
    required this.startX,
    required this.speed,
    required this.size,
    required this.phase,
    required this.wobble,
    required this.rotation,
  });
  final double startX, speed, size, phase, wobble, rotation;
}

// ═══════════════════════════════════════════════════════════════════
// FRIEND MODE: Galaxy with drifting star particles
// ═══════════════════════════════════════════════════════════════════

class _GalaxyStarPainter extends CustomPainter {
  _GalaxyStarPainter({required this.progress});
  final double progress;

  static const int _starCount = 50;
  static final List<_StarData> _stars = List.generate(_starCount, (i) {
    final rng = Random(i * 53);
    return _StarData(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      size: 1.0 + rng.nextDouble() * 3.0,
      twinkleSpeed: 0.5 + rng.nextDouble() * 2.0,
      phase: rng.nextDouble() * 2 * pi,
      driftX: (rng.nextDouble() - 0.5) * 0.02,
      driftY: (rng.nextDouble() - 0.5) * 0.01,
      color: _starColors[rng.nextInt(_starColors.length)],
    );
  });

  static const List<Color> _starColors = [
    Color(0xFF00D2FF), // cyan
    Color(0xFFE0E7FF), // white-blue
    Color(0xFFFFD700), // gold
    Color(0xFF7DF9FF), // electric blue
    Color(0xFFB388FF), // lavender
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Galaxy nebula glow
    final nebulaCenter = Offset(size.width * 0.5, size.height * 0.4);
    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1A237E).withValues(alpha: 0.08),
          const Color(0xFF7C4DFF).withValues(alpha: 0.03),
          Colors.transparent,
        ],
      ).createShader(
          Rect.fromCircle(center: nebulaCenter, radius: size.width * 0.5));
    canvas.drawCircle(nebulaCenter, size.width * 0.5, nebulaPaint);

    // Stars
    for (final s in _stars) {
      final drift = progress * 10;
      final x = (s.x * size.width + s.driftX * drift * size.width) % size.width;
      final y =
          (s.y * size.height + s.driftY * drift * size.height) % size.height;
      final twinkle =
          (sin(progress * 2 * pi * s.twinkleSpeed + s.phase) + 1) / 2;
      final alpha = 0.2 + twinkle * 0.6;
      final starSize = s.size * (0.7 + twinkle * 0.3);

      final paint = Paint()..color = s.color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), starSize, paint);

      // Cross-flare for bright stars
      if (s.size > 2.5) {
        final flarePaint = Paint()
          ..color = s.color.withValues(alpha: alpha * 0.3)
          ..strokeWidth = 0.5;
        canvas.drawLine(
          Offset(x - starSize * 2, y),
          Offset(x + starSize * 2, y),
          flarePaint,
        );
        canvas.drawLine(
          Offset(x, y - starSize * 2),
          Offset(x, y + starSize * 2),
          flarePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GalaxyStarPainter old) => true;
}

class _StarData {
  const _StarData({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleSpeed,
    required this.phase,
    required this.driftX,
    required this.driftY,
    required this.color,
  });
  final double x, y, size, twinkleSpeed, phase, driftX, driftY;
  final Color color;
}

// ═══════════════════════════════════════════════════════════════════
// SOLO MODE: Floating bubbles — hybrid of couple+friend colours
// ═══════════════════════════════════════════════════════════════════

class _BubbleParticlePainter extends CustomPainter {
  _BubbleParticlePainter({required this.progress, required this.baseColor});
  final double progress;
  final Color baseColor;

  static const int _bubbleCount = 20;
  static final List<_BubbleData> _bubbles = List.generate(_bubbleCount, (i) {
    final rng = Random(i * 61);
    return _BubbleData(
      startX: rng.nextDouble(),
      speed: 0.2 + rng.nextDouble() * 0.5,
      radius: 6.0 + rng.nextDouble() * 20.0,
      phase: rng.nextDouble(),
      wobble: 15.0 + rng.nextDouble() * 30.0,
      colorBlend: rng.nextDouble(), // 0 = couple warm, 1 = friend cool
    );
  });

  static const _warmColor = Color(0xFFE88A6A);
  static const _coolColor = Color(0xFF00D2FF);

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in _bubbles) {
      final t = (progress * b.speed + b.phase) % 1.0;
      final y = size.height * (1.0 - t);
      final x =
          size.width * b.startX + sin(t * 2 * pi + b.phase * 4) * b.wobble;
      final alpha = (sin(t * pi) * 0.12).clamp(0.0, 0.12);

      final blendedColor = Color.lerp(_warmColor, _coolColor, b.colorBlend)!;

      // Bubble outline
      final outlinePaint = Paint()
        ..color = blendedColor.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(x, y), b.radius, outlinePaint);

      // Inner glow
      final fillPaint = Paint()
        ..color = blendedColor.withValues(alpha: alpha * 0.3);
      canvas.drawCircle(Offset(x, y), b.radius * 0.7, fillPaint);

      // Highlight spec
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.5);
      canvas.drawCircle(
        Offset(x - b.radius * 0.25, y - b.radius * 0.25),
        b.radius * 0.15,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubbleParticlePainter old) => true;
}

class _BubbleData {
  const _BubbleData({
    required this.startX,
    required this.speed,
    required this.radius,
    required this.phase,
    required this.wobble,
    required this.colorBlend,
  });
  final double startX, speed, radius, phase, wobble, colorBlend;
}
