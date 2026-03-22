import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/locale_service.dart';
import '../../../../data/models/game_model.dart';
import '../../../../data/repositories/games_repository.dart';

class ArenaGamesPage extends StatefulWidget {
  const ArenaGamesPage({super.key, required this.gameType});
  final CoupleGameType gameType;

  @override
  State<ArenaGamesPage> createState() => _ArenaGamesPageState();
}

class _ArenaGamesPageState extends State<ArenaGamesPage> {
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
    if (_gameOver) return _ArenaGameOver(p1: _p1Score, p2: _p2Score);

    switch (widget.gameType) {
      case CoupleGameType.sumoBall:
        return _SumoBallGame(onEnd: _endGame);
      case CoupleGameType.miniPool:
        return _MiniPoolGame(onEnd: _endGame);
      case CoupleGameType.carRace:
        return _CarRaceGame(onEnd: _endGame);
      case CoupleGameType.laserDodge:
        return _LaserDodgeGame(onEnd: _endGame);
      case CoupleGameType.icePlatform:
        return _IcePlatformGame(onEnd: _endGame);
      default:
        Navigator.of(context).pop();
        return const SizedBox.shrink();
    }
  }
}

// ══════════════════════════════════════════════════
//  ARENA GAME OVER
// ══════════════════════════════════════════════════
class _ArenaGameOver extends StatelessWidget {
  const _ArenaGameOver({required this.p1, required this.p2});
  final int p1, p2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final winner = p1 > p2
        ? l.tr('👩 Player 1 Wins!', '👩 Oyuncu 1 Kazandi!')
        : p2 > p1
            ? l.tr('👨 Player 2 Wins!', '👨 Oyuncu 2 Kazandi!')
            : l.tr('🤝 Draw!', '🤝 Berabere!');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.2),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 80))
                      .animate()
                      .scale(duration: 800.ms, curve: Curves.elasticOut),
                  const Gap(24),
                  Text(winner,
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w900))
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .slideY(begin: 0.3),
                  const Gap(32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ScoreBox(
                          label: l.tr('👩 P1', '👩 O1'),
                          score: p1,
                          color: Colors.pink),
                      const Gap(24),
                      _ScoreBox(
                          label: l.tr('👨 P2', '👨 O2'),
                          score: p2,
                          color: Colors.blue),
                    ],
                  ).animate().fadeIn(delay: 500.ms),
                  const Gap(40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l.tr('Back to Games', 'Oyunlara Don'),
                          style: const TextStyle(fontSize: 16)),
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  const _ScoreBox(
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

// ══════════════════════════════════════════════════
//  1. SUMO BALL 🔴 — Push opponent off platform
// ══════════════════════════════════════════════════
class _SumoBallGame extends StatefulWidget {
  const _SumoBallGame({required this.onEnd});
  final Future<void> Function(int p1, int p2, {int bonus}) onEnd;

  @override
  State<_SumoBallGame> createState() => _SumoBallGameState();
}

class _SumoBallGameState extends State<_SumoBallGame>
    with TickerProviderStateMixin {
  // Positions (0..1 normalized)
  double _p1X = 0.35, _p1Y = 0.5;
  double _p2X = 0.65, _p2Y = 0.5;
  // Velocities
  double _p1VX = 0, _p1VY = 0;
  double _p2VX = 0, _p2VY = 0;
  // Ball radius (fraction of arena)
  static const _ballR = 0.06;
  // Platform radius
  static const _platR = 0.42;
  // Center
  static const _cx = 0.5, _cy = 0.5;

  int _p1Wins = 0, _p2Wins = 0;
  int _roundNum = 0;
  bool _roundOver = false;
  String _roundText = '';
  Timer? _physicsTimer;
  bool _countdown = true;
  int _countVal = 3;

  // Drag tracking
  int? _draggingPlayer; // 1 or 2

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdown = true;
    _countVal = 3;
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_countVal <= 1) {
        t.cancel();
        setState(() => _countdown = false);
        _startPhysics();
      } else {
        setState(() => _countVal--);
      }
    });
  }

  void _startPhysics() {
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || _roundOver) return;
      setState(() {
        // Apply friction
        _p1VX *= 0.96; _p1VY *= 0.96;
        _p2VX *= 0.96; _p2VY *= 0.96;
        // Move
        _p1X += _p1VX; _p1Y += _p1VY;
        _p2X += _p2VX; _p2Y += _p2VY;

        // Collision between balls
        final dx = _p2X - _p1X;
        final dy = _p2Y - _p1Y;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist < _ballR * 2 && dist > 0) {
          final nx = dx / dist;
          final ny = dy / dist;
          // Push apart
          final overlap = _ballR * 2 - dist;
          _p1X -= nx * overlap * 0.5;
          _p1Y -= ny * overlap * 0.5;
          _p2X += nx * overlap * 0.5;
          _p2Y += ny * overlap * 0.5;
          // Transfer velocity (elastic)
          final relV = (_p1VX - _p2VX) * nx + (_p1VY - _p2VY) * ny;
          if (relV > 0) {
            _p1VX -= relV * nx * 0.8;
            _p1VY -= relV * ny * 0.8;
            _p2VX += relV * nx * 0.8;
            _p2VY += relV * ny * 0.8;
            HapticFeedback.mediumImpact();
          }
        }

        // Check out-of-bounds
        final p1Dist = sqrt((_p1X - _cx) * (_p1X - _cx) + (_p1Y - _cy) * (_p1Y - _cy));
        final p2Dist = sqrt((_p2X - _cx) * (_p2X - _cx) + (_p2Y - _cy) * (_p2Y - _cy));

        if (p1Dist > _platR) {
          _roundOver = true;
          _p2Wins++;
          _roundText = l.tr('👨 Player 2 scores!', '👨 Oyuncu 2 puan aldi!');
          HapticFeedback.heavyImpact();
          _nextRound();
        } else if (p2Dist > _platR) {
          _roundOver = true;
          _p1Wins++;
          _roundText = l.tr('👩 Player 1 scores!', '👩 Oyuncu 1 puan aldi!');
          HapticFeedback.heavyImpact();
          _nextRound();
        }
      });
    });
  }

  void _nextRound() async {
    _physicsTimer?.cancel();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (_p1Wins >= 3 || _p2Wins >= 3) {
      widget.onEnd(_p1Wins * 15, _p2Wins * 15, bonus: 10);
    } else {
      setState(() {
        _roundNum++;
        _roundOver = false;
        _roundText = '';
        _p1X = 0.35; _p1Y = 0.5;
        _p2X = 0.65; _p2Y = 0.5;
        _p1VX = 0; _p1VY = 0;
        _p2VX = 0; _p2VY = 0;
      });
      _startCountdown();
    }
  }

  void _onDragStart(DragStartDetails d, Size arenaSize) {
    final lx = d.localPosition.dx / arenaSize.width;
    final ly = d.localPosition.dy / arenaSize.height;
    final d1 = sqrt((lx - _p1X) * (lx - _p1X) + (ly - _p1Y) * (ly - _p1Y));
    final d2 = sqrt((lx - _p2X) * (lx - _p2X) + (ly - _p2Y) * (ly - _p2Y));
    if (d1 < _ballR * 2.5) {
      _draggingPlayer = 1;
    } else if (d2 < _ballR * 2.5) {
      _draggingPlayer = 2;
    }
  }

  void _onDragUpdate(DragUpdateDetails d, Size arenaSize) {
    if (_draggingPlayer == null || _roundOver || _countdown) return;
    final dx = d.delta.dx / arenaSize.width * 0.15;
    final dy = d.delta.dy / arenaSize.height * 0.15;
    setState(() {
      if (_draggingPlayer == 1) {
        _p1VX += dx; _p1VY += dy;
      } else {
        _p2VX += dx; _p2VY += dy;
      }
    });
  }

  void _onDragEnd(DragEndDetails d) {
    _draggingPlayer = null;
  }

  @override
  void dispose() {
    _physicsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text('${l.tr('Sumo Ball', 'Sumo Topu')} 🔴 — '
            '${l.tr('Round', 'Tur')} ${_roundNum + 1}'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scoreboard
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SumoScore(label: '👩', wins: _p1Wins, color: Colors.pinkAccent),
                  Text(l.tr('Best of 5', '5in En Iyisi'),
                      style: const TextStyle(color: Colors.white54)),
                  _SumoScore(label: '👨', wins: _p2Wins, color: Colors.blueAccent),
                ],
              ),
            ),
            // Arena
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(constraints.maxWidth, constraints.maxHeight);
                    final minDim = min(size.width, size.height);
                    return GestureDetector(
                      onPanStart: (d) => _onDragStart(d, size),
                      onPanUpdate: (d) => _onDragUpdate(d, size),
                      onPanEnd: _onDragEnd,
                      child: CustomPaint(
                        size: size,
                        painter: _SumoArenaPainter(
                          p1X: _p1X, p1Y: _p1Y,
                          p2X: _p2X, p2Y: _p2Y,
                          ballR: _ballR,
                          platR: _platR,
                        ),
                        child: _countdown
                            ? Center(
                                child: Text('$_countVal',
                                    style: const TextStyle(
                                        fontSize: 80,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white))
                                    .animate(onPlay: (c) => c.repeat(reverse: true))
                                    .scale(begin: const Offset(0.8, 0.8),
                                        end: const Offset(1.3, 1.3),
                                        duration: 500.ms),
                              )
                            : _roundOver
                                ? Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(_roundText,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800)),
                                    ).animate().scale(
                                        duration: 400.ms,
                                        curve: Curves.elasticOut),
                                  )
                                : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Instructions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l.tr('Swipe on your ball to push! Push opponent off the platform!',
                    'Topuna dokun ve suretle! Rakibini platformdan dusur!'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SumoScore extends StatelessWidget {
  const _SumoScore({required this.label, required this.wins, required this.color});
  final String label;
  final int wins;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 28)),
        const Gap(8),
        ...List.generate(3, (i) => Container(
          width: 16, height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < wins ? color : Colors.white24,
            boxShadow: i < wins
                ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)]
                : null,
          ),
        )),
      ],
    );
  }
}

class _SumoArenaPainter extends CustomPainter {
  _SumoArenaPainter({
    required this.p1X, required this.p1Y,
    required this.p2X, required this.p2Y,
    required this.ballR, required this.platR,
  });
  final double p1X, p1Y, p2X, p2Y, ballR, platR;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final minDim = min(size.width, size.height);

    // Platform shadow
    canvas.drawCircle(
      Offset(cx + 4, cy + 6),
      minDim * platR,
      Paint()..color = Colors.black26,
    );

    // Platform gradient
    final platPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1A237E),
          const Color(0xFF0D47A1),
          const Color(0xFF01579B),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: minDim * platR));
    canvas.drawCircle(Offset(cx, cy), minDim * platR, platPaint);

    // Platform edge glow
    canvas.drawCircle(
      Offset(cx, cy),
      minDim * platR,
      Paint()
        ..color = Colors.cyanAccent.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Danger zone ring
    canvas.drawCircle(
      Offset(cx, cy),
      minDim * (platR - 0.05),
      Paint()
        ..color = Colors.red.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Player 1 ball
    _drawBall(canvas, size, p1X, p1Y, ballR,
        Colors.pinkAccent, Colors.pink.shade900);

    // Player 2 ball
    _drawBall(canvas, size, p2X, p2Y, ballR,
        Colors.blueAccent, Colors.blue.shade900);
  }

  void _drawBall(Canvas canvas, Size size, double x, double y,
      double r, Color main, Color dark) {
    final bx = x * size.width;
    final by = y * size.height;
    final br = r * min(size.width, size.height);

    // Shadow
    canvas.drawCircle(
      Offset(bx + 2, by + 3), br,
      Paint()..color = Colors.black38,
    );

    // Ball gradient
    final ballPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [main.withValues(alpha: 1.0), dark],
      ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: br));
    canvas.drawCircle(Offset(bx, by), br, ballPaint);

    // Highlight
    canvas.drawCircle(
      Offset(bx - br * 0.25, by - br * 0.25),
      br * 0.3,
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );

    // Glow
    canvas.drawCircle(
      Offset(bx, by), br + 4,
      Paint()
        ..color = main.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(covariant _SumoArenaPainter old) => true;
}

// ══════════════════════════════════════════════════
//  2. MINI POOL 🎱 — Touch billiards
// ══════════════════════════════════════════════════
class _MiniPoolGame extends StatefulWidget {
  const _MiniPoolGame({required this.onEnd});
  final Future<void> Function(int p1, int p2, {int bonus}) onEnd;

  @override
  State<_MiniPoolGame> createState() => _MiniPoolGameState();
}

class _MiniPoolGameState extends State<_MiniPoolGame> {
  static const int _totalBalls = 10;
  final _rng = Random();

  late List<_PoolBall> _balls;
  double _cueX = 0.5, _cueY = 0.75;
  double _cueVX = 0, _cueVY = 0;
  bool _aiming = false;
  Offset? _aimStart;
  Offset? _aimEnd;
  bool _isP1Turn = true;
  int _p1Pocketed = 0, _p2Pocketed = 0;
  Timer? _physTimer;
  bool _ballsMoving = false;

  // Pockets (corners + side centers) — normalized coords
  static const _pockets = [
    Offset(0.03, 0.03), Offset(0.97, 0.03),
    Offset(0.03, 0.97), Offset(0.97, 0.97),
    Offset(0.50, 0.02), Offset(0.50, 0.98),
  ];
  static const _pocketR = 0.035;
  static const _ballR = 0.022;

  @override
  void initState() {
    super.initState();
    _setupTable();
    _startPhysics();
  }

  void _setupTable() {
    _balls = [];
    // Triangle formation
    const startX = 0.5;
    const startY = 0.35;
    int idx = 0;
    final colors = [
      Colors.red, Colors.yellow, Colors.green, Colors.brown,
      Colors.orange, Colors.purple, Colors.teal, Colors.indigo,
      Colors.amber, Colors.cyan,
    ];
    for (int row = 0; row < 4 && idx < _totalBalls; row++) {
      for (int col = 0; col <= row && idx < _totalBalls; col++) {
        _balls.add(_PoolBall(
          x: startX + (col - row / 2.0) * 0.055,
          y: startY + row * 0.05,
          color: colors[idx % colors.length],
        ));
        idx++;
      }
    }
    _cueX = 0.5;
    _cueY = 0.75;
    _cueVX = 0;
    _cueVY = 0;
  }

  void _startPhysics() {
    _physTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      setState(() {
        _ballsMoving = false;

        // Update cue ball
        _cueX += _cueVX;
        _cueY += _cueVY;
        _cueVX *= 0.985;
        _cueVY *= 0.985;
        if (_cueVX.abs() > 0.0005 || _cueVY.abs() > 0.0005) _ballsMoving = true;

        // Wall bounce for cue
        if (_cueX < _ballR) { _cueX = _ballR; _cueVX = -_cueVX * 0.7; }
        if (_cueX > 1 - _ballR) { _cueX = 1 - _ballR; _cueVX = -_cueVX * 0.7; }
        if (_cueY < _ballR) { _cueY = _ballR; _cueVY = -_cueVY * 0.7; }
        if (_cueY > 1 - _ballR) { _cueY = 1 - _ballR; _cueVY = -_cueVY * 0.7; }

        // Update balls
        for (final b in _balls) {
          if (b.pocketed) continue;
          b.x += b.vx;
          b.y += b.vy;
          b.vx *= 0.985;
          b.vy *= 0.985;
          if (b.vx.abs() > 0.0005 || b.vy.abs() > 0.0005) _ballsMoving = true;

          // Wall bounce
          if (b.x < _ballR) { b.x = _ballR; b.vx = -b.vx * 0.7; }
          if (b.x > 1 - _ballR) { b.x = 1 - _ballR; b.vx = -b.vx * 0.7; }
          if (b.y < _ballR) { b.y = _ballR; b.vy = -b.vy * 0.7; }
          if (b.y > 1 - _ballR) { b.y = 1 - _ballR; b.vy = -b.vy * 0.7; }

          // Ball-to-cue collision
          final dx = b.x - _cueX;
          final dy = b.y - _cueY;
          final dist = sqrt(dx * dx + dy * dy);
          if (dist < _ballR * 2 && dist > 0) {
            final nx = dx / dist;
            final ny = dy / dist;
            final relV = (_cueVX - b.vx) * nx + (_cueVY - b.vy) * ny;
            if (relV > 0) {
              _cueVX -= relV * nx * 0.5;
              _cueVY -= relV * ny * 0.5;
              b.vx += relV * nx * 0.5;
              b.vy += relV * ny * 0.5;
              HapticFeedback.lightImpact();
            }
            final overlap = _ballR * 2 - dist;
            b.x += nx * overlap * 0.5;
            b.y += ny * overlap * 0.5;
            _cueX -= nx * overlap * 0.5;
            _cueY -= ny * overlap * 0.5;
          }

          // Ball-to-ball collision
          for (final other in _balls) {
            if (other == b || other.pocketed) continue;
            final odx = other.x - b.x;
            final ody = other.y - b.y;
            final odist = sqrt(odx * odx + ody * ody);
            if (odist < _ballR * 2 && odist > 0) {
              final onx = odx / odist;
              final ony = ody / odist;
              final rv = (b.vx - other.vx) * onx + (b.vy - other.vy) * ony;
              if (rv > 0) {
                b.vx -= rv * onx * 0.5;
                b.vy -= rv * ony * 0.5;
                other.vx += rv * onx * 0.5;
                other.vy += rv * ony * 0.5;
              }
              final ovl = _ballR * 2 - odist;
              b.x -= onx * ovl * 0.5;
              b.y -= ony * ovl * 0.5;
              other.x += onx * ovl * 0.5;
              other.y += ony * ovl * 0.5;
            }
          }

          // Pocket check
          for (final p in _pockets) {
            final pd = sqrt((b.x - p.dx) * (b.x - p.dx) + (b.y - p.dy) * (b.y - p.dy));
            if (pd < _pocketR) {
              b.pocketed = true;
              b.vx = 0; b.vy = 0;
              if (_isP1Turn) {
                _p1Pocketed++;
              } else {
                _p2Pocketed++;
              }
              HapticFeedback.heavyImpact();
              break;
            }
          }
        }

        // Cue pocket check (scratch)
        for (final p in _pockets) {
          final pd = sqrt((_cueX - p.dx) * (_cueX - p.dx) + (_cueY - p.dy) * (_cueY - p.dy));
          if (pd < _pocketR) {
            // Reset cue ball
            _cueX = 0.5; _cueY = 0.75;
            _cueVX = 0; _cueVY = 0;
            _isP1Turn = !_isP1Turn;
            break;
          }
        }

        // Check game end
        if (_balls.every((b) => b.pocketed)) {
          _physTimer?.cancel();
          widget.onEnd(_p1Pocketed * 10, _p2Pocketed * 10, bonus: 15);
        }

        // Turn switch after balls stop
        if (!_ballsMoving && (_cueVX.abs() < 0.0002 && _cueVY.abs() < 0.0002)) {
          _cueVX = 0; _cueVY = 0;
        }
      });
    });
  }

  void _onPanStart(DragStartDetails d, Size size) {
    if (_ballsMoving) return;
    final lx = d.localPosition.dx / size.width;
    final ly = d.localPosition.dy / size.height;
    final dist = sqrt((lx - _cueX) * (lx - _cueX) + (ly - _cueY) * (ly - _cueY));
    if (dist < 0.08) {
      _aiming = true;
      _aimStart = d.localPosition;
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!_aiming) return;
    setState(() => _aimEnd = d.localPosition);
  }

  void _onPanEnd(DragEndDetails d, Size size) {
    if (!_aiming || _aimStart == null || _aimEnd == null) {
      _aiming = false;
      return;
    }
    // Direction: from aimEnd towards aimStart (pull back to shoot)
    final dx = (_aimStart!.dx - _aimEnd!.dx) / size.width;
    final dy = (_aimStart!.dy - _aimEnd!.dy) / size.height;
    final power = sqrt(dx * dx + dy * dy).clamp(0.0, 0.05);
    setState(() {
      _cueVX = dx * 0.4;
      _cueVY = dy * 0.4;
      _aiming = false;
      _aimStart = null;
      _aimEnd = null;
      // Switch turn when ball stops (handled in physics loop)
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_ballsMoving) {
          setState(() => _isP1Turn = !_isP1Turn);
        }
      });
    });
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _physTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1B3A26),
      appBar: AppBar(
        title: Text('${l.tr('Mini Pool', 'Mini Bilardo')} 🎱'),
        backgroundColor: const Color(0xFF0D2818),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Score
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PoolPlayerInfo(
                    label: '👩', pocketed: _p1Pocketed,
                    isActive: _isP1Turn, color: Colors.pinkAccent,
                  ),
                  Text(
                    _isP1Turn
                        ? l.tr('👩 Turn', '👩 Sira')
                        : l.tr('👨 Turn', '👨 Sira'),
                    style: const TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.w600),
                  ),
                  _PoolPlayerInfo(
                    label: '👨', pocketed: _p2Pocketed,
                    isActive: !_isP1Turn, color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
            // Table
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(constraints.maxWidth, constraints.maxHeight);
                    return GestureDetector(
                      onPanStart: (d) => _onPanStart(d, size),
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: (d) => _onPanEnd(d, size),
                      child: CustomPaint(
                        size: size,
                        painter: _PoolTablePainter(
                          balls: _balls,
                          cueX: _cueX, cueY: _cueY,
                          ballR: _ballR, pocketR: _pocketR,
                          pockets: _pockets,
                          aimStart: _aiming ? _aimStart : null,
                          aimEnd: _aiming ? _aimEnd : null,
                          tableSize: size,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l.tr('Drag back from cue ball to aim & shoot!',
                    'Beyaz toptan geriye cekerek nisan al ve vur!'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PoolBall {
  _PoolBall({required this.x, required this.y, required this.color});
  double x, y;
  double vx = 0, vy = 0;
  final Color color;
  bool pocketed = false;
}

class _PoolPlayerInfo extends StatelessWidget {
  const _PoolPlayerInfo({
    required this.label, required this.pocketed,
    required this.isActive, required this.color,
  });
  final String label;
  final int pocketed;
  final bool isActive;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 300.ms,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? color : Colors.transparent, width: 2),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 24)),
          const Gap(8),
          Text('$pocketed', style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800,
          )),
        ],
      ),
    );
  }
}

class _PoolTablePainter extends CustomPainter {
  _PoolTablePainter({
    required this.balls, required this.cueX, required this.cueY,
    required this.ballR, required this.pocketR, required this.pockets,
    this.aimStart, this.aimEnd, required this.tableSize,
  });
  final List<_PoolBall> balls;
  final double cueX, cueY, ballR, pocketR;
  final List<Offset> pockets;
  final Offset? aimStart, aimEnd;
  final Size tableSize;

  @override
  void paint(Canvas canvas, Size size) {
    // Table surface
    final tableRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(tableRect, const Radius.circular(12)),
      Paint()..color = const Color(0xFF2E7D32),
    );
    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(tableRect, const Radius.circular(12)),
      Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // Pockets
    for (final p in pockets) {
      canvas.drawCircle(
        Offset(p.dx * size.width, p.dy * size.height),
        pocketR * min(size.width, size.height),
        Paint()..color = Colors.black87,
      );
    }

    // Balls
    for (final b in balls) {
      if (b.pocketed) continue;
      final bx = b.x * size.width;
      final by = b.y * size.height;
      final br = ballR * min(size.width, size.height);
      // Shadow
      canvas.drawCircle(Offset(bx + 1, by + 2), br, Paint()..color = Colors.black26);
      // Ball
      canvas.drawCircle(Offset(bx, by), br, Paint()..color = b.color);
      // Highlight
      canvas.drawCircle(Offset(bx - br * 0.2, by - br * 0.2), br * 0.3,
          Paint()..color = Colors.white.withValues(alpha: 0.4));
    }

    // Cue ball
    final cx = cueX * size.width;
    final cy = cueY * size.height;
    final cr = ballR * min(size.width, size.height);
    canvas.drawCircle(Offset(cx + 1, cy + 2), cr, Paint()..color = Colors.black26);
    canvas.drawCircle(Offset(cx, cy), cr, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx, cy), cr,
        Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 1);

    // Aim line
    if (aimStart != null && aimEnd != null) {
      final dx = aimStart!.dx - aimEnd!.dx;
      final dy = aimStart!.dy - aimEnd!.dy;
      final len = sqrt(dx * dx + dy * dy);
      if (len > 5) {
        final nx = dx / len;
        final ny = dy / len;
        // Draw dotted aim line
        final linePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..strokeWidth = 2;
        canvas.drawLine(
          Offset(cx, cy),
          Offset(cx + nx * min(len, 200), cy + ny * min(len, 200)),
          linePaint,
        );
        // Power indicator
        final power = (len / 200).clamp(0.0, 1.0);
        canvas.drawCircle(
          Offset(cx, cy), cr + 4,
          Paint()
            ..color = Color.lerp(Colors.green, Colors.red, power)!.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PoolTablePainter old) => true;
}

// ══════════════════════════════════════════════════
//  3. CAR RACE 🏎️ — Tap to accelerate
// ══════════════════════════════════════════════════
class _CarRaceGame extends StatefulWidget {
  const _CarRaceGame({required this.onEnd});
  final Future<void> Function(int p1, int p2, {int bonus}) onEnd;

  @override
  State<_CarRaceGame> createState() => _CarRaceGameState();
}

class _CarRaceGameState extends State<_CarRaceGame> {
  double _p1Pos = 0, _p2Pos = 0; // 0..1 progress
  double _p1Speed = 0, _p2Speed = 0;
  bool _countdown = true;
  int _countVal = 3;
  bool _racing = false;
  bool _finished = false;
  Timer? _gameTimer;
  final _rng = Random();

  // Track obstacles
  late List<double> _obstacles;

  @override
  void initState() {
    super.initState();
    _obstacles = List.generate(5, (i) => 0.15 + i * 0.18 + _rng.nextDouble() * 0.05);
    _startCountdown();
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_countVal <= 1) {
        t.cancel();
        setState(() {
          _countdown = false;
          _racing = true;
        });
        _startRace();
      } else {
        setState(() => _countVal--);
        HapticFeedback.lightImpact();
      }
    });
  }

  void _startRace() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || _finished) return;
      setState(() {
        // Apply deceleration
        _p1Speed *= 0.995;
        _p2Speed *= 0.995;
        _p1Pos += _p1Speed;
        _p2Pos += _p2Speed;

        // Check finish
        if (_p1Pos >= 1.0 || _p2Pos >= 1.0) {
          _finished = true;
          _gameTimer?.cancel();
          final p1Pts = _p1Pos >= 1.0 ? 30 : 10;
          final p2Pts = _p2Pos >= 1.0 ? 30 : 10;
          widget.onEnd(p1Pts, p2Pts, bonus: 10);
        }
      });
    });
  }

  void _tapP1() {
    if (!_racing || _finished) return;
    HapticFeedback.lightImpact();
    setState(() => _p1Speed += 0.003 + _rng.nextDouble() * 0.001);
  }

  void _tapP2() {
    if (!_racing || _finished) return;
    HapticFeedback.lightImpact();
    setState(() => _p2Speed += 0.003 + _rng.nextDouble() * 0.001);
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF263238),
      appBar: AppBar(
        title: Text('${l.tr('Car Race', 'Araba Yarisi')} 🏎️'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_countdown)
              Expanded(
                child: Center(
                  child: Text('$_countVal',
                          style: const TextStyle(
                              fontSize: 100,
                              fontWeight: FontWeight.w900,
                              color: Colors.white))
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(duration: 500.ms),
                ),
              )
            else ...[
              const Gap(8),
              // Race track visualization
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomPaint(
                    painter: _RaceTrackPainter(
                      p1Pos: _p1Pos.clamp(0.0, 1.0),
                      p2Pos: _p2Pos.clamp(0.0, 1.0),
                      obstacles: _obstacles,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              // Control buttons
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    // P1 button
                    Expanded(
                      child: GestureDetector(
                        onTapDown: (_) => _tapP1(),
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.pink.shade400, Colors.pink.shade800],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pink.withValues(alpha: 0.4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🏎️', style: TextStyle(fontSize: 40)),
                              const Gap(8),
                              Text(l.tr('👩 TAP!', '👩 BAS!'),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800)),
                              Text('${(_p1Pos * 100).toInt()}%',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // P2 button
                    Expanded(
                      child: GestureDetector(
                        onTapDown: (_) => _tapP2(),
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade400, Colors.blue.shade800],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🏎️', style: TextStyle(fontSize: 40)),
                              const Gap(8),
                              Text(l.tr('👨 TAP!', '👨 BAS!'),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800)),
                              Text('${(_p2Pos * 100).toInt()}%',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RaceTrackPainter extends CustomPainter {
  _RaceTrackPainter({
    required this.p1Pos, required this.p2Pos, required this.obstacles,
  });
  final double p1Pos, p2Pos;
  final List<double> obstacles;

  @override
  void paint(Canvas canvas, Size size) {
    final laneH = size.height;
    final laneW = size.width;
    final lane1Y = laneH * 0.35;
    final lane2Y = laneH * 0.65;and 

    // Road
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, laneH * 0.15, laneW, laneH * 0.7),
        const Radius.circular(16),
      ),
      Paint()..color = const Color(0xFF424242),
    );

    // Center line
    for (double x = 0; x < laneW; x += 30) {
      canvas.drawRect(
        Rect.fromLTWH(x, laneH * 0.49, 15, 3),
        Paint()..color = Colors.yellow.withValues(alpha: 0.5),
      );
    }

    // Finish line
    canvas.drawRect(
      Rect.fromLTWH(laneW - 10, laneH * 0.15, 10, laneH * 0.7),
      Paint()..color = Colors.white,
    );
    for (int i = 0; i < 8; i++) {
      canvas.drawRect(
        Rect.fromLTWH(laneW - 10, laneH * 0.15 + i * laneH * 0.7 / 8,
            5, laneH * 0.7 / 16),
        Paint()..color = Colors.black,
      );
    }

    // Cars
    _drawCar(canvas, p1Pos * (laneW - 50) + 10, lane1Y, Colors.pinkAccent, size);
    _drawCar(canvas, p2Pos * (laneW - 50) + 10, lane2Y, Colors.blueAccent, size);
  }

  void _drawCar(Canvas canvas, double x, double y, Color color, Size size) {
    // Car body
    final carRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, y), width: 40, height: 20),
      const Radius.circular(6),
    );
    canvas.drawRRect(carRect, Paint()..color = color);
    // Windshield
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x + 8, y), width: 12, height: 14),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
    // Glow
    canvas.drawCircle(
      Offset(x, y), 25,
      Paint()
        ..color = color.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  @override
  bool shouldRepaint(covariant _RaceTrackPainter old) =>
      old.p1Pos != p1Pos || old.p2Pos != p2Pos;
}

// ══════════════════════════════════════════════════
//  4. LASER DODGE ⚡ — Survive the beams
// ══════════════════════════════════════════════════
class _LaserDodgeGame extends StatefulWidget {
  const _LaserDodgeGame({required this.onEnd});
  final Future<void> Function(int p1, int p2, {int bonus}) onEnd;

  @override
  State<_LaserDodgeGame> createState() => _LaserDodgeGameState();
}

class _LaserDodgeGameState extends State<_LaserDodgeGame> {
  double _p1X = 0.3, _p1Y = 0.5;
  double _p2X = 0.7, _p2Y = 0.5;
  bool _p1Alive = true, _p2Alive = true;
  int _survivalTime = 0;
  Timer? _gameTimer;
  Timer? _laserTimer;
  final _rng = Random();
  final List<_Laser> _lasers = [];
  bool _countdown = true;
  int _countVal = 3;
  int? _dragging; // 1 or 2

  static const _playerR = 0.03;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_countVal <= 1) {
        t.cancel();
        setState(() => _countdown = false);
        _startGame();
      } else {
        setState(() => _countVal--);
      }
    });
  }

  void _startGame() {
    // Spawn lasers periodically
    _laserTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (!mounted) return;
      _spawnLaser();
      // Increase difficulty
      if (_survivalTime > 10 && _survivalTime % 5 == 0) {
        _spawnLaser();
      }
    });

    // Physics & collision
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      setState(() {
        _survivalTime = DateTime.now().difference(_startTime!).inSeconds;

        // Move lasers
        for (final laser in _lasers) {
          laser.progress += laser.speed;
        }
        _lasers.removeWhere((l) => l.progress > 1.5);

        // Check collisions
        for (final laser in _lasers) {
          if (_p1Alive && _laserHitsPlayer(laser, _p1X, _p1Y)) {
            _p1Alive = false;
            HapticFeedback.heavyImpact();
          }
          if (_p2Alive && _laserHitsPlayer(laser, _p2X, _p2Y)) {
            _p2Alive = false;
            HapticFeedback.heavyImpact();
          }
        }

        if (!_p1Alive && !_p2Alive) {
          _gameTimer?.cancel();
          _laserTimer?.cancel();
          widget.onEnd(_p1Alive ? _survivalTime * 3 : _survivalTime,
              _p2Alive ? _survivalTime * 3 : _survivalTime, bonus: _survivalTime);
        } else if (!_p1Alive || !_p2Alive) {
          // One player dead — other survives for bonus
          if (_survivalTime > 30) {
            _gameTimer?.cancel();
            _laserTimer?.cancel();
            widget.onEnd(
                _p1Alive ? _survivalTime * 3 : 5,
                _p2Alive ? _survivalTime * 3 : 5,
                bonus: 15);
          }
        }
      });
    });
    _startTime = DateTime.now();
  }

  DateTime? _startTime;

  void _spawnLaser() {
    final type = _rng.nextInt(4); // 0=top,1=bottom,2=left,3=right
    double fromX, fromY, toX, toY;
    switch (type) {
      case 0: // top to bottom
        fromX = _rng.nextDouble();
        fromY = -0.05;
        toX = fromX + (_rng.nextDouble() - 0.5) * 0.3;
        toY = 1.05;
        break;
      case 1: // bottom to top
        fromX = _rng.nextDouble();
        fromY = 1.05;
        toX = fromX + (_rng.nextDouble() - 0.5) * 0.3;
        toY = -0.05;
        break;
      case 2: // left to right
        fromX = -0.05;
        fromY = _rng.nextDouble();
        toX = 1.05;
        toY = fromY + (_rng.nextDouble() - 0.5) * 0.3;
        break;
      default: // right to left
        fromX = 1.05;
        fromY = _rng.nextDouble();
        toX = -0.05;
        toY = fromY + (_rng.nextDouble() - 0.5) * 0.3;
    }
    final colors = [Colors.red, Colors.cyanAccent, Colors.greenAccent, Colors.amber];
    setState(() {
      _lasers.add(_Laser(
          fromX: fromX, fromY: fromY, toX: toX, toY: toY,
          speed: 0.008 + _rng.nextDouble() * 0.004,
          color: colors[_rng.nextInt(colors.length)]));
    });
  }

  bool _laserHitsPlayer(_Laser laser, double px, double py) {
    // Point on laser line at current progress
    final lx = laser.fromX + (laser.toX - laser.fromX) * laser.progress;
    final ly = laser.fromY + (laser.toY - laser.fromY) * laser.progress;
    // Check distance to player center
    final dx = lx - px;
    final dy = ly - py;
    return sqrt(dx * dx + dy * dy) < _playerR + 0.015;
  }

  void _onDragStart(DragStartDetails d, Size size) {
    if (_countdown) return;
    final lx = d.localPosition.dx / size.width;
    final ly = d.localPosition.dy / size.height;
    final d1 = sqrt((lx - _p1X) * (lx - _p1X) + (ly - _p1Y) * (ly - _p1Y));
    final d2 = sqrt((lx - _p2X) * (lx - _p2X) + (ly - _p2Y) * (ly - _p2Y));
    if (d1 < 0.08 && _p1Alive) _dragging = 1;
    else if (d2 < 0.08 && _p2Alive) _dragging = 2;
  }

  void _onDragUpdate(DragUpdateDetails d, Size size) {
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

  void _onDragEnd(DragEndDetails d) => _dragging = null;

  @override
  void dispose() {
    _gameTimer?.cancel();
    _laserTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        title: Text('${l.tr('Laser Dodge', 'Lazer Kacis')} ⚡'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('⏱️ $_survivalTime',
                  style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    _p1Alive ? '👩 ❤️' : '👩 💀',
                    style: const TextStyle(fontSize: 24),
                  ),
                  Text(
                    _p2Alive ? '👨 ❤️' : '👨 💀',
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(constraints.maxWidth, constraints.maxHeight);
                    return GestureDetector(
                      onPanStart: (d) => _onDragStart(d, size),
                      onPanUpdate: (d) => _onDragUpdate(d, size),
                      onPanEnd: _onDragEnd,
                      child: CustomPaint(
                        size: size,
                        painter: _LaserArenaPainter(
                          p1X: _p1X, p1Y: _p1Y, p1Alive: _p1Alive,
                          p2X: _p2X, p2Y: _p2Y, p2Alive: _p2Alive,
                          lasers: _lasers, playerR: _playerR,
                        ),
                        child: _countdown
                            ? Center(
                                child: Text('$_countVal',
                                        style: const TextStyle(
                                            fontSize: 80,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.cyanAccent))
                                    .animate(onPlay: (c) => c.repeat(reverse: true))
                                    .scale(duration: 500.ms),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l.tr('Drag your circle to dodge lasers!',
                    'Daireni surukleyerek lazerlerden kac!'),
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Laser {
  _Laser({
    required this.fromX, required this.fromY,
    required this.toX, required this.toY,
    required this.speed, required this.color,
  });
  final double fromX, fromY, toX, toY, speed;
  final Color color;
  double progress = 0;
}

class _LaserArenaPainter extends CustomPainter {
  _LaserArenaPainter({
    required this.p1X, required this.p1Y, required this.p1Alive,
    required this.p2X, required this.p2Y, required this.p2Alive,
    required this.lasers, required this.playerR,
  });
  final double p1X, p1Y, p2X, p2Y, playerR;
  final bool p1Alive, p2Alive;
  final List<_Laser> lasers;

  @override
  void paint(Canvas canvas, Size size) {
    // Grid background
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Lasers
    for (final laser in lasers) {
      final lx = laser.fromX + (laser.toX - laser.fromX) * laser.progress;
      final ly = laser.fromY + (laser.toY - laser.fromY) * laser.progress;
      final x = lx * size.width;
      final y = ly * size.height;

      // Beam glow
      canvas.drawCircle(
        Offset(x, y), 15,
        Paint()
          ..color = laser.color.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      // Beam core
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = laser.color);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);

      // Trail
      final tx = laser.fromX + (laser.toX - laser.fromX) * (laser.progress - 0.05);
      final ty = laser.fromY + (laser.toY - laser.fromY) * (laser.progress - 0.05);
      canvas.drawLine(
        Offset(tx * size.width, ty * size.height),
        Offset(x, y),
        Paint()
          ..color = laser.color.withValues(alpha: 0.4)
          ..strokeWidth = 2,
      );
    }

    // Players
    if (p1Alive) _drawPlayer(canvas, size, p1X, p1Y, Colors.pinkAccent);
    if (p2Alive) _drawPlayer(canvas, size, p2X, p2Y, Colors.blueAccent);
  }

  void _drawPlayer(Canvas canvas, Size size, double x, double y, Color color) {
    final px = x * size.width;
    final py = y * size.height;
    final pr = playerR * min(size.width, size.height);

    // Outer glow
    canvas.drawCircle(
      Offset(px, py), pr + 8,
      Paint()
        ..color = color.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    // Ring
    canvas.drawCircle(
      Offset(px, py), pr,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    // Core
    canvas.drawCircle(
      Offset(px, py), pr * 0.5,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _LaserArenaPainter old) => true;
}

// ══════════════════════════════════════════════════
//  5. ICE PLATFORM 🧊 — Shrinking island survival
// ══════════════════════════════════════════════════
class _IcePlatformGame extends StatefulWidget {
  const _IcePlatformGame({required this.onEnd});
  final Future<void> Function(int p1, int p2, {int bonus}) onEnd;

  @override
  State<_IcePlatformGame> createState() => _IcePlatformGameState();
}

class _IcePlatformGameState extends State<_IcePlatformGame> {
  double _p1X = 0.35, _p1Y = 0.45;
  double _p2X = 0.65, _p2Y = 0.55;
  double _p1VX = 0, _p1VY = 0;
  double _p2VX = 0, _p2VY = 0;
  double _platformR = 0.42; // Shrinks over time
  static const _ballR = 0.04;
  static const _cx = 0.5, _cy = 0.5;

  int _p1Wins = 0, _p2Wins = 0;
  int _roundNum = 0;
  bool _roundOver = false;
  String _roundText = '';
  Timer? _physicsTimer;
  Timer? _shrinkTimer;
  bool _countdown = true;
  int _countVal = 3;
  int? _dragging;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdown = true;
    _countVal = 3;
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_countVal <= 1) {
        t.cancel();
        setState(() => _countdown = false);
        _startPhysics();
        _startShrink();
      } else {
        setState(() => _countVal--);
      }
    });
  }

  void _startShrink() {
    _shrinkTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || _roundOver) return;
      setState(() {
        _platformR -= 0.0003; // Slow shrink
        if (_platformR < 0.1) _platformR = 0.1;
      });
    });
  }

  void _startPhysics() {
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || _roundOver) return;
      setState(() {
        // Ice friction (very slippery!)
        _p1VX *= 0.99; _p1VY *= 0.99;
        _p2VX *= 0.99; _p2VY *= 0.99;
        _p1X += _p1VX; _p1Y += _p1VY;
        _p2X += _p2VX; _p2Y += _p2VY;

        // Ball collision
        final dx = _p2X - _p1X;
        final dy = _p2Y - _p1Y;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist < _ballR * 2 && dist > 0) {
          final nx = dx / dist;
          final ny = dy / dist;
          final overlap = _ballR * 2 - dist;
          _p1X -= nx * overlap * 0.5;
          _p1Y -= ny * overlap * 0.5;
          _p2X += nx * overlap * 0.5;
          _p2Y += ny * overlap * 0.5;
          final relV = (_p1VX - _p2VX) * nx + (_p1VY - _p2VY) * ny;
          if (relV > 0) {
            _p1VX -= relV * nx * 0.9;
            _p1VY -= relV * ny * 0.9;
            _p2VX += relV * nx * 0.9;
            _p2VY += relV * ny * 0.9;
            HapticFeedback.mediumImpact();
          }
        }

        // Out-of-bounds
        final p1D = sqrt((_p1X - _cx) * (_p1X - _cx) + (_p1Y - _cy) * (_p1Y - _cy));
        final p2D = sqrt((_p2X - _cx) * (_p2X - _cx) + (_p2Y - _cy) * (_p2Y - _cy));

        if (p1D > _platformR) {
          _roundOver = true;
          _p2Wins++;
          _roundText = l.tr('👨 P2 survives!', '👨 O2 hayatta kaldi!');
          HapticFeedback.heavyImpact();
          _nextRound();
        } else if (p2D > _platformR) {
          _roundOver = true;
          _p1Wins++;
          _roundText = l.tr('👩 P1 survives!', '👩 O1 hayatta kaldi!');
          HapticFeedback.heavyImpact();
          _nextRound();
        }
      });
    });
  }

  void _nextRound() async {
    _physicsTimer?.cancel();
    _shrinkTimer?.cancel();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (_p1Wins >= 3 || _p2Wins >= 3) {
      widget.onEnd(_p1Wins * 15, _p2Wins * 15, bonus: 10);
    } else {
      setState(() {
        _roundNum++;
        _roundOver = false;
        _roundText = '';
        _platformR = 0.42;
        _p1X = 0.35; _p1Y = 0.45;
        _p2X = 0.65; _p2Y = 0.55;
        _p1VX = 0; _p1VY = 0;
        _p2VX = 0; _p2VY = 0;
      });
      _startCountdown();
    }
  }

  void _onDragStart(DragStartDetails d, Size size) {
    if (_countdown || _roundOver) return;
    final lx = d.localPosition.dx / size.width;
    final ly = d.localPosition.dy / size.height;
    final d1 = sqrt((lx - _p1X) * (lx - _p1X) + (ly - _p1Y) * (ly - _p1Y));
    final d2 = sqrt((lx - _p2X) * (lx - _p2X) + (ly - _p2Y) * (ly - _p2Y));
    if (d1 < _ballR * 3) _dragging = 1;
    else if (d2 < _ballR * 3) _dragging = 2;
  }

  void _onDragUpdate(DragUpdateDetails d, Size size) {
    if (_dragging == null) return;
    final dx = d.delta.dx / size.width * 0.12;
    final dy = d.delta.dy / size.height * 0.12;
    setState(() {
      if (_dragging == 1) {
        _p1VX += dx; _p1VY += dy;
      } else {
        _p2VX += dx; _p2VY += dy;
      }
    });
  }

  void _onDragEnd(DragEndDetails d) => _dragging = null;

  @override
  void dispose() {
    _physicsTimer?.cancel();
    _shrinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F3C),
      appBar: AppBar(
        title: Text('${l.tr('Ice Platform', 'Buz Platformu')} 🧊 — '
            '${l.tr('Round', 'Tur')} ${_roundNum + 1}'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SumoScore(label: '👩', wins: _p1Wins, color: Colors.pinkAccent),
                  Text(l.tr('Best of 5', '5in En Iyisi'),
                      style: const TextStyle(color: Colors.white54)),
                  _SumoScore(label: '👨', wins: _p2Wins, color: Colors.blueAccent),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(constraints.maxWidth, constraints.maxHeight);
                    return GestureDetector(
                      onPanStart: (d) => _onDragStart(d, size),
                      onPanUpdate: (d) => _onDragUpdate(d, size),
                      onPanEnd: _onDragEnd,
                      child: CustomPaint(
                        size: size,
                        painter: _IcePlatformPainter(
                          p1X: _p1X, p1Y: _p1Y,
                          p2X: _p2X, p2Y: _p2Y,
                          ballR: _ballR, platformR: _platformR,
                        ),
                        child: _countdown
                            ? Center(
                                child: Text('$_countVal',
                                        style: const TextStyle(
                                            fontSize: 80,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.cyanAccent))
                                    .animate(onPlay: (c) => c.repeat(reverse: true))
                                    .scale(duration: 500.ms),
                              )
                            : _roundOver
                                ? Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(_roundText,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800)),
                                    ).animate().scale(
                                        duration: 400.ms,
                                        curve: Curves.elasticOut),
                                  )
                                : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Shrink warning
                  LinearProgressIndicator(
                    value: _platformR / 0.42,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(
                      Color.lerp(Colors.red, Colors.cyanAccent, _platformR / 0.42)!,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    l.tr('⚠️ Platform is shrinking! Push opponent off!',
                        '⚠️ Platform kuculuyor! Rakibini dusur!'),
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
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

class _IcePlatformPainter extends CustomPainter {
  _IcePlatformPainter({
    required this.p1X, required this.p1Y,
    required this.p2X, required this.p2Y,
    required this.ballR, required this.platformR,
  });
  final double p1X, p1Y, p2X, p2Y, ballR, platformR;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final minDim = min(size.width, size.height);

    // Water background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0A1628),
    );

    // Platform shadow
    canvas.drawCircle(
      Offset(cx + 3, cy + 5),
      minDim * platformR,
      Paint()..color = Colors.black26,
    );

    // Ice platform (gradient)
    final icePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE0F7FA),
          const Color(0xFF80DEEA),
          const Color(0xFF26C6DA),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: minDim * platformR));
    canvas.drawCircle(Offset(cx, cy), minDim * platformR, icePaint);

    // Ice cracks
    final crackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 6; i++) {
      final angle = i * 3.14159 / 3;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + cos(angle) * minDim * platformR * 0.8,
            cy + sin(angle) * minDim * platformR * 0.8),
        crackPaint,
      );
    }

    // Edge glow (warning)
    final danger = 1.0 - (platformR / 0.42);
    canvas.drawCircle(
      Offset(cx, cy),
      minDim * platformR,
      Paint()
        ..color = Color.lerp(Colors.cyanAccent, Colors.red, danger)!.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Snow particles
    final rng = Random(42);
    for (int i = 0; i < 20; i++) {
      final sx = rng.nextDouble() * size.width;
      final sy = rng.nextDouble() * size.height;
      canvas.drawCircle(
        Offset(sx, sy), 1.5,
        Paint()..color = Colors.white.withValues(alpha: 0.2),
      );
    }

    // Players
    _drawIceBall(canvas, size, p1X, p1Y, ballR, Colors.pinkAccent);
    _drawIceBall(canvas, size, p2X, p2Y, ballR, Colors.blueAccent);
  }

  void _drawIceBall(Canvas canvas, Size size, double x, double y,
      double r, Color color) {
    final bx = x * size.width;
    final by = y * size.height;
    final br = r * min(size.width, size.height);

    // Shadow on ice
    canvas.drawOval(
      Rect.fromCenter(center: Offset(bx, by + br * 0.5), width: br * 2, height: br * 0.6),
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );

    // Ball
    final ballPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: [color.withValues(alpha: 1.0), color.withValues(alpha: 0.6)],
      ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: br));
    canvas.drawCircle(Offset(bx, by), br, ballPaint);

    // Highlight
    canvas.drawCircle(
      Offset(bx - br * 0.3, by - br * 0.3), br * 0.25,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );

    // Ring
    canvas.drawCircle(
      Offset(bx, by), br + 2,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _IcePlatformPainter old) => true;
}
