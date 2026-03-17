import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/native_bridge_service.dart';
import '../../../../data/models/mood_log_model.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../sync_engine/bloc/sync_engine_bloc.dart';
import '../../../sync_engine/cubit/partner_mood_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _noteController = TextEditingController();
  int _energyLevel = 62;
  int _toleranceLevel = 58;
  MoodSignal _selectedSignal = MoodSignal.neutral;
  bool _shareWithPartner = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartnerMoodCubit>().start();
      context.read<SyncEngineBloc>().add(const SyncEngineStarted());
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitMood() async {
    context.read<SyncEngineBloc>().add(
          MoodSubmitted(
            energyLevel: _energyLevel,
            toleranceLevel: _toleranceLevel,
            signal: _selectedSignal,
            note: _noteController.text,
            shareWithPartner: _shareWithPartner,
          ),
        );
    await getIt<NativeBridgeService>().refreshHomeWidget(_selectedSignal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Home'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.dashboard),
            icon: const Icon(Icons.insights_outlined),
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.settings),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final name =
                    state.user?.displayName ?? state.user?.email ?? 'Kullanici';
                return Text(
                  'Bugun nasil hissediyorsun, $name?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                );
              },
            ),
            const Gap(16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enerji: $_energyLevel'),
                    Slider(
                      value: _energyLevel.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      onChanged: (value) {
                        setState(() {
                          _energyLevel = value.round();
                        });
                      },
                    ),
                    const Gap(12),
                    Text('Tolerans: $_toleranceLevel'),
                    Slider(
                      value: _toleranceLevel.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      onChanged: (value) {
                        setState(() {
                          _toleranceLevel = value.round();
                        });
                      },
                    ),
                    const Gap(16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MoodSignal.values
                          .map(
                            (signal) => ChoiceChip(
                              label: Text('${signal.emoji} ${signal.name}'),
                              selected: _selectedSignal == signal,
                              onSelected: (_) {
                                setState(() {
                                  _selectedSignal = signal;
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const Gap(16),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Kisa not',
                        hintText:
                            'Isterseniz durumunuzu bir cümleyle netlestirin',
                      ),
                    ),
                    const Gap(12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _shareWithPartner,
                      title: const Text('Partner ile paylas'),
                      subtitle:
                          const Text('Sinyal partner kartinda guncellenir'),
                      onChanged: (value) {
                        setState(() {
                          _shareWithPartner = value;
                        });
                      },
                    ),
                    const Gap(12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitMood,
                        child: const Text('Mood kaydet ve senkronize et'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(16),
            BlocBuilder<PartnerMoodCubit, PartnerMoodState>(
              builder: (context, state) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Partner durumu',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Gap(10),
                        if (!state.hasLinkedPartner)
                          Text(state.message ?? 'Partner baglantisi yok')
                        else if (state.mood == null)
                          const Text('Paylasilan partner sinyali henuz yok.')
                        else
                          Text(
                            '${state.mood!.signal.emoji} ${state.mood!.signal.label}',
                            style: theme.textTheme.titleLarge,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Gap(16),
            BlocBuilder<SyncEngineBloc, SyncEngineState>(
              builder: (context, state) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Micro Advice',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Gap(10),
                        Text(
                          state.microAdvice ??
                              'Son mood girisinizden sonra burada kisa bir yonlendirme gorunecek.',
                        ),
                        const Gap(16),
                        OutlinedButton(
                          onPressed: () => context
                              .read<SyncEngineBloc>()
                              .add(const TriggerReportRequested()),
                          child: const Text('Trigger raporu olustur'),
                        ),
                        if (state.triggerReport != null) ...[
                          const Gap(12),
                          Text(state.triggerReport!.summaryText),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
