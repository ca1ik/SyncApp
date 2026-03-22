import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/locale_service.dart';
import '../../../../data/models/relationship_mode_model.dart';

class ModeSelectionPage extends StatefulWidget {
  const ModeSelectionPage({super.key});

  @override
  State<ModeSelectionPage> createState() => _ModeSelectionPageState();
}

class _ModeSelectionPageState extends State<ModeSelectionPage>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _particleCtrl;
  RelationshipMode? _selectedMode;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  Future<void> _onModeSelected(RelationshipMode mode) async {
    if (_isTransitioning) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _selectedMode = mode;
      _isTransitioning = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefRelationshipModeKey, mode.name);

    await Future.delayed(const Duration(milliseconds: 800));

    if (mode == RelationshipMode.solo) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dark gradient background
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (context, _) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _selectedMode != null
                      ? _selectedMode!.gradientColors
                      : const [Color(0xFF0F0C29), Color(0xFF302B63)],
                ),
              ),
            ),
          ),

          // Ambient particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleCtrl,
              builder: (context, _) => CustomPaint(
                painter: _AmbientParticlePainter(
                  progress: _particleCtrl.value,
                  mode: _selectedMode,
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Gap(40),
                  // Title
                  Text(
                    l.tr('Choose Your Mode', 'Modunuzu Secin'),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.3, curve: Curves.easeOutBack),
                  const Gap(8),
                  Text(
                    l.tr('How would you like to use Sync?',
                        'Sync\'i nasil kullanmak istersiniz?'),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                  const Gap(40),

                  // Mode cards
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ModeCard(
                          mode: RelationshipMode.couple,
                          isSelected: _selectedMode == RelationshipMode.couple,
                          onTap: () => _onModeSelected(RelationshipMode.couple),
                          delay: 300,
                        ),
                        const Gap(16),
                        _ModeCard(
                          mode: RelationshipMode.friend,
                          isSelected: _selectedMode == RelationshipMode.friend,
                          onTap: () => _onModeSelected(RelationshipMode.friend),
                          delay: 450,
                        ),
                        const Gap(16),
                        _ModeCard(
                          mode: RelationshipMode.solo,
                          isSelected: _selectedMode == RelationshipMode.solo,
                          onTap: () => _onModeSelected(RelationshipMode.solo),
                          delay: 600,
                        ),
                      ],
                    ),
                  ),

                  // Footer hint
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      l.tr('You can change this later in Settings',
                          'Bunu daha sonra Ayarlar\'dan degistirebilirsiniz'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),

          // Transition overlay
          if (_isTransitioning)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: _isTransitioning ? 1.0 : 0.0,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedMode?.emoji ?? '',
                          style: const TextStyle(fontSize: 64),
                        ).animate().scale(
                              duration: 500.ms,
                              curve: Curves.elasticOut,
                            ),
                        const Gap(16),
                        Text(
                          _selectedMode?.title ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Mode Card Widget ────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
    required this.delay,
  });

  final RelationshipMode mode;
  final bool isSelected;
  final VoidCallback onTap;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final colors = mode.gradientColors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? colors
                : [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.04),
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Emoji container with glow
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  mode.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const Gap(4),
                  Text(
                    mode.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.85)
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            // Mode-specific features
            Column(
              children: [
                _featureChip(mode),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideX(begin: 0.15, curve: Curves.easeOutCubic);
  }

  Widget _featureChip(RelationshipMode mode) {
    String label;
    IconData icon;
    switch (mode) {
      case RelationshipMode.couple:
        label = l.tr('Hearts', 'Kalpler');
        icon = Icons.favorite;
      case RelationshipMode.friend:
        label = l.tr('Stars', 'Yildizlar');
        icon = Icons.star;
      case RelationshipMode.solo:
        label = l.tr('Bubbles', 'Baloncuklar');
        icon = Icons.bubble_chart;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.7)),
          const Gap(4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ambient Particle Painter ────────────────────────────────────

class _AmbientParticlePainter extends CustomPainter {
  _AmbientParticlePainter({required this.progress, this.mode});

  final double progress;
  final RelationshipMode? mode;

  static const int _count = 30;
  static final _rng = Random(777);
  static final List<_Particle> _particles = List.generate(_count, (i) {
    return _Particle(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      size: 2 + _rng.nextDouble() * 4,
      speed: 0.2 + _rng.nextDouble() * 0.6,
      phase: _rng.nextDouble() * 2 * pi,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = (progress * p.speed + p.x) % 1.0;
      final y = size.height * (1 - t);
      final x = size.width * p.x + sin(t * 2 * pi + p.phase) * 30;
      final alpha = (sin(t * pi) * 0.15).clamp(0.0, 0.15);

      final color =
          (mode?.accentColor ?? Colors.white).withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), p.size, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientParticlePainter old) => true;
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
  });
  final double x, y, size, speed, phase;
}
