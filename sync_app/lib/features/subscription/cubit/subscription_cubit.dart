import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionState extends Equatable {
  const SubscriptionState({
    this.isLoading = false,
    this.isPro = false,
    this.isNoAds = false,
    this.dailyMoodCount = 0,
    this.lastResetDate,
  });

  final bool isLoading;
  final bool isPro;
  final bool isNoAds;
  final int dailyMoodCount;
  final String? lastResetDate;

  static const int freeDailyLimit = 5;
  static const int freeHistoryLimit = 10;
  static const double noAdsPriceMonthly = 50.0; // TL

  bool get canSubmitMood => isPro || dailyMoodCount < freeDailyLimit;
  int get remainingMoods =>
      isPro ? 999 : (freeDailyLimit - dailyMoodCount).clamp(0, freeDailyLimit);
  bool get canViewFullHistory => isPro;
  bool get canGenerateReport => isPro;
  bool get canUseBreathing => true; // Free: 1 exercise, Pro: unlimited
  bool get canViewInsights => isPro;
  bool get hasAdvancedAnalytics => isPro;

  /// PRO users automatically get ad-free experience
  bool get shouldShowAds => !isPro && !isNoAds;

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isPro,
    bool? isNoAds,
    int? dailyMoodCount,
    String? lastResetDate,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isPro: isPro ?? this.isPro,
      isNoAds: isNoAds ?? this.isNoAds,
      dailyMoodCount: dailyMoodCount ?? this.dailyMoodCount,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, isPro, isNoAds, dailyMoodCount, lastResetDate];
}

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const SubscriptionState());

  final SharedPreferences _prefs;
  static const String _proKey = 'sync_is_pro';
  static const String _noAdsKey = 'sync_is_no_ads';
  static const String _dailyCountKey = 'sync_daily_mood_count';
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
        lastResetDate: _prefs.getString(_lastResetKey),
      ),
    );
  }

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

  void _checkDailyReset() {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastReset = _prefs.getString(_lastResetKey);
    if (lastReset != todayStr) {
      _prefs.setInt(_dailyCountKey, 0);
      _prefs.setString(_lastResetKey, todayStr);
      emit(state.copyWith(dailyMoodCount: 0, lastResetDate: todayStr));
    }
  }
}
