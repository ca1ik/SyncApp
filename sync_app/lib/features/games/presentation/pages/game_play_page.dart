import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../../core/di/injection.dart';
import '../../../../data/models/game_model.dart';
import '../../../../data/repositories/games_repository.dart';
import '../../../../core/services/locale_service.dart';

class GamePlayPage extends StatefulWidget {
  const GamePlayPage({super.key, required this.gameType});
  final CoupleGameType gameType;

  @override
  State<GamePlayPage> createState() => _GamePlayPageState();
}

class _GamePlayPageState extends State<GamePlayPage> {
  late final GamesRepository _repo;
  int _p1Score = 0;
  int _p2Score = 0;
  int _round = 0;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _repo = getIt<GamesRepository>();
  }

  Future<void> _endGame({int bonus = 0}) async {
    setState(() => _gameOver = true);
    HapticFeedback.heavyImpact();
    await _repo.saveScore(GameScore(
      gameType: widget.gameType,
      player1Score: _p1Score,
      player2Score: _p2Score,
      playedAt: DateTime.now(),
      bonusPoints: bonus,
    ));
  }

  void _addP1P2(int p1, int p2) {
    _p1Score += p1;
    _p2Score += p2;
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) return _GameOverScreen(p1: _p1Score, p2: _p2Score);

    final type = widget.gameType;
    if (type == CoupleGameType.countTrap) {
      return _CountTrapGame(onScore: _addP1P2, onEnd: _endGame);
    }
    if (type == CoupleGameType.truthOrDare) {
      return _TruthOrDareGame(
        repo: _repo,
        round: _round,
        onNext: () => setState(() => _round++),
        onEnd: () {
          _p1Score = _round * 5;
          _p2Score = _round * 5;
          _endGame();
        },
      );
    }
    if (type == CoupleGameType.wouldYouRather) {
      return _WouldYouRatherGame(
        repo: _repo,
        round: _round,
        onNext: () => setState(() => _round++),
        onEnd: () {
          _p1Score = _round * 8;
          _p2Score = _round * 8;
          _endGame();
        },
      );
    }
    if (type == CoupleGameType.knowMeQuiz) {
      return _KnowMeQuizGame(
        repo: _repo,
        round: _round,
        onScore: (correct) {
          _p1Score += correct ? 15 : 0;
          _p2Score += correct ? 15 : 0;
          _round++;
        },
        onEnd: () => _endGame(bonus: _round > 5 ? 20 : 0),
      );
    }
    if (type == CoupleGameType.tripMeter) {
      return _TripMeterGame(
        repo: _repo,
        round: _round,
        onScore: (level) {
          _p1Score += level * 3;
          _p2Score += level * 3;
          _round++;
        },
        onEnd: () => _endGame(),
      );
    }
    if (type == CoupleGameType.finishSentence) {
      return _FinishSentenceGame(
        repo: _repo,
        round: _round,
        onNext: (pts) {
          _p1Score += pts;
          _p2Score += pts;
          setState(() => _round++);
        },
        onEnd: () => _endGame(),
      );
    }
    if (type == CoupleGameType.emojiGuess) {
      return _EmojiGuessGame(
        repo: _repo,
        round: _round,
        onNext: (pts) {
          _p1Score += pts;
          _p2Score += pts;
          setState(() => _round++);
        },
        onEnd: () => _endGame(),
      );
    }
    if (type == CoupleGameType.loveMap) {
      return _LoveMapGame(onEnd: () {
        _p1Score = 25;
        _p2Score = 25;
        _endGame(bonus: 10);
      });
    }
    if (type == CoupleGameType.secretMessage) {
      return _SecretMessageGame(onEnd: () {
        _p1Score = 20;
        _p2Score = 20;
        _endGame();
      });
    }
    return _CompatibilityGame(
      repo: _repo,
      onEnd: (matchPct) {
        _p1Score = matchPct;
        _p2Score = matchPct;
        _endGame(bonus: matchPct > 70 ? 30 : 0);
      },
    );
  }
}

// ══════════════════════════════════════════════════
//  GAME OVER SCREEN
// ══════════════════════════════════════════════════
class _GameOverScreen extends StatelessWidget {
  const _GameOverScreen({required this.p1, required this.p2});
  final int p1, p2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = p1 + p2;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 64))
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),
                const Gap(16),
                Text(
                  l.tr('Game Over!', 'Oyun Bitti!'),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const Gap(24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '+$total',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(l.tr('points earned!', 'puan kazandiniz!'),
                          style: theme.textTheme.titleMedium),
                      const Gap(12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ScoreChip(label: l.tr('👩 Me', '👩 Ben'), score: p1),
                          const Gap(16),
                          _ScoreChip(
                              label: l.tr('👨 Partner', '👨 Partner'),
                              score: p2),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                const Gap(32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l.tr('Back to Games', 'Oyunlara Don')),
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.label, required this.score});
  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text('$score',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════
//  1. SAYI TUZAĞI (Count & Trap)
// ══════════════════════════════════════════════════
class _CountTrapGame extends StatefulWidget {
  const _CountTrapGame({required this.onScore, required this.onEnd});
  final void Function(int p1, int p2) onScore;
  final Future<void> Function({int bonus}) onEnd;

  @override
  State<_CountTrapGame> createState() => _CountTrapGameState();
}

class _CountTrapGameState extends State<_CountTrapGame> {
  int _currentNumber = 1;
  bool _isPlayer1Turn = true; // true = player1, false = player2
  int _trapNumber = 0;
  String _trapWord = '';
  bool _setupPhase = true;
  bool _trapped = false;
  Timer? _timer;
  int _timeLeft = 3;
  final _wordController = TextEditingController();
  final _numberController = TextEditingController();

  void _startGame() {
    final num = int.tryParse(_numberController.text);
    if (num == null ||
        num < 1 ||
        num > 10 ||
        _wordController.text.trim().isEmpty) return;
    setState(() {
      _trapNumber = num;
      _trapWord = _wordController.text.trim();
      _setupPhase = false;
    });
  }

  void _tapNumber() {
    if (_trapped) return;

    if (_currentNumber == _trapNumber) {
      // Must say the trap word — start 3s timer
      setState(() {
        _timeLeft = 3;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_timeLeft <= 1) {
          t.cancel();
          setState(() => _trapped = true);
          HapticFeedback.heavyImpact();
          // Person who gets trapped loses
          widget.onScore(_isPlayer1Turn ? 0 : 20, _isPlayer1Turn ? 20 : 0);
          widget.onEnd();
        } else {
          setState(() => _timeLeft--);
        }
      });
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _currentNumber++;
      _isPlayer1Turn = !_isPlayer1Turn;
      if (_currentNumber > 10) {
        widget.onScore(15, 15);
        widget.onEnd();
      }
    });
  }

  void _saidTrapWord() {
    _timer?.cancel();
    HapticFeedback.mediumImpact();
    setState(() {
      _currentNumber++;
      _isPlayer1Turn = !_isPlayer1Turn;
      if (_currentNumber > 10) {
        widget.onScore(20, 20);
        widget.onEnd(bonus: 10);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wordController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.tr('Number Trap 🔢', 'Sayi Tuzagi 🔢'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _setupPhase ? _buildSetup(theme) : _buildGame(theme),
        ),
      ),
    );
  }

  Widget _buildSetup(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🔢', style: TextStyle(fontSize: 56)),
        const Gap(16),
        Text(l.tr('Set the Trap!', 'Tuzagi Kur!'),
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
        const Gap(8),
        Text(
          l.tr(
              'Pick a number between 1-10 and write the word to be said instead.\n'
                  'You will count alternately, the person reaching that number must say the word within 3 seconds!',
              '1-10 arasi bir sayi sec ve yerine soylenmesi gereken kelimeyi yaz.\n'
                  'Karsilikli sayacaksiniz, o sayiya gelen kisi kelimeyi 3 saniye icinde soylemeli!'),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const Gap(24),
        TextField(
          controller: _numberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l.tr('Trap number (1-10)', 'Tuzak sayi (1-10)'),
            prefixIcon: Icon(Icons.pin),
          ),
        ),
        const Gap(12),
        TextField(
          controller: _wordController,
          decoration: InputDecoration(
            labelText: l.tr('Trap word (e.g. mom, pizza)',
                'Tuzak kelime (ör: anne, pizza)'),
            prefixIcon: Icon(Icons.text_fields),
          ),
        ),
        const Gap(24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _startGame,
            child: Text(l.tr('Start Game!', 'Oyunu Baslat!')),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildGame(ThemeData theme) {
    final displayText =
        _currentNumber == _trapNumber ? '"$_trapWord" de!' : '$_currentNumber';
    final isTrap = _currentNumber == _trapNumber;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isPlayer1Turn
              ? l.tr('👩 Your Turn', '👩 Senin Siran')
              : l.tr('👨 Partner\'s Turn', '👨 Partner Sirasi'),
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(32),
        if (isTrap && !_trapped) ...[
          Text('⏱️ $_timeLeft',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w900,
                  )).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: 500.ms,
              ),
          const Gap(16),
        ],
        GestureDetector(
          onTap: isTrap ? null : _tapNumber,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTrap
                  ? Colors.orange.withValues(alpha: 0.2)
                  : theme.colorScheme.primary.withValues(alpha: 0.15),
              border: Border.all(
                color: isTrap ? Colors.orange : theme.colorScheme.primary,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                displayText,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isTrap ? Colors.orange : theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        if (isTrap && !_trapped) ...[
          const Gap(24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saidTrapWord,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('✅ "$_trapWord" dedi!',
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
        if (!isTrap) ...[
          const Gap(32),
          Text(
            l.tr('Tap and say "$_currentNumber"!',
                'Dokun ve "$_currentNumber" de!'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
        const Gap(16),
        // Progress dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(10, (i) {
            final num = i + 1;
            return Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: num < _currentNumber
                    ? theme.colorScheme.primary
                    : num == _currentNumber
                        ? Colors.orange
                        : theme.colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: Text(
                  num == _trapNumber ? '💣' : '$num',
                  style: TextStyle(
                    fontSize: 10,
                    color: num < _currentNumber
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ══════════════════════════════════════════════════
//  2. DOĞRULUK MU CESARET Mİ
// ══════════════════════════════════════════════════
class _TruthOrDareGame extends StatefulWidget {
  const _TruthOrDareGame({
    required this.repo,
    required this.round,
    required this.onNext,
    required this.onEnd,
  });
  final GamesRepository repo;
  final int round;
  final VoidCallback onNext, onEnd;

  @override
  State<_TruthOrDareGame> createState() => _TruthOrDareGameState();
}

class _TruthOrDareGameState extends State<_TruthOrDareGame> {
  String? _currentQ;
  bool? _isTruth;

  void _pick(bool truth) {
    setState(() {
      _isTruth = truth;
      _currentQ =
          truth ? widget.repo.getRandomTruth() : widget.repo.getRandomDare();
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isP1 = widget.round % 2 == 0;

    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${l.tr('Truth or Dare', 'Dogruluk mu Cesaret mi')} — ${l.tr('Round', 'Tur')} ${widget.round + 1}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isP1 ? '👩 Senin Siran' : '👨 Partner Sirasi',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const Gap(24),
              if (_currentQ == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _BigButton(
                        emoji: '🤔',
                        label: 'Dogruluk',
                        color: Colors.blue,
                        onTap: () => _pick(true),
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: _BigButton(
                        emoji: '🔥',
                        label: l.tr('Dare', 'Cesaret'),
                        color: Colors.red,
                        onTap: () => _pick(false),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                            _isTruth!
                                ? l.tr('🤔 Truth', '🤔 Dogruluk')
                                : l.tr('🔥 Dare', '🔥 Cesaret'),
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const Gap(12),
                        Text(_currentQ!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(height: 1.5)),
                      ],
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                const Gap(24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _currentQ = null);
                          widget.onNext();
                        },
                        child: Text(l.tr('Next Round', 'Sonraki Tur')),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.round >= 9
                            ? widget.onEnd
                            : () {
                                setState(() => _currentQ = null);
                                widget.onNext();
                              },
                        child: Text(widget.round >= 9
                            ? l.tr('Finish', 'Bitir')
                            : l.tr('Completed ✅', 'Tamamlandi ✅')),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  3. HANGİSİNİ TERCİH EDERSİN
// ══════════════════════════════════════════════════
class _WouldYouRatherGame extends StatefulWidget {
  const _WouldYouRatherGame({
    required this.repo,
    required this.round,
    required this.onNext,
    required this.onEnd,
  });
  final GamesRepository repo;
  final int round;
  final VoidCallback onNext, onEnd;

  @override
  State<_WouldYouRatherGame> createState() => _WouldYouRatherGameState();
}

class _WouldYouRatherGameState extends State<_WouldYouRatherGame> {
  late String _question;
  @override
  void initState() {
    super.initState();
    _question = widget.repo.getRandomWouldYouRather();
  }

  void _next() {
    setState(() {
      _question = widget.repo.getRandomWouldYouRather();
    });
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = _question.split(' yoksa ');
    final option1 = parts.isNotEmpty ? parts[0] : _question;
    final option2 = parts.length > 1 ? parts[1].replaceAll('?', '') : '...';

    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${l.tr('Preference', 'Tercih')} — ${l.tr('Round', 'Tur')} ${widget.round + 1}/10')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('⚖️', style: const TextStyle(fontSize: 48)),
              const Gap(16),
              Text(_question,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700, height: 1.5)),
              const Gap(32),
              _BigButton(
                  emoji: '1️⃣',
                  label: option1,
                  color: Colors.teal,
                  onTap: () {}),
              const Gap(12),
              const Text('veya', style: TextStyle(fontWeight: FontWeight.w600)),
              const Gap(12),
              _BigButton(
                  emoji: '2️⃣',
                  label: option2,
                  color: Colors.purple,
                  onTap: () {}),
              const Gap(32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: widget.round >= 9 ? widget.onEnd : _next,
                  child: Text(widget.round >= 9
                      ? l.tr('See Results', 'Sonuclari Gor')
                      : l.tr('Next Question', 'Sonraki Soru')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  4. BENİ NE KADAR TANIYORSUN
// ══════════════════════════════════════════════════
class _KnowMeQuizGame extends StatefulWidget {
  const _KnowMeQuizGame({
    required this.repo,
    required this.onScore,
    required this.round,
    required this.onEnd,
  });
  final GamesRepository repo;
  final void Function(bool correct) onScore;
  final int round;
  final VoidCallback onEnd;

  @override
  State<_KnowMeQuizGame> createState() => _KnowMeQuizGameState();
}

class _KnowMeQuizGameState extends State<_KnowMeQuizGame> {
  late String _question;
  final _answerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _question = widget.repo.getRandomKnowMeQuestion();
  }

  void _nextQ(bool correct) {
    widget.onScore(correct);
    if (widget.round >= 9) {
      widget.onEnd();
      return;
    }
    setState(() {
      _question = widget.repo.getRandomKnowMeQuestion();
      _answerCtrl.clear();
    });
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${l.tr('Know Me', 'Beni Tani')} — ${l.tr('Round', 'Tur')} ${widget.round + 1}/10')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🧠', style: TextStyle(fontSize: 48)),
              const Gap(16),
              Text(_question,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const Gap(24),
              TextField(
                controller: _answerCtrl,
                decoration: InputDecoration(
                  labelText:
                      l.tr('Partner\'s answer...', 'Partnerin cevabi...'),
                  prefixIcon: Icon(Icons.question_answer),
                ),
              ),
              const Gap(24),
              Text(l.tr('The asker decides:', 'Soran kisi karar versin:'),
                  style: theme.textTheme.bodyMedium),
              const Gap(12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _nextQ(true),
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: Text(l.tr('Correct ✅', 'Dogru ✅')),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _nextQ(false),
                      icon: const Icon(Icons.cancel),
                      label: Text(l.tr('Wrong ❌', 'Yanlis ❌')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  5. TRIP ÖLÇER
// ══════════════════════════════════════════════════
class _TripMeterGame extends StatefulWidget {
  const _TripMeterGame({
    required this.repo,
    required this.onScore,
    required this.round,
    required this.onEnd,
  });
  final GamesRepository repo;
  final void Function(int level) onScore;
  final int round;
  final VoidCallback onEnd;

  @override
  State<_TripMeterGame> createState() => _TripMeterGameState();
}

class _TripMeterGameState extends State<_TripMeterGame> {
  late Map<String, dynamic> _scenario;
  double _tripLevel = 0;

  @override
  void initState() {
    super.initState();
    _scenario = widget.repo.getRandomTripScenario();
  }

  void _rate(double value) {
    setState(() => _tripLevel = value);
  }

  void _submit() {
    final level = _tripLevel.round();
    widget.onScore(level);
    if (widget.round >= 7) {
      widget.onEnd();
      return;
    }
    setState(() {
      _scenario = widget.repo.getRandomTripScenario();
      _tripLevel = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scenarioLevel = _scenario['level'] as int;

    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${l.tr('Trip Meter', 'Trip Olcer')} — ${l.tr('Scenario', 'Senaryo')} ${widget.round + 1}/8')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_getTripEmoji(scenarioLevel),
                  style: const TextStyle(fontSize: 48)),
              const Gap(16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _scenario['scenario'] as String,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600, height: 1.5),
                  ),
                ),
              ),
              const Gap(24),
              Text(
                  l.tr('How much would this trip you?',
                      'Bu seni ne kadar trip attirir?'),
                  style: theme.textTheme.bodyLarge),
              const Gap(16),
              Row(
                children: [
                  const Text('😌', style: TextStyle(fontSize: 24)),
                  Expanded(
                    child: Slider(
                      value: _tripLevel,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: '${_tripLevel.round()}',
                      onChanged: _rate,
                    ),
                  ),
                  const Text('😤', style: TextStyle(fontSize: 24)),
                ],
              ),
              Text(
                  '${l.tr('Trip Level', 'Trip Seviyesi')}: ${_tripLevel.round()}/10',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.round >= 7
                      ? l.tr('See Results', 'Sonuclari Gor')
                      : l.tr('Next Scenario', 'Sonraki Senaryo')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTripEmoji(int level) {
    if (level >= 5) return '🌋';
    if (level >= 3) return '😤';
    return '😐';
  }
}

// ══════════════════════════════════════════════════
//  6. CÜMLE TAMAMLA
// ══════════════════════════════════════════════════
class _FinishSentenceGame extends StatefulWidget {
  const _FinishSentenceGame({
    required this.repo,
    required this.round,
    required this.onNext,
    required this.onEnd,
  });
  final GamesRepository repo;
  final int round;
  final void Function(int pts) onNext;
  final VoidCallback onEnd;

  @override
  State<_FinishSentenceGame> createState() => _FinishSentenceGameState();
}

class _FinishSentenceGameState extends State<_FinishSentenceGame> {
  late String _prompt;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prompt = widget.repo.getRandomFinishSentence();
  }

  void _submit() {
    if (_ctrl.text.trim().isEmpty) return;
    if (widget.round >= 9) {
      widget.onNext(10);
      widget.onEnd();
      return;
    }
    widget.onNext(10);
    setState(() {
      _prompt = widget.repo.getRandomFinishSentence();
      _ctrl.clear();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${l.tr('Finish Sentence', 'Cumle Tamamla')} — ${widget.round + 1}/10')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✍️', style: TextStyle(fontSize: 48)),
              const Gap(16),
              Text(_prompt,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic)),
              const Gap(24),
              TextField(
                controller: _ctrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText:
                      l.tr('Complete the sentence...', 'Cumleyi tamamla...'),
                  prefixIcon: Icon(Icons.edit),
                ),
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(l.tr('Send', 'Gonder')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  7. EMOJİ TAHMİN
// ══════════════════════════════════════════════════
class _EmojiGuessGame extends StatefulWidget {
  const _EmojiGuessGame({
    required this.repo,
    required this.round,
    required this.onNext,
    required this.onEnd,
  });
  final GamesRepository repo;
  final int round;
  final void Function(int pts) onNext;
  final VoidCallback onEnd;

  @override
  State<_EmojiGuessGame> createState() => _EmojiGuessGameState();
}

class _EmojiGuessGameState extends State<_EmojiGuessGame> {
  late String _challenge;
  final _emojiCtrl = TextEditingController();
  final _guessCtrl = TextEditingController();
  bool _showGuessPhase = false;

  @override
  void initState() {
    super.initState();
    _challenge = widget.repo.getRandomEmojiChallenge();
  }

  void _showGuess() => setState(() => _showGuessPhase = true);

  void _next(bool correct) {
    if (widget.round >= 9) {
      widget.onNext(correct ? 15 : 5);
      widget.onEnd();
      return;
    }
    widget.onNext(correct ? 15 : 5);
    setState(() {
      _challenge = widget.repo.getRandomEmojiChallenge();
      _emojiCtrl.clear();
      _guessCtrl.clear();
      _showGuessPhase = false;
    });
  }

  @override
  void dispose() {
    _emojiCtrl.dispose();
    _guessCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${l.tr('Emoji Guess', 'Emoji Tahmin')} — ${widget.round + 1}/10')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎯', style: TextStyle(fontSize: 48)),
              const Gap(16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(_challenge,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ),
              const Gap(24),
              if (!_showGuessPhase) ...[
                TextField(
                  controller: _emojiCtrl,
                  decoration: InputDecoration(
                    labelText:
                        l.tr('Express with emojis...', 'Emojilerle anlat...'),
                    hintText: l.tr('🎬🦁👑 like this...', '🎬🦁👑 gibi...'),
                    prefixIcon: Icon(Icons.emoji_emotions),
                  ),
                  style: const TextStyle(fontSize: 28),
                ),
                const Gap(16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _emojiCtrl.text.isNotEmpty ? _showGuess : null,
                    child:
                        Text(l.tr('Let Partner Guess', 'Partner Tahmin Etsin')),
                  ),
                ),
              ] else ...[
                Text('Emojiler: ${_emojiCtrl.text}',
                    style: const TextStyle(fontSize: 32)),
                const Gap(16),
                TextField(
                  controller: _guessCtrl,
                  decoration: InputDecoration(
                    labelText: l.tr('Write your guess...', 'Tahminini yaz...'),
                    prefixIcon: Icon(Icons.lightbulb),
                  ),
                ),
                const Gap(16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _next(true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: Text(l.tr('Correct! ✅', 'Dogru! ✅'),
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _next(false),
                        child: Text(l.tr('Wrong ❌', 'Yanlis ❌')),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  8. AŞK HARİTASI
// ══════════════════════════════════════════════════
class _LoveMapGame extends StatefulWidget {
  const _LoveMapGame({required this.onEnd});
  final VoidCallback onEnd;

  @override
  State<_LoveMapGame> createState() => _LoveMapGameState();
}

class _LoveMapGameState extends State<_LoveMapGame> {
  final List<Map<String, String>> _memories = [];
  final _titleCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  static const _milestones = [
    'First meeting',
    'First date',
    'First kiss',
    'First argument and making up',
    'First vacation',
    'Decision to live together',
    'Unforgettable moment',
    'Funniest moment',
    'Most romantic moment',
    'Future dream',
  ];

  void _addMemory() {
    if (_titleCtrl.text.isEmpty) return;
    setState(() {
      _memories.add({
        'title': _titleCtrl.text,
        'date': _dateCtrl.text,
      });
      _titleCtrl.clear();
      _dateCtrl.clear();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.tr('Love Map 🗺️', 'Ask Haritasi 🗺️'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
                l.tr('Record the important moments of your relationship!',
                    'Iliskinizin onemli anlarini kaydedin!'),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const Gap(8),
            Text(l.tr('Suggested:', 'Onerilir:'),
                style: theme.textTheme.bodySmall),
            const Gap(4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _milestones
                  .map((m) => ActionChip(
                        label: Text(m, style: const TextStyle(fontSize: 11)),
                        onPressed: () => _titleCtrl.text = m,
                      ))
                  .toList(),
            ),
            const Gap(16),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                  labelText: l.tr('Memory title', 'Ani basligi'),
                  prefixIcon: Icon(Icons.star)),
            ),
            const Gap(8),
            TextField(
              controller: _dateCtrl,
              decoration: InputDecoration(
                  labelText: l.tr('Date (optional)', 'Tarih (opsiyonel)'),
                  prefixIcon: Icon(Icons.calendar_today)),
            ),
            const Gap(12),
            ElevatedButton.icon(
              onPressed: _addMemory,
              icon: const Icon(Icons.add),
              label: Text(l.tr('Add', 'Ekle')),
            ),
            const Gap(20),
            ..._memories.asMap().entries.map((e) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${e.key + 1}')),
                  title: Text(e.value['title']!),
                  subtitle: e.value['date']!.isNotEmpty
                      ? Text(e.value['date']!)
                      : null,
                  trailing: const Text('💕'),
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: e.key * 100));
            }),
            const Gap(24),
            if (_memories.length >= 3)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: widget.onEnd,
                  child: Text(l.tr('Complete the Map!', 'Haritayi Tamamla!')),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  9. GİZLİ MESAJ
// ══════════════════════════════════════════════════
class _SecretMessageGame extends StatefulWidget {
  const _SecretMessageGame({required this.onEnd});
  final VoidCallback onEnd;

  @override
  State<_SecretMessageGame> createState() => _SecretMessageGameState();
}

class _SecretMessageGameState extends State<_SecretMessageGame> {
  final _msgCtrl = TextEditingController();
  String? _encrypted;
  bool _revealed = false;
  final _rng = Random();

  String _encrypt(String text) {
    final shift = _rng.nextInt(5) + 3;
    return String.fromCharCodes(
      text.runes.map((c) => c + shift),
    );
  }

  void _send() {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() {
      _encrypted = _encrypt(_msgCtrl.text);
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.tr('Secret Message 🔐', 'Gizli Mesaj 🔐'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔐', style: TextStyle(fontSize: 48)),
              const Gap(16),
              Text(
                  l.tr('Send an encrypted love letter to your partner!',
                      'Partnerine sifrelenmis bir ask mektubu gonder!'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const Gap(24),
              if (_encrypted == null) ...[
                TextField(
                  controller: _msgCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l.tr(
                        'Write your love letter...', 'Ask mektubunu yaz...'),
                    hintText: l.tr('I love you so much because...',
                        'Seni cok seviyorum cunku...'),
                    prefixIcon: Icon(Icons.mail),
                  ),
                ),
                const Gap(16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _send,
                    child: Text(l.tr('Encrypt and Send', 'Sifrele ve Gonder')),
                  ),
                ),
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(l.tr('Encrypted Message:', 'Sifrelenmis Mesaj:'),
                            style: theme.textTheme.labelLarge),
                        const Gap(8),
                        Text(
                          _revealed ? _msgCtrl.text : _encrypted!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontFamily: 'monospace',
                            color: _revealed ? theme.colorScheme.primary : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                const Gap(16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_revealed) {
                        widget.onEnd();
                      } else {
                        setState(() => _revealed = true);
                        HapticFeedback.heavyImpact();
                      }
                    },
                    child: Text(_revealed
                        ? l.tr('Complete 💕', 'Tamamla 💕')
                        : l.tr('Decode! 🔓', 'Coz! 🔓')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  10. UYUM TESTİ
// ══════════════════════════════════════════════════
class _CompatibilityGame extends StatefulWidget {
  const _CompatibilityGame({
    required this.repo,
    required this.onEnd,
  });
  final GamesRepository repo;
  final void Function(int matchPercent) onEnd;

  @override
  State<_CompatibilityGame> createState() => _CompatibilityGameState();
}

class _CompatibilityGameState extends State<_CompatibilityGame> {
  final List<List<String>> _questions = [];
  int _qIndex = 0;
  int? _p1Answer, _p2Answer;
  bool _isP1Phase = true;
  int _matches = 0;

  @override
  void initState() {
    super.initState();
    final allQ =
        List<List<String>>.from(GamesRepository.compatibilityQuestions);
    allQ.shuffle();
    _questions.addAll(allQ.take(8));
  }

  void _selectAnswer(int idx) {
    if (_isP1Phase) {
      setState(() {
        _p1Answer = idx;
        _isP1Phase = false;
      });
    } else {
      setState(() => _p2Answer = idx);
      if (_p1Answer == idx) _matches++;

      Future.delayed(const Duration(milliseconds: 600), () {
        if (_qIndex >= _questions.length - 1) {
          final pct = ((_matches / _questions.length) * 100).round();
          widget.onEnd(pct);
        } else {
          setState(() {
            _qIndex++;
            _p1Answer = null;
            _p2Answer = null;
            _isP1Phase = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_qIndex >= _questions.length) return const SizedBox.shrink();
    final q = _questions[_qIndex];
    final question = q[0];
    final options = q.sublist(1);

    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${l.tr('Compatibility Test', 'Uyum Testi')} — ${_qIndex + 1}/${_questions.length}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isP1Phase
                    ? l.tr('👩 Your Answer', '👩 Senin Cevabın')
                    : l.tr('👨 Partner\'s Answer', '👨 Partner Cevabı'),
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (!_isP1Phase)
                Text(
                    l.tr('(Don\'t look at the other side!)',
                        '(Diger tarafa bakma!)'),
                    style:
                        theme.textTheme.bodySmall?.copyWith(color: Colors.red)),
              const Gap(24),
              Text(question,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const Gap(24),
              ...options.asMap().entries.map((e) {
                final selected = !_isP1Phase && _p2Answer == e.key;
                final matched = _p2Answer != null &&
                    _p1Answer == e.key &&
                    _p2Answer == e.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed:
                          _p2Answer != null ? null : () => _selectAnswer(e.key),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: matched
                            ? Colors.green.withValues(alpha: 0.1)
                            : selected
                                ? theme.colorScheme.primary
                                    .withValues(alpha: 0.1)
                                : null,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Text(e.value),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  SHARED WIDGETS
// ══════════════════════════════════════════════════
class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const Gap(8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
