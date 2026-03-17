import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../data/repositories/gamification_repository.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../subscription/cubit/subscription_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<AppThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Account & streak summary ──
          FutureBuilder(
            future: getIt<GamificationRepository>().getStreak(),
            builder: (context, snap) {
              final streak = snap.data;
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: themeProvider.activeGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hosgeldin 👋',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'Tercih ve plan ayarlarin burada.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (streak != null && streak.currentStreak > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 20)),
                            const Gap(4),
                            Text(
                              '${streak.currentStreak}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
            },
          ),
          const Gap(24),

          // ── Quick actions ──
          Text('Hizli Erisim',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  emoji: '🧘',
                  label: 'Nefes',
                  onTap: () => Get.toNamed(AppRoutes.breathing),
                ),
              ),
              const Gap(12),
              Expanded(
                child: _QuickActionCard(
                  emoji: '🏆',
                  label: 'Basarimlar',
                  onTap: () => Get.toNamed(AppRoutes.achievements),
                ),
              ),
              const Gap(12),
              Expanded(
                child: _QuickActionCard(
                  emoji: '👑',
                  label: 'PRO',
                  onTap: () => Get.toNamed(AppRoutes.subscription),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.1),
          const Gap(24),

          // ── Theme selector ──
          Text('Tema',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const Gap(12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: SyncThemeVariant.values
                  .map((variant) => _ThemePreviewCard(
                        variant: variant,
                        isSelected: themeProvider.variant == variant,
                        onTap: () => themeProvider.setTheme(variant),
                      ))
                  .toList(),
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.1),
          const Gap(24),

          // ── Pro plan ──
          Text('Plan',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const Gap(12),
          BlocBuilder<SubscriptionCubit, SubscriptionState>(
            builder: (context, state) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: state.isPro
                      ? BorderSide(color: theme.colorScheme.primary, width: 2)
                      : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: state.isPro
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.15)
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              state.isPro ? '👑' : '🆓',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.isPro ? 'PRO Aktif' : 'Ucretsiz Plan',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Gap(2),
                                Text(
                                  state.isPro
                                      ? 'Tum ozellikler aktif'
                                      : 'Gunluk ${SubscriptionState.freeDailyLimit} mood, sinirli ozellikler',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: state.isPro,
                            onChanged: (_) =>
                                context.read<SubscriptionCubit>().togglePro(),
                          ),
                        ],
                      ),
                      if (!state.isPro) ...[
                        const Gap(12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                            onPressed: () =>
                                Get.toNamed(AppRoutes.subscription),
                            child: const Text('PRO\'ya Yukselt'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          const Gap(24),

          // ── App info ──
          _SettingTile(
            icon: Icons.info_outline,
            label: 'Uygulama Hakkinda',
            trailing: Text('v1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            onTap: () {},
          ),
          _SettingTile(
            icon: Icons.share_outlined,
            label: 'Arkadasa Oner',
            onTap: () {},
          ),
          const Gap(16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthSignOutRequested());
                Get.offAllNamed(AppRoutes.login);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cikis Yap'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          const Gap(32),
        ],
      ),
    );
  }
}

// ── Quick action card ──
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const Gap(4),
            Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Theme preview card ──
class _ThemePreviewCard extends StatelessWidget {
  const _ThemePreviewCard({
    required this.variant,
    required this.isSelected,
    required this.onTap,
  });

  final SyncThemeVariant variant;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = switch (variant) {
      SyncThemeVariant.calmSunset => [
          AppTheme.sunsetPrimary,
          AppTheme.sunsetSecondary
        ],
      SyncThemeVariant.oceanBreeze => [
          AppTheme.oceanPrimary,
          AppTheme.oceanSecondary
        ],
      SyncThemeVariant.midnightSoft => [
          AppTheme.midnightPrimary,
          AppTheme.midnightSecondary
        ],
      SyncThemeVariant.morningDew => [
          const Color(0xFF7DBD8C),
          const Color(0xFFA8D9B0)
        ],
      SyncThemeVariant.rosePetal => [
          const Color(0xFFE06B8F),
          const Color(0xFFF2A3B8)
        ],
      SyncThemeVariant.lavenderDream => [
          const Color(0xFF8B7EC8),
          const Color(0xFFB5A8E0)
        ],
      SyncThemeVariant.cherryBlossom => [
          const Color(0xFFD4869C),
          const Color(0xFFF0B6C8)
        ],
      SyncThemeVariant.goldenHour => [
          const Color(0xFFD4A843),
          const Color(0xFFECC872)
        ],
      SyncThemeVariant.arcticAurora => [
          const Color(0xFF5AA5C8),
          const Color(0xFF7DD4C8)
        ],
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 3)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
            const Gap(4),
            Text(
              variant.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Generic setting tile ──
class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
