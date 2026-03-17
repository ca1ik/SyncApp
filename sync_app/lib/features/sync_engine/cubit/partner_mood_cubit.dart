import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/mood_log_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/mood_repository.dart';

class PartnerMoodState extends Equatable {
  const PartnerMoodState({
    this.isLoading = false,
    this.mood,
    this.message,
    this.hasLinkedPartner = false,
  });

  final bool isLoading;
  final MoodLogModel? mood;
  final String? message;
  final bool hasLinkedPartner;

  PartnerMoodState copyWith({
    bool? isLoading,
    MoodLogModel? mood,
    String? message,
    bool? hasLinkedPartner,
    bool clearMessage = false,
  }) {
    return PartnerMoodState(
      isLoading: isLoading ?? this.isLoading,
      mood: mood ?? this.mood,
      message: clearMessage ? null : (message ?? this.message),
      hasLinkedPartner: hasLinkedPartner ?? this.hasLinkedPartner,
    );
  }

  @override
  List<Object?> get props => [isLoading, mood, message, hasLinkedPartner];
}

class PartnerMoodCubit extends Cubit<PartnerMoodState> {
  PartnerMoodCubit({
    required AuthRepository authRepository,
    required MoodRepository moodRepository,
  })  : _authRepository = authRepository,
        _moodRepository = moodRepository,
        super(const PartnerMoodState());

  final AuthRepository _authRepository;
  final MoodRepository _moodRepository;
  StreamSubscription<MoodLogModel?>? _subscription;

  Future<void> start() async {
    emit(state.copyWith(isLoading: true, clearMessage: true));
    final currentUser = await _authRepository.getCurrentUserProfile();
    final partnerUid = currentUser?.partnerUid;

    if (partnerUid == null || partnerUid.isEmpty) {
      emit(
        state.copyWith(
          isLoading: false,
          hasLinkedPartner: false,
          message: 'Partner baglantisi henuz yok.',
        ),
      );
      return;
    }

    await _subscription?.cancel();
    _subscription = _moodRepository.watchPartnerLatestMood(partnerUid).listen(
      (mood) {
        emit(
          state.copyWith(
            isLoading: false,
            mood: mood,
            hasLinkedPartner: true,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
