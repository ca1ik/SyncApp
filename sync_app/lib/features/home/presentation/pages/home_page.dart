import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/native_bridge_service.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../data/models/achievement_model.dart';
import '../../../../data/models/mood_log_model.dart';
import '../../../../data/repositories/gamification_repository.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../subscription/cubit/subscription_cubit.dart';
import '../../../sync_engine/bloc/sync_engine_bloc.dart';
import '../../../sync_engine/cubit/partner_mood_cubit.dart';

// ── Daily affirmation quotes ──
const List<String> _dailyQuotes = [
  '"Birbirinizi anlamak, birbirinizi sevmekten daha onemlidir." — Mevlana',
  '"Iyi bir iliski, birbirinizi dinlemeyle baslar."',
  '"Gercek guc, zamnalamaktir — ne zaman konusacagini, ne zaman susacagini bilmek."',
  '"Bugunku kucuk adim, yarinki buyuk farki yaratir."',
  '"Birlikte nefes alin, birlikte buyuyun."',
  '"Duygunuzu paylasmaniz, iliskinizin en buyuk gucudur."',
  '"Her gun bir sinyal — her sinyal bir kopru."',
  '"Empati, kelimelerin otesinde baslar."',
  '"Partnerinizin ihtiyacini bilmek, sevginin modern halidir."',
  '"Sakin kalmak cesaret, paylsmak guven ister."',
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final _noteController = TextEditingController();
  int _energyLevel = 62;
  int _toleranceLevel = 58;
  MoodSignal _selectedSignal = MoodSignal.neutral;
  bool _shareWithPartner = true;
  bool _showSubmitSuccess = false;
  int _relationshipScore = 50;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<PartnerMoodCubit>().start();
      context.read<SyncEngineBloc>().add(const SyncEngineStarted());
      await _loadRelationshipScore();
    });
  }

  Future<void> _loadRelationshipScore() async {
    final gamification = getIt<GamificationRepository>();
    final syncState = context.read<SyncEngineBloc>().state;
    final streak = await gamification.getStreak();
    final score = await gamification.getRelationshipScore(
      history: syncState.history,
      streak: streak,
    );
    if (mounted) setState(() => _relationshipScore = score);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitMood() async {
    final subState = context.read<SubscriptionCubit>().state;
    if (!subState.canSubmitMood) {
      _showUpgradeDialog();
      return;
    }

    HapticFeedback.mediumImpact();

    context.read<SyncEngineBloc>().add(
          MoodSubmitted(
            energyLevel: _energyLevel,
            toleranceLevel: _toleranceLevel,
            signal: _selectedSignal,
            note: _noteController.text,
            shareWithPartner: _shareWithPartner,
          ),
        );

    context.read<SubscriptionCubit>().incrementDailyMood();
    await getIt<NativeBridgeService>().refreshHomeWidget(_selectedSignal);

    // Gamification
    final gamification = getIt<GamificationRepository>();
    final streak = await gamification.recordEntry();
    final syncState = context.read<SyncEngineBloc>().state;
    final authState = context.read<AuthBloc>().state;
    final newAchievements = await gamification.checkAndUnlockAchievements(
      streak: streak,
      history: syncState.history,
      hasPartner: authState.user?.partnerUid != null,
      hasReport: syncState.triggerReport != null,
    );

    setState(() => _showSubmitSuccess = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSubmitSuccess = false);
    });

    // Show achievement notification
    for (final a in newAchievements) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(a.type.icon, style: const TextStyle(fontSize: 24)),
                const Gap(12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basarim Acildi!',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(a.type.title),
                    ],
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    await _loadRelationshipScore();
    _noteController.clear();
  }

  void _showUpgradeDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(20),
              const Text('👑', style: TextStyle(fontSize: 48)),
              const Gap(12),
              Text(
                'Gunluk mood limitine ulastiniz',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Gap(8),
              Text(
                'PRO ile sinirsiz mood girisi, gelismis analiz ve daha fazlasi!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Get.toNamed(AppRoutes.subscription);
                  },
                  child: const Text('PRO\'yu Kesfet'),
                ),
              ),
              const Gap(8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Yarin tekrar'),
              ),
              const Gap(8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = context.watch<AppThemeProvider>().activeGradient;

    return Scaffold(
      body: BlocListener<SyncEngineBloc, SyncEngineState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            // ── Gradient Header ──
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final name = state.user?.displayName ??
                                  state.user?.email ??
                                  'Kullanici';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Merhaba, $name 👋',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(duration: 500.ms)
                                      .slideX(begin: -0.1),
                                  const Gap(4),
                                  Text(
                                    _getDailyQuote(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.85),
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 2,
                                  )
                                      .animate()
                                      .fadeIn(delay: 200.ms, duration: 500.ms),
                                ],
                              );
                            },
                          ),
                        ),
                        const Gap(8),
                        // Streak Fire
                        FutureBuilder(
                          future: getIt<GamificationRepository>().getStreak(),
                          builder: (context, snapshot) {
                            final streak = snapshot.data;
                            if (streak == null || streak.currentStreak == 0) {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🔥',
                                      style: TextStyle(fontSize: 18)),
                                  const Gap(4),
                                  Text(
                                    '${streak.currentStreak}',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().scale(
                                duration: 600.ms, curve: Curves.elasticOut);
                          },
                        ),
                      ],
                    ),
                    const Gap(16),
                    // ── Relationship Score & Quick Stats ──
                    Row(
                      children: [
                        _StatBubble(
                          emoji: '💕',
                          label: 'Iliski',
                          value: '$_relationshipScore',
                        ),
                        const Gap(12),
                        BlocBuilder<SubscriptionCubit, SubscriptionState>(
                          builder: (context, state) {
                            return _StatBubble(
                              emoji: '📝',
                              label: 'Kalan',
                              value:
                                  state.isPro ? '∞' : '${state.remainingMoods}',
                            );
                          },
                        ),
                        const Gap(12),
                        BlocBuilder<SyncEngineBloc, SyncEngineState>(
                          builder: (context, state) {
                            return _StatBubble(
                              emoji: '📊',
                              label: 'Kayit',
                              value: '${state.history.length}',
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // ── Quick Mood Section ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hizli Sinyal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(12),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: MoodSignal.values.length,
                        separatorBuilder: (_, __) => const Gap(10),
                        itemBuilder: (context, index) {
                          final signal = MoodSignal.values[index];
                          final isSelected = _selectedSignal == signal;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedSignal = signal);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 72,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                        .withValues(alpha: 0.15)
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    signal.emoji,
                                    style: TextStyle(
                                      fontSize: isSelected ? 32 : 26,
                                    ),
                                  ),
                                  const Gap(4),
                                  Text(
                                    signal.name,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Mood Input Card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bolt_rounded,
                                color: theme.colorScheme.primary, size: 20),
                            const Gap(6),
                            Text(
                              'Enerji',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getEnergyColor(_energyLevel)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_energyLevel',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: _getEnergyColor(_energyLevel),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10),
                          ),
                          child: Slider(
                            value: _energyLevel.toDouble(),
                            min: 0,
                            max: 100,
                            divisions: 20,
                            onChanged: (v) =>
                                setState(() => _energyLevel = v.round()),
                          ),
                        ),
                        const Gap(8),
                        Row(
                          children: [
                            Icon(Icons.shield_rounded,
                                color: theme.colorScheme.secondary, size: 20),
                            const Gap(6),
                            Text(
                              'Tolerans',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getToleranceColor(_toleranceLevel)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_toleranceLevel',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: _getToleranceColor(_toleranceLevel),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10),
                          ),
                          child: Slider(
                            value: _toleranceLevel.toDouble(),
                            min: 0,
                            max: 100,
                            divisions: 20,
                            onChanged: (v) =>
                                setState(() => _toleranceLevel = v.round()),
                          ),
                        ),
                        const Gap(12),
                        TextField(
                          controller: _noteController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Kisa not (istege bagli)',
                            hintText: 'Duygunu bir cumleyle acikla...',
                            prefixIcon: const Icon(Icons.edit_note_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const Gap(12),
                        Row(
                          children: [
                            Expanded(
                              child: SwitchListTile.adaptive(
                                contentPadding: EdgeInsets.zero,
                                value: _shareWithPartner,
                                title: const Text('Partner ile paylas'),
                                subtitle: const Text('Sinyali gonder'),
                                onChanged: (v) =>
                                    setState(() => _shareWithPartner = v),
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _showSubmitSuccess
                                ? Container(
                                    key: const ValueKey('success'),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.green.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.check_circle,
                                              color: Colors.green),
                                          const Gap(8),
                                          Text(
                                            'Kaydedildi!',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).animate().scale(
                                      duration: 400.ms,
                                      curve: Curves.elasticOut,
                                    )
                                : ElevatedButton.icon(
                                    key: const ValueKey('submit'),
                                    onPressed: _submitMood,
                                    icon: const Icon(Icons.send_rounded),
                                    label: Text(
                                      'Mood Kaydet ${_selectedSignal.emoji}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              ),
            ),

            // ── Partner Status ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: BlocBuilder<PartnerMoodCubit, PartnerMoodState>(
                  builder: (context, state) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: state.hasLinkedPartner
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                const Gap(8),
                                Text(
                                  'Partner Durumu',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(12),
                            if (!state.hasLinkedPartner)
                              _PartnerLinkPrompt(theme: theme)
                            else if (state.mood == null)
                              Text(
                                'Paylasilan partner sinyali henuz yok.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Text(
                                    state.mood!.signal.emoji,
                                    style: const TextStyle(fontSize: 40),
                                  )
                                      .animate(
                                          onPlay: (c) =>
                                              c.repeat(reverse: true))
                                      .scale(
                                        begin: const Offset(1, 1),
                                        end: const Offset(1.1, 1.1),
                                        duration: 2000.ms,
                                      ),
                                  const Gap(12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.mood!.signal.label,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (state.mood!.note != null &&
                                            state.mood!.note!.isNotEmpty)
                                          Text(
                                            state.mood!.note!,
                                            style: theme.textTheme.bodySmall,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
                  },
                ),
              ),
            ),

            // ── Micro Advice ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: BlocBuilder<SyncEngineBloc, SyncEngineState>(
                  builder: (context, state) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('💡',
                                    style: TextStyle(fontSize: 20)),
                                const Gap(8),
                                Text(
                                  'Mikro Tavsiye',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(12),
                            Text(
                              state.microAdvice ??
                                  'Mood girisi yaptiginizda kisisel oneriler burada gorunecek.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.75),
                                height: 1.5,
                              ),
                            ),
                            if (state.triggerReport != null) ...[
                              const Gap(12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Text('📊',
                                        style: TextStyle(fontSize: 18)),
                                    const Gap(8),
                                    Expanded(
                                      child: Text(
                                        state.triggerReport!.summaryText,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const Gap(12),
                            BlocBuilder<SubscriptionCubit, SubscriptionState>(
                              builder: (context, subState) {
                                return Row(
                                  children: [
                                    if (subState.canGenerateReport)
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => context
                                              .read<SyncEngineBloc>()
                                              .add(
                                                  const TriggerReportRequested()),
                                          icon: const Icon(
                                              Icons.analytics_outlined,
                                              size: 18),
                                          label: const Text('Tetik raporu'),
                                        ),
                                      )
                                    else
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => Get.toNamed(
                                              AppRoutes.subscription),
                                          icon: const Icon(Icons.lock_outline,
                                              size: 18),
                                          label:
                                              const Text('PRO: Tetik raporu'),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
                  },
                ),
              ),
            ),

            // ── Quick Actions Grid ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hizli Erisim',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: '🧘',
                            label: 'Nefes',
                            theme: theme,
                            onTap: () => Get.toNamed(AppRoutes.breathing),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: _QuickAction(
                            icon: '🎮',
                            label: 'Oyunlar',
                            theme: theme,
                            onTap: () => Get.toNamed(AppRoutes.gamesHub),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: _QuickAction(
                            icon: '📊',
                            label: 'Dashboard',
                            theme: theme,
                            onTap: () => Get.toNamed(AppRoutes.dashboard),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: _QuickAction(
                            icon: '🏆',
                            label: 'Basarimlar',
                            theme: theme,
                            onTap: () => Get.toNamed(AppRoutes.achievements),
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: '💬',
                            label: 'Soru-Cevap',
                            theme: theme,
                            onTap: () => Get.toNamed(AppRoutes.qaSystem),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: _QuickAction(
                            icon: '👑',
                            label: 'PRO',
                            theme: theme,
                            onTap: () => Get.toNamed(AppRoutes.subscription),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: _QuickAction(
                            icon: '💕',
                            label: 'Iliski Kocu',
                            theme: theme,
                            onTap: () => Get.toNamed(AppRoutes.aiAssistant),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: _QuickAction(
                            icon: '🔮',
                            label: 'Burc',
                            theme: theme,
                            onTap: () => Get.toNamed(AppRoutes.aiAssistant),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: Gap(100)),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              break; // Already on home
            case 1:
              Get.toNamed(AppRoutes.dashboard);
            case 2:
              Get.toNamed(AppRoutes.breathing);
            case 3:
              Get.toNamed(AppRoutes.settings);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Analiz',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement_outlined),
            selectedIcon: Icon(Icons.self_improvement_rounded),
            label: 'Nefes',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }

  String _getDailyQuote() {
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return _dailyQuotes[dayOfYear % _dailyQuotes.length];
  }

  Color _getEnergyColor(int level) {
    if (level < 30) return Colors.red;
    if (level < 60) return Colors.orange;
    return Colors.green;
  }

  Color _getToleranceColor(int level) {
    if (level < 30) return Colors.red;
    if (level < 60) return Colors.orange;
    return Colors.teal;
  }
}

class _StatBubble extends StatelessWidget {
  const _StatBubble({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const Gap(6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PartnerLinkPrompt extends StatelessWidget {
  const _PartnerLinkPrompt({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🔗', style: TextStyle(fontSize: 28)),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Partneri bagla',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(2),
                Text(
                  'Birlikte kullanin, birlikte buyuyun.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.partnerLink),
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.colorScheme.primary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.theme,
    required this.onTap,
  });

  final String icon;
  final String label;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const Gap(6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
