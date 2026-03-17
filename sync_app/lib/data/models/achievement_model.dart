import 'package:equatable/equatable.dart';

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
        return 'Ilk Adim';
      case AchievementType.streak3:
        return '3 Gun Serisi';
      case AchievementType.streak7:
        return 'Haftalik Kahraman';
      case AchievementType.streak14:
        return 'Azimli Cift';
      case AchievementType.streak30:
        return 'Aylik Sampiyon';
      case AchievementType.partnerLinked:
        return 'Baglantiyi Kurduk';
      case AchievementType.first10Moods:
        return '10 Mood Girisi';
      case AchievementType.first50Moods:
        return '50 Mood Ustasi';
      case AchievementType.firstReport:
        return 'Ilk Analiz';
      case AchievementType.moodVariety:
        return 'Duygu Paleti';
      case AchievementType.nightOwl:
        return 'Gece Kusu';
      case AchievementType.earlyBird:
        return 'Erken Kalkan';
      case AchievementType.weekendWarrior:
        return 'Hafta Sonu Savascisi';
      case AchievementType.consistentCouple:
        return 'Uyumlu Cift';
    }
  }

  String get description {
    switch (this) {
      case AchievementType.firstMood:
        return 'Ilk mood girisini yaptin!';
      case AchievementType.streak3:
        return '3 gun ust uste mood girisi!';
      case AchievementType.streak7:
        return '7 gun boyunca kesintisiz!';
      case AchievementType.streak14:
        return '2 hafta boyunca her gun giris yaptin!';
      case AchievementType.streak30:
        return '30 gun boyunca asla vazgecmedin!';
      case AchievementType.partnerLinked:
        return 'Partnerini basariyla bagladin!';
      case AchievementType.first10Moods:
        return '10 mood girisi tamamlandi!';
      case AchievementType.first50Moods:
        return '50 mood girisine ulastin!';
      case AchievementType.firstReport:
        return 'Ilk tetikleyici raporunu olusturdun!';
      case AchievementType.moodVariety:
        return '5 farkli sinyal turunu kullandin!';
      case AchievementType.nightOwl:
        return 'Gece yarisi sonrasi mood girisi yaptin!';
      case AchievementType.earlyBird:
        return 'Sabah 7 den once mood girisi yaptin!';
      case AchievementType.weekendWarrior:
        return 'Hafta sonu da mood girisini ihmal etmedin!';
      case AchievementType.consistentCouple:
        return 'Ikisi de ayni gun mood girisini yapti!';
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
