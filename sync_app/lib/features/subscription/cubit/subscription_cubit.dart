import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionState extends Equatable {
  const SubscriptionState({
    this.isLoading = false,
    this.isPro = false,
  });

  final bool isLoading;
  final bool isPro;

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isPro,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isPro: isPro ?? this.isPro,
    );
  }

  @override
  List<Object?> get props => [isLoading, isPro];
}

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const SubscriptionState());

  final SharedPreferences _prefs;
  static const String _proKey = 'sync_is_pro';

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    emit(
      state.copyWith(
        isLoading: false,
        isPro: _prefs.getBool(_proKey) ?? false,
      ),
    );
  }

  Future<void> togglePro() async {
    final next = !state.isPro;
    await _prefs.setBool(_proKey, next);
    emit(state.copyWith(isPro: next));
  }
}
