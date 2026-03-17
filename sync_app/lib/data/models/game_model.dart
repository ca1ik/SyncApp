import 'package:equatable/equatable.dart';

enum CoupleGameType {
  countTrap, // Sayı Tuzağı
  truthOrDare, // Doğruluk mu Cesaret mi
  wouldYouRather, // Hangisini Tercih Edersin
  knowMeQuiz, // Beni Ne Kadar Tanıyorsun
  tripMeter, // Trip Ölçer
  finishSentence, // Cümle Tamamla
  emojiGuess, // Emoji Tahmin
  loveMap, // Aşk Haritası
  secretMessage, // Gizli Mesaj
  compatibilityTest, // Uyum Testi
}

extension CoupleGameTypeX on CoupleGameType {
  String get title {
    switch (this) {
      case CoupleGameType.countTrap:
        return 'Sayi Tuzagi';
      case CoupleGameType.truthOrDare:
        return 'Dogruluk mu Cesaret mi';
      case CoupleGameType.wouldYouRather:
        return 'Hangisini Tercih Edersin';
      case CoupleGameType.knowMeQuiz:
        return 'Beni Ne Kadar Taniyorsun';
      case CoupleGameType.tripMeter:
        return 'Trip Olcer';
      case CoupleGameType.finishSentence:
        return 'Cumle Tamamla';
      case CoupleGameType.emojiGuess:
        return 'Emoji Tahmin';
      case CoupleGameType.loveMap:
        return 'Ask Haritasi';
      case CoupleGameType.secretMessage:
        return 'Gizli Mesaj';
      case CoupleGameType.compatibilityTest:
        return 'Uyum Testi';
    }
  }

  String get emoji {
    switch (this) {
      case CoupleGameType.countTrap:
        return '🔢';
      case CoupleGameType.truthOrDare:
        return '🎭';
      case CoupleGameType.wouldYouRather:
        return '⚖️';
      case CoupleGameType.knowMeQuiz:
        return '🧠';
      case CoupleGameType.tripMeter:
        return '😤';
      case CoupleGameType.finishSentence:
        return '✍️';
      case CoupleGameType.emojiGuess:
        return '🎯';
      case CoupleGameType.loveMap:
        return '🗺️';
      case CoupleGameType.secretMessage:
        return '🔐';
      case CoupleGameType.compatibilityTest:
        return '💞';
    }
  }

  String get description {
    switch (this) {
      case CoupleGameType.countTrap:
        return '1-10 arasi karsilikli sayin, tuzak sayiyi soyleyeni yakalayin!';
      case CoupleGameType.truthOrDare:
        return 'Cesaret mi dogruluk mu? Ciftlere ozel sorular!';
      case CoupleGameType.wouldYouRather:
        return 'Zor secimler yapin, birbirinizi daha iyi taniyin!';
      case CoupleGameType.knowMeQuiz:
        return 'Partneriniz hakkinda ne kadar biliyorsunuz?';
      case CoupleGameType.tripMeter:
        return 'Sinir zorlama oyunu — kim daha sabirli?';
      case CoupleGameType.finishSentence:
        return 'Cumleyi tamamlayin, uyumunuzu test edin!';
      case CoupleGameType.emojiGuess:
        return 'Emojilerle anlatın, partner tahmin etsin!';
      case CoupleGameType.loveMap:
        return 'Iliski anılarınızı haritalayin!';
      case CoupleGameType.secretMessage:
        return 'Sifrelı ask mektuplari gonderin!';
      case CoupleGameType.compatibilityTest:
        return 'Ayni sorulari cevaplayin, uyum yuzdenizi gorun!';
    }
  }

  bool get isProOnly {
    switch (this) {
      case CoupleGameType.countTrap:
      case CoupleGameType.truthOrDare:
      case CoupleGameType.wouldYouRather:
        return false;
      default:
        return true;
    }
  }
}

class GameScore extends Equatable {
  const GameScore({
    required this.gameType,
    required this.player1Score,
    required this.player2Score,
    required this.playedAt,
    this.bonusPoints = 0,
  });

  final CoupleGameType gameType;
  final int player1Score;
  final int player2Score;
  final DateTime playedAt;
  final int bonusPoints;

  int get totalPoints => player1Score + player2Score + bonusPoints;

  Map<String, dynamic> toJson() => {
        'gameType': gameType.index,
        'player1Score': player1Score,
        'player2Score': player2Score,
        'playedAt': playedAt.toIso8601String(),
        'bonusPoints': bonusPoints,
      };

  factory GameScore.fromJson(Map<String, dynamic> json) => GameScore(
        gameType: CoupleGameType.values[json['gameType'] as int],
        player1Score: json['player1Score'] as int,
        player2Score: json['player2Score'] as int,
        playedAt: DateTime.parse(json['playedAt'] as String),
        bonusPoints: json['bonusPoints'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [gameType, player1Score, player2Score, playedAt];
}

class CouplePoints extends Equatable {
  const CouplePoints({
    this.totalPoints = 0,
    this.bondLevel = 1,
    this.gamesPlayed = 0,
    this.currentDayStreak = 0,
    this.questionsAsked = 0,
    this.questionsAnswered = 0,
  });

  final int totalPoints;
  final int bondLevel;
  final int gamesPlayed;
  final int currentDayStreak;
  final int questionsAsked;
  final int questionsAnswered;

  /// Points needed for next bond level (exponential curve)
  int get nextLevelPoints => bondLevel * 150;
  double get levelProgress => (totalPoints % nextLevelPoints) / nextLevelPoints;

  String get bondTitle {
    if (bondLevel >= 20) return 'Ruh Ikizi';
    if (bondLevel >= 15) return 'Ayrilmaz Cift';
    if (bondLevel >= 10) return 'Tutkulu Asiklar';
    if (bondLevel >= 7) return 'Guvenilir Partner';
    if (bondLevel >= 5) return 'Yakin Cift';
    if (bondLevel >= 3) return 'Gelisen Iliski';
    return 'Yeni Baslangic';
  }

  Map<String, dynamic> toJson() => {
        'totalPoints': totalPoints,
        'bondLevel': bondLevel,
        'gamesPlayed': gamesPlayed,
        'currentDayStreak': currentDayStreak,
        'questionsAsked': questionsAsked,
        'questionsAnswered': questionsAnswered,
      };

  factory CouplePoints.fromJson(Map<String, dynamic> json) => CouplePoints(
        totalPoints: json['totalPoints'] as int? ?? 0,
        bondLevel: json['bondLevel'] as int? ?? 1,
        gamesPlayed: json['gamesPlayed'] as int? ?? 0,
        currentDayStreak: json['currentDayStreak'] as int? ?? 0,
        questionsAsked: json['questionsAsked'] as int? ?? 0,
        questionsAnswered: json['questionsAnswered'] as int? ?? 0,
      );

  CouplePoints copyWith({
    int? totalPoints,
    int? bondLevel,
    int? gamesPlayed,
    int? currentDayStreak,
    int? questionsAsked,
    int? questionsAnswered,
  }) =>
      CouplePoints(
        totalPoints: totalPoints ?? this.totalPoints,
        bondLevel: bondLevel ?? this.bondLevel,
        gamesPlayed: gamesPlayed ?? this.gamesPlayed,
        currentDayStreak: currentDayStreak ?? this.currentDayStreak,
        questionsAsked: questionsAsked ?? this.questionsAsked,
        questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      );

  @override
  List<Object?> get props =>
      [totalPoints, bondLevel, gamesPlayed, currentDayStreak];
}

class CoupleQuestion extends Equatable {
  const CoupleQuestion({
    required this.id,
    required this.question,
    required this.category,
    this.askerAnswer,
    this.responderAnswer,
    this.rating,
    this.isCorrect,
    this.createdAt,
  });

  final String id;
  final String question;
  final String category;
  final String? askerAnswer;
  final String? responderAnswer;
  final int? rating;
  final bool? isCorrect;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'category': category,
        'askerAnswer': askerAnswer,
        'responderAnswer': responderAnswer,
        'rating': rating,
        'isCorrect': isCorrect,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory CoupleQuestion.fromJson(Map<String, dynamic> json) => CoupleQuestion(
        id: json['id'] as String,
        question: json['question'] as String,
        category: json['category'] as String? ?? 'genel',
        askerAnswer: json['askerAnswer'] as String?,
        responderAnswer: json['responderAnswer'] as String?,
        rating: json['rating'] as int?,
        isCorrect: json['isCorrect'] as bool?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );

  @override
  List<Object?> get props => [id, question];
}
