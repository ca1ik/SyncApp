import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../cubit/subscription_cubit.dart';
import '../../../../core/services/locale_service.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = context.read<AppThemeProvider>().activeGradient;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: gradient),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Gap(40),
                      Text(
                        '👑',
                        style: const TextStyle(fontSize: 48),
                      ).animate().scale(
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          ),
                      const Gap(8),
                      Text(
                        'Sync PRO',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3),
                      Text(
                        l.tr('Take your relationship to the next level',
                            'Iliskinizi bir ust seviyeye tasiyin'),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _ComparisonTable(theme: theme),
                  const Gap(24),
                  _ProFeatureCard(
                    icon: '🔓',
                    title:
                        l.tr('Unlimited Mood Entries', 'Sinirsiz Mood Girisi'),
                    description: l.tr(
                        'Record mood as much as you want without daily limits.',
                        'Gunluk limit olmadan istediginiz kadar mood kaydedin.'),
                    theme: theme,
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                  const Gap(12),
                  _ProFeatureCard(
                    icon: '📊',
                    title: l.tr('Advanced Analysis & Reports',
                        'Gelismis Analiz & Raporlar'),
                    description: l.tr(
                        'Trigger report, weekly trend analysis and conflict risk score.',
                        'Tetikleyici raporu, haftalik trend analizi ve cakisma riski skoru.'),
                    theme: theme,
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                  const Gap(12),
                  _ProFeatureCard(
                    icon: '🧘',
                    title: l.tr('Unlimited Breathing Exercises',
                        'Sinirsiz Nefes Egzersizi'),
                    description: l.tr(
                        'Calm down with different breathing techniques, exercise together.',
                        'Farkli nefes teknikleri ile sakinlesin, birlikte egzersiz yapin.'),
                    theme: theme,
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                  const Gap(12),
                  _ProFeatureCard(
                    icon: '💡',
                    title: l.tr('Deep Insights', 'Derin Iclgorular'),
                    description: l.tr(
                        'See patterns in your relationship, discover strengthening and challenging moments.',
                        'Iliskinizdeki paternleri gorun, guclendiren ve zorlayan anlari kesfein.'),
                    theme: theme,
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                  const Gap(12),
                  _ProFeatureCard(
                    icon: '🏆',
                    title: l.tr('Special Achievements', 'Ozel Basarimlar'),
                    description: l.tr(
                        'Unlock PRO exclusive achievements and track your progress.',
                        'PRO Ozel basarimlarin kilidini acin ve ilerlemenizi takip edin.'),
                    theme: theme,
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                  const Gap(32),
                  BlocBuilder<SubscriptionCubit, SubscriptionState>(
                    builder: (context, state) {
                      if (state.isPro) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              const Text('✅', style: TextStyle(fontSize: 32)),
                              const Gap(8),
                              Text(
                                l.tr('PRO Active!', 'PRO Aktif!'),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                l.tr('You are enjoying all features.',
                                    'Tum ozelliklerden yararlaniyorsunuz.'),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ).animate().shimmer(
                              duration: 2000.ms,
                              color: Colors.white.withValues(alpha: 0.15),
                            );
                      }
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<SubscriptionCubit>().togglePro();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: Text(
                                l.tr('Upgrade to PRO', 'PRO\'ya Yukselt'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ).animate().scale(
                              delay: 600.ms,
                              duration: 400.ms,
                              curve: Curves.elasticOut),
                          const Gap(12),
                          Text(
                            l.tr('You can cancel anytime',
                                'Istediginiz zaman iptal edebilirsiniz'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Gap(32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              l.tr('Plan Comparison', 'Plan Karsilastirmasi'),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(16),
            _row(l.tr('Daily mood entries', 'Gunluk mood girisi'),
                l.tr('5 / day', '5 / gun'), l.tr('Unlimited', 'Sinirsiz')),
            const Divider(height: 16),
            _row(l.tr('Mood history', 'Mood gecmisi'),
                l.tr('Last 10', 'Son 10'), l.tr('All', 'Tumu')),
            const Divider(height: 16),
            _row(l.tr('Micro advice', 'Mikro tavsiyeler'), '✅',
                l.tr('✅ Personal', '✅ Kisisel')),
            const Divider(height: 16),
            _row(l.tr('Trigger analysis', 'Tetik analizi'), '❌', '✅'),
            const Divider(height: 16),
            _row(
                l.tr('Breathing exercise', 'Nefes egzersizi'),
                l.tr('1 technique', '1 teknik'),
                l.tr('All techniques', 'Tum teknikler')),
            const Divider(height: 16),
            _row(l.tr('Deep insights', 'Derin icgorular'), '❌', '✅'),
            const Divider(height: 16),
            _row(l.tr('Special achievements', 'Ozel basarimlar'),
                l.tr('Basic', 'Temel'), l.tr('All', 'Tumu')),
            const Divider(height: 16),
            _row(l.tr('Relationship score', 'Iliski skoru'),
                l.tr('Basic', 'Temel'), l.tr('Detailed', 'Detayli')),
          ],
        ),
      ),
    );
  }

  Widget _row(String feature, String free, String pro) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(feature, style: theme.textTheme.bodyMedium),
        ),
        Expanded(
          flex: 2,
          child: Text(
            free,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            pro,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProFeatureCard extends StatelessWidget {
  const _ProFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.theme,
  });

  final String icon;
  final String title;
  final String description;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
