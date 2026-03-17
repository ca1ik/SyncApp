import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/romantic_background.dart';
import '../../../../data/models/game_model.dart';
import '../../../../data/repositories/games_repository.dart';

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
      body: RomanticBackground(
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
                                      'Cift Oyunlari',
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
                                'Bag Seviyesi ${_points.bondLevel}',
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
                title: const Text('Oyunlar'),
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
                      label: 'Oyun',
                    ),
                    const Gap(8),
                    _StatChip(
                      emoji: '⭐',
                      value: '${_points.totalPoints}',
                      label: 'Puan',
                    ),
                    const Gap(8),
                    _StatChip(
                      emoji: '💕',
                      value: 'Lv.${_points.bondLevel}',
                      label: 'Bag',
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
              ),
            ),
            // Game cards
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final game = CoupleGameType.values[index];
                    return _GameCard(
                      game: game,
                      index: index,
                      onRefresh: _loadPoints,
                    );
                  },
                  childCount: CoupleGameType.values.length,
                ),
              ),
            ),
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
                                  'Soru-Cevap',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  'Partnerine soru sor, puanla veya dogru/yanlis de!',
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

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Get.toNamed(
            AppRoutes.gamePlay,
            arguments: game,
          );
          onRefresh();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                game.emoji,
                style: const TextStyle(fontSize: 40),
              ),
              const Gap(10),
              Text(
                game.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const Gap(6),
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
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '👑 PRO',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '🆓 Ucretsiz',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 80 * index),
          duration: 400.ms,
        );
  }
}
