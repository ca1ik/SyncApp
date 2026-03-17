import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../data/models/mood_log_model.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../subscription/cubit/subscription_cubit.dart';
import '../../../sync_engine/bloc/sync_engine_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              return _MetricCard(
                title: 'Hesap durumu',
                value: authState.user?.displayName ??
                    authState.user?.email ??
                    'Misafir',
                subtitle: authState.user?.partnerUid == null
                    ? 'Partner baglantisi eksik'
                    : 'Partner baglantisi aktif',
              );
            },
          ),
          const Gap(12),
          BlocBuilder<SubscriptionCubit, SubscriptionState>(
            builder: (context, subscriptionState) {
              return _MetricCard(
                title: 'Plan',
                value: subscriptionState.isPro ? 'PRO aktif' : 'Standart',
                subtitle: subscriptionState.isPro
                    ? 'Gelistirilmis analiz acik'
                    : 'Yerel tavsiyeler kullaniliyor',
              );
            },
          ),
          const Gap(12),
          BlocBuilder<SyncEngineBloc, SyncEngineState>(
            builder: (context, state) {
              return _MetricCard(
                title: 'Son sinyal',
                value: state.latestMood?.signal.label ?? 'Henüz veri yok',
                subtitle: 'Kayitli mood girisi: ${state.history.length}',
              );
            },
          ),
          const Gap(20),
          Text(
            'Gecmis',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(12),
          BlocBuilder<SyncEngineBloc, SyncEngineState>(
            builder: (context, state) {
              if (state.history.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Henüz mood kaydi bulunmuyor.'),
                  ),
                );
              }
              return Column(
                children: state.history
                    .take(8)
                    .map(
                      (log) => Card(
                        child: ListTile(
                          leading: Text(log.signal.emoji,
                              style: const TextStyle(fontSize: 24)),
                          title: Text(log.signal.label),
                          subtitle: Text(
                            'Enerji ${log.energyLevel} • Tolerans ${log.toleranceLevel}',
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.labelLarge),
            const Gap(8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Gap(4),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}
