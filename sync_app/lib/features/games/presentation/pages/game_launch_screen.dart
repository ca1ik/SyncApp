import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../../core/services/game_audio_service.dart';
import '../../../../core/services/locale_service.dart';
import '../../../../data/models/game_model.dart';

/// Epic cinematic game launch screen with particle effects,
/// countdown timer, and game-specific theme colors.
class GameLaunchScreen extends StatefulWidget {
  const GameLaunchScreen({
    super.key,
    required this.gameType,
    required this.child,
  });
  final CoupleGameType gameType;
  final Widget child;

  @override
  State<GameLaunchScreen> createState() => _GameLaunchScreenState();
}

class _GameLaunchScreenState extends State<GameLaunchScreen>
    with TickerProviderStateMixin {
  bool _launched = false;
  int _countdown = 3;
  Timer? _timer;
  late AnimationController _pulseCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _ringCtrl;
  late AnimationController _bgCtrl;
  final _rng = Random();
  late List<_Particle> _particles;
  late List<_RingWave> _rings;

  // Game-specific theme
  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _accentColor;
  late String _bgEmoji;
  late GameMusicTheme _musicTheme;

  @override
  void initState() {
    super.initState();
    _setupTheme();
    _particles = List.generate(60, (_) => _Particle.random(_rng));
    _rings = [];

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _startCountdown();
  }

  void _setupTheme() {
    switch (widget.gameType) {
      case CoupleGameType.sumoBall:
        _primaryColor = const Color(0xFF1A237E);
        _secondaryColor = const Color(0xFF0D47A1);
        _accentColor = Colors.cyanAccent;
        _bgEmoji = '🔴';
        _musicTheme = GameMusicTheme.epicBattle;
      case CoupleGameType.miniPool:
        _primaryColor = const Color(0xFF1B5E20);
        _secondaryColor = const Color(0xFF2E7D32);
        _accentColor = Colors.yellowAccent;
        _bgEmoji = '🎱';
        _musicTheme = GameMusicTheme.funPlayful;
      case CoupleGameType.carRace:
        _primaryColor = const Color(0xFF212121);
        _secondaryColor = const Color(0xFF424242);
        _accentColor = Colors.redAccent;
        _bgEmoji = '🏎️';
        _musicTheme = GameMusicTheme.speedRush;
      case CoupleGameType.laserDodge:
        _primaryColor = const Color(0xFF0D0D2B);
        _secondaryColor = const Color(0xFF1A1A3E);
        _accentColor = Colors.greenAccent;
        _bgEmoji = '⚡';
        _musicTheme = GameMusicTheme.tension;
      case CoupleGameType.icePlatform:
        _primaryColor = const Color(0xFF0A1628);
        _secondaryColor = const Color(0xFF1A2D46);
        _accentColor = Colors.lightBlueAccent;
        _bgEmoji = '🧊';
        _musicTheme = GameMusicTheme.mysteryDeep;
      case CoupleGameType.colorMatch:
        _primaryColor = const Color(0xFF1A1A2E);
        _secondaryColor = const Color(0xFF2A1A3E);
        _accentColor = Colors.purpleAccent;
        _bgEmoji = '🎨';
        _musicTheme = GameMusicTheme.funPlayful;
      case CoupleGameType.meteorShower:
        _primaryColor = const Color(0xFF0D0D1A);
        _secondaryColor = const Color(0xFF1A0D2E);
        _accentColor = Colors.orangeAccent;
        _bgEmoji = '☄️';
        _musicTheme = GameMusicTheme.space;
      case CoupleGameType.balloonPop:
        _primaryColor = const Color(0xFF2196F3);
        _secondaryColor = const Color(0xFF87CEEB);
        _accentColor = Colors.pinkAccent;
        _bgEmoji = '🎈';
        _musicTheme = GameMusicTheme.funPlayful;
      case CoupleGameType.treasureDive:
        _primaryColor = const Color(0xFF0A3D62);
        _secondaryColor = const Color(0xFF0E4D7A);
        _accentColor = Colors.amberAccent;
        _bgEmoji = '💎';
        _musicTheme = GameMusicTheme.mysteryDeep;
      case CoupleGameType.bombPass:
        _primaryColor = const Color(0xFF1A1A2E);
        _secondaryColor = const Color(0xFF3E1A1A);
        _accentColor = Colors.orange;
        _bgEmoji = '💥';
        _musicTheme = GameMusicTheme.tension;
      case CoupleGameType.towerStack:
        _primaryColor = const Color(0xFF1A1A2E);
        _secondaryColor = const Color(0xFF2E2A1A);
        _accentColor = Colors.tealAccent;
        _bgEmoji = '🏗️';
        _musicTheme = GameMusicTheme.funPlayful;
      case CoupleGameType.fruitCatch:
        _primaryColor = const Color(0xFF2D5016);
        _secondaryColor = const Color(0xFF3D6826);
        _accentColor = Colors.redAccent;
        _bgEmoji = '🍎';
        _musicTheme = GameMusicTheme.nature;
      case CoupleGameType.targetShot:
        _primaryColor = const Color(0xFF1B2838);
        _secondaryColor = const Color(0xFF2B3848);
        _accentColor = Colors.redAccent;
        _bgEmoji = '🎯';
        _musicTheme = GameMusicTheme.tension;
      case CoupleGameType.lavaFloor:
        _primaryColor = const Color(0xFF1A0A00);
        _secondaryColor = const Color(0xFF3A1A00);
        _accentColor = Colors.deepOrangeAccent;
        _bgEmoji = '🌋';
        _musicTheme = GameMusicTheme.horror;
      case CoupleGameType.paintWar:
        _primaryColor = const Color(0xFF2D2D2D);
        _secondaryColor = const Color(0xFF3D3D3D);
        _accentColor = Colors.purpleAccent;
        _bgEmoji = '🖌️';
        _musicTheme = GameMusicTheme.funPlayful;
      case CoupleGameType.snakeArena:
        _primaryColor = const Color(0xFF0A0A1A);
        _secondaryColor = const Color(0xFF1A1A2A);
        _accentColor = Colors.greenAccent;
        _bgEmoji = '🐍';
        _musicTheme = GameMusicTheme.tension;
      case CoupleGameType.asteroidBreaker:
        _primaryColor = const Color(0xFF0A0A1A);
        _secondaryColor = const Color(0xFF1A1A2A);
        _accentColor = Colors.grey;
        _bgEmoji = '🪨';
        _musicTheme = GameMusicTheme.space;
      case CoupleGameType.rhythmTap:
        _primaryColor = const Color(0xFF1A0A2E);
        _secondaryColor = const Color(0xFF2A1A3E);
        _accentColor = Colors.pinkAccent;
        _bgEmoji = '🎵';
        _musicTheme = GameMusicTheme.rhythm;
      case CoupleGameType.mazeRunner:
        _primaryColor = const Color(0xFF1A1A2E);
        _secondaryColor = const Color(0xFF2A2A3E);
        _accentColor = Colors.greenAccent;
        _bgEmoji = '🏃';
        _musicTheme = GameMusicTheme.tension;
      case CoupleGameType.shieldBlock:
        _primaryColor = const Color(0xFF0D1B2A);
        _secondaryColor = const Color(0xFF1D2B3A);
        _accentColor = Colors.cyanAccent;
        _bgEmoji = '🛡️';
        _musicTheme = GameMusicTheme.epicBattle;
      default:
        _primaryColor = const Color(0xFF1A1A2E);
        _secondaryColor = const Color(0xFF2A2A3E);
        _accentColor = Colors.white;
        _bgEmoji = '🎮';
        _musicTheme = GameMusicTheme.funPlayful;
    }
  }

  void _startCountdown() {
    // Start music on launch
    GameAudioService.instance.startBgMusic(_musicTheme);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      GameAudioService.instance.playSfx(GameSfx.countdown);
      _rings.add(_RingWave(born: DateTime.now()));
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          t.cancel();
          Future.delayed(300.ms, () {
            if (mounted) setState(() => _launched = true);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    _particleCtrl.dispose();
    _ringCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_launched) return widget.child;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([_particleCtrl, _bgCtrl, _pulseCtrl]),
        builder: (context, _) {
          return Stack(
            children: [
              // ── Animated gradient background ──
              Positioned.fill(
                child: CustomPaint(
                  painter: _LaunchBgPainter(
                    primary: _primaryColor,
                    secondary: _secondaryColor,
                    accent: _accentColor,
                    phase: _bgCtrl.value,
                    particles: _particles,
                    particlePhase: _particleCtrl.value,
                    rings: _rings,
                  ),
                ),
              ),

              // ── Center content ──
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Game emoji — large with glow
                    Transform.scale(
                      scale: 1.0 + _pulseCtrl.value * 0.15,
                      child: Text(
                        _bgEmoji,
                        style: const TextStyle(fontSize: 100),
                      ),
                    ),
                    const Gap(24),

                    // Game title
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [_accentColor, Colors.white, _accentColor],
                        stops: [0, _bgCtrl.value, 1],
                      ).createShader(bounds),
                      child: Text(
                        widget.gameType.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.3, curve: Curves.easeOut),

                    const Gap(8),

                    // Description
                    Text(
                      widget.gameType.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

                    const Gap(48),

                    // Countdown number
                    if (_countdown > 0) ...[
                      TweenAnimationBuilder<double>(
                        key: ValueKey(_countdown),
                        tween: Tween(begin: 2.0, end: 1.0),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                        builder: (context, scale, _) {
                          return Transform.scale(
                            scale: scale,
                            child: ShaderMask(
                              shaderCallback: (bounds) => RadialGradient(
                                colors: [
                                  _accentColor,
                                  _accentColor.withValues(alpha: 0.5),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                '$_countdown',
                                style: const TextStyle(
                                  fontSize: 120,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            _accentColor,
                            Colors.white,
                            _accentColor,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          l.tr('GO!', 'BASLA!'),
                          style: const TextStyle(
                            fontSize: 100,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 8,
                          ),
                        ),
                      )
                          .animate()
                          .scale(
                              begin: const Offset(0.3, 0.3),
                              end: const Offset(1, 1),
                              duration: 300.ms,
                              curve: Curves.elasticOut)
                          .then()
                          .shimmer(duration: 300.ms),
                    ],

                    const Gap(32),

                    // Player indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _PlayerBadge(
                          label: l.tr('Player 1', 'Oyuncu 1'),
                          emoji: '👩',
                          color: Colors.pinkAccent,
                        ),
                        const Gap(32),
                        Text('VS',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: _accentColor.withValues(alpha: 0.8),
                            )),
                        const Gap(32),
                        _PlayerBadge(
                          label: l.tr('Player 2', 'Oyuncu 2'),
                          emoji: '👨',
                          color: Colors.blueAccent,
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                    const Gap(24),

                    // Mode badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _accentColor.withValues(alpha: 0.3),
                        ),
                        color: _accentColor.withValues(alpha: 0.1),
                      ),
                      child: Text(
                        '⚔️ ${l.tr('ARENA MODE', 'ARENA MODU')}',
                        style: TextStyle(
                          color: _accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                  ],
                ),
              ),

              // ── Top corners — decorative lines ──
              Positioned(
                top: 60,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CornerDecor(color: _accentColor, flip: false),
                    _CornerDecor(color: _accentColor, flip: true),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlayerBadge extends StatelessWidget {
  const _PlayerBadge({
    required this.label,
    required this.emoji,
    required this.color,
  });
  final String label, emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child:
              Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
        ),
        const Gap(6),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _CornerDecor extends StatelessWidget {
  const _CornerDecor({required this.color, required this.flip});
  final Color color;
  final bool flip;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..scale(flip ? -1.0 : 1.0, 1.0),
      alignment: Alignment.center,
      child: SizedBox(
        width: 40,
        height: 40,
        child: CustomPaint(
          painter: _CornerPainter(color: color),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) => false;
}

// ═══════════════════════════════════════
//  PARTICLE & RING MODELS
// ═══════════════════════════════════════
class _Particle {
  double x, y, speed, size, angle;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.angle,
    required this.opacity,
  });

  factory _Particle.random(Random rng) => _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        speed: 0.001 + rng.nextDouble() * 0.003,
        size: 1 + rng.nextDouble() * 3,
        angle: rng.nextDouble() * 2 * pi,
        opacity: 0.1 + rng.nextDouble() * 0.4,
      );
}

class _RingWave {
  final DateTime born;
  _RingWave({required this.born});
  double get age => DateTime.now().difference(born).inMilliseconds / 1200.0;
}

// ═══════════════════════════════════════
//  LAUNCH BG PAINTER — cinematic particles + rings
// ═══════════════════════════════════════
class _LaunchBgPainter extends CustomPainter {
  _LaunchBgPainter({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.phase,
    required this.particles,
    required this.particlePhase,
    required this.rings,
  });
  final Color primary, secondary, accent;
  final double phase, particlePhase;
  final List<_Particle> particles;
  final List<_RingWave> rings;

  @override
  void paint(Canvas canvas, Size size) {
    // ── Multi-layer gradient background ──
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Base gradient — rotating angle
    final angle = phase * 2 * pi;
    canvas.drawRect(
      bgRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(cos(angle), sin(angle)),
          end: Alignment(-cos(angle), -sin(angle)),
          colors: [primary, secondary, primary.withValues(alpha: 0.8)],
        ).createShader(bgRect),
    );

    // Radial overlay glow from center
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.4),
      size.width * 0.6,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: 0.08 + phase * 0.04),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(size.width / 2, size.height * 0.4),
          radius: size.width * 0.6,
        )),
    );

    // ── Grid effect ──
    final gridPaint = Paint()
      ..color = accent.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ── Floating particles ──
    for (final p in particles) {
      final px = ((p.x + cos(p.angle + particlePhase * 2 * pi) * 0.02) % 1.0) *
          size.width;
      final py = ((p.y +
                  sin(p.angle + particlePhase * 2 * pi) * 0.02 -
                  particlePhase * p.speed * 10) %
              1.0) *
          size.height;
      canvas.drawCircle(
        Offset(px, py),
        p.size,
        Paint()..color = accent.withValues(alpha: p.opacity),
      );
      // Glow
      canvas.drawCircle(
        Offset(px, py),
        p.size * 3,
        Paint()
          ..color = accent.withValues(alpha: p.opacity * 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // ── Expanding ring waves ──
    rings.removeWhere((r) => r.age > 1.0);
    for (final ring in rings) {
      final a = ring.age.clamp(0.0, 1.0);
      final r = a * size.width * 0.5;
      canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.45),
        r,
        Paint()
          ..color = accent.withValues(alpha: (1 - a) * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * (1 - a),
      );
    }

    // ── Scanline effect ──
    final scanY = (particlePhase * size.height * 2) % size.height;
    canvas.drawRect(
      Rect.fromLTWH(0, scanY - 1, size.width, 2),
      Paint()..color = accent.withValues(alpha: 0.06),
    );
  }

  @override
  bool shouldRepaint(covariant _LaunchBgPainter old) => true;
}
