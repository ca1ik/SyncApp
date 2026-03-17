part of 'sync_engine_bloc.dart';

abstract class SyncEngineEvent extends Equatable {
  const SyncEngineEvent();

  @override
  List<Object?> get props => [];
}

class SyncEngineStarted extends SyncEngineEvent {
  const SyncEngineStarted();
}

class MoodSubmitted extends SyncEngineEvent {
  const MoodSubmitted({
    required this.energyLevel,
    required this.toleranceLevel,
    required this.signal,
    required this.note,
    required this.shareWithPartner,
  });

  final int energyLevel;
  final int toleranceLevel;
  final MoodSignal signal;
  final String note;
  final bool shareWithPartner;

  @override
  List<Object?> get props => [
        energyLevel,
        toleranceLevel,
        signal,
        note,
        shareWithPartner,
      ];
}

class TriggerReportRequested extends SyncEngineEvent {
  const TriggerReportRequested();
}

class _LatestMoodChanged extends SyncEngineEvent {
  const _LatestMoodChanged(this.mood);

  final MoodLogModel? mood;

  @override
  List<Object?> get props => [mood];
}
