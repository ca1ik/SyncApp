import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
import '../../../../data/models/mood_log_model.dart';
import '../../../../data/repositories/gamification_repository.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../subscription/cubit/subscription_cubit.dart';
import '../../../sync_engine/bloc/sync_engine_bloc.dart';
import '../../../../core/services/locale_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = context.read<AppThemeProvider>().activeGradient;
    final isPro = context.watch<SubscriptionCubit>().state.isPro;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tr('Analysis', 'Analiz')),
        centerTitle: true,
      ),
      bottomSheet: const BannerAdWidget(),
      body: BlocBuilder<SyncEngineBloc, SyncEngineState>(
        builder: (context, syncState) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Relationship Score ──
              _RelationshipScoreCard(
                history: syncState.history,
                gradient: gradient,
                theme: theme,
              ),
              const Gap(16),

              // ── Quick Stats Row ──
              Row(
                children: [
                  Expanded(
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        return _MiniStat(
                          icon: Icons.person_outlined,
                          label: l.tr('Account', 'Hesap'),
                          value: authState.user?.displayName ??
                              authState.user?.email ??
                              l.tr('Guest', 'Misafir'),
                          theme: theme,
                        );
                      },
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
                      builder: (context, state) {
                        return _MiniStat(
                          icon: state.isPro
                              ? Icons.workspace_premium
                              : Icons.star_outline,
                          label: l.tr('Plan', 'Plan'),
                          value: state.isPro
                              ? 'PRO'
                              : l.tr('Standard', 'Standart'),
                          theme: theme,
                          accent: state.isPro,
                        );
                      },
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),
              const Gap(16),

              // ── Mood Distribution Chart ──
              if (syncState.history.isNotEmpty) ...[
                Text(
                  l.tr('Signal Distribution', 'Sinyal Dagilimi'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: 200,
                      child: _MoodDistributionChart(
                        history: syncState.history,
                        theme: theme,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const Gap(16),
              ],

              // ── Energy/Tolerance Trend (PRO) ──
              if (isPro && syncState.history.length >= 3) ...[
                Text(
                  l.tr('Energy & Tolerance Trend', 'Enerji & Tolerans Trendi'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: 200,
                      child: _TrendChart(
                        history: syncState.history,
                        theme: theme,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const Gap(16),
              ] else if (!isPro) ...[
                _ProFeatureTeaser(
                  title: l.tr(
                      'Energy & Tolerance Trend', 'Enerji & Tolerans Trendi'),
                  description: l.tr(
                      'See how your energy and tolerance levels change over time with PRO.',
                      'PRO ile enerji ve tolerans seviyelerinizin zamanla nasil degistigini gorun.'),
                  theme: theme,
                ).animate().fadeIn(delay: 300.ms),
                const Gap(16),
              ],

              // ── Mood History ──
              Row(
                children: [
                  Text(
                    l.tr('History', 'Gecmis'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (!isPro &&
                      syncState.history.length >
                          SubscriptionState.freeHistoryLimit)
                    TextButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.subscription),
                      icon: const Icon(Icons.lock_outline, size: 14),
                      label: Text(l.tr('See all', 'Tumunu gor')),
                    ),
                ],
              ),
              const Gap(8),
              if (syncState.history.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(l.tr('No mood entries yet.',
                        'Henuz mood kaydi bulunmuyor.')),
                  ),
                )
              else ...[
                ...syncState.history
                    .take(isPro ? 50 : SubscriptionState.freeHistoryLimit)
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  entry.value.signal.emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                            title: Text(
                              entry.value.signal.label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${l.tr('Energy', 'Enerji')} ${entry.value.energyLevel} • ${l.tr('Tolerance', 'Tolerans')} ${entry.value.toleranceLevel}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            trailing: entry.value.isSharedWithPartner
                                ? Icon(
                                    Icons.share_outlined,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                          ),
                        ).animate().fadeIn(
                              delay: Duration(milliseconds: entry.key * 40),
                              duration: 300.ms,
                            ),
                      ),
                    ),
              ],
              const Gap(80),
            ],
          );
        },
      ),
    );
  }
}

class _RelationshipScoreCard extends StatelessWidget {
  const _RelationshipScoreCard({
    required this.history,
    required this.gradient,
    required this.theme,
  });

  final List<MoodLogModel> history;
  final LinearGradient gradient;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _calculateScore(),
      builder: (context, snapshot) {
        final score = snapshot.data ?? 50;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.tr('Relationship Score', 'Iliski Skoru'),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '$score',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      _getScoreLabel(score),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    Text(
                      _getScoreEmoji(score),
                      style: const TextStyle(fontSize: 28),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1);
      },
    );
  }

  Future<int> _calculateScore() async {
    final gamification = getIt<GamificationRepository>();
    final streak = await gamification.getStreak();
    return gamification.getRelationshipScore(history: history, streak: streak);
  }

  String _getScoreLabel(int score) {
    if (score >= 80)
      return l.tr(
          'Great harmony! Keep it up 💪', 'Harika uyum! Boyle devam edin 💪');
    if (score >= 60)
      return l.tr('Going well, small steps make a big difference.',
          'Iyi gidiyorsunuz, kucuk adimlar buyuk fark yaratir.');
    if (score >= 40)
      return l.tr(
          'Spend time together, talk.', 'Birbirinize vakit ayirin, konusun.');
    return l.tr('Be careful, seek support.', 'Dikkatli olun, destek alin.');
  }

  String _getScoreEmoji(int score) {
    if (score >= 80) return '💚';
    if (score >= 60) return '💛';
    if (score >= 40) return '🧡';
    return '❤️‍🩹';
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: accent ? theme.colorScheme.primary.withValues(alpha: 0.08) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: accent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: accent ? theme.colorScheme.primary : null,
                    ),
                    overflow: TextOverflow.ellipsis,
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

class _MoodDistributionChart extends StatelessWidget {
  const _MoodDistributionChart({
    required this.history,
    required this.theme,
  });

  final List<MoodLogModel> history;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final signalCounts = <MoodSignal, int>{};
    for (final log in history) {
      signalCounts[log.signal] = (signalCounts[log.signal] ?? 0) + 1;
    }

    final sections = signalCounts.entries.map((e) {
      final percentage = (e.value / history.length) * 100;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${percentage.round()}%',
        titleStyle: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        radius: 60,
        color: _signalColor(e.key),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 30,
              sectionsSpace: 2,
            ),
          ),
        ),
        const Gap(16),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: signalCounts.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _signalColor(e.key),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Gap(6),
                    Expanded(
                      child: Text(
                        '${e.key.emoji} ${e.value}',
                        style: theme.textTheme.labelSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _signalColor(MoodSignal signal) {
    switch (signal) {
      case MoodSignal.needHug:
        return const Color(0xFFE88A70);
      case MoodSignal.needSilence:
        return const Color(0xFF7BAFD4);
      case MoodSignal.needSpace:
        return const Color(0xFF6E6EA6);
      case MoodSignal.needTalk:
        return const Color(0xFF5DAE8B);
      case MoodSignal.exhausted:
        return const Color(0xFFB0B0B0);
      case MoodSignal.happy:
        return const Color(0xFFF5C242);
      case MoodSignal.anxious:
        return const Color(0xFFD47B7B);
      case MoodSignal.neutral:
        return const Color(0xFF8FC7B8);
    }
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({
    required this.history,
    required this.theme,
  });

  final List<MoodLogModel> history;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final recent = history.take(15).toList().reversed.toList();

    final energySpots = recent.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.energyLevel.toDouble());
    }).toList();

    final toleranceSpots = recent.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.toleranceLevel.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: energySpots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          LineChartBarData(
            spots: toleranceSpots,
            isCurved: true,
            color: theme.colorScheme.secondary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProFeatureTeaser extends StatelessWidget {
  const _ProFeatureTeaser({
    required this.title,
    required this.description,
    required this.theme,
  });

  final String title;
  final String description;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.subscription),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('👑', style: TextStyle(fontSize: 24)),
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const Gap(2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
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
          ),
        ),
      ),
    );
  }
}
