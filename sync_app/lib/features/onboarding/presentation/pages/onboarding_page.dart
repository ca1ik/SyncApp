import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingKey, true);
    await Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'Sync',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Gap(12),
              Text(
                'Ciftler icin kriz anlarinda hizli, sade ve gercek zamanli duygusal koordinasyon.',
                style: theme.textTheme.titleMedium,
              ),
              const Gap(32),
              const _InfoCard(
                title: 'One-Touch Bridge',
                body:
                    'Uzun aciklamalar yerine tek dokunusla neye ihtiyaciniz oldugunu paylasin.',
              ),
              const Gap(16),
              const _InfoCard(
                title: 'Micro Advice',
                body:
                    'Zor anda ne yapmaniz gerektigini kisa ve uygulanabilir onerilerle gorun.',
              ),
              const Gap(16),
              const _InfoCard(
                title: 'Predict and Prevent',
                body:
                    'Mood paternlerini gorup tetikleyici saatleri erken fark edin.',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Baslayalim'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(8),
            Text(body),
          ],
        ),
      ),
    );
  }
}
