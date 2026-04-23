import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/di/injection.dart';
import '../../data/services/ads_service.dart';
import '../../features/subscription/cubit/subscription_cubit.dart';

/// PRO/NoAds olmayan kullanıcılara banner reklam gösterir.
/// PRO/NoAds için `SizedBox.shrink()` döner — ekranı tıkamaz.
class AdaptiveBannerAd extends StatefulWidget {
  const AdaptiveBannerAd({super.key, this.padding = EdgeInsets.zero});

  final EdgeInsets padding;

  @override
  State<AdaptiveBannerAd> createState() => _AdaptiveBannerAdState();
}

class _AdaptiveBannerAdState extends State<AdaptiveBannerAd> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final ads = getIt<AdsService>();
    _ad = ads.createBanner()
      ..load().then((_) {
        if (mounted) setState(() => _loaded = true);
      }).catchError((_) {
        if (mounted) setState(() => _loaded = false);
      });
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        if (!state.shouldShowAds || !_loaded || _ad == null) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: widget.padding,
          child: SizedBox(
            width: _ad!.size.width.toDouble(),
            height: _ad!.size.height.toDouble(),
            child: AdWidget(ad: _ad!),
          ),
        );
      },
    );
  }
}
