import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: themeProvider.activeGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'Arayuz temi ve plan tercihlerini buradan yonetin.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Gap(20),
          Text('Tema', style: theme.textTheme.titleLarge),
          const Gap(12),
          ...SyncThemeVariant.values.map(
            (variant) => Card(
              child: ListTile(
                title: Text(variant.name),
                trailing: themeProvider.variant == variant
                    ? Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                      )
                    : const Icon(Icons.circle_outlined),
                onTap: () => themeProvider.setTheme(variant),
              ),
            ),
          ),
          const Gap(20),
          Text('Plan', style: theme.textTheme.titleLarge),
          const Gap(12),
          BlocBuilder<SubscriptionCubit, SubscriptionState>(
            builder: (context, state) {
              return SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: const Text('PRO modu'),
                subtitle: Text(
                  state.isPro
                      ? 'Gelismis analiz ozellikleri aktif gorunuyor.'
                      : 'Yerel mod ve temel analiz aktif.',
                ),
                value: state.isPro,
                onChanged: (_) => context.read<SubscriptionCubit>().togglePro(),
              );
            },
          ),
          const Gap(20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthSignOutRequested());
                Get.offAllNamed(AppRoutes.login);
              },
              child: const Text('Cikis yap'),
            ),
          ),
        ],
      ),
    );
  }
}
