import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/services/billing_service.dart';

class SubscriptionState extends Equatable {
  const SubscriptionState({
    this.isLoading = false,
    this.isPro = false,
    this.isNoAds = false,
    this.dailyMoodCount = 0,
    this.dailyCoachAiCount = 0,
    this.dailyAstroAiCount = 0,
    this.lastResetDate,
  });

  final bool isLoading;
  final bool isPro;
  final bool isNoAds;
  final int dailyMoodCount;
  final int dailyCoachAiCount;
  final int dailyAstroAiCount;
  final String? lastResetDate;

  static const int freeDailyLimit = 10;
  static const int freeHistoryLimit = 30;
  static const int freeAiDailyLimit = 1;
  static const double noAdsPriceMonthly = 50.0; // TL

  bool get canSubmitMood => isPro || dailyMoodCount < freeDailyLimit;
  int get remainingMoods =>
      isPro ? 999 : (freeDailyLimit - dailyMoodCount).clamp(0, freeDailyLimit);
  bool get canViewFullHistory => isPro;
  bool get canGenerateReport => true; // Free: basic, Pro: detailed
  bool get canUseBreathing => true; // Free: 3 techniques, Pro: all
  bool get canViewInsights => true; // Free: basic, Pro: deep
  bool get hasAdvancedAnalytics => isPro;

  /// AI assistant daily gates
  bool get canUseCoachAi => isPro || dailyCoachAiCount < freeAiDailyLimit;
  bool get canUseAstroAi => isPro || dailyAstroAiCount < freeAiDailyLimit;
  int get remainingCoachAi => isPro
      ? 999
      : (freeAiDailyLimit - dailyCoachAiCount).clamp(0, freeAiDailyLimit);
  int get remainingAstroAi => isPro
      ? 999
      : (freeAiDailyLimit - dailyAstroAiCount).clamp(0, freeAiDailyLimit);

  /// PRO users automatically get ad-free experience
  bool get shouldShowAds => !isPro && !isNoAds;

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isPro,
    bool? isNoAds,
    int? dailyMoodCount,
    int? dailyCoachAiCount,
    int? dailyAstroAiCount,
    String? lastResetDate,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isPro: isPro ?? this.isPro,
      isNoAds: isNoAds ?? this.isNoAds,
      dailyMoodCount: dailyMoodCount ?? this.dailyMoodCount,
      dailyCoachAiCount: dailyCoachAiCount ?? this.dailyCoachAiCount,
      dailyAstroAiCount: dailyAstroAiCount ?? this.dailyAstroAiCount,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isPro,
        isNoAds,
        dailyMoodCount,
        dailyCoachAiCount,
        dailyAstroAiCount,
        lastResetDate,
      ];
}

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({
    required SharedPreferences prefs,
    required BillingService billing,
  })  : _prefs = prefs,
        _billing = billing,
        super(const SubscriptionState());

  final SharedPreferences _prefs;
  final BillingService _billing;
  static const String _proKey = 'sync_is_pro';
  static const String _noAdsKey = 'sync_is_no_ads';
  static const String _dailyCountKey = 'sync_daily_mood_count';
  static const String _dailyCoachAiKey = 'sync_daily_coach_ai_count';
  static const String _dailyAstroAiKey = 'sync_daily_astro_ai_count';
  static const String _lastResetKey = 'sync_last_reset_date';

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    _checkDailyReset();
    emit(
      state.copyWith(
        isLoading: false,
        isPro: _prefs.getBool(_proKey) ?? false,
        isNoAds: _prefs.getBool(_noAdsKey) ?? false,
        dailyMoodCount: _prefs.getInt(_dailyCountKey) ?? 0,
        dailyCoachAiCount: _prefs.getInt(_dailyCoachAiKey) ?? 0,
        dailyAstroAiCount: _prefs.getInt(_dailyAstroAiKey) ?? 0,
        lastResetDate: _prefs.getString(_lastResetKey),
      ),
    );

    // Billing servisini başlat ve satın alma akışını dinle
    await _billing.init(onPurchaseUpdated: _handlePurchase);
  }

  /// Play Store'dan gelen satın alımı işle.
  void _handlePurchase(PurchaseDetails purchase) {
    switch (purchase.productID) {
      case BillingService.kProMonthlyId:
      case BillingService.kProYearlyId:
        _prefs.setBool(_proKey, true);
        emit(state.copyWith(isPro: true));
        break;
      case BillingService.kNoAdsMonthlyId:
        _prefs.setBool(_noAdsKey, true);
        emit(state.copyWith(isNoAds: true));
        break;
    }
  }

  /// Belirli bir ürünü satın al (ekrandan tetiklenir).
  Future<void> purchase(String productId) =>
      _billing.buy(productId).then((_) {});

  /// Önceki abonelikleri geri yükle.
  Future<void> restore() => _billing.restore();

  /// Geliştirme amaçlı: PRO durumunu manuel değiştir.
  Future<void> togglePro() async {
    final next = !state.isPro;
    await _prefs.setBool(_proKey, next);
    emit(state.copyWith(isPro: next));
  }

  Future<void> toggleNoAds() async {
    final next = !state.isNoAds;
    await _prefs.setBool(_noAdsKey, next);
    emit(state.copyWith(isNoAds: next));
  }

  Future<void> incrementDailyMood() async {
    _checkDailyReset();
    final newCount = state.dailyMoodCount + 1;
    await _prefs.setInt(_dailyCountKey, newCount);
    emit(state.copyWith(dailyMoodCount: newCount));
  }

  Future<void> incrementCoachAi() async {
    _checkDailyReset();
    final newCount = state.dailyCoachAiCount + 1;
    await _prefs.setInt(_dailyCoachAiKey, newCount);
    emit(state.copyWith(dailyCoachAiCount: newCount));
  }

  Future<void> incrementAstroAi() async {
    _checkDailyReset();
    final newCount = state.dailyAstroAiCount + 1;
    await _prefs.setInt(_dailyAstroAiKey, newCount);
    emit(state.copyWith(dailyAstroAiCount: newCount));
  }

  void _checkDailyReset() {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastReset = _prefs.getString(_lastResetKey);
    if (lastReset != todayStr) {
      _prefs.setInt(_dailyCountKey, 0);
      _prefs.setInt(_dailyCoachAiKey, 0);
      _prefs.setInt(_dailyAstroAiKey, 0);
      _prefs.setString(_lastResetKey, todayStr);
      emit(state.copyWith(
        dailyMoodCount: 0,
        dailyCoachAiCount: 0,
        dailyAstroAiCount: 0,
        lastResetDate: todayStr,
      ));
    }
  }
}
