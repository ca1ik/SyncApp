import 'package:equatable/equatable.dart';

import '../../core/services/locale_service.dart';

enum AchievementType {
  firstMood,
  streak3,
  streak7,
  streak14,
  streak30,
  partnerLinked,
  first10Moods,
  first50Moods,
  firstReport,
  moodVariety,
  nightOwl,
  earlyBird,
  weekendWarrior,
  consistentCouple,
}

extension AchievementTypeX on AchievementType {
  String get title {
    switch (this) {
      case AchievementType.firstMood:
        return l.tr('First Step', 'Ilk Adim');
      case AchievementType.streak3:
        return l.tr('3-Day Streak', '3 Gun Serisi');
      case AchievementType.streak7:
        return l.tr('Weekly Hero', 'Haftalik Kahraman');
      case AchievementType.streak14:
        return l.tr('Dedicated Couple', 'Azimli Cift');
      case AchievementType.streak30:
        return l.tr('Monthly Champion', 'Aylik Sampiyon');
      case AchievementType.partnerLinked:
        return l.tr('Connected!', 'Baglantiyi Kurduk');
      case AchievementType.first10Moods:
        return l.tr('10 Mood Entries', '10 Mood Girisi');
      case AchievementType.first50Moods:
        return l.tr('50 Mood Master', '50 Mood Ustasi');
      case AchievementType.firstReport:
        return l.tr('First Analysis', 'Ilk Analiz');
      case AchievementType.moodVariety:
        return l.tr('Emotion Palette', 'Duygu Paleti');
      case AchievementType.nightOwl:
        return l.tr('Night Owl', 'Gece Kusu');
      case AchievementType.earlyBird:
        return l.tr('Early Bird', 'Erken Kalkan');
      case AchievementType.weekendWarrior:
        return l.tr('Weekend Warrior', 'Hafta Sonu Savascisi');
      case AchievementType.consistentCouple:
        return l.tr('Harmonious Couple', 'Uyumlu Cift');
    }
  }

  String get description {
    switch (this) {
      case AchievementType.firstMood:
        return l.tr(
            'You made your first mood entry!', 'Ilk mood girisini yaptin!');
      case AchievementType.streak3:
        return l.tr('3 consecutive days of mood entries!',
            '3 gun ust uste mood girisi!');
      case AchievementType.streak7:
        return l.tr(
            '7 days without interruption!', '7 gun boyunca kesintisiz!');
      case AchievementType.streak14:
        return l.tr('You entered daily for 2 weeks!',
            '2 hafta boyunca her gun giris yaptin!');
      case AchievementType.streak30:
        return l.tr('You never gave up for 30 days!',
            '30 gun boyunca asla vazgecmedin!');
      case AchievementType.partnerLinked:
        return l.tr('You successfully linked your partner!',
            'Partnerini basariyla bagladin!');
      case AchievementType.first10Moods:
        return l.tr('10 mood entries completed!', '10 mood girisi tamamlandi!');
      case AchievementType.first50Moods:
        return l.tr(
            'You reached 50 mood entries!', '50 mood girisine ulastin!');
      case AchievementType.firstReport:
        return l.tr('You generated your first trigger report!',
            'Ilk tetikleyici raporunu olusturdun!');
      case AchievementType.moodVariety:
        return l.tr('You used 5 different signal types!',
            '5 farkli sinyal turunu kullandin!');
      case AchievementType.nightOwl:
        return l.tr('You made a mood entry after midnight!',
            'Gece yarisi sonrasi mood girisi yaptin!');
      case AchievementType.earlyBird:
        return l.tr('You made a mood entry before 7 AM!',
            'Sabah 7 den once mood girisi yaptin!');
      case AchievementType.weekendWarrior:
        return l.tr('You didn\'t skip mood entries on weekends!',
            'Hafta sonu da mood girisini ihmal etmedin!');
      case AchievementType.consistentCouple:
        return l.tr('Both of you made mood entries on the same day!',
            'Ikisi de ayni gun mood girisini yapti!');
    }
  }

  String get icon {
    switch (this) {
      case AchievementType.firstMood:
        return '🌱';
      case AchievementType.streak3:
        return '🔥';
      case AchievementType.streak7:
        return '⭐';
      case AchievementType.streak14:
        return '💎';
      case AchievementType.streak30:
        return '🏆';
      case AchievementType.partnerLinked:
        return '🔗';
      case AchievementType.first10Moods:
        return '📝';
      case AchievementType.first50Moods:
        return '🎯';
      case AchievementType.firstReport:
        return '📊';
      case AchievementType.moodVariety:
        return '🎨';
      case AchievementType.nightOwl:
        return '🦉';
      case AchievementType.earlyBird:
        return '🐦';
      case AchievementType.weekendWarrior:
        return '💪';
      case AchievementType.consistentCouple:
        return '💕';
    }
  }

  bool get isProOnly {
    switch (this) {
      case AchievementType.streak14:
      case AchievementType.streak30:
      case AchievementType.first50Moods:
      case AchievementType.consistentCouple:
        return true;
      default:
        return false;
    }
  }
}

class AchievementModel extends Equatable {
  const AchievementModel({
    required this.type,
    required this.unlockedAt,
    this.isNew = false,
  });

  final AchievementType type;
  final DateTime unlockedAt;
  final bool isNew;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'unlockedAt': unlockedAt.toIso8601String(),
      };

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      AchievementModel(
        type: AchievementType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => AchievementType.firstMood,
        ),
        unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      );

  @override
  List<Object?> get props => [type, unlockedAt, isNew];
}
