import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/mood_log_model.dart';
import '../../../data/models/trigger_report_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/mood_repository.dart';
import '../../../data/services/ai_api_client.dart';
import '../../../data/services/notification_service.dart';

part 'sync_engine_events.dart';

class SyncEngineState extends Equatable {
  const SyncEngineState({
    this.isLoading = false,
    this.latestMood,
    this.history = const <MoodLogModel>[],
    this.microAdvice,
    this.triggerReport,
    this.errorMessage,
  });

  final bool isLoading;
  final MoodLogModel? latestMood;
  final List<MoodLogModel> history;
  final String? microAdvice;
  final TriggerReportModel? triggerReport;
  final String? errorMessage;

  SyncEngineState copyWith({
    bool? isLoading,
    MoodLogModel? latestMood,
    List<MoodLogModel>? history,
    String? microAdvice,
    TriggerReportModel? triggerReport,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SyncEngineState(
      isLoading: isLoading ?? this.isLoading,
      latestMood: latestMood ?? this.latestMood,
      history: history ?? this.history,
      microAdvice: microAdvice ?? this.microAdvice,
      triggerReport: triggerReport ?? this.triggerReport,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        latestMood,
        history,
        microAdvice,
        triggerReport,
        errorMessage,
      ];
}

class SyncEngineBloc extends Bloc<SyncEngineEvent, SyncEngineState> {
  SyncEngineBloc({
    required AuthRepository authRepository,
    required MoodRepository moodRepository,
    required AiApiClient aiApiClient,
    required NotificationService notificationService,
  })  : _authRepository = authRepository,
        _moodRepository = moodRepository,
        _aiApiClient = aiApiClient,
        _notificationService = notificationService,
        super(const SyncEngineState()) {
    on<SyncEngineStarted>(_onStarted);
    on<MoodSubmitted>(_onMoodSubmitted);
    on<TriggerReportRequested>(_onTriggerReportRequested);
    on<_LatestMoodChanged>(_onLatestMoodChanged);
  }

  final AuthRepository _authRepository;
  final MoodRepository _moodRepository;
  final AiApiClient _aiApiClient;
  final NotificationService _notificationService;
  StreamSubscription<MoodLogModel?>? _myMoodSubscription;

  Future<void> _onStarted(
    SyncEngineStarted event,
    Emitter<SyncEngineState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final user = await _authRepository.getCurrentUserProfile();
    if (user == null) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Aktif kullanici bulunamadi.',
        ),
      );
      return;
    }

    await _myMoodSubscription?.cancel();
    _myMoodSubscription = _moodRepository.watchMyLatestMood(user.uid).listen(
          (mood) => add(_LatestMoodChanged(mood)),
        );

    final history = await _moodRepository.fetchMoodHistory(userId: user.uid);
    emit(
      state.copyWith(
        isLoading: false,
        history: history,
        latestMood: history.isEmpty ? null : history.first,
      ),
    );
  }

  Future<void> _onMoodSubmitted(
    MoodSubmitted event,
    Emitter<SyncEngineState> emit,
  ) async {
    final user = await _authRepository.getCurrentUserProfile();
    if (user == null) {
      emit(state.copyWith(errorMessage: 'Mood kaydetmek icin giris yapin.'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    final mood = MoodLogModel(
      id: '',
      userId: user.uid,
      energyLevel: event.energyLevel,
      toleranceLevel: event.toleranceLevel,
      signal: event.signal,
      note: event.note.trim().isEmpty ? null : event.note.trim(),
      isSharedWithPartner: event.shareWithPartner,
      timestamp: DateTime.now(),
    );

    await _moodRepository.saveMoodLog(mood);
    final updatedHistory =
        await _moodRepository.fetchMoodHistory(userId: user.uid);
    final advice = await _aiApiClient.generateMicroAdvice(
      currentMood: updatedHistory.first,
      partnerMood: null,
    );

    if (event.shareWithPartner && user.partnerUid != null) {
      await _notificationService.showPartnerMoodNotification(
        partnerName: user.displayName ?? 'Partner',
        signalLabel: event.signal.label,
        signalEmoji: event.signal.emoji,
      );
    }

    emit(
      state.copyWith(
        isLoading: false,
        latestMood: updatedHistory.first,
        history: updatedHistory,
        microAdvice: advice,
      ),
    );
  }

  Future<void> _onTriggerReportRequested(
    TriggerReportRequested event,
    Emitter<SyncEngineState> emit,
  ) async {
    final user = await _authRepository.getCurrentUserProfile();
    if (user == null || user.coupleId == null) {
      emit(
        state.copyWith(
          errorMessage: 'Tetik raporu icin partner baglantisi gerekiyor.',
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));
    final report = await _aiApiClient.generateTriggerReport(
      coupleId: user.coupleId!,
      history: state.history,
    );
    emit(state.copyWith(isLoading: false, triggerReport: report));
  }

  void _onLatestMoodChanged(
    _LatestMoodChanged event,
    Emitter<SyncEngineState> emit,
  ) {
    emit(state.copyWith(latestMood: event.mood));
  }

  @override
  Future<void> close() async {
    await _myMoodSubscription?.cancel();
    return super.close();
  }
}
