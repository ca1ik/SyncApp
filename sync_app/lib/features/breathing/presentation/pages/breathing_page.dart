import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../subscription/cubit/subscription_cubit.dart';

enum BreathingTechnique {
  box,
  calm478,
  energize,
  coupleSync,
}

extension BreathingTechniqueX on BreathingTechnique {
  String get title {
    switch (this) {
      case BreathingTechnique.box:
        return 'Kutu Nefes';
      case BreathingTechnique.calm478:
        return '4-7-8 Sakinlestirici';
      case BreathingTechnique.energize:
        return 'Enerji Nefesi';
      case BreathingTechnique.coupleSync:
        return 'Cift Senkron Nefes';
    }
  }

  String get description {
    switch (this) {
      case BreathingTechnique.box:
        return '4 adimli sakinlestirici teknik. Kriz anlarinda etkili.';
      case BreathingTechnique.calm478:
        return 'Derin rahatlatici nefes. Uyku oncesi ve gerginlikte ideal.';
      case BreathingTechnique.energize:
        return 'Kisa ve canlandirici nefes dongusu.';
      case BreathingTechnique.coupleSync:
        return 'Partnerinizle ayni anda nefes egzersizi yapin.';
    }
  }

  String get icon {
    switch (this) {
      case BreathingTechnique.box:
        return '📦';
      case BreathingTechnique.calm478:
        return '🌙';
      case BreathingTechnique.energize:
        return '⚡';
      case BreathingTechnique.coupleSync:
        return '💞';
    }
  }

  bool get isProOnly {
    switch (this) {
      case BreathingTechnique.box:
        return false;
      case BreathingTechnique.calm478:
      case BreathingTechnique.energize:
      case BreathingTechnique.coupleSync:
        return true;
    }
  }

  List<_BreathPhase> get phases {
    switch (this) {
      case BreathingTechnique.box:
        return [
          _BreathPhase('Nefes al', 4),
          _BreathPhase('Tut', 4),
          _BreathPhase('Nefes ver', 4),
          _BreathPhase('Tut', 4),
        ];
      case BreathingTechnique.calm478:
        return [
          _BreathPhase('Nefes al', 4),
          _BreathPhase('Tut', 7),
          _BreathPhase('Nefes ver', 8),
        ];
      case BreathingTechnique.energize:
        return [
          _BreathPhase('Hizli nefes al', 2),
          _BreathPhase('Hizli nefes ver', 2),
        ];
      case BreathingTechnique.coupleSync:
        return [
          _BreathPhase('Birlikte nefes alin', 5),
          _BreathPhase('Birlikte tutun', 3),
          _BreathPhase('Birlikte nefes verin', 5),
          _BreathPhase('Dinlenin', 2),
        ];
    }
  }

  int get totalCycles {
    switch (this) {
      case BreathingTechnique.box:
        return 4;
      case BreathingTechnique.calm478:
        return 3;
      case BreathingTechnique.energize:
        return 8;
      case BreathingTechnique.coupleSync:
        return 4;
    }
  }
}

class _BreathPhase {
  const _BreathPhase(this.label, this.seconds);
  final String label;
  final int seconds;
}

class BreathingPage extends StatefulWidget {
  const BreathingPage({super.key});

  @override
  State<BreathingPage> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage>
    with TickerProviderStateMixin {
  BreathingTechnique? _activeTechnique;
  bool _isRunning = false;
  int _currentPhaseIndex = 0;
  int _currentCycle = 0;
  int _countdown = 0;
  Timer? _timer;
  late AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  void _startExercise(BreathingTechnique technique) {
    setState(() {
      _activeTechnique = technique;
      _isRunning = true;
      _currentPhaseIndex = 0;
      _currentCycle = 0;
    });
    _startPhase();
  }

  void _startPhase() {
    if (_activeTechnique == null) return;
    final phases = _activeTechnique!.phases;
    final phase = phases[_currentPhaseIndex];

    setState(() {
      _countdown = phase.seconds;
    });

    _breathController.duration = Duration(seconds: phase.seconds);
    if (phase.label.contains('al')) {
      _breathController.forward(from: 0);
    } else if (phase.label.contains('ver')) {
      _breathController.reverse(from: 1);
    }

    HapticFeedback.lightImpact();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        _nextPhase();
        return;
      }
      setState(() {
        _countdown--;
      });
    });
  }

  void _nextPhase() {
    if (_activeTechnique == null) return;
    final phases = _activeTechnique!.phases;

    if (_currentPhaseIndex < phases.length - 1) {
      setState(() {
        _currentPhaseIndex++;
      });
      _startPhase();
    } else {
      _currentCycle++;
      if (_currentCycle < _activeTechnique!.totalCycles) {
        setState(() {
          _currentPhaseIndex = 0;
        });
        _startPhase();
      } else {
        _completeExercise();
      }
    }
  }

  void _completeExercise() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      _isRunning = false;
    });
  }

  void _stopExercise() {
    _timer?.cancel();
    _breathController.stop();
    setState(() {
      _isRunning = false;
      _activeTechnique = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPro = context.watch<SubscriptionCubit>().state.isPro;

    if (_isRunning && _activeTechnique != null) {
      return _buildActiveExercise(theme);
    }

    if (_activeTechnique != null && !_isRunning) {
      return _buildCompletionScreen(theme);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nefes Egzersizi'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  '🫁',
                  style: const TextStyle(fontSize: 40),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                const Gap(8),
                Text(
                  'Zor anlarda nefes alin',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(4),
                Text(
                  'Dogru nefes teknigi stres seviyesini aninda dusurur.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const Gap(24),
          ...BreathingTechnique.values.map((technique) {
            final locked = technique.isProOnly && !isPro;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TechniqueCard(
                technique: technique,
                locked: locked,
                theme: theme,
                onTap: () {
                  if (locked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bu teknik PRO uyeler icindir. Yukselt!'),
                      ),
                    );
                    return;
                  }
                  _startExercise(technique);
                },
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 100 * technique.index),
                    duration: 400.ms,
                  ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActiveExercise(ThemeData theme) {
    final phases = _activeTechnique!.phases;
    final currentPhase = phases[_currentPhaseIndex];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Gap(20),
            Text(
              _activeTechnique!.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Tur ${_currentCycle + 1} / ${_activeTechnique!.totalCycles}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _breathController,
              builder: (context, child) {
                final scale = 0.5 + (_breathController.value * 0.5);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.6),
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 40 * _breathController.value,
                          spreadRadius: 10 * _breathController.value,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$_countdown',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const Gap(32),
            Text(
              currentPhase.label,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            )
                .animate(
                  key: ValueKey('$_currentPhaseIndex-$_currentCycle'),
                )
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                phases.length,
                (i) => Container(
                  width: i == _currentPhaseIndex ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i == _currentPhaseIndex
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            const Gap(24),
            TextButton.icon(
              onPressed: _stopExercise,
              icon: const Icon(Icons.close),
              label: const Text('Bitir'),
            ),
            const Gap(32),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(ThemeData theme) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🌟',
                  style: const TextStyle(fontSize: 64),
                )
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.elasticOut)
                    .then()
                    .shimmer(duration: 1500.ms),
                const Gap(24),
                Text(
                  'Harika!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const Gap(8),
                Text(
                  'Nefes egzersiznizi tamamladiniz.\nKendinizi daha iyi hissedeceksiniz.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ).animate().fadeIn(delay: 500.ms),
                const Gap(40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _activeTechnique = null;
                      });
                    },
                    child: const Text('Tekrar basla'),
                  ),
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3),
                const Gap(12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Kapat'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TechniqueCard extends StatelessWidget {
  const _TechniqueCard({
    required this.technique,
    required this.locked,
    required this.theme,
    required this.onTap,
  });

  final BreathingTechnique technique;
  final bool locked;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: locked
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    locked ? '🔒' : technique.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          technique.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: locked
                                ? theme.colorScheme.onSurface
                                    .withValues(alpha: 0.4)
                                : null,
                          ),
                        ),
                        if (technique.isProOnly) ...[
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'PRO',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Gap(4),
                    Text(
                      technique.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: locked
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: locked
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.2)
                    : theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
