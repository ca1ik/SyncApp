import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/game_audio_service.dart';
import '../../../../core/services/locale_service.dart';
import '../../../../data/models/game_model.dart';
import '../../../../data/repositories/games_repository.dart';
import 'game_launch_screen.dart';

class ArenaGamesExtraPage extends StatefulWidget {
  const ArenaGamesExtraPage({super.key, required this.gameType});
  final CoupleGameType gameType;

  @override
  State<ArenaGamesExtraPage> createState() => _ArenaGamesExtraPageState();
}

class _ArenaGamesExtraPageState extends State<ArenaGamesExtraPage> {
  bool _gameOver = false;
  int _p1Score = 0;
  int _p2Score = 0;

  Future<void> _endGame(int p1, int p2, {int bonus = 0}) async {
    setState(() {
      _gameOver = true;
      _p1Score = p1;
      _p2Score = p2;
    });
    HapticFeedback.heavyImpact();
    await getIt<GamesRepository>().saveScore(GameScore(
      gameType: widget.gameType,
      player1Score: p1,
      player2Score: p2,
      playedAt: DateTime.now(),
      bonusPoints: bonus,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) {
      GameAudioService.instance.fadeOutBgMusic();
      return _ExtraGameOver(p1: _p1Score, p2: _p2Score);
    }

    Widget game;
    switch (widget.gameType) {
      case CoupleGameType.colorMatch:
        game = _ColorMatchGame(onEnd: _endGame);
      case CoupleGameType.meteorShower:
        game = _MeteorShowerGame(onEnd: _endGame);
      case CoupleGameType.balloonPop:
        game = _BalloonPopGame(onEnd: _endGame);
      case CoupleGameType.treasureDive:
        game = _TreasureDiveGame(onEnd: _endGame);
      case CoupleGameType.bombPass:
        game = _BombPassGame(onEnd: _endGame);
      case CoupleGameType.towerStack:
        game = _TowerStackGame(onEnd: _endGame);
      case CoupleGameType.fruitCatch:
        game = _FruitCatchGame(onEnd: _endGame);
      case CoupleGameType.targetShot:
        game = _TargetShotGame(onEnd: _endGame);
      case CoupleGameType.lavaFloor:
        game = _LavaFloorGame(onEnd: _endGame);
      case CoupleGameType.paintWar:
        game = _PaintWarGame(onEnd: _endGame);
      case CoupleGameType.snakeArena:
        game = _SnakeArenaGame(onEnd: _endGame);
      case CoupleGameType.asteroidBreaker:
        game = _AsteroidBreakerGame(onEnd: _endGame);
      case CoupleGameType.rhythmTap:
        game = _RhythmTapGame(onEnd: _endGame);
      case CoupleGameType.mazeRunner:
        game = _MazeRunnerGame(onEnd: _endGame);
      case CoupleGameType.shieldBlock:
        game = _ShieldBlockGame(onEnd: _endGame);
      default:
        Navigator.of(context).pop();
        return const SizedBox.shrink();
    }
    return GameLaunchScreen(gameType: widget.gameType, child: game);
  }
}

// ═══════════════════════════════════════
//  GAME OVER (shared) — cinematic with confetti
// ═══════════════════════════════════════
class _ExtraGameOver extends StatefulWidget {
  const _ExtraGameOver({required this.p1, required this.p2});
  final int p1, p2;

  @override
  State<_ExtraGameOver> createState() => _ExtraGameOverState();
}

class _ExtraGameOverState extends State<_ExtraGameOver>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiCtrl;
  late List<_ExtraConfetti> _confetti;

  @override
  void initState() {
    super.initState();
    GameAudioService.instance
        .playSfx(widget.p1 != widget.p2 ? GameSfx.victory : GameSfx.score);
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    final rng = Random();
    _confetti = List.generate(
        40,
        (_) => _ExtraConfetti(
              x: rng.nextDouble(),
              y: -rng.nextDouble(),
              speed: 0.003 + rng.nextDouble() * 0.005,
              size: 4 + rng.nextDouble() * 8,
              color: [
                Colors.pinkAccent,
                Colors.blueAccent,
                Colors.amber,
                Colors.greenAccent,
                Colors.purpleAccent,
              ][rng.nextInt(5)],
              rot: rng.nextDouble() * 6.28,
              drift: (rng.nextDouble() - 0.5) * 0.002,
            ));
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winner = widget.p1 > widget.p2
        ? l.tr('👩 Player 1 Wins!', '👩 Oyuncu 1 Kazandi!')
        : widget.p2 > widget.p1
            ? l.tr('👨 Player 2 Wins!', '👨 Oyuncu 2 Kazandi!')
            : l.tr('🤝 Draw!', '🤝 Berabere!');
    final winColor = widget.p1 > widget.p2
        ? Colors.pinkAccent
        : widget.p2 > widget.p1
            ? Colors.blueAccent
            : Colors.amber;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _confettiCtrl,
        builder: (context, _) => Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      winColor.withValues(alpha: 0.15),
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _ExtraConfettiPainter(
                  confetti: _confetti,
                  phase: _confettiCtrl.value,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 100))
                          .animate()
                          .scale(duration: 800.ms, curve: Curves.elasticOut)
                          .then()
                          .shimmer(
                              duration: 1500.ms,
                              color: Colors.amber.withValues(alpha: 0.5)),
                      const Gap(24),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [winColor, Colors.white, winColor],
                        ).createShader(bounds),
                        child: Text(winner,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1)),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                      const Gap(32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ScorePill(
                              label: l.tr('👩 P1', '👩 O1'),
                              score: widget.p1,
                              color: Colors.pinkAccent),
                          const Gap(24),
                          _ScorePill(
                              label: l.tr('👨 P2', '👨 O2'),
                              score: widget.p2,
                              color: Colors.blueAccent),
                        ],
                      ).animate().fadeIn(delay: 500.ms),
                      const Gap(40),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(colors: [
                              winColor,
                              winColor.withValues(alpha: 0.7)
                            ]),
                            boxShadow: [
                              BoxShadow(
                                color: winColor.withValues(alpha: 0.4),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(l.tr('Back to Games', 'Oyunlara Don'),
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExtraConfetti {
  double x, y, speed, size, rot, drift;
  Color color;
  _ExtraConfetti({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
    required this.rot,
    required this.drift,
  });
}

class _ExtraConfettiPainter extends CustomPainter {
  _ExtraConfettiPainter({required this.confetti, required this.phase});
  final List<_ExtraConfetti> confetti;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in confetti) {
      final y = (c.y + phase * c.speed * 60) % 1.2;
      final x = c.x + sin(phase * 6.28 + c.rot) * 0.03 + c.drift * phase * 60;
      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(c.rot + phase * 2);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: c.size, height: c.size * 0.6),
        Paint()..color = c.color.withValues(alpha: 0.8),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ExtraConfettiPainter old) => true;
}

class _ScorePill extends StatelessWidget {
  const _ScorePill(
      {required this.label, required this.score, required this.color});
  final String label;
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: color)),
          Text('$score',
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}

typedef _EndCb = Future<void> Function(int p1, int p2, {int bonus});

// ═══════════════════════════════════════
//  1. COLOR MATCH 🎨
// ═══════════════════════════════════════
class _ColorMatchGame extends StatefulWidget {
  const _ColorMatchGame({required this.onEnd});
  final _EndCb onEnd;
  @override
  State<_ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends State<_ColorMatchGame> {
  final _rng = Random();
  static const _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange
  ];
  static const _names = ['Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Orange'];
  static const _namesTr = [
    'Kirmizi',
    'Mavi',
    'Yesil',
    'Sari',
    'Mor',
    'Turuncu'
  ];

  int _p1Score = 0, _p2Score = 0;
  int _round = 0;
  static const _maxRounds = 15;
  late int _targetIdx;
  late List<int> _options;
  bool _p1Turn = true;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  void _nextRound() {
    if (_round >= _maxRounds) {
      widget.onEnd(_p1Score * 5, _p2Score * 5, bonus: 10);
      return;
    }
    _targetIdx = _rng.nextInt(_colors.length);
    _options = List.generate(_colors.length, (i) => i)..shuffle(_rng);
    _options = _options.take(4).toList();
    if (!_options.contains(_targetIdx)) {
      _options[_rng.nextInt(4)] = _targetIdx;
    }
    _answered = false;
    _p1Turn = _round.isEven;
    setState(() {});
  }

  void _onTap(int idx) {
    if (_answered) return;
    _answered = true;
    HapticFeedback.lightImpact();
    GameAudioService.instance.playSfx(GameSfx.tap);
    if (idx == _targetIdx) {
      if (_p1Turn) {
        _p1Score++;
      } else {
        _p2Score++;
      }
    }
    _round++;
    Future.delayed(400.ms, _nextRound);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('${l.tr('Color Match', 'Renk Eslestirme')} 🎨  '
            '${_round + 1}/$_maxRounds'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _PlayerScoreRow(p1: _p1Score, p2: _p2Score, p1Turn: _p1Turn),
            const Gap(24),
            Text(
              l.tr('Find: ${_names[_targetIdx]}',
                  'Bul: ${_namesTr[_targetIdx]}'),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800),
            ).animate().fadeIn(duration: 200.ms),
            const Gap(8),
            Text(
              _p1Turn
                  ? l.tr('👩 Player 1 Turn', '👩 Oyuncu 1 Sirasi')
                  : l.tr('👨 Player 2 Turn', '👨 Oyuncu 2 Sirasi'),
              style: TextStyle(
                  color: _p1Turn ? Colors.pinkAccent : Colors.blueAccent,
                  fontSize: 16),
            ),
            const Spacer(),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: _options.map((idx) {
                return GestureDetector(
                  onTap: () => _onTap(idx),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _colors[idx],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _colors[idx].withValues(alpha: 0.5),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
//  2. METEOR SHOWER ☄️
// ═══════════════════════════════════════
class _MeteorShowerGame extends StatefulWidget {
  const _MeteorShowerGame({required this.onEnd});
  final _EndCb onEnd;
  @override
  State<_MeteorShowerGame> createState() => _MeteorShowerGameState();
}

class _MeteorShowerGameState extends State<_MeteorShowerGame> {
  final _rng = Random();
  double _p1X = 0.3, _p2X = 0.7;
  static const _playerY = 0.85;
  static const _playerR = 0.035;
  bool _p1Alive = true, _p2Alive = true;
  int _survived = 0;
  final List<_Meteor> _meteors = [];
  Timer? _tick, _spawn;
  int? _dragging;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _spawn = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (!mounted) return;
      setState(() {
        _meteors.add(_Meteor(
          x: _rng.nextDouble() * 0.9 + 0.05,
          y: -0.05,
          speed: 0.005 + _rng.nextDouble() * 0.003 + _survived * 0.0002,
          radius: 0.02 + _rng.nextDouble() * 0.015,
        ));
      });
    });
    _tick = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      setState(() {
        _survived++;
        for (final m in _meteors) {
          m.y += m.speed;
        }
        _meteors.removeWhere((m) => m.y > 1.1);

        for (final m in _meteors) {
          if (_p1Alive) {
            final d = sqrt((m.x - _p1X) * (m.x - _p1X) +
                (m.y - _playerY) * (m.y - _playerY));
            if (d < _playerR + m.radius) {
              _p1Alive = false;
              HapticFeedback.heavyImpact();
              GameAudioService.instance.playSfx(GameSfx.explosion);
            }
          }
          if (_p2Alive) {
            final d = sqrt((m.x - _p2X) * (m.x - _p2X) +
                (m.y - _playerY) * (m.y - _playerY));
            if (d < _playerR + m.radius) {
              _p2Alive = false;
              HapticFeedback.heavyImpact();
              GameAudioService.instance.playSfx(GameSfx.explosion);
            }
          }
        }

        if (!_p1Alive && !_p2Alive) {
          _tick?.cancel();
          _spawn?.cancel();
          widget.onEnd(_p1Alive ? _survived ~/ 60 * 5 : _survived ~/ 120,
              _p2Alive ? _survived ~/ 60 * 5 : _survived ~/ 120,
              bonus: _survived ~/ 60);
        }
      });
    });
  }

  void _onPanStart(DragStartDetails d, Size size) {
    final lx = d.localPosition.dx / size.width;
    final d1 = (lx - _p1X).abs();
    final d2 = (lx - _p2X).abs();
    if (d1 < 0.08 && _p1Alive)
      _dragging = 1;
    else if (d2 < 0.08 && _p2Alive) _dragging = 2;
  }

  void _onPanUpdate(DragUpdateDetails d, Size size) {
    if (_dragging == null) return;
    setState(() {
      final dx = d.delta.dx / size.width;
      if (_dragging == 1) _p1X = (_p1X + dx).clamp(0.05, 0.95);
      if (_dragging == 2) _p2X = (_p2X + dx).clamp(0.05, 0.95);
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _spawn?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: Text('${l.tr('Meteor Shower', 'Meteor Yagmuru')} ☄️'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final size = Size(c.maxWidth, c.maxHeight);
            return GestureDetector(
              onPanStart: (d) => _onPanStart(d, size),
              onPanUpdate: (d) => _onPanUpdate(d, size),
              onPanEnd: (_) => _dragging = null,
              child: CustomPaint(
                size: size,
                painter: _MeteorPainter(
                  p1X: _p1X,
                  p2X: _p2X,
                  playerY: _playerY,
                  playerR: _playerR,
                  p1Alive: _p1Alive,
                  p2Alive: _p2Alive,
                  meteors: _meteors,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Meteor {
  _Meteor(
      {required this.x,
      required this.y,
      required this.speed,
      required this.radius});
  double x, y;
  final double speed, radius;
}

class _MeteorPainter extends CustomPainter {
  _MeteorPainter({
    required this.p1X,
    required this.p2X,
    required this.playerY,
    required this.playerR,
    required this.p1Alive,
    required this.p2Alive,
    required this.meteors,
  });
  final double p1X, p2X, playerY, playerR;
  final bool p1Alive, p2Alive;
  final List<_Meteor> meteors;

  @override
  void paint(Canvas canvas, Size size) {
    // Stars background
    final rng = Random(7);
    for (int i = 0; i < 40; i++) {
      canvas.drawCircle(
          Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
          1,
          Paint()..color = Colors.white.withValues(alpha: 0.3));
    }

    // Meteors
    for (final m in meteors) {
      final mx = m.x * size.width;
      final my = m.y * size.height;
      final mr = m.radius * min(size.width, size.height);
      canvas.drawCircle(
          Offset(mx, my),
          mr + 6,
          Paint()
            ..color = Colors.orange.withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      canvas.drawCircle(Offset(mx, my), mr, Paint()..color = Colors.deepOrange);
      canvas.drawCircle(
          Offset(mx, my), mr * 0.4, Paint()..color = Colors.yellow);
      // Tail
      canvas.drawLine(
          Offset(mx, my - mr),
          Offset(mx + mr * 0.5, my - mr * 3),
          Paint()
            ..color = Colors.orange.withValues(alpha: 0.4)
            ..strokeWidth = 2);
    }

    // Players
    if (p1Alive) _drawP(canvas, size, p1X, Colors.pinkAccent);
    if (p2Alive) _drawP(canvas, size, p2X, Colors.blueAccent);
  }

  void _drawP(Canvas canvas, Size size, double x, Color c) {
    final px = x * size.width;
    final py = playerY * size.height;
    final pr = playerR * min(size.width, size.height);
    canvas.drawCircle(
        Offset(px, py),
        pr + 4,
        Paint()
          ..color = c.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawCircle(Offset(px, py), pr, Paint()..color = c);
  }

  @override
  bool shouldRepaint(covariant _MeteorPainter old) => true;
}

// ═══════════════════════════════════════
//  3. BALLOON POP 🎈
// ═══════════════════════════════════════
class _BalloonPopGame extends StatefulWidget {
  const _BalloonPopGame({required this.onEnd});
  final _EndCb onEnd;
  @override
  State<_BalloonPopGame> createState() => _BalloonPopGameState();
}

class _BalloonPopGameState extends State<_BalloonPopGame> {
  final _rng = Random();
  int _p1Score = 0, _p2Score = 0;
  int _timeLeft = 20; // seconds
  final List<_Balloon> _balloons = [];
  Timer? _tick, _spawn, _countdown;

  @override
  void initState() {
    super.initState();
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        _tick?.cancel();
        _spawn?.cancel();
        _countdown?.cancel();
        widget.onEnd(_p1Score * 5, _p2Score * 5, bonus: 10);
      }
    });
    _spawn = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(() {
        _balloons.add(_Balloon(
          x: _rng.nextDouble() * 0.8 + 0.1,
          y: 1.1,
          speed: 0.003 + _rng.nextDouble() * 0.003,
          color: [
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.purple,
            Colors.orange
          ][_rng.nextInt(6)],
          isLeft: _rng.nextBool(),
        ));
      });
    });
    _tick = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      setState(() {
        for (final b in _balloons) {
          b.y -= b.speed;
        }
        _balloons.removeWhere((b) => b.y < -0.1);
      });
    });
  }

  void _onTapDown(TapDownDetails d, Size size) {
    final tx = d.localPosition.dx / size.width;
    final ty = d.localPosition.dy / size.height;
    final isLeftSide = tx < 0.5;

    for (int i = _balloons.length - 1; i >= 0; i--) {
      final b = _balloons[i];
      final dx = tx - b.x;
      final dy = ty - b.y;
      if (sqrt(dx * dx + dy * dy) < 0.06) {
        HapticFeedback.lightImpact();
        GameAudioService.instance.playSfx(GameSfx.pop);
        if (isLeftSide) {
          _p1Score++;
        } else {
          _p2Score++;
        }
        _balloons.removeAt(i);
        setState(() {});
        return;
      }
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    _spawn?.cancel();
    _countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      appBar: AppBar(
        title:
            Text('${l.tr('Balloon Pop', 'Balon Patlatma')} 🎈  ⏱️$_timeLeft'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _PlayerScoreRow(p1: _p1Score, p2: _p2Score, p1Turn: true),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = Size(c.maxWidth, c.maxHeight);
                  return GestureDetector(
                    onTapDown: (d) => _onTapDown(d, size),
                    child: CustomPaint(
                      size: size,
                      painter: _BalloonPainter(balloons: _balloons),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                l.tr('👩 Tap left side  |  👨 Tap right side',
                    '👩 Sol tarafa dokun  |  👨 Sag tarafa dokun'),
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Balloon {
  _Balloon(
      {required this.x,
      required this.y,
      required this.speed,
      required this.color,
      required this.isLeft});
  double x, y;
  final double speed;
  final Color color;
  final bool isLeft;
}

class _BalloonPainter extends CustomPainter {
  _BalloonPainter({required this.balloons});
  final List<_Balloon> balloons;

  @override
  void paint(Canvas canvas, Size size) {
    // Center divider
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 1,
    );

    for (final b in balloons) {
      final bx = b.x * size.width;
      final by = b.y * size.height;
      // String
      canvas.drawLine(
          Offset(bx, by + 20),
          Offset(bx, by + 40),
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 1);
      // Balloon body
      final balloonPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [b.color.withValues(alpha: 0.9), b.color],
        ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: 20));
      canvas.drawOval(
        Rect.fromCenter(center: Offset(bx, by), width: 36, height: 44),
        balloonPaint,
      );
      // Highlight
      canvas.drawCircle(Offset(bx - 6, by - 8), 5,
          Paint()..color = Colors.white.withValues(alpha: 0.4));
    }
  }

  @override
  bool shouldRepaint(covariant _BalloonPainter old) => true;
}

// ═══════════════════════════════════════
//  4. TREASURE DIVE 💎
// ═══════════════════════════════════════
class _TreasureDiveGame extends StatefulWidget {
  const _TreasureDiveGame({required this.onEnd});
  final _EndCb onEnd;
  @override
  State<_TreasureDiveGame> createState() => _TreasureDiveGameState();
}

class _TreasureDiveGameState extends State<_TreasureDiveGame> {
  final _rng = Random();
  double _p1X = 0.3, _p1Y = 0.2;
  double _p2X = 0.7, _p2Y = 0.2;
  int _p1Gems = 0, _p2Gems = 0;
  int _timeLeft = 25;
  final List<_Gem> _gems = [];
  Timer? _tick, _spawn, _countdown;
  int? _dragging;
  static const _playerR = 0.04;

  @override
  void initState() {
    super.initState();
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        _tick?.cancel();
        _spawn?.cancel();
        _countdown?.cancel();
        widget.onEnd(_p1Gems * 8, _p2Gems * 8, bonus: 10);
      }
    });
    _spawn = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (!mounted) return;
      setState(() {
        final gems = ['💎', '💰', '⭐', '🪙'];
        _gems.add(_Gem(
          x: _rng.nextDouble() * 0.8 + 0.1,
          y: -0.05,
          emoji: gems[_rng.nextInt(gems.length)],
          value: _rng.nextInt(3) + 1,
        ));
      });
    });
    _tick = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      setState(() {
        for (final g in _gems) {
          g.y += 0.003;
        }
        _gems.removeWhere((g) => g.y > 1.1);

        // Collection check
        for (int i = _gems.length - 1; i >= 0; i--) {
          final g = _gems[i];
          final d1 =
              sqrt((g.x - _p1X) * (g.x - _p1X) + (g.y - _p1Y) * (g.y - _p1Y));
          final d2 =
              sqrt((g.x - _p2X) * (g.x - _p2X) + (g.y - _p2Y) * (g.y - _p2Y));
          if (d1 < _playerR + 0.03) {
            _p1Gems += g.value;
            _gems.removeAt(i);
            HapticFeedback.lightImpact();
            GameAudioService.instance.playSfx(GameSfx.score);
          } else if (d2 < _playerR + 0.03) {
            _p2Gems += g.value;
            _gems.removeAt(i);
            HapticFeedback.lightImpact();
            GameAudioService.instance.playSfx(GameSfx.score);
          }
        }
      });
    });
  }

  void _onPanStart(DragStartDetails d, Size size) {
    final lx = d.localPosition.dx / size.width;
    final ly = d.localPosition.dy / size.height;
    final d1 = sqrt((lx - _p1X) * (lx - _p1X) + (ly - _p1Y) * (ly - _p1Y));
    final d2 = sqrt((lx - _p2X) * (lx - _p2X) + (ly - _p2Y) * (ly - _p2Y));
    if (d1 < 0.08)
      _dragging = 1;
    else if (d2 < 0.08) _dragging = 2;
  }

  void _onPanUpdate(DragUpdateDetails d, Size size) {
    if (_dragging == null) return;
    setState(() {
      final dx = d.delta.dx / size.width;
      final dy = d.delta.dy / size.height;
      if (_dragging == 1) {
        _p1X = (_p1X + dx).clamp(0.05, 0.95);
        _p1Y = (_p1Y + dy).clamp(0.05, 0.95);
      } else {
        _p2X = (_p2X + dx).clamp(0.05, 0.95);
        _p2Y = (_p2Y + dy).clamp(0.05, 0.95);
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _spawn?.cancel();
    _countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A3D62),
      appBar: AppBar(
        title:
            Text('${l.tr('Treasure Dive', 'Hazine Dalisi')} 💎  ⏱️$_timeLeft'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _PlayerScoreRow(p1: _p1Gems, p2: _p2Gems, p1Turn: true),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = Size(c.maxWidth, c.maxHeight);
                  return GestureDetector(
                    onPanStart: (d) => _onPanStart(d, size),
                    onPanUpdate: (d) => _onPanUpdate(d, size),
                    onPanEnd: (_) => _dragging = null,
                    child: CustomPaint(
                      size: size,
                      painter: _TreasurePainter(
                        p1X: _p1X,
                        p1Y: _p1Y,
                        p2X: _p2X,
                        p2Y: _p2Y,
                        playerR: _playerR,
                        gems: _gems,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Gem {
  _Gem(
      {required this.x,
      required this.y,
      required this.emoji,
      required this.value});
  double x, y;
  final String emoji;
  final int value;
}

class _TreasurePainter extends CustomPainter {
  _TreasurePainter(
      {required this.p1X,
      required this.p1Y,
      required this.p2X,
      required this.p2Y,
      required this.playerR,
      required this.gems});
  final double p1X, p1Y, p2X, p2Y, playerR;
  final List<_Gem> gems;

  @override
  void paint(Canvas canvas, Size size) {
    // Water bubbles
    final rng = Random(42);
    for (int i = 0; i < 15; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        3 + rng.nextDouble() * 4,
        Paint()..color = Colors.white.withValues(alpha: 0.08),
      );
    }

    // Gems
    for (final g in gems) {
      final gx = g.x * size.width;
      final gy = g.y * size.height;
      canvas.drawCircle(
          Offset(gx, gy),
          14,
          Paint()
            ..color = Colors.amber.withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      final tp = TextPainter(
        text: TextSpan(text: g.emoji, style: const TextStyle(fontSize: 22)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(gx - tp.width / 2, gy - tp.height / 2));
    }

    // Players (divers)
    _drawDiver(canvas, size, p1X, p1Y, Colors.pinkAccent, '🤿');
    _drawDiver(canvas, size, p2X, p2Y, Colors.blueAccent, '🤿');
  }

  void _drawDiver(
      Canvas canvas, Size size, double x, double y, Color c, String emoji) {
    final px = x * size.width;
    final py = y * size.height;
    final pr = playerR * min(size.width, size.height);
    canvas.drawCircle(
        Offset(px, py),
        pr + 4,
        Paint()
          ..color = c.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawCircle(Offset(px, py), pr, Paint()..color = c);
    final tp = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 18)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(px - tp.width / 2, py - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _TreasurePainter old) => true;
}

// ═══════════════════════════════════════
//  5. BOMB PASS 💥
// ═══════════════════════════════════════
class _BombPassGame extends StatefulWidget {
  const _BombPassGame({required this.onEnd});
  final _EndCb onEnd;
  @override
  State<_BombPassGame> createState() => _BombPassGameState();
}

class _BombPassGameState extends State<_BombPassGame>
    with SingleTickerProviderStateMixin {
  final _rng = Random();
  bool _p1HasBomb = true;
  int _p1Score = 0, _p2Score = 0;
  int _round = 0;
  static const _maxRounds = 7;
  double _fuseProgress = 0;
  bool _exploded = false;
  late double _fuseSpeed;
  late AnimationController _shakeCtrl;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50));
    _startRound();
  }

  void _startRound() {
    _exploded = false;
    _fuseProgress = 0;
    _fuseSpeed = 0.003 + _rng.nextDouble() * 0.004;
    _p1HasBomb = _rng.nextBool();
    _tick = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || _exploded) return;
      setState(() {
        _fuseProgress += _fuseSpeed;
        if (_fuseProgress >= 1.0) {
          _exploded = true;
          HapticFeedback.heavyImpact();
          GameAudioService.instance.playSfx(GameSfx.explosion);
          if (_p1HasBomb) {
            _p2Score++;
          } else {
            _p1Score++;
          }
          _round++;
          _tick?.cancel();
          if (_round >= _maxRounds) {
            Future.delayed(1.seconds,
                () => widget.onEnd(_p1Score * 10, _p2Score * 10, bonus: 10));
          } else {
            Future.delayed(1500.ms, () {
              if (mounted) _startRound();
            });
          }
        }
        // Shake when danger
        if (_fuseProgress > 0.7 && !_exploded) {
          _shakeCtrl.forward().then((_) => _shakeCtrl.reverse());
        }
      });
    });
  }

  void _passBomb() {
    if (_exploded) return;
    HapticFeedback.mediumImpact();
    GameAudioService.instance.playSfx(GameSfx.whoosh);
    setState(() => _p1HasBomb = !_p1HasBomb);
  }

  @override
  void dispose() {
    _tick?.cancel();
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final danger = _fuseProgress.clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: Color.lerp(
          const Color(0xFF1A1A2E), Colors.red.shade900, danger * 0.5)!,
      appBar: AppBar(
        title: Text(
            '${l.tr('Bomb Pass', 'Bomba Pas')} 💥  ${_round + 1}/$_maxRounds'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _PlayerScoreRow(p1: _p1Score, p2: _p2Score, p1Turn: _p1HasBomb),
            const Spacer(),
            if (_exploded)
              const Text('💥', style: TextStyle(fontSize: 100))
                  .animate()
                  .scale(duration: 300.ms, curve: Curves.easeOut)
            else
              AnimatedBuilder(
                animation: _shakeCtrl,
                builder: (context, child) {
                  final offset = sin(_shakeCtrl.value * pi * 4) * 5 * danger;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: Text(
                  '💣',
                  style: TextStyle(fontSize: 80 + danger * 30),
                ),
              ),
            const Gap(16),
            if (!_exploded)
              Text(
                _p1HasBomb
                    ? l.tr('👩 has the bomb!', '👩 bomba sende!')
                    : l.tr('👨 has the bomb!', '👨 bomba sende!'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            const Gap(8),
            // Fuse bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: danger,
                  minHeight: 12,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(
                    Color.lerp(Colors.green, Colors.red, danger)!,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Pass button
            if (!_exploded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: ElevatedButton(
                    onPressed: _passBomb,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      l.tr('PASS THE BOMB! 💣', 'BOMBAYI PAS VER! 💣'),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                  ),
                ),
              ).animate().shake(
                  duration: Duration(milliseconds: (danger * 500).toInt())),
            const Gap(32),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
//  6. TOWER STACK 🏗️
// ═══════════════════════════════════════
class _TowerStackGame extends StatefulWidget {
  const _TowerStackGame({required this.onEnd});
  final _EndCb onEnd;
  @override
  State<_TowerStackGame> createState() => _TowerStackGameState();
}

class _TowerStackGameState extends State<_TowerStackGame> {
  bool _p1Turn = true;
  int _p1Height = 0, _p2Height = 0;
  int _totalTurns = 0;
  static const _maxTurns = 20;

  // Moving block
  double _blockX = 0;
  double _blockDir = 1;
  double _blockWidth = 0.4;
  double _stackTop = 0.9; // normalized Y of tower top
  Timer? _moveTimer;
  bool _dropping = false;

  @override
  void initState() {
    super.initState();
    _startMoving();
  }

  void _startMoving() {
    _blockX = 0;
    _blockDir = 1;
    _dropping = false;
    _moveTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || _dropping) return;
      setState(() {
        _blockX += _blockDir * 0.008;
        if (_blockX > 1 - _blockWidth) _blockDir = -1;
        if (_blockX < 0) _blockDir = 1;
      });
    });
  }

  void _dropBlock() {
    if (_dropping) return;
    _dropping = true;
    _moveTimer?.cancel();
    HapticFeedback.mediumImpact();
    GameAudioService.instance.playSfx(GameSfx.tap);

    // Check alignment (center is ~0.3)
    final center = 0.5 - _blockWidth / 2;
    final diff = (_blockX - center).abs();
    final quality = (1 - diff * 3).clamp(0.0, 1.0);

    if (quality > 0.2) {
      if (_p1Turn) {
        _p1Height++;
      } else {
        _p2Height++;
      }
    }

    _totalTurns++;
    _blockWidth = (_blockWidth * (0.85 + quality * 0.15)).clamp(0.15, 0.5);

    if (_totalTurns >= _maxTurns) {
      widget.onEnd(_p1Height * 8, _p2Height * 8, bonus: 10);
      return;
    }

    setState(() {
      _p1Turn = !_p1Turn;
      _stackTop -= 0.03;
    });

    Future.delayed(400.ms, () {
      if (mounted) _startMoving();
    });
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(
            '${l.tr('Tower Stack', 'Kule Yigma')} 🏗️  ${_totalTurns + 1}/$_maxTurns'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _PlayerScoreRow(p1: _p1Height, p2: _p2Height, p1Turn: _p1Turn),
            Expanded(
              child: GestureDetector(
                onTapDown: (_) => _dropBlock(),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final size = Size(c.maxWidth, c.maxHeight);
                    return CustomPaint(
                      size: size,
                      painter: _TowerPainter(
                        blockX: _blockX,
                        blockWidth: _blockWidth,
                        stackTop: _stackTop,
                        p1Height: _p1Height,
                        p2Height: _p2Height,
                        p1Turn: _p1Turn,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l.tr('Tap to drop the block!', 'Blogu birakmak icin dokun!'),
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TowerPainter extends CustomPainter {
  _TowerPainter(
      {required this.blockX,
      required this.blockWidth,
      required this.stackTop,
      required this.p1Height,
      required this.p2Height,
      required this.p1Turn});
  final double blockX, blockWidth, stackTop;
  final int p1Height, p2Height;
  final bool p1Turn;

  @override
  void paint(Canvas canvas, Size size) {
    final blockH = size.height * 0.04;
    final maxH = max(p1Height, p2Height);

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.92, size.width, size.height * 0.08),
      Paint()..color = const Color(0xFF2D2D44),
    );

    // Tower blocks
    for (int i = 0; i < maxH; i++) {
      final y = size.height * 0.92 - (i + 1) * blockH;
      final w = size.width * (blockWidth - i * 0.01).clamp(0.15, 0.5);
      final x = (size.width - w) / 2;
      final hue = (i * 25.0) % 360;
      final color = HSLColor.fromAHSL(1, hue, 0.7, 0.5).toColor();
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w, blockH - 2), const Radius.circular(4)),
        Paint()..color = color,
      );
    }

    // Moving block
    final bx = blockX * size.width;
    final bw = blockWidth * size.width;
    final by = size.height * stackTop - maxH * blockH - blockH;
    final color = p1Turn ? Colors.pinkAccent : Colors.blueAccent;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, by, bw, blockH - 2), const Radius.circular(4)),
      Paint()..color = color,
    );
    // Glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(bx - 2, by - 2, bw + 4, blockH + 2),
          const Radius.circular(6)),
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(covariant _TowerPainter old) => true;
}

// ═══════════════════════════════════════
//  7. FRUIT CATCH 🍎
// ═══════════════════════════════════════
class _FruitCatchGame extends StatefulWidget {
  const _FruitCatchGame({required this.onEnd});
  final _EndCb onEnd;
  @override
  State<_FruitCatchGame> createState() => _FruitCatchGameState();
}

class _FruitCatchGameState extends State<_FruitCatchGame> {
  final _rng = Random();
  double _p1X = 0.25, _p2X = 0.75;
  int _p1Score = 0, _p2Score = 0;
  int _timeLeft = 20;
  final List<_FallingItem> _items = [];
  Timer? _tick, _spawn, _countdown;
  int? _dragging;

  static const _fruits = ['🍎', '🍊', '🍇', '🍌', '🍓', '🥝'];
  static const _bad = ['💀', '🦠'];

  @override
  void initState() {
    super.initState();
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        _tick?.cancel();
        _spawn?.cancel();
        _countdown?.cancel();
        widget.onEnd(_p1Score * 5, _p2Score * 5, bonus: 10);
      }
    });
    _spawn = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (!mounted) return;
      final isBad = _rng.nextDouble() < 0.15;
      setState(() {
        _items.add(_FallingItem(
          x: _rng.nextDouble() * 0.85 + 0.075,
          y: -0.05,
          emoji: isBad
              ? _bad[_rng.nextInt(_bad.length)]
              : _fruits[_rng.nextInt(_fruits.length)],
          isBad: isBad,
          speed: 0.004 + _rng.nextDouble() * 0.003,
        ));
      });
    });
    _tick = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      setState(() {
        for (final item in _items) {
          item.y += item.speed;
        }
        // Catch check
        for (int i = _items.length - 1; i >= 0; i--) {
          final item = _items[i];
          if (item.y > 0.88) {
            // P1 catch zone
            if ((item.x - _p1X).abs() < 0.08) {
              if (item.isBad) {
                _p1Score = max(0, _p1Score - 2);
              } else {
                _p1Score++;
              }
              _items.removeAt(i);
              HapticFeedback.lightImpact();
              GameAudioService.instance.playSfx(GameSfx.score);
              continue;
            }
            // P2 catch zone
            if ((item.x - _p2X).abs() < 0.08) {
              if (item.isBad) {
                _p2Score = max(0, _p2Score - 2);
              } else {
                _p2Score++;
              }
              _items.removeAt(i);
              HapticFeedback.lightImpact();
              GameAudioService.instance.playSfx(GameSfx.score);
              continue;
            }
          }
        }
        _items.removeWhere((i) => i.y > 1.05);
      });
    });
  }

  void _onPanStart(DragStartDetails d, Size size) {
    final lx = d.localPosition.dx / size.width;
    if ((lx - _p1X).abs() < 0.1)
      _dragging = 1;
    else if ((lx - _p2X).abs() < 0.1) _dragging = 2;
  }

  void _onPanUpdate(DragUpdateDetails d, Size size) {
    if (_dragging == null) return;
    setState(() {
      final dx = d.delta.dx / size.width;
      if (_dragging == 1) _p1X = (_p1X + dx).clamp(0.08, 0.48);
      if (_dragging == 2) _p2X = (_p2X + dx).clamp(0.52, 0.92);
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _spawn?.cancel();
    _countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D5016),
      appBar: AppBar(
        title: Text('${l.tr('Fruit Catch', 'Meyve Toplama')} 🍎  ⏱️$_timeLeft'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _PlayerScoreRow(p1: _p1Score, p2: _p2Score, p1Turn: true),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = Size(c.maxWidth, c.maxHeight);
                  return GestureDetector(
                    onPanStart: (d) => _onPanStart(d, size),
                    onPanUpdate: (d) => _onPanUpdate(d, size),
                    onPanEnd: (_) => _dragging = null,
                    child: CustomPaint(
                      size: size,
                      painter: _FruitPainter(
                        p1X: _p1X,
                        p2X: _p2X,
                        items: _items,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallingItem {
  _FallingItem(
      {required this.x,
      required this.y,
      required this.emoji,
      required this.isBad,
      required this.speed});
  double x, y;
  final String emoji;
  final bool isBad;
  final double speed;
}

class _FruitPainter extends CustomPainter {
  _FruitPainter({required this.p1X, required this.p2X, required this.items});
  final double p1X, p2X;
  final List<_FallingItem> items;

  @override
  void paint(Canvas canvas, Size size) {
    // Divider
    canvas.drawLine(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.15)
          ..strokeWidth = 1);

    // Items
    for (final item in items) {
      final tp = TextPainter(
        text: TextSpan(text: item.emoji, style: const TextStyle(fontSize: 28)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas,
          Offset(item.x * size.width - tp.width / 2,
              item.y * size.height - tp.height / 2));
    }

    // Baskets
    _drawBasket(canvas, size, p1X, Colors.pinkAccent);
    _drawBasket(canvas, size, p2X, Colors.blueAccent);
  }

  void _drawBasket(Canvas canvas, Size size, double x, Color c) {
    final bx = x * size.width;
    final by = size.height * 0.9;
    final path = Path()
      ..moveTo(bx - 30, by - 10)
      ..lineTo(bx - 20, by + 15)
      ..lineTo(bx + 20, by + 15)
      ..lineTo(bx + 30, by - 10)
      ..close();
    canvas.drawPath(path, Paint()..color = c);
    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant _FruitPainter old) => true;
}

// ═══════════════════════════════════════
//  8. TARGET SHOT 🎯
// ═══════════════════════════════════════
class _TargetShotGame extends StatefulWidget {
  const _TargetShotGame({required this.onEnd});
  final _EndCb onEnd;
  @override
  State<_TargetShotGame> createState() => _TargetShotGameState();
}

class _TargetShotGameState extends State<_TargetShotGame> {
  final _rng = Random();
  int _p1Score = 0, _p2Score = 0;
  int _round = 0;
  static const _maxRounds = 20;
  bool _p1Turn = true;
  double _targetX = 0.5, _targetY = 0.5;
  double _targetR = 0.08;
  Timer? _moveTimer;

  @override
  void initState() {
    super.initState();
    _spawnTarget();
  }

  void _spawnTarget() {
    _targetX = _rng.nextDouble() * 0.7 + 0.15;
    _targetY = _rng.nextDouble() * 0.6 + 0.15;
    _targetR = 0.04 + _rng.nextDouble() * 0.06;
    _moveTimer?.cancel();
    _moveTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      setState(() {
        _targetX +=
            sin(_round + DateTime.now().millisecondsSinceEpoch / 500) * 0.002;
        _targetY +=
            cos(_round + DateTime.now().millisecondsSinceEpoch / 700) * 0.001;
        _targetX = _targetX.clamp(0.1, 0.9);
        _targetY = _targetY.clamp(0.1, 0.9);
      });
    });
  }

  void _onTap(TapDownDetails d, Size size) {
    final tx = d.localPosition.dx / size.width;
    final ty = d.localPosition.dy / size.height;
    final dist = sqrt(
        (tx - _targetX) * (tx - _targetX) + (ty - _targetY) * (ty - _targetY));

    HapticFeedback.lightImpact();
    GameAudioService.instance.playSfx(GameSfx.tap);
    if (dist < _targetR) {
      // Bullseye scoring
      final accuracy = (1 - dist / _targetR);
      final pts = (accuracy * 10).round().clamp(1, 10);
      if (_p1Turn) {
        _p1Score += pts;
      } else {
        _p2Score += pts;
      }
    }

    _round++;
    _p1Turn = !_p1Turn;
    if (_round >= _maxRounds) {
      _moveTimer?.cancel();
      widget.onEnd(_p1Score, _p2Score, bonus: 10);
    } else {
      _spawnTarget();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2838),
      appBar: AppBar(
        title: Text(
            '${l.tr('Target Shot', 'Hedef Vurma')} 🎯  ${_round + 1}/$_maxRounds'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _PlayerScoreRow(p1: _p1Score, p2: _p2Score, p1Turn: _p1Turn),
            const Gap(8),
            Text(
              _p1Turn
                  ? l.tr('👩 Player 1 — Shoot!', '👩 Oyuncu 1 — Ates!')
                  : l.tr('👨 Player 2 — Shoot!', '👨 Oyuncu 2 — Ates!'),
              style: TextStyle(
                color: _p1Turn ? Colors.pinkAccent : Colors.blueAccent,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = Size(c.maxWidth, c.maxHeight);
                  return GestureDetector(
                    onTapDown: (d) => _onTap(d, size),
                    child: CustomPaint(
                      size: size,
                      painter: _TargetPainter(
                          targetX: _targetX,
                          targetY: _targetY,
                          targetR: _targetR),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetPainter extends CustomPainter {
  _TargetPainter(
      {required this.targetX, required this.targetY, required this.targetR});
  final double targetX, targetY, targetR;

  @override
  void paint(Canvas canvas, Size size) {
    final tx = targetX * size.width;
    final ty = targetY * size.height;
    final tr = targetR * min(size.width, size.height);

    // Target rings
    for (int i = 3; i >= 0; i--) {
      final r = tr * (i + 1) / 4;
      canvas.drawCircle(Offset(tx, ty), r,
          Paint()..color = i.isEven ? Colors.red : Colors.white);
    }

    // Crosshair
    canvas.drawLine(
        Offset(tx - tr - 10, ty),
        Offset(tx + tr + 10, ty),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..strokeWidth = 1);
    canvas.drawLine(
        Offset(tx, ty - tr - 10),
        Offset(tx, ty + tr + 10),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(covariant _TargetPainter old) =>
      old.targetX != targetX || old.targetY != targetY;
}

// ═══════════════════════════════════════
//  9. LAVA FLOOR 🌋
// ═══════════════════════════════════════
class _LavaFloorGame extends StatefulWidget {
  const _LavaFloorGame({required this.onEnd});
  final _EndCb onEnd;
  @override
  State<_LavaFloorGame> createState() => _LavaFloorGameState();
}

class _LavaFloorGameState extends State<_LavaFloorGame> {
  final _rng = Random();
  double _p1X = 0.3, _p1Y = 0.7;
  double _p2X = 0.7, _p2Y = 0.7;
  bool _p1Alive = true, _p2Alive = true;
  double _lavaY = 1.0; // Rising from bottom
  final List<_Platform> _platforms = [];
  Timer? _tick;
  int? _dragging;
  static const _playerR = 0.03;

  @override
  void initState() {
    super.initState();
    // Generate platforms
    for (int i = 0; i < 20; i++) {
      _platforms.add(_Platform(
        x: _rng.nextDouble() * 0.7 + 0.15,
        y: 0.85 - i * 0.12,
        width: 0.1 + _rng.nextDouble() * 0.1,
      ));
    }
    _tick = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      setState(() {
        _lavaY -= 0.0004; // Slow rise

        // Gravity for players
        if (_p1Alive) {
          _p1Y += 0.002; // Gravity
          // Platform collision
          for (final p in _platforms) {
            if (_p1Y > p.y - 0.02 &&
                _p1Y < p.y + 0.02 &&
                _p1X > p.x - p.width / 2 &&
                _p1X < p.x + p.width / 2) {
              _p1Y = p.y - 0.02;
            }
          }
          if (_p1Y > _lavaY) {
            _p1Alive = false;
            HapticFeedback.heavyImpact();
            GameAudioService.instance.playSfx(GameSfx.defeat);
          }
        }
        if (_p2Alive) {
          _p2Y += 0.002;
          for (final p in _platforms) {
            if (_p2Y > p.y - 0.02 &&
                _p2Y < p.y + 0.02 &&
                _p2X > p.x - p.width / 2 &&
                _p2X < p.x + p.width / 2) {
              _p2Y = p.y - 0.02;
            }
          }
          if (_p2Y > _lavaY) {
            _p2Alive = false;
            HapticFeedback.heavyImpact();
            GameAudioService.instance.playSfx(GameSfx.defeat);
          }
        }

        // Game over
        if (!_p1Alive && !_p2Alive) {
          _tick?.cancel();
          widget.onEnd(_p1Alive ? 30 : 10, _p2Alive ? 30 : 10, bonus: 10);
        }
      });
    });
  }

  void _onPanStart(DragStartDetails d, Size size) {
    final lx = d.localPosition.dx / size.width;
    final ly = d.localPosition.dy / size.height;
    final d1 = sqrt((lx - _p1X) * (lx - _p1X) + (ly - _p1Y) * (ly - _p1Y));
    final d2 = sqrt((lx - _p2X) * (lx - _p2X) + (ly - _p2Y) * (ly - _p2Y));
    if (d1 < 0.08 && _p1Alive)
      _dragging = 1;
    else if (d2 < 0.08 && _p2Alive) _dragging = 2;
  }

  void _onPanUpdate(DragUpdateDetails d, Size size) {
    if (_dragging == null) return;
    setState(() {
      final dx = d.delta.dx / size.width;
      final dy = d.delta.dy / size.height;
      if (_dragging == 1) {
        _p1X = (_p1X + dx).clamp(0.05, 0.95);
        _p1Y = (_p1Y + dy * 0.5).clamp(0.0, _lavaY);
      } else {
        _p2X = (_p2X + dx).clamp(0.05, 0.95);
        _p2Y = (_p2Y + dy * 0.5).clamp(0.0, _lavaY);
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A00),
      appBar: AppBar(
        title: Text('${l.tr('Lava Floor', 'Lav Zemin')} 🌋'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final size = Size(c.maxWidth, c.maxHeight);
            return GestureDetector(
              onPanStart: (d) => _onPanStart(d, size),
              onPanUpdate: (d) => _onPanUpdate(d, size),
              onPanEnd: (_) => _dragging = null,
              child: CustomPaint(
                size: size,
                painter: _LavaPainter(
                  p1X: _p1X,
                  p1Y: _p1Y,
                  p1Alive: _p1Alive,
                  p2X: _p2X,
                  p2Y: _p2Y,
                  p2Alive: _p2Alive,
                  lavaY: _lavaY,
                  platforms: _platforms,
                  playerR: _playerR,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Platform {
  _Platform({required this.x, required this.y, required this.width});
  final double x, y, width;
}

class _LavaPainter extends CustomPainter {
  _LavaPainter(
      {required this.p1X,
      required this.p1Y,
      required this.p1Alive,
      required this.p2X,
      required this.p2Y,
      required this.p2Alive,
      required this.lavaY,
      required this.platforms,
      required this.playerR});
  final double p1X, p1Y, p2X, p2Y, lavaY, playerR;
  final bool p1Alive, p2Alive;
  final List<_Platform> platforms;

  @override
  void paint(Canvas canvas, Size size) {
    // Lava
    final lavaTop = lavaY * size.height;
    canvas.drawRect(
      Rect.fromLTWH(0, lavaTop, size.width, size.height - lavaTop),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF4500), Color(0xFFFF0000), Color(0xFF8B0000)],
        ).createShader(
            Rect.fromLTWH(0, lavaTop, size.width, size.height - lavaTop)),
    );
    // Lava glow
    canvas.drawRect(
      Rect.fromLTWH(0, lavaTop - 10, size.width, 20),
      Paint()
        ..color = Colors.orange.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Platforms
    for (final p in platforms) {
      final px = (p.x - p.width / 2) * size.width;
      final py = p.y * size.height;
      final pw = p.width * size.width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(px, py, pw, 8), const Radius.circular(4)),
        Paint()..color = const Color(0xFF6B4226),
      );
    }

    // Players
    if (p1Alive) _drawP(canvas, size, p1X, p1Y, Colors.pinkAccent);
    if (p2Alive) _drawP(canvas, size, p2X, p2Y, Colors.blueAccent);
  }

  void _drawP(Canvas canvas, Size size, double x, double y, Color c) {
    final px = x * size.width;
    final py = y * size.height;
    final pr = playerR * min(size.width, size.height);
    canvas.drawCircle(Offset(px, py), pr, Paint()..color = c);
    canvas.drawCircle(
        Offset(px, py),
        pr + 3,
        Paint()
          ..color = c.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
  }

  @override
  bool shouldRepaint(covariant _LavaPainter old) => true;
}

// ═══════════════════════════════════════
//  10. PAINT WAR 🖌️
// ═══════════════════════════════════════
class _PaintWarGame extends StatefulWidget {
  const _PaintWarGame({required this.onEnd});
  final _EndCb onEnd;
  @override
  State<_PaintWarGame> createState() => _PaintWarGameState();
}

class _PaintWarGameState extends State<_PaintWarGame> {
  static const _gridW = 20;
  static const _gridH = 30;
  // 0 = empty, 1 = P1, 2 = P2
  late List<List<int>> _grid;
  int _timeLeft = 15;
  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    _grid = List.generate(_gridH, (_) => List.filled(_gridW, 0));
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        _countdown?.cancel();
        int p1 = 0, p2 = 0;
        for (final row in _grid) {
          for (final c in row) {
            if (c == 1) p1++;
            if (c == 2) p2++;
          }
        }
        widget.onEnd(p1, p2, bonus: 10);
      }
    });
  }

  void _onPan(DragUpdateDetails d, Size size) {
    final cellW = size.width / _gridW;
    final cellH = size.height / _gridH;
    final gx = (d.localPosition.dx / cellW).floor().clamp(0, _gridW - 1);
    final gy = (d.localPosition.dy / cellH).floor().clamp(0, _gridH - 1);
    final isLeftSide = d.localPosition.dx < size.width / 2;
    final player = isLeftSide ? 1 : 2;

    // Paint 3x3 brush
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        final nx = gx + dx;
        final ny = gy + dy;
        if (nx >= 0 && nx < _gridW && ny >= 0 && ny < _gridH) {
          _grid[ny][nx] = player;
        }
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2D),
      appBar: AppBar(
        title: Text('${l.tr('Paint War', 'Boya Savasi')} 🖌️  ⏱️$_timeLeft'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text('👩 ${l.tr('Left', 'Sol')}',
                      style: const TextStyle(color: Colors.pinkAccent)),
                  const Spacer(),
                  Text('👨 ${l.tr('Right', 'Sag')}',
                      style: const TextStyle(color: Colors.blueAccent)),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = Size(c.maxWidth, c.maxHeight);
                  return GestureDetector(
                    onPanUpdate: (d) => _onPan(d, size),
                    child: CustomPaint(
                      size: size,
                      painter: _PaintGridPainter(grid: _grid),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                l.tr('Swipe to paint! Left side = P1, Right side = P2',
                    'Kaydirarak boya! Sol = O1, Sag = O2'),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaintGridPainter extends CustomPainter {
  _PaintGridPainter({required this.grid});
  final List<List<int>> grid;

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / _PaintWarGameState._gridW;
    final cellH = size.height / _PaintWarGameState._gridH;

    for (int y = 0; y < grid.length; y++) {
      for (int x = 0; x < grid[y].length; x++) {
        Color c;
        switch (grid[y][x]) {
          case 1:
            c = Colors.pinkAccent.withValues(alpha: 0.6);
            break;
          case 2:
            c = Colors.blueAccent.withValues(alpha: 0.6);
            break;
          default:
            c = Colors.white.withValues(alpha: 0.05);
        }
        canvas.drawRect(
          Rect.fromLTWH(x * cellW, y * cellH, cellW - 1, cellH - 1),
          Paint()..color = c,
        );
      }
    }

    // Center divider
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _PaintGridPainter old) => true;
}

// ═══════════════════════════════════════
//  11. SNAKE ARENA 🐍
// ═══════════════════════════════════════
class _SnakeArenaGame extends StatefulWidget {
  const _SnakeArenaGame({required this.onEnd});
  final _EndCb onEnd;
  @override
  State<_SnakeArenaGame> createState() => _SnakeArenaGameState();
}

class _SnakeArenaGameState extends State<_SnakeArenaGame> {
  final _rng = Random();
  static const _gridSize = 20;
  late List<Point<int>> _p1Body, _p2Body;
  Point<int> _p1Dir = const Point(1, 0);
  Point<int> _p2Dir = const Point(-1, 0);
  late Point<int> _food;
  bool _p1Alive = true, _p2Alive = true;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _p1Body = [const Point(3, 10), const Point(2, 10), const Point(1, 10)];
    _p2Body = [const Point(16, 10), const Point(17, 10), const Point(18, 10)];
    _spawnFood();
    _tick = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (!mounted) return;
      _moveSnakes();
    });
  }

  void _spawnFood() {
    do {
      _food = Point(_rng.nextInt(_gridSize), _rng.nextInt(_gridSize));
    } while (_p1Body.contains(_food) || _p2Body.contains(_food));
  }

  void _moveSnakes() {
    setState(() {
      if (_p1Alive) {
        final newHead = Point((_p1Body.first.x + _p1Dir.x) % _gridSize,
            (_p1Body.first.y + _p1Dir.y) % _gridSize);
        if (_p1Body.contains(newHead) || _p2Body.contains(newHead)) {
          _p1Alive = false;
        } else {
          _p1Body.insert(0, newHead);
          if (newHead == _food) {
            _spawnFood();
            HapticFeedback.lightImpact();
            GameAudioService.instance.playSfx(GameSfx.powerUp);
          } else {
            _p1Body.removeLast();
          }
        }
      }
      if (_p2Alive) {
        final newHead = Point((_p2Body.first.x + _p2Dir.x) % _gridSize,
            (_p2Body.first.y + _p2Dir.y) % _gridSize);
        if (_p2Body.contains(newHead) || _p1Body.contains(newHead)) {
          _p2Alive = false;
        } else {
          _p2Body.insert(0, newHead);
          if (newHead == _food) {
            _spawnFood();
            HapticFeedback.lightImpact();
            GameAudioService.instance.playSfx(GameSfx.powerUp);
          } else {
            _p2Body.removeLast();
          }
        }
      }

      if (!_p1Alive || !_p2Alive) {
        _tick?.cancel();
        widget.onEnd(_p1Body.length * 5, _p2Body.length * 5, bonus: 10);
      }
    });
  }

  void _onSwipe(DragUpdateDetails d) {
    final dx = d.delta.dx;
    final dy = d.delta.dy;
    final isLeft = d.localPosition.dx < MediaQuery.of(context).size.width / 2;

    if (dx.abs() > dy.abs()) {
      // Horizontal
      if (isLeft && _p1Dir.y != 0) {
        _p1Dir = Point(dx > 0 ? 1 : -1, 0);
      } else if (!isLeft && _p2Dir.y != 0) {
        _p2Dir = Point(dx > 0 ? 1 : -1, 0);
      }
    } else {
      if (isLeft && _p1Dir.x != 0) {
        _p1Dir = Point(0, dy > 0 ? 1 : -1);
      } else if (!isLeft && _p2Dir.x != 0) {
        _p2Dir = Point(0, dy > 0 ? 1 : -1);
      }
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        title: Text('${l.tr('Snake Arena', 'Yilan Arenasi')} 🐍'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: GestureDetector(
          onPanUpdate: _onSwipe,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('👩 ${_p1Body.length}',
                        style: const TextStyle(
                            color: Colors.pinkAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    Text('👨 ${_p2Body.length}',
                        style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CustomPaint(
                      painter: _SnakePainter(
                        p1Body: _p1Body,
                        p2Body: _p2Body,
                        food: _food,
                        gridSize: _gridSize,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  l.tr('Swipe left side = P1, right side = P2',
                      'Sol taraf = O1, sag taraf = O2'),
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SnakePainter extends CustomPainter {
  _SnakePainter(
      {required this.p1Body,
      required this.p2Body,
      required this.food,
      required this.gridSize});
  final List<Point<int>> p1Body, p2Body;
  final Point<int> food;
  final int gridSize;

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridSize;

    // Grid
    for (int x = 0; x <= gridSize; x++) {
      canvas.drawLine(
          Offset(x * cellSize, 0),
          Offset(x * cellSize, size.height),
          Paint()..color = Colors.white.withValues(alpha: 0.05));
    }
    for (int y = 0; y <= gridSize; y++) {
      canvas.drawLine(Offset(0, y * cellSize), Offset(size.width, y * cellSize),
          Paint()..color = Colors.white.withValues(alpha: 0.05));
    }

    // Snakes
    for (final seg in p1Body) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(seg.x * cellSize + 1, seg.y * cellSize + 1,
              cellSize - 2, cellSize - 2),
          const Radius.circular(4),
        ),
        Paint()..color = Colors.pinkAccent,
      );
    }
    for (final seg in p2Body) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(seg.x * cellSize + 1, seg.y * cellSize + 1,
              cellSize - 2, cellSize - 2),
          const Radius.circular(4),
        ),
        Paint()..color = Colors.blueAccent,
      );
    }

    // Food
    canvas.drawCircle(
      Offset(
          food.x * cellSize + cellSize / 2, food.y * cellSize + cellSize / 2),
      cellSize / 3,
      Paint()..color = Colors.greenAccent,
    );
    canvas.drawCircle(
      Offset(
          food.x * cellSize + cellSize / 2, food.y * cellSize + cellSize / 2),
      cellSize / 2,
      Paint()
        ..color = Colors.greenAccent.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(covariant _SnakePainter old) => true;
}

// ═══════════════════════════════════════
//  12. ASTEROID BREAKER 🪨
// ═══════════════════════════════════════
class _AsteroidBreakerGame extends StatefulWidget {
  const _AsteroidBreakerGame({required this.onEnd});
  final _EndCb onEnd;
  @override
  State<_AsteroidBreakerGame> createState() => _AsteroidBreakerGameState();
}

class _AsteroidBreakerGameState extends State<_AsteroidBreakerGame> {
  final _rng = Random();
  int _p1Score = 0, _p2Score = 0;
  int _timeLeft = 20;
  int _missed = 0;
  final List<_Asteroid> _asteroids = [];
  Timer? _tick, _spawn, _countdown;

  @override
  void initState() {
    super.initState();
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0 || _missed >= 10) {
        _tick?.cancel();
        _spawn?.cancel();
        _countdown?.cancel();
        widget.onEnd(_p1Score * 5, _p2Score * 5, bonus: 10);
      }
    });
    _spawn = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!mounted) return;
      setState(() {
        _asteroids.add(_Asteroid(
          x: _rng.nextDouble() * 0.8 + 0.1,
          y: _rng.nextDouble() * 0.8 + 0.1,
          radius: 0.03 + _rng.nextDouble() * 0.04,
          lifetime: 60 + _rng.nextInt(40),
        ));
      });
    });
    _tick = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      setState(() {
        for (final a in _asteroids) {
          a.age++;
        }
        final expired = _asteroids.where((a) => a.age >= a.lifetime).length;
        _missed += expired;
        _asteroids.removeWhere((a) => a.age >= a.lifetime);
      });
    });
  }

  void _onTapDown(TapDownDetails d, Size size) {
    final tx = d.localPosition.dx / size.width;
    final ty = d.localPosition.dy / size.height;
    final isLeft = tx < 0.5;

    for (int i = _asteroids.length - 1; i >= 0; i--) {
      final a = _asteroids[i];
      final dist = sqrt((tx - a.x) * (tx - a.x) + (ty - a.y) * (ty - a.y));
      if (dist < a.radius + 0.03) {
        if (isLeft) {
          _p1Score++;
        } else {
          _p2Score++;
        }
        _asteroids.removeAt(i);
        HapticFeedback.lightImpact();
        GameAudioService.instance.playSfx(GameSfx.hit);
        setState(() {});
        return;
      }
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    _spawn?.cancel();
    _countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        title: Text(
            '${l.tr('Asteroid Breaker', 'Asteroid Kirma')} 🪨  ⏱️$_timeLeft'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _PlayerScoreRow(p1: _p1Score, p2: _p2Score, p1Turn: true),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = Size(c.maxWidth, c.maxHeight);
                  return GestureDetector(
                    onTapDown: (d) => _onTapDown(d, size),
                    child: CustomPaint(
                      size: size,
                      painter: _AsteroidPainter(asteroids: _asteroids),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '${l.tr('Missed', 'Kacirilan')}: $_missed/10  |  '
                '${l.tr('Left = P1, Right = P2', 'Sol = O1, Sag = O2')}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Asteroid {
  _Asteroid(
      {required this.x,
      required this.y,
      required this.radius,
      required this.lifetime});
  final double x, y, radius;
  final int lifetime;
  int age = 0;
  double get progress => (age / lifetime).clamp(0.0, 1.0);
}

class _AsteroidPainter extends CustomPainter {
  _AsteroidPainter({required this.asteroids});
  final List<_Asteroid> asteroids;

  @override
  void paint(Canvas canvas, Size size) {
    // Stars
    final rng = Random(99);
    for (int i = 0; i < 30; i++) {
      canvas.drawCircle(
          Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
          1,
          Paint()..color = Colors.white.withValues(alpha: 0.2));
    }

    for (final a in asteroids) {
      final ax = a.x * size.width;
      final ay = a.y * size.height;
      final ar = a.radius * min(size.width, size.height);
      // Danger ring
      final danger = a.progress;
      canvas.drawCircle(
          Offset(ax, ay),
          ar + 8,
          Paint()
            ..color = Color.lerp(Colors.grey, Colors.red, danger)!
                .withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      // Rock body
      canvas.drawCircle(
          Offset(ax, ay),
          ar,
          Paint()
            ..color = Color.lerp(const Color(0xFF808080), Colors.red, danger)!);
      // Craters
      canvas.drawCircle(Offset(ax - ar * 0.2, ay - ar * 0.2), ar * 0.2,
          Paint()..color = Colors.black.withValues(alpha: 0.2));
      canvas.drawCircle(Offset(ax + ar * 0.3, ay + ar * 0.1), ar * 0.15,
          Paint()..color = Colors.black.withValues(alpha: 0.15));
    }
  }

  @override
  bool shouldRepaint(covariant _AsteroidPainter old) => true;
}

// ═══════════════════════════════════════
//  13. RHYTHM TAP 🎵
// ═══════════════════════════════════════
class _RhythmTapGame extends StatefulWidget {
  const _RhythmTapGame({required this.onEnd});
  final _EndCb onEnd;
  @override
  State<_RhythmTapGame> createState() => _RhythmTapGameState();
}

class _RhythmTapGameState extends State<_RhythmTapGame> {
  final _rng = Random();
  int _p1Score = 0, _p2Score = 0;
  // Notes falling in 2 lanes
  final List<_RhythmNote> _notes = [];
  Timer? _tick, _spawn;
  int _totalNotes = 0;
  static const _maxNotes = 40;
  static const _hitZoneY = 0.85;

  @override
  void initState() {
    super.initState();
    _spawn = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted || _totalNotes >= _maxNotes) return;
      _totalNotes++;
      setState(() {
        _notes.add(_RhythmNote(
          lane: _rng.nextInt(2), // 0 = left (P1), 1 = right (P2)
          y: -0.05,
        ));
      });
    });
    _tick = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      setState(() {
        for (final n in _notes) {
          n.y += 0.005;
        }
        // Missed notes
        _notes.removeWhere((n) => n.y > 1.0);

        if (_totalNotes >= _maxNotes && _notes.isEmpty) {
          _tick?.cancel();
          _spawn?.cancel();
          widget.onEnd(_p1Score * 3, _p2Score * 3, bonus: 10);
        }
      });
    });
  }

  void _tapLane(int lane) {
    // Find closest note in this lane near hit zone
    _RhythmNote? best;
    double bestDist = 0.15; // max acceptable distance
    for (final n in _notes) {
      if (n.lane == lane && !n.hit) {
        final dist = (n.y - _hitZoneY).abs();
        if (dist < bestDist) {
          bestDist = dist;
          best = n;
        }
      }
    }
    if (best != null) {
      best.hit = true;
      _notes.remove(best);
      final accuracy = (1 - bestDist / 0.15);
      final pts = (accuracy * 5).round().clamp(1, 5);
      if (lane == 0) {
        _p1Score += pts;
      } else {
        _p2Score += pts;
      }
      HapticFeedback.lightImpact();
      GameAudioService.instance.playSfx(GameSfx.score);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    _spawn?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A2E),
      appBar: AppBar(
        title: Text('${l.tr('Rhythm Tap', 'Ritim Dokun')} 🎵'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _PlayerScoreRow(p1: _p1Score, p2: _p2Score, p1Turn: true),
            Expanded(
              child: Row(
                children: [
                  // P1 Lane
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => _tapLane(0),
                      child: _RhythmLane(
                        notes: _notes.where((n) => n.lane == 0).toList(),
                        color: Colors.pinkAccent,
                        hitZoneY: _hitZoneY,
                      ),
                    ),
                  ),
                  Container(width: 2, color: Colors.white12),
                  // P2 Lane
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => _tapLane(1),
                      child: _RhythmLane(
                        notes: _notes.where((n) => n.lane == 1).toList(),
                        color: Colors.blueAccent,
                        hitZoneY: _hitZoneY,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RhythmNote {
  _RhythmNote({required this.lane, required this.y});
  final int lane;
  double y;
  bool hit = false;
}

class _RhythmLane extends StatelessWidget {
  const _RhythmLane(
      {required this.notes, required this.color, required this.hitZoneY});
  final List<_RhythmNote> notes;
  final Color color;
  final double hitZoneY;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return CustomPaint(
          size: Size(c.maxWidth, c.maxHeight),
          painter: _RhythmLanePainter(
              notes: notes, color: color, hitZoneY: hitZoneY),
        );
      },
    );
  }
}

class _RhythmLanePainter extends CustomPainter {
  _RhythmLanePainter(
      {required this.notes, required this.color, required this.hitZoneY});
  final List<_RhythmNote> notes;
  final Color color;
  final double hitZoneY;

  @override
  void paint(Canvas canvas, Size size) {
    // Hit zone
    final hzy = hitZoneY * size.height;
    canvas.drawRect(
      Rect.fromLTWH(0, hzy - 15, size.width, 30),
      Paint()..color = color.withValues(alpha: 0.15),
    );
    canvas.drawLine(
        Offset(0, hzy),
        Offset(size.width, hzy),
        Paint()
          ..color = color.withValues(alpha: 0.4)
          ..strokeWidth = 2);

    // Notes
    for (final n in notes) {
      final ny = n.y * size.height;
      final nx = size.width / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(nx, ny), width: 50, height: 20),
          const Radius.circular(10),
        ),
        Paint()..color = color,
      );
      // Glow
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(nx, ny), width: 56, height: 26),
          const Radius.circular(13),
        ),
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RhythmLanePainter old) => true;
}

// ═══════════════════════════════════════
//  14. MAZE RUNNER 🏃
// ═══════════════════════════════════════
class _MazeRunnerGame extends StatefulWidget {
  const _MazeRunnerGame({required this.onEnd});
  final _EndCb onEnd;
  @override
  State<_MazeRunnerGame> createState() => _MazeRunnerGameState();
}

class _MazeRunnerGameState extends State<_MazeRunnerGame> {
  static const _mazeW = 11;
  static const _mazeH = 11;
  late List<List<bool>> _walls; // true = wall
  Point<int> _p1 = const Point(1, 1);
  Point<int> _p2 = const Point(1, 3);
  late Point<int> _exit;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _generateMaze();
    _exit = const Point(_mazeW - 2, _mazeH - 2);
  }

  void _generateMaze() {
    _walls = List.generate(_mazeH, (_) => List.filled(_mazeW, true));
    // Simple recursive backtracker
    final visited = <Point<int>>{};

    void carve(Point<int> p) {
      _walls[p.y][p.x] = false;
      visited.add(p);
      final dirs = [
        const Point(0, -2),
        const Point(0, 2),
        const Point(-2, 0),
        const Point(2, 0),
      ]..shuffle(Random());
      for (final d in dirs) {
        final nx = p.x + d.x;
        final ny = p.y + d.y;
        final next = Point(nx, ny);
        if (nx > 0 &&
            nx < _mazeW - 1 &&
            ny > 0 &&
            ny < _mazeH - 1 &&
            !visited.contains(next)) {
          _walls[p.y + d.y ~/ 2][p.x + d.x ~/ 2] = false;
          carve(next);
        }
      }
    }

    carve(const Point(1, 1));
    // Ensure exit is open
    _walls[_mazeH - 2][_mazeW - 2] = false;
    _walls[_mazeH - 3][_mazeW - 2] = false;
  }

  void _movePlayer(int player, Point<int> dir) {
    if (_finished) return;
    setState(() {
      final pos = player == 1 ? _p1 : _p2;
      final nx = pos.x + dir.x;
      final ny = pos.y + dir.y;
      if (nx >= 0 && nx < _mazeW && ny >= 0 && ny < _mazeH && !_walls[ny][nx]) {
        if (player == 1) {
          _p1 = Point(nx, ny);
          if (_p1 == _exit) {
            _finished = true;
            widget.onEnd(30, 10, bonus: 15);
          }
        } else {
          _p2 = Point(nx, ny);
          if (_p2 == _exit) {
            _finished = true;
            widget.onEnd(10, 30, bonus: 15);
          }
        }
        HapticFeedback.selectionClick();
        GameAudioService.instance.playSfx(GameSfx.tap);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('${l.tr('Maze Runner', 'Labirent Kosusu')} 🏃'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _mazeW / _mazeH,
                  child: CustomPaint(
                    painter: _MazePainter(
                      walls: _walls,
                      p1: _p1,
                      p2: _p2,
                      exit: _exit,
                      mazeW: _mazeW,
                      mazeH: _mazeH,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            // D-pad controls
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  Expanded(
                      child: _DPad(
                    color: Colors.pinkAccent,
                    label: '👩',
                    onDir: (d) => _movePlayer(1, d),
                  )),
                  const VerticalDivider(color: Colors.white24),
                  Expanded(
                      child: _DPad(
                    color: Colors.blueAccent,
                    label: '👨',
                    onDir: (d) => _movePlayer(2, d),
                  )),
                ],
              ),
            ),
            const Gap(8),
          ],
        ),
      ),
    );
  }
}

class _DPad extends StatelessWidget {
  const _DPad({required this.color, required this.label, required this.onDir});
  final Color color;
  final String label;
  final void Function(Point<int>) onDir;

  @override
  Widget build(BuildContext context) {
    Widget btn(String icon, Point<int> dir) {
      return GestureDetector(
        onTap: () => onDir(dir),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 16)),
        const Gap(4),
        btn('⬆️', const Point(0, -1)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            btn('⬅️', const Point(-1, 0)),
            const Gap(8),
            btn('➡️', const Point(1, 0)),
          ],
        ),
        btn('⬇️', const Point(0, 1)),
      ],
    );
  }
}

class _MazePainter extends CustomPainter {
  _MazePainter(
      {required this.walls,
      required this.p1,
      required this.p2,
      required this.exit,
      required this.mazeW,
      required this.mazeH});
  final List<List<bool>> walls;
  final Point<int> p1, p2, exit;
  final int mazeW, mazeH;

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / mazeW;
    final cellH = size.height / mazeH;

    // Walls
    for (int y = 0; y < mazeH; y++) {
      for (int x = 0; x < mazeW; x++) {
        if (walls[y][x]) {
          canvas.drawRect(
            Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH),
            Paint()..color = const Color(0xFF3A3A5C),
          );
        }
      }
    }

    // Exit
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            exit.x * cellW + 2, exit.y * cellH + 2, cellW - 4, cellH - 4),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.greenAccent,
    );

    // Exit glow
    canvas.drawCircle(
      Offset(exit.x * cellW + cellW / 2, exit.y * cellH + cellH / 2),
      cellW,
      Paint()
        ..color = Colors.greenAccent.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Players
    canvas.drawCircle(
      Offset(p1.x * cellW + cellW / 2, p1.y * cellH + cellH / 2),
      cellW / 3,
      Paint()..color = Colors.pinkAccent,
    );
    canvas.drawCircle(
      Offset(p2.x * cellW + cellW / 2, p2.y * cellH + cellH / 2),
      cellW / 3,
      Paint()..color = Colors.blueAccent,
    );
  }

  @override
  bool shouldRepaint(covariant _MazePainter old) => true;
}

// ═══════════════════════════════════════
//  15. SHIELD BLOCK 🛡️
// ═══════════════════════════════════════
class _ShieldBlockGame extends StatefulWidget {
  const _ShieldBlockGame({required this.onEnd});
  final _EndCb onEnd;
  @override
  State<_ShieldBlockGame> createState() => _ShieldBlockGameState();
}

class _ShieldBlockGameState extends State<_ShieldBlockGame> {
  final _rng = Random();
  double _p1Angle = 0; // Shield angle in radians (0 = right)
  double _p2Angle = pi;
  int _p1HP = 5, _p2HP = 5;
  final List<_Projectile> _projectiles = [];
  Timer? _tick, _spawn;
  static const _shieldLen = 0.6; // arc length in radians

  @override
  void initState() {
    super.initState();
    _spawn = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (!mounted) return;
      final angle = _rng.nextDouble() * 2 * pi;
      setState(() {
        _projectiles.add(_Projectile(
          x: 0.5 + cos(angle) * 0.55,
          y: 0.5 + sin(angle) * 0.55,
          dx: -cos(angle) * 0.004,
          dy: -sin(angle) * 0.004,
          color: [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.cyan
          ][_rng.nextInt(4)],
        ));
      });
    });
    _tick = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      setState(() {
        for (final p in _projectiles) {
          p.x += p.dx;
          p.y += p.dy;
        }

        // Hit detection
        for (int i = _projectiles.length - 1; i >= 0; i--) {
          final p = _projectiles[i];
          final dist =
              sqrt((p.x - 0.5) * (p.x - 0.5) + (p.y - 0.5) * (p.y - 0.5));

          if (dist < 0.08) {
            // Hit center — check which player should've blocked
            final angle = atan2(p.y - 0.5, p.x - 0.5);

            // Check P1 shield
            var angleDiff1 = (angle - _p1Angle) % (2 * pi);
            if (angleDiff1 > pi) angleDiff1 -= 2 * pi;
            final p1Blocked = angleDiff1.abs() < _shieldLen / 2;

            // Check P2 shield
            var angleDiff2 = (angle - _p2Angle) % (2 * pi);
            if (angleDiff2 > pi) angleDiff2 -= 2 * pi;
            final p2Blocked = angleDiff2.abs() < _shieldLen / 2;

            if (p1Blocked || p2Blocked) {
              // Blocked
              HapticFeedback.lightImpact();
              GameAudioService.instance.playSfx(GameSfx.hit);
            } else {
              // Damage
              if (angleDiff1.abs() < angleDiff2.abs()) {
                _p1HP--;
              } else {
                _p2HP--;
              }
              HapticFeedback.heavyImpact();
              GameAudioService.instance.playSfx(GameSfx.explosion);
            }
            _projectiles.removeAt(i);
          } else if (dist > 0.6) {
            _projectiles.removeAt(i);
          }
        }

        if (_p1HP <= 0 || _p2HP <= 0) {
          _tick?.cancel();
          _spawn?.cancel();
          widget.onEnd(_p1HP * 10, _p2HP * 10, bonus: 10);
        }
      });
    });
  }

  void _onPan(DragUpdateDetails d, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final angle = atan2(d.localPosition.dy - cy, d.localPosition.dx - cx);

    // Left side controls P1, right side controls P2
    if (d.localPosition.dx < cx) {
      _p1Angle = angle;
    } else {
      _p2Angle = angle;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _tick?.cancel();
    _spawn?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text('${l.tr('Shield Block', 'Kalkan Blok')} 🛡️'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _HPBar(label: '👩', hp: _p1HP, color: Colors.pinkAccent),
                  _HPBar(label: '👨', hp: _p2HP, color: Colors.blueAccent),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = Size(c.maxWidth, c.maxHeight);
                  return GestureDetector(
                    onPanUpdate: (d) => _onPan(d, size),
                    child: CustomPaint(
                      size: size,
                      painter: _ShieldArenaPainter(
                        p1Angle: _p1Angle,
                        p2Angle: _p2Angle,
                        shieldLen: _shieldLen,
                        projectiles: _projectiles,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                l.tr('Drag left half = P1 shield, right half = P2 shield',
                    'Sol yari = O1 kalkan, sag yari = O2 kalkan'),
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HPBar extends StatelessWidget {
  const _HPBar({required this.label, required this.hp, required this.color});
  final String label;
  final int hp;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 24)),
        const Gap(8),
        ...List.generate(
            5,
            (i) => Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i < hp ? color : Colors.white12,
                  ),
                )),
      ],
    );
  }
}

class _Projectile {
  _Projectile(
      {required this.x,
      required this.y,
      required this.dx,
      required this.dy,
      required this.color});
  double x, y;
  final double dx, dy;
  final Color color;
}

class _ShieldArenaPainter extends CustomPainter {
  _ShieldArenaPainter(
      {required this.p1Angle,
      required this.p2Angle,
      required this.shieldLen,
      required this.projectiles});
  final double p1Angle, p2Angle, shieldLen;
  final List<_Projectile> projectiles;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final minDim = min(size.width, size.height);
    final arenaR = minDim * 0.35;

    // Arena
    canvas.drawCircle(
        Offset(cx, cy),
        arenaR,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        Offset(cx, cy),
        arenaR,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Center core
    canvas.drawCircle(Offset(cx, cy), 12,
        Paint()..color = Colors.white.withValues(alpha: 0.3));

    // Shields
    _drawShield(canvas, cx, cy, arenaR * 0.3, p1Angle, Colors.pinkAccent);
    _drawShield(canvas, cx, cy, arenaR * 0.3, p2Angle, Colors.blueAccent);

    // Divider
    canvas.drawLine(
        Offset(cx, 0),
        Offset(cx, size.height),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.08)
          ..strokeWidth = 1);

    // Projectiles
    for (final p in projectiles) {
      final px = p.x * size.width;
      final py = p.y * size.height;
      canvas.drawCircle(Offset(px, py), 6, Paint()..color = p.color);
      canvas.drawCircle(
          Offset(px, py),
          10,
          Paint()
            ..color = p.color.withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }
  }

  void _drawShield(Canvas canvas, double cx, double cy, double r, double angle,
      Color color) {
    final shieldR = r + 40;
    final path = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: shieldR),
        angle - shieldLen / 2,
        shieldLen,
      );
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round);
    // Shield glow
    canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
  }

  @override
  bool shouldRepaint(covariant _ShieldArenaPainter old) => true;
}

// ═══════════════════════════════════════
//  SHARED: Player Score Row
// ═══════════════════════════════════════
class _PlayerScoreRow extends StatelessWidget {
  const _PlayerScoreRow(
      {required this.p1, required this.p2, required this.p1Turn});
  final int p1, p2;
  final bool p1Turn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AnimatedContainer(
            duration: 300.ms,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: p1Turn
                  ? Colors.pinkAccent.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: p1Turn ? Colors.pinkAccent : Colors.transparent,
                  width: 2),
            ),
            child: Text('👩 $p1',
                style: const TextStyle(
                    color: Colors.pinkAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
          ),
          AnimatedContainer(
            duration: 300.ms,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: !p1Turn
                  ? Colors.blueAccent.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: !p1Turn ? Colors.blueAccent : Colors.transparent,
                  width: 2),
            ),
            child: Text('👨 $p2',
                style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
