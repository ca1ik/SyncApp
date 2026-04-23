import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

/// AdMob reklam servisi — banner, interstitial, rewarded.
///
/// **ÖNEMLİ:** Aşağıdaki ID'ler Google'ın resmi TEST ID'leridir.
/// Yayına almadan önce AdMob konsolundaki gerçek ID'ler ile
/// `release` ortamında değiştirin (env veya build flavor önerilir).
///
/// Test ID listesi:
/// https://developers.google.com/admob/android/test-ads
class AdsService {
  AdsService(this._logger);

  final Logger _logger;

  // ── Reklam birim kimlikleri ───────────────────────────────────────
  // Sadece Android — iOS için ayrıca tanımlayın.
  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';

  // TODO: Gerçek ID'leri AdMob konsolundan alıp aşağıdakilerle değiştirin.
  static const String _prodBannerAndroid =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodInterstitialAndroid =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodRewardedAndroid =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // Geliştirme sırasında daima TEST ID kullan. Yayına çıkarken false yap.
  static const bool kUseTestAds = true;

  String get bannerId => Platform.isAndroid
      ? (kUseTestAds ? _testBannerAndroid : _prodBannerAndroid)
      : '';
  String get interstitialId => Platform.isAndroid
      ? (kUseTestAds ? _testInterstitialAndroid : _prodInterstitialAndroid)
      : '';
  String get rewardedId => Platform.isAndroid
      ? (kUseTestAds ? _testRewardedAndroid : _prodRewardedAndroid)
      : '';

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;

  /// SDK'yı başlat. main()'de bir kez çağrılır.
  Future<void> init() async {
    await MobileAds.instance.initialize();
    _logger.i('[Ads] MobileAds başlatıldı.');
    // Aşağıdaki cihazlar geliştirme/test için "test cihazı" olarak işaretlenir.
    // Production'da boşaltın.
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: const []),
    );
    _preloadInterstitial();
    _preloadRewarded();
  }

  // ── Banner ────────────────────────────────────────────────────────
  BannerAd createBanner({AdSize size = AdSize.banner}) {
    return BannerAd(
      adUnitId: bannerId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, err) {
          _logger.w('[Ads] Banner load hatası: $err');
          ad.dispose();
        },
      ),
    );
  }

  // ── Interstitial ──────────────────────────────────────────────────
  void _preloadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (err) =>
            _logger.w('[Ads] Interstitial load hatası: $err'),
      ),
    );
  }

  /// Geçiş reklamı göster — yoksa sessizce geç.
  Future<void> showInterstitial() async {
    final ad = _interstitial;
    if (ad == null) return;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        _preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _interstitial = null;
        _preloadInterstitial();
      },
    );
    await ad.show();
    _interstitial = null;
  }

  // ── Rewarded ──────────────────────────────────────────────────────
  void _preloadRewarded() {
    RewardedAd.load(
      adUnitId: rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (err) =>
            _logger.w('[Ads] Rewarded load hatası: $err'),
      ),
    );
  }

  /// Ödüllü reklam göster — kullanıcı ödülü hak ederse [onReward] çağrılır.
  Future<void> showRewarded(
      {required void Function(int amount) onReward}) async {
    final ad = _rewarded;
    if (ad == null) {
      _logger.w('[Ads] Rewarded hazır değil.');
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        _preloadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _rewarded = null;
        _preloadRewarded();
      },
    );
    await ad.show(onUserEarnedReward: (ad, reward) {
      onReward(reward.amount.toInt());
    });
    _rewarded = null;
  }

  void dispose() {
    _interstitial?.dispose();
    _rewarded?.dispose();
  }
}
