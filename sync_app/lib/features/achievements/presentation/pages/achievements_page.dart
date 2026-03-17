import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/di/injection.dart';
import '../../../../data/models/achievement_model.dart';
import '../../../../data/repositories/gamification_repository.dart';
import '../../../subscription/cubit/subscription_cubit.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPro = context.watch<SubscriptionCubit>().state.isPro;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Basarimlar'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<AchievementModel>>(
        future: getIt<GamificationRepository>().getAchievements(),
        builder: (context, snapshot) {
          final unlocked = snapshot.data ?? [];
          final unlockedTypes = unlocked.map((e) => e.type).toSet();

          return FutureBuilder(
            future: getIt<GamificationRepository>().getStreak(),
            builder: (context, streakSnap) {
              final streak = streakSnap.data;
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── Streak card ──
                  if (streak != null)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🔥 Mevcut Seri',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              Text(
                                '${streak.currentStreak} gun',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'En Yuksek',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              Text(
                                '${streak.longestStreak} gun',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Toplam',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              Text(
                                '${streak.totalEntries}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                  const Gap(24),
                  Text(
                    'Acilan basarimlar (${unlocked.length}/${AchievementType.values.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(4),
                  LinearProgressIndicator(
                    value: unlocked.length / AchievementType.values.length,
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 6,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                  const Gap(16),
                  ...AchievementType.values.asMap().entries.map((entry) {
                    final type = entry.value;
                    final index = entry.key;
                    final isUnlocked = unlockedTypes.contains(type);
                    final isLocked = type.isProOnly && !isPro;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        color: isUnlocked
                            ? theme.colorScheme.primary.withValues(alpha: 0.06)
                            : null,
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.12)
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                isUnlocked
                                    ? type.icon
                                    : (isLocked ? '🔒' : '❓'),
                                style: TextStyle(
                                  fontSize: isUnlocked ? 24 : 20,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            type.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isUnlocked
                                  ? null
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                            ),
                          ),
                          subtitle: Text(
                            isUnlocked
                                ? type.description
                                : (isLocked ? 'PRO ozeligi' : 'Henuz acilmadi'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isUnlocked
                                  ? theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6)
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.3),
                            ),
                          ),
                          trailing: isUnlocked
                              ? Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                )
                              : (isLocked
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'PRO',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    )
                                  : null),
                        ),
                      ).animate().fadeIn(
                            delay: Duration(milliseconds: index * 50),
                            duration: 300.ms,
                          ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
