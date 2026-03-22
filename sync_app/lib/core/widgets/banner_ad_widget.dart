import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/subscription/cubit/subscription_cubit.dart';
import '../services/locale_service.dart';

/// A mock banner ad widget that shows promotional content for free users.
/// Automatically hidden when user has PRO or NoAds subscription.
/// Replace inner content with real AdMob BannerAd when integrating google_mobile_ads.
class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  static const double bannerHeight = 60;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        if (!state.shouldShowAds) return const SizedBox.shrink();
        return const _MockBannerAd();
      },
    );
  }
}

class _MockBannerAd extends StatefulWidget {
  const _MockBannerAd();

  @override
  State<_MockBannerAd> createState() => _MockBannerAdState();
}

class _MockBannerAdState extends State<_MockBannerAd> {
  late final int _adIndex;

  static final List<_AdContent> _ads = [
    _AdContent(
      icon: '👑',
      gradient: [const Color(0xFFFFA726), const Color(0xFFFF7043)],
      textEn: 'Upgrade to PRO — Unlock all features!',
      textTr: 'PRO\'ya yukselt — Tum ozelliklerin kilidini ac!',
    ),
    _AdContent(
      icon: '🚫',
      gradient: [const Color(0xFF42A5F5), const Color(0xFF7E57C2)],
      textEn: 'Remove Ads — Only ₺50/month',
      textTr: 'Reklamlari kaldir — Aylik sadece ₺50',
    ),
    _AdContent(
      icon: '🎮',
      gradient: [const Color(0xFF66BB6A), const Color(0xFF26A69A)],
      textEn: 'Play 20+ Arena Games with PRO!',
      textTr: 'PRO ile 20+ Arena Oyunu oyna!',
    ),
    _AdContent(
      icon: '🧘',
      gradient: [const Color(0xFFAB47BC), const Color(0xFFEC407A)],
      textEn: 'Unlock all breathing exercises',
      textTr: 'Tum nefes egzersizlerinin kilidini ac',
    ),
    _AdContent(
      icon: '📊',
      gradient: [const Color(0xFF29B6F6), const Color(0xFF26C6DA)],
      textEn: 'Deep relationship insights await',
      textTr: 'Derin iliski icgoruleri seni bekliyor',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _adIndex = Random().nextInt(_ads.length);
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ads[_adIndex];
    return Container(
      width: double.infinity,
      height: BannerAdWidget.bannerHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: ad.gradient),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed('/subscription'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(ad.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.tr(ad.textEn, ad.textTr),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l.tr('Ad', 'Reklam'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdContent {
  const _AdContent({
    required this.icon,
    required this.gradient,
    required this.textEn,
    required this.textTr,
  });

  final String icon;
  final List<Color> gradient;
  final String textEn;
  final String textTr;
}
