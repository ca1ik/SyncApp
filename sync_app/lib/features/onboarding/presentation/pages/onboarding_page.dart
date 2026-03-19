import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/locale_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<_OnboardingData> get _pages => [
        _OnboardingData(
          emoji: '💕',
          title: 'Sync',
          subtitle: l.tr('Emotional coordination for couples',
              'Ciftler icin duygusal koordinasyon'),
          body: l.tr(
              'Build fast, simple and real-time emotional connections during crisis moments.',
              'Kriz anlarinda hizli, sade ve gercek zamanli duygusal baglanti kurun.'),
          gradient: [Color(0xFFE88A6A), Color(0xFFF2B19A)],
        ),
        _OnboardingData(
          emoji: '🤝',
          title: l.tr('One-Touch Bridge', 'Tek Dokunusla Kopru'),
          subtitle: l.tr('Share with a single tap', 'One-Touch Bridge'),
          body: l.tr(
              'Share what you need with a single touch instead of long explanations. 8 different emotional signals.',
              'Uzun aciklamalar yerine tek dokunusla neye ihtiyaciniz oldugunu paylasin. 8 farkli duygusal sinyal.'),
          gradient: [Color(0xFF4DA8A0), Color(0xFF80C9C3)],
        ),
        _OnboardingData(
          emoji: '💡',
          title: l.tr('Micro Advice', 'Mikro Tavsiyeler'),
          subtitle: l.tr('Instant guidance', 'Anlik yonlendirme'),
          body: l.tr(
              'See short and actionable suggestions for what to do in difficult moments.',
              'Zor anlarda ne yapmaniz gerektigini kisa ve uygulanabilir onerilerle gorun.'),
          gradient: [Color(0xFF9B7EDE), Color(0xFFBBA2F0)],
        ),
        _OnboardingData(
          emoji: '🧘',
          title: l.tr('Breath & Calm', 'Nefes & Sakinlik'),
          subtitle: l.tr('Relax together', 'Birlikte rahatlayin'),
          body: l.tr(
              'Instantly reduce tension with breathing exercises and calming techniques.',
              'Nefes egzersizleri ve sakinlestirici tekniklerle gerginligi aninda azaltin.'),
          gradient: [Color(0xFF7DBD8C), Color(0xFFA8D9B0)],
        ),
        _OnboardingData(
          emoji: '📊',
          title: l.tr('Predict & Prevent', 'Tahmin Et & Engelle'),
          subtitle: 'Predict & Prevent',
          body: l.tr(
              'See mood patterns and detect trigger times early. Stay motivated with achievements.',
              'Mood paternlerini gorup tetikleyici saatleri erken fark edin. Basarimlarla motive olun.'),
          gradient: [Color(0xFFE88A6A), Color(0xFF9B7EDE)],
        ),
      ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingKey, true);
    await Get.offAllNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // ── Animated background ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _pages[_currentPage].gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // ── Page content ──
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      l.tr('Skip', 'Atla'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final data = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data.emoji,
                              style: const TextStyle(fontSize: 72),
                            )
                                .animate(key: ValueKey('emoji_$index'))
                                .scale(
                                  duration: 600.ms,
                                  curve: Curves.elasticOut,
                                )
                                .fadeIn(),
                            const Gap(24),
                            Text(
                              data.title,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                                .animate(key: ValueKey('title_$index'))
                                .fadeIn(delay: 150.ms, duration: 400.ms)
                                .slideY(begin: 0.2),
                            const Gap(8),
                            Text(
                              data.subtitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            )
                                .animate(key: ValueKey('sub_$index'))
                                .fadeIn(delay: 250.ms, duration: 400.ms),
                            const Gap(20),
                            Text(
                              data.body,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.6,
                              ),
                            )
                                .animate(key: ValueKey('body_$index'))
                                .fadeIn(delay: 350.ms, duration: 400.ms),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // ── Page indicator & CTA ──
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: i == _currentPage ? 28 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: i == _currentPage
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                      const Gap(24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLastPage
                              ? _completeOnboarding
                              : () => _pageController.nextPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _pages[_currentPage].gradient[0],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            isLastPage
                                ? l.tr('Let\'s Start', 'Baslayalim')
                                : l.tr('Continue', 'Devam'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.gradient,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String body;
  final List<Color> gradient;
}
