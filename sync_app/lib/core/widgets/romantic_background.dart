import 'dart:math';
import 'package:flutter/material.dart';

/// Romantic background with low-opacity couple silhouette and floating hearts.
class RomanticBackground extends StatefulWidget {
  const RomanticBackground({super.key, this.child});
  final Widget? child;

  @override
  State<RomanticBackground> createState() => _RomanticBackgroundState();
}

class _RomanticBackgroundState extends State<RomanticBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Couple silhouette — very faint
        Positioned.fill(
          child: CustomPaint(
            painter: _CoupleSilhouettePainter(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
            ),
          ),
        ),
        // Floating hearts
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) => CustomPaint(
              painter: _FloatingHeartsPainter(
                progress: _ctrl.value,
                baseColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _CoupleSilhouettePainter extends CustomPainter {
  _CoupleSilhouettePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final cx = size.width * 0.5;
    final cy = size.height * 0.55;

    // Left person (slightly shorter)
    _drawPerson(
        canvas, paint, cx - size.width * 0.08, cy, size.height * 0.13, 0.9);
    // Right person
    _drawPerson(
        canvas, paint, cx + size.width * 0.08, cy, size.height * 0.13, 1.0);

    // Heart between them
    _drawHeart(canvas, paint, cx, cy - size.height * 0.1, size.width * 0.04);
  }

  void _drawPerson(Canvas canvas, Paint paint, double cx, double cy, double h,
      double scale) {
    // Head
    canvas.drawCircle(
        Offset(cx, cy - h * 0.85 * scale), h * 0.18 * scale, paint);
    // Body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx, cy - h * 0.35 * scale),
          width: h * 0.4 * scale,
          height: h * 0.6 * scale),
      Radius.circular(h * 0.12 * scale),
    );
    canvas.drawRRect(bodyRect, paint);
  }

  void _drawHeart(
      Canvas canvas, Paint paint, double cx, double cy, double size) {
    final path = Path();
    path.moveTo(cx, cy + size * 0.5);
    path.cubicTo(cx - size, cy - size * 0.2, cx - size * 0.5, cy - size, cx,
        cy - size * 0.4);
    path.cubicTo(cx + size * 0.5, cy - size, cx + size, cy - size * 0.2, cx,
        cy + size * 0.5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CoupleSilhouettePainter old) =>
      old.color != color;
}

class _FloatingHeartsPainter extends CustomPainter {
  _FloatingHeartsPainter({required this.progress, required this.baseColor});
  final double progress;
  final Color baseColor;

  static const int _heartCount = 12;
  static final List<_HeartParticle> _particles = List.generate(
    _heartCount,
    (i) {
      final rng = Random(i * 42);
      return _HeartParticle(
        startX: rng.nextDouble(),
        speed: 0.3 + rng.nextDouble() * 0.7,
        size: 6.0 + rng.nextDouble() * 10.0,
        phase: rng.nextDouble(),
        wobble: 8.0 + rng.nextDouble() * 20.0,
      );
    },
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = (progress * p.speed + p.phase) % 1.0;
      final y = size.height * (1.0 - t);
      final x =
          size.width * p.startX + sin(t * 2 * pi + p.phase * 6) * p.wobble;
      final alpha = (sin(t * pi) * 0.12).clamp(0.0, 0.12);
      final paint = Paint()..color = baseColor.withValues(alpha: alpha);
      _drawHeart(canvas, paint, x, y, p.size);
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
  bool shouldRepaint(covariant _FloatingHeartsPainter old) => true;
}

class _HeartParticle {
  const _HeartParticle({
    required this.startX,
    required this.speed,
    required this.size,
    required this.phase,
    required this.wobble,
  });
  final double startX, speed, size, phase, wobble;
}
