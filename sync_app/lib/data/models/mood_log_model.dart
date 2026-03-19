import 'package:equatable/equatable.dart';

import '../../core/services/locale_service.dart';

/// NLC signals that can be shared with a single tap.
enum MoodSignal {
  needHug,
  needSilence,
  needSpace,
  needTalk,
  exhausted,
  happy,
  anxious,
  neutral,
}

extension MoodSignalExtension on MoodSignal {
  String get label {
    switch (this) {
      case MoodSignal.needHug:
        return l.tr('I need a hug 🤗', 'Sarılmaya ihtiyacım var 🤗');
      case MoodSignal.needSilence:
        return l.tr('I need silence 🤫', 'Sessizliğe ihtiyacım var 🤫');
      case MoodSignal.needSpace:
        return l.tr(
            'I need some alone time 🌙', 'Biraz yalnız kalmam lazım 🌙');
      case MoodSignal.needTalk:
        return l.tr('I\'m ready to talk 💬', 'Konuşmaya hazırım 💬');
      case MoodSignal.exhausted:
        return l.tr('I\'m exhausted, need understanding 🔋',
            'Çok yoruldum, anlayış bekliyorum 🔋');
      case MoodSignal.happy:
        return l.tr('Feeling great! ✨', 'Harika hissediyorum! ✨');
      case MoodSignal.anxious:
        return l.tr('Feeling anxious, need support 🫂',
            'Biraz kaygılıyım, destek lazım 🫂');
      case MoodSignal.neutral:
        return l.tr('Everything is fine 😊', 'Her şey normal 😊');
    }
  }

  String get emoji {
    switch (this) {
      case MoodSignal.needHug:
        return '🤗';
      case MoodSignal.needSilence:
        return '🤫';
      case MoodSignal.needSpace:
        return '🌙';
      case MoodSignal.needTalk:
        return '💬';
      case MoodSignal.exhausted:
        return '🔋';
      case MoodSignal.happy:
        return '✨';
      case MoodSignal.anxious:
        return '🫂';
      case MoodSignal.neutral:
        return '😊';
    }
  }

  String get jsonValue {
    switch (this) {
      case MoodSignal.needHug:
        return 'need_hug';
      case MoodSignal.needSilence:
        return 'need_silence';
      case MoodSignal.needSpace:
        return 'need_space';
      case MoodSignal.needTalk:
        return 'need_talk';
      case MoodSignal.exhausted:
        return 'exhausted';
      case MoodSignal.happy:
        return 'happy';
      case MoodSignal.anxious:
        return 'anxious';
      case MoodSignal.neutral:
        return 'neutral';
    }
  }

  static MoodSignal fromJsonValue(String value) {
    switch (value) {
      case 'need_hug':
        return MoodSignal.needHug;
      case 'need_silence':
        return MoodSignal.needSilence;
      case 'need_space':
        return MoodSignal.needSpace;
      case 'need_talk':
        return MoodSignal.needTalk;
      case 'exhausted':
        return MoodSignal.exhausted;
      case 'happy':
        return MoodSignal.happy;
      case 'anxious':
        return MoodSignal.anxious;
      case 'neutral':
      default:
        return MoodSignal.neutral;
    }
  }
}

class MoodLogModel extends Equatable {
  const MoodLogModel({
    required this.id,
    required this.userId,
    required this.energyLevel,
    required this.toleranceLevel,
    required this.signal,
    this.note,
    this.isSharedWithPartner = false,
    this.timestamp,
  });

  final String id;
  final String userId;
  final int energyLevel;
  final int toleranceLevel;
  final MoodSignal signal;
  final String? note;
  final bool isSharedWithPartner;
  final DateTime? timestamp;

  MoodLogModel copyWith({
    String? id,
    String? userId,
    int? energyLevel,
    int? toleranceLevel,
    MoodSignal? signal,
    String? note,
    bool? isSharedWithPartner,
    DateTime? timestamp,
  }) {
    return MoodLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      energyLevel: energyLevel ?? this.energyLevel,
      toleranceLevel: toleranceLevel ?? this.toleranceLevel,
      signal: signal ?? this.signal,
      note: note ?? this.note,
      isSharedWithPartner: isSharedWithPartner ?? this.isSharedWithPartner,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'energyLevel': energyLevel,
        'toleranceLevel': toleranceLevel,
        'signal': signal.jsonValue,
        'note': note,
        'isSharedWithPartner': isSharedWithPartner,
        'timestamp': timestamp?.toIso8601String(),
      };

  factory MoodLogModel.fromJson(Map<String, dynamic> json) => MoodLogModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        energyLevel: json['energyLevel'] as int,
        toleranceLevel: json['toleranceLevel'] as int,
        signal: MoodSignalExtension.fromJsonValue(json['signal'] as String),
        note: json['note'] as String?,
        isSharedWithPartner: json['isSharedWithPartner'] as bool? ?? false,
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'] as String)
            : null,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        energyLevel,
        toleranceLevel,
        signal,
        note,
        isSharedWithPartner,
        timestamp,
      ];
}
