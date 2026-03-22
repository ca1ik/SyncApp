import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
import '../../../../core/widgets/themed_background.dart';
import '../../../../data/models/game_model.dart';
import '../../../../data/repositories/games_repository.dart';
import '../../../../core/services/locale_service.dart';

class GamesHubPage extends StatefulWidget {
  const GamesHubPage({super.key});

  @override
  State<GamesHubPage> createState() => _GamesHubPageState();
}

class _GamesHubPageState extends State<GamesHubPage> {
  CouplePoints _points = const CouplePoints();

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    final p = await getIt<GamesRepository>().getPoints();
    if (mounted) setState(() => _points = p);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      bottomSheet: const BannerAdWidget(),
      body: ThemedBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                '🎮',
                                style: const TextStyle(fontSize: 36),
                              ).animate().scale(
                                    duration: 600.ms,
                                    curve: Curves.elasticOut,
                                  ),
                              const Gap(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l.tr('Couple Games', 'Cift Oyunlari'),
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      _points.bondTitle,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color:
                                            Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Gap(12),
                          // Bond level bar
                          Row(
                            children: [
                              Text(
                                '${l.tr('Bond Level', 'Bag Seviyesi')} ${_points.bondLevel}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Gap(8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _points.levelProgress,
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.2),
                                    valueColor: const AlwaysStoppedAnimation(
                                        Colors.white),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const Gap(8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_points.totalPoints}⭐',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                title: Text(l.tr('Games', 'Oyunlar')),
              ),
            ),
            // Stats row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    _StatChip(
                      emoji: '🎮',
                      value: '${_points.gamesPlayed}',
                      label: l.tr('Games', 'Oyun'),
                    ),
                    const Gap(8),
                    _StatChip(
                      emoji: '⭐',
                      value: '${_points.totalPoints}',
                      label: l.tr('Points', 'Puan'),
                    ),
                    const Gap(8),
                    _StatChip(
                      emoji: '💕',
                      value: 'Lv.${_points.bondLevel}',
                      label: l.tr('Bond', 'Bag'),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
              ),
            ),
            // Game categories
            ...GameCategory.values.map((cat) {
              final games = CoupleGameType.values
                  .where((g) => g.category == cat)
                  .toList();
              if (games.isEmpty) return const SliverGap(0);
              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: cat.isRgbPro
                          ? _RgbCategoryHeader(cat: cat, count: games.length)
                          : Row(
                              children: [
                                Text(
                                  cat.emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const Gap(8),
                                Text(
                                  cat.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${games.length} ${l.tr('games', 'oyun')}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _GameCard(
                            game: games[index],
                            index: index,
                            onRefresh: _loadPoints,
                          );
                        },
                        childCount: games.length,
                      ),
                    ),
                  ),
                ],
              );
            }),
            // Q&A Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Card(
                  child: InkWell(
                    onTap: () async {
                      await Get.toNamed(AppRoutes.qaSystem);
                      _loadPoints();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Text('❓', style: TextStyle(fontSize: 36)),
                          const Gap(16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.tr('Q&A', 'Soru-Cevap'),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  l.tr(
                                      'Ask your partner a question, rate or say true/false!',
                                      'Partnerine soru sor, puanla veya dogru/yanlis de!'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
              ),
            ),
            const SliverGap(32),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.emoji,
    required this.value,
    required this.label,
  });
  final String emoji, value, label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.index,
    required this.onRefresh,
  });
  final CoupleGameType game;
  final int index;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArena = game.category == GameCategory.arena;
    final cardColors = _gameCardColors(game);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColors.$1.withValues(alpha: 0.12),
            cardColors.$2.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(
          color: cardColors.$1.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cardColors.$1.withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            if (game == CoupleGameType.bracketTournament) {
              await Get.toNamed(AppRoutes.tournament);
            } else if (game == CoupleGameType.rateAndRank) {
              await Get.toNamed(AppRoutes.ranking);
            } else if (game.category == GameCategory.arena) {
              const originalArena = {
                CoupleGameType.sumoBall,
                CoupleGameType.miniPool,
                CoupleGameType.carRace,
                CoupleGameType.laserDodge,
                CoupleGameType.icePlatform,
              };
              final route = originalArena.contains(game)
                  ? AppRoutes.arenaGame
                  : AppRoutes.arenaGameExtra;
              await Get.toNamed(route, arguments: game);
            } else {
              await Get.toNamed(
                AppRoutes.gamePlay,
                arguments: game,
              );
            }
            onRefresh();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji with glow container
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cardColors.$1.withValues(alpha: 0.1),
                    boxShadow: isArena
                        ? [
                            BoxShadow(
                              color: cardColors.$1.withValues(alpha: 0.2),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      game.emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
                const Gap(10),
                Text(
                  game.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const Gap(4),
                Text(
                  game.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                if (game.isProOnly)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: isArena
                          ? LinearGradient(
                              colors: [
                                cardColors.$1.withValues(alpha: 0.3),
                                cardColors.$2.withValues(alpha: 0.3),
                              ],
                            )
                          : null,
                      color:
                          isArena ? null : Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isArena ? '⚡ ARENA PRO' : '👑 PRO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isArena ? cardColors.$1 : null,
                      ),
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l.tr('🆓 Free', '🆓 Ucretsiz'),
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 80 * index),
          duration: 400.ms,
        )
        .slideY(begin: 0.1, duration: 400.ms);
  }

  static (Color, Color) _gameCardColors(CoupleGameType game) {
    switch (game) {
      case CoupleGameType.sumoBall:
        return (Colors.redAccent, Colors.deepOrange);
      case CoupleGameType.miniPool:
        return (Colors.green, Colors.teal);
      case CoupleGameType.carRace:
        return (Colors.grey, Colors.blueGrey);
      case CoupleGameType.laserDodge:
        return (Colors.cyanAccent, Colors.blueAccent);
      case CoupleGameType.icePlatform:
        return (Colors.lightBlueAccent, Colors.blue);
      case CoupleGameType.colorMatch:
        return (Colors.purpleAccent, Colors.deepPurple);
      case CoupleGameType.meteorShower:
        return (Colors.orange, Colors.deepOrange);
      case CoupleGameType.balloonPop:
        return (Colors.pinkAccent, Colors.pink);
      case CoupleGameType.treasureDive:
        return (Colors.amber, Colors.orange);
      case CoupleGameType.bombPass:
        return (Colors.redAccent, Colors.red);
      case CoupleGameType.towerStack:
        return (Colors.tealAccent, Colors.teal);
      case CoupleGameType.fruitCatch:
        return (Colors.greenAccent, Colors.green);
      case CoupleGameType.targetShot:
        return (Colors.red, Colors.deepOrange);
      case CoupleGameType.lavaFloor:
        return (Colors.deepOrangeAccent, Colors.redAccent);
      case CoupleGameType.paintWar:
        return (Colors.purple, Colors.deepPurple);
      case CoupleGameType.snakeArena:
        return (Colors.greenAccent, Colors.green);
      case CoupleGameType.asteroidBreaker:
        return (Colors.grey, Colors.blueGrey);
      case CoupleGameType.rhythmTap:
        return (Colors.pinkAccent, Colors.purple);
      case CoupleGameType.mazeRunner:
        return (Colors.teal, Colors.cyan);
      case CoupleGameType.shieldBlock:
        return (Colors.cyanAccent, Colors.indigo);
      default:
        return (Colors.blueAccent, Colors.blue);
    }
  }
}

// ── RGB Animated Category Header for Arena PRO ──────────
class _RgbCategoryHeader extends StatefulWidget {
  const _RgbCategoryHeader({required this.cat, required this.count});
  final GameCategory cat;
  final int count;

  @override
  State<_RgbCategoryHeader> createState() => _RgbCategoryHeaderState();
}

class _RgbCategoryHeaderState extends State<_RgbCategoryHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final hue = (_ctrl.value * 360).round();
        final c1 = HSLColor.fromAHSL(1, hue.toDouble(), 0.9, 0.5).toColor();
        final c2 =
            HSLColor.fromAHSL(1, (hue + 120.0) % 360, 0.9, 0.5).toColor();
        final c3 =
            HSLColor.fromAHSL(1, (hue + 240.0) % 360, 0.9, 0.5).toColor();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              c1.withValues(alpha: 0.15),
              c2.withValues(alpha: 0.15),
              c3.withValues(alpha: 0.15),
            ]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: c1.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Text(widget.cat.emoji, style: const TextStyle(fontSize: 22)),
              const Gap(8),
              Text(widget.cat.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    foreground: Paint()
                      ..shader = LinearGradient(colors: [c1, c2, c3])
                          .createShader(const Rect.fromLTWH(0, 0, 200, 24)),
                  )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [c1, c2]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.count} ${l.tr('games', 'oyun')}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
