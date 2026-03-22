import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../di/injection.dart';
import '../services/locale_service.dart';
import '../../data/models/game_model.dart';

/// Full-screen tutorial overlay with LED-style step indicators.
/// Hard-mode games get a blur overlay with a clear highlight zone.
///
/// Usage:
/// ```dart
/// GameTutorialOverlay.showIfNeeded(
///   context: context,
///   gameType: CoupleGameType.sumoBall,
///   onComplete: () { /* start game */ },
/// );
/// ```
class GameTutorialOverlay extends StatefulWidget {
  const GameTutorialOverlay({
    super.key,
    required this.gameType,
    required this.onComplete,
  });

  final CoupleGameType gameType;
  final VoidCallback onComplete;

  /// Shows tutorial if not seen before; otherwise calls [onComplete] directly.
  static Future<void> showIfNeeded({
    required BuildContext context,
    required CoupleGameType gameType,
    required VoidCallback onComplete,
  }) async {
    final prefs = getIt<SharedPreferences>();
    final key = '${AppConstants.prefTutorialSeenPrefix}${gameType.name}';
    final seen = prefs.getBool(key) ?? false;

    if (seen) {
      onComplete();
      return;
    }

    if (!context.mounted) return;

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      pageBuilder: (ctx, a1, a2) => GameTutorialOverlay(
        gameType: gameType,
        onComplete: () {
          prefs.setBool(key, true);
          Navigator.of(ctx).pop();
          onComplete();
        },
      ),
    );
  }

  @override
  State<GameTutorialOverlay> createState() => _GameTutorialOverlayState();
}

class _GameTutorialOverlayState extends State<GameTutorialOverlay>
    with SingleTickerProviderStateMixin {
  late final List<TutorialStep> _steps;
  late final bool _isHard;
  int _current = 0;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _steps = widget.gameType.tutorialSteps;
    _isHard = widget.gameType.difficulty == GameDifficulty.hard;

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _steps.length - 1) {
      _fadeCtrl.forward(from: 0);
      setState(() => _current++);
    } else {
      widget.onComplete();
    }
  }

  void _skip() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final step = _steps[_current];
    final isLast = _current == _steps.length - 1;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blur background — stronger for hard games
          Positioned.fill(
            child: _isHard && step.highlightZone != null
                ? _buildBlurWithHighlight(size, step.highlightZone!)
                : BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _isHard ? 12 : 6,
                      sigmaY: _isHard ? 12 : 6,
                    ),
                    child: Container(
                      color:
                          Colors.black.withValues(alpha: _isHard ? 0.75 : 0.6),
                    ),
                  ),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 16),
                      child: TextButton(
                        onPressed: _skip,
                        child: Text(
                          l.tr('Skip', 'Atla'),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Step icon
                  Text(step.icon, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 20),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      step.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      step.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // LED step indicators
                  _buildLedIndicators(),

                  const SizedBox(height: 32),

                  // Next / Start button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isHard
                              ? Colors.redAccent.withValues(alpha: 0.3)
                              : Colors.cyanAccent.withValues(alpha: 0.2),
                          foregroundColor:
                              _isHard ? Colors.redAccent : Colors.cyanAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: (_isHard
                                      ? Colors.redAccent
                                      : Colors.cyanAccent)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isLast
                              ? l.tr('Start Game', 'Oyunu Başlat')
                              : l.tr('Next', 'İleri'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Difficulty badge
                  _buildDifficultyBadge(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// LED-style dot indicators
  Widget _buildLedIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (i) {
        final isActive = i == _current;
        final isPast = i < _current;
        final color = isActive
            ? (_isHard ? Colors.redAccent : Colors.cyanAccent)
            : isPast
                ? Colors.greenAccent
                : Colors.white.withValues(alpha: 0.2);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 28 : 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  /// Blur with a clear highlight hole for hard games
  Widget _buildBlurWithHighlight(Size size, HighlightZone zone) {
    final Rect clearRect;
    switch (zone) {
      case HighlightZone.top:
        clearRect = Rect.fromLTWH(
          size.width * 0.1,
          size.height * 0.08,
          size.width * 0.8,
          size.height * 0.25,
        );
      case HighlightZone.center:
        clearRect = Rect.fromLTWH(
          size.width * 0.1,
          size.height * 0.3,
          size.width * 0.8,
          size.height * 0.35,
        );
      case HighlightZone.bottom:
        clearRect = Rect.fromLTWH(
          size.width * 0.1,
          size.height * 0.6,
          size.width * 0.8,
          size.height * 0.3,
        );
    }

    return CustomPaint(
      painter: _HighlightCutoutPainter(clearRect: clearRect),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    final diff = widget.gameType.difficulty;
    final Color color;
    final String label;
    switch (diff) {
      case GameDifficulty.easy:
        color = Colors.greenAccent;
        label = l.tr('Easy', 'Kolay');
      case GameDifficulty.medium:
        color = Colors.orangeAccent;
        label = l.tr('Medium', 'Orta');
      case GameDifficulty.hard:
        color = Colors.redAccent;
        label = l.tr('Hard', 'Zor');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter that creates a dark overlay with a clear rounded-rect cutout
class _HighlightCutoutPainter extends CustomPainter {
  _HighlightCutoutPainter({required this.clearRect});

  final Rect clearRect;

  @override
  void paint(Canvas canvas, Size size) {
    final fullPath = Path()..addRect(Offset.zero & size);
    final holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(clearRect, const Radius.circular(20)));

    final combined = Path.combine(PathOperation.difference, fullPath, holePath);
    canvas.drawPath(
      combined,
      Paint()..color = Colors.black.withValues(alpha: 0.75),
    );

    // Glow border around the cutout
    final borderPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(clearRect, const Radius.circular(20)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HighlightCutoutPainter old) =>
      old.clearRect != clearRect;
}
