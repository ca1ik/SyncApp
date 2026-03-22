import 'package:equatable/equatable.dart';

import '../../core/services/locale_service.dart';

/// Game categories for organized hub display
enum GameCategory {
  classic, // Klasik çift oyunları
  competition, // Yarışma & rekabet
  arena, // Fizik tabanlı arena oyunları
  tournament, // Turnuva & eleme
  romantic, // Romantik modlar
  ranking, // Sıralama & puanlama
}

/// Player mode: solo or multiplayer
enum PlayerMode { solo, multi }

extension GameCategoryX on GameCategory {
  String get title {
    switch (this) {
      case GameCategory.classic:
        return l.tr('Classic', 'Klasik');
      case GameCategory.competition:
        return l.tr('Competition', 'Yarisma');
      case GameCategory.arena:
        return l.tr('Arena', 'Arena');
      case GameCategory.tournament:
        return l.tr('Tournament', 'Turnuva');
      case GameCategory.romantic:
        return l.tr('Romantic', 'Romantik');
      case GameCategory.ranking:
        return l.tr('Ranking', 'Siralama');
    }
  }

  String get emoji {
    switch (this) {
      case GameCategory.classic:
        return '🎭';
      case GameCategory.competition:
        return '🏆';
      case GameCategory.arena:
        return '⚔️';
      case GameCategory.tournament:
        return '🏅';
      case GameCategory.romantic:
        return '💕';
      case GameCategory.ranking:
        return '📊';
    }
  }

  bool get isRgbPro {
    switch (this) {
      case GameCategory.arena:
        return true;
      default:
        return false;
    }
  }
}

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
  // ── New Competitive Games (Pummel Party Inspired) ──
  quickTapDuel, // Hızlı Dokunuş Düellosu
  reactionRace, // Reaksiyon Yarışı
  memoryMatch, // Hafıza Eşleştirme
  diceDuel, // Zar Düellosu
  wordBomb, // Kelime Bombası
  // ── Tournament ──
  bracketTournament, // Turnuva Elemesi
  // ── Ranking ──
  rateAndRank, // 1-10 Puanlama
  // ── Arena (Physics) ──
  sumoBall, // Sumo İtme
  miniPool, // Mini Bilardo
  carRace, // Araba Yarışı
  laserDodge, // Lazer Kaçış
  icePlatform, // Buz Platformu
}

extension CoupleGameTypeX on CoupleGameType {
  String get title {
    switch (this) {
      case CoupleGameType.countTrap:
        return l.tr('Number Trap', 'Sayi Tuzagi');
      case CoupleGameType.truthOrDare:
        return l.tr('Truth or Dare', 'Dogruluk mu Cesaret mi');
      case CoupleGameType.wouldYouRather:
        return l.tr('Would You Rather', 'Hangisini Tercih Edersin');
      case CoupleGameType.knowMeQuiz:
        return l.tr('How Well Do You Know Me', 'Beni Ne Kadar Taniyorsun');
      case CoupleGameType.tripMeter:
        return l.tr('Trip Meter', 'Trip Olcer');
      case CoupleGameType.finishSentence:
        return l.tr('Finish the Sentence', 'Cumle Tamamla');
      case CoupleGameType.emojiGuess:
        return l.tr('Emoji Guess', 'Emoji Tahmin');
      case CoupleGameType.loveMap:
        return l.tr('Love Map', 'Ask Haritasi');
      case CoupleGameType.secretMessage:
        return l.tr('Secret Message', 'Gizli Mesaj');
      case CoupleGameType.compatibilityTest:
        return l.tr('Compatibility Test', 'Uyum Testi');
      case CoupleGameType.quickTapDuel:
        return l.tr('Quick Tap Duel', 'Hizli Dokun Duellosu');
      case CoupleGameType.reactionRace:
        return l.tr('Reaction Race', 'Reaksiyon Yarisi');
      case CoupleGameType.memoryMatch:
        return l.tr('Memory Match', 'Hafiza Eslestirme');
      case CoupleGameType.diceDuel:
        return l.tr('Dice Duel', 'Zar Duellosu');
      case CoupleGameType.wordBomb:
        return l.tr('Word Bomb', 'Kelime Bombasi');
      case CoupleGameType.bracketTournament:
        return l.tr('Bracket Tournament', 'Turnuva Elemesi');
      case CoupleGameType.rateAndRank:
        return l.tr('Rate & Rank', 'Puanla ve Sirala');
      case CoupleGameType.sumoBall:
        return l.tr('Sumo Ball', 'Sumo Topu');
      case CoupleGameType.miniPool:
        return l.tr('Mini Pool', 'Mini Bilardo');
      case CoupleGameType.carRace:
        return l.tr('Car Race', 'Araba Yarisi');
      case CoupleGameType.laserDodge:
        return l.tr('Laser Dodge', 'Lazer Kacis');
      case CoupleGameType.icePlatform:
        return l.tr('Ice Platform', 'Buz Platformu');
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
      case CoupleGameType.quickTapDuel:
        return '⚡';
      case CoupleGameType.reactionRace:
        return '🏎️';
      case CoupleGameType.memoryMatch:
        return '🃏';
      case CoupleGameType.diceDuel:
        return '🎲';
      case CoupleGameType.wordBomb:
        return '💣';
      case CoupleGameType.bracketTournament:
        return '🏅';
      case CoupleGameType.rateAndRank:
        return '📊';
      case CoupleGameType.sumoBall:
        return '🔴';
      case CoupleGameType.miniPool:
        return '🎱';
      case CoupleGameType.carRace:
        return '🏎️';
      case CoupleGameType.laserDodge:
        return '⚡';
      case CoupleGameType.icePlatform:
        return '🧊';
    }
  }

  String get description {
    switch (this) {
      case CoupleGameType.countTrap:
        return l.tr(
            'Count together 1-10, catch the one who says the trap number!',
            '1-10 arasi karsilikli sayin, tuzak sayiyi soyleyeni yakalayin!');
      case CoupleGameType.truthOrDare:
        return l.tr('Truth or dare? Special questions for couples!',
            'Cesaret mi dogruluk mu? Ciftlere ozel sorular!');
      case CoupleGameType.wouldYouRather:
        return l.tr('Make tough choices, get to know each other better!',
            'Zor secimler yapin, birbirinizi daha iyi taniyin!');
      case CoupleGameType.knowMeQuiz:
        return l.tr('How much do you know about your partner?',
            'Partneriniz hakkinda ne kadar biliyorsunuz?');
      case CoupleGameType.tripMeter:
        return l.tr('Boundary-testing game — who is more patient?',
            'Sinir zorlama oyunu — kim daha sabirli?');
      case CoupleGameType.finishSentence:
        return l.tr('Complete the sentence, test your harmony!',
            'Cumleyi tamamlayin, uyumunuzu test edin!');
      case CoupleGameType.emojiGuess:
        return l.tr('Express with emojis, partner guesses!',
            'Emojilerle anlatın, partner tahmin etsin!');
      case CoupleGameType.loveMap:
        return l.tr('Map your relationship memories!',
            'Iliski anılarınızı haritalayin!');
      case CoupleGameType.secretMessage:
        return l.tr(
            'Send encrypted love letters!', 'Sifrelı ask mektuplari gonderin!');
      case CoupleGameType.compatibilityTest:
        return l.tr('Answer the same questions, see your compatibility!',
            'Ayni sorulari cevaplayin, uyum yuzdenizi gorun!');
      case CoupleGameType.quickTapDuel:
        return l.tr('Tap as fast as you can! Who reaches 30 first?',
            'Olabildigince hizli dokun! Kim 30a ilk ulasir?');
      case CoupleGameType.reactionRace:
        return l.tr('Wait for green, tap fastest! Test your reflexes!',
            'Yesili bekle, en hizli dokun! Reflekslerini test et!');
      case CoupleGameType.memoryMatch:
        return l.tr('Find matching pairs! Who has better memory?',
            'Eslesen kartlari bul! Kimin hafizasi daha iyi?');
      case CoupleGameType.diceDuel:
        return l.tr('Roll dice and compete! Best of 5 rounds wins!',
            'Zar at ve yaris! 5 turun en iyisi kazanir!');
      case CoupleGameType.wordBomb:
        return l.tr('Say a word before the bomb explodes! 5 second timer!',
            'Bomba patlamadan kelime soyle! 5 saniye suren!');
      case CoupleGameType.bracketTournament:
        return l.tr('Bracket elimination! Pick your favorites from 64 to 1!',
            'Eleme turnuvasi! 64ten 1e favorilerini sec!');
      case CoupleGameType.rateAndRank:
        return l.tr('Rate items 1-10 together, compare your rankings!',
            'Birlikte 1-10 puanla, siralamalari karsilastir!');
      case CoupleGameType.sumoBall:
        return l.tr(
            'Push your opponent off the platform! Last one standing wins!',
            'Rakibini platformdan it! Ayakta kalan kazanir!');
      case CoupleGameType.miniPool:
        return l.tr('Pocket the balls! Classic pool with touch controls!',
            'Toplari cukura sok! Dokunmatik kontrol ile bilardo!');
      case CoupleGameType.carRace:
        return l.tr('Race to the finish line! Tilt and tap to drive!',
            'Bitis cizgisine yaris! Dokun ve sur!');
      case CoupleGameType.laserDodge:
        return l.tr('Dodge the lasers! Survive the longest!',
            'Lazerlerden kac! En uzun surede hayatta kal!');
      case CoupleGameType.icePlatform:
        return l.tr('Stay on the shrinking ice! Push others off!',
            'Kuculen buzda kal! Digerlerini dusur!');
    }
  }

  bool get isProOnly {
    switch (this) {
      case CoupleGameType.countTrap:
      case CoupleGameType.truthOrDare:
      case CoupleGameType.wouldYouRather:
      case CoupleGameType.quickTapDuel:
      case CoupleGameType.diceDuel:
      case CoupleGameType.sumoBall:
        return false;
      default:
        return true;
    }
  }

  /// Which player modes this game supports
  List<PlayerMode> get supportedModes {
    switch (this) {
      case CoupleGameType.truthOrDare:
      case CoupleGameType.wouldYouRather:
      case CoupleGameType.knowMeQuiz:
      case CoupleGameType.tripMeter:
      case CoupleGameType.finishSentence:
      case CoupleGameType.emojiGuess:
      case CoupleGameType.loveMap:
      case CoupleGameType.secretMessage:
      case CoupleGameType.bracketTournament:
      case CoupleGameType.rateAndRank:
        return [PlayerMode.solo, PlayerMode.multi];
      case CoupleGameType.countTrap:
      case CoupleGameType.quickTapDuel:
      case CoupleGameType.reactionRace:
      case CoupleGameType.memoryMatch:
      case CoupleGameType.diceDuel:
      case CoupleGameType.wordBomb:
      case CoupleGameType.compatibilityTest:
      case CoupleGameType.sumoBall:
      case CoupleGameType.miniPool:
      case CoupleGameType.carRace:
      case CoupleGameType.laserDodge:
      case CoupleGameType.icePlatform:
        return [PlayerMode.multi];
    }
  }

  GameCategory get category {
    switch (this) {
      case CoupleGameType.truthOrDare:
      case CoupleGameType.wouldYouRather:
      case CoupleGameType.knowMeQuiz:
      case CoupleGameType.tripMeter:
        return GameCategory.classic;
      case CoupleGameType.countTrap:
      case CoupleGameType.quickTapDuel:
      case CoupleGameType.reactionRace:
      case CoupleGameType.memoryMatch:
      case CoupleGameType.diceDuel:
      case CoupleGameType.wordBomb:
        return GameCategory.competition;
      case CoupleGameType.bracketTournament:
        return GameCategory.tournament;
      case CoupleGameType.finishSentence:
      case CoupleGameType.emojiGuess:
      case CoupleGameType.loveMap:
      case CoupleGameType.secretMessage:
      case CoupleGameType.compatibilityTest:
        return GameCategory.romantic;
      case CoupleGameType.rateAndRank:
        return GameCategory.ranking;
      case CoupleGameType.sumoBall:
      case CoupleGameType.miniPool:
      case CoupleGameType.carRace:
      case CoupleGameType.laserDodge:
      case CoupleGameType.icePlatform:
        return GameCategory.arena;
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
    if (bondLevel >= 20) return l.tr('Soul Mates', 'Ruh Ikizi');
    if (bondLevel >= 15) return l.tr('Inseparable Couple', 'Ayrilmaz Cift');
    if (bondLevel >= 10) return l.tr('Passionate Lovers', 'Tutkulu Asiklar');
    if (bondLevel >= 7) return l.tr('Trusted Partner', 'Guvenilir Partner');
    if (bondLevel >= 5) return l.tr('Close Couple', 'Yakin Cift');
    if (bondLevel >= 3) return l.tr('Growing Relationship', 'Gelisen Iliski');
    return l.tr('New Beginning', 'Yeni Baslangic');
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

// ══════════════════════════════════════════════════
//  TOURNAMENT BRACKET MODEL
// ══════════════════════════════════════════════════

/// Pre-defined tournament categories
enum TournamentCategory {
  beautifulWomen,
  food,
  regionalFood,
  drinks,
  dateIdeas,
  tripDestinations,
  movies,
  songs,
  desserts,
  custom,
}

extension TournamentCategoryX on TournamentCategory {
  String get title {
    switch (this) {
      case TournamentCategory.beautifulWomen:
        return l.tr('Most Beautiful Women', 'En Guzel Kadinlar');
      case TournamentCategory.food:
        return l.tr('Food Ranking', 'Yemek Siralamasi');
      case TournamentCategory.regionalFood:
        return l.tr('Regional Food', 'Bolgesel Yemekler');
      case TournamentCategory.drinks:
        return l.tr('Drink Ranking', 'Icecek Siralamasi');
      case TournamentCategory.dateIdeas:
        return l.tr('Best Date Ideas', 'En Iyi Date Fikirleri');
      case TournamentCategory.tripDestinations:
        return l.tr('Trip Destinations', 'Seyahat Noktalari');
      case TournamentCategory.movies:
        return l.tr('Best Movies', 'En Iyi Filmler');
      case TournamentCategory.songs:
        return l.tr('Best Songs', 'En Iyi Sarkilar');
      case TournamentCategory.desserts:
        return l.tr('Best Desserts', 'En Iyi Tatlilar');
      case TournamentCategory.custom:
        return l.tr('Custom Tournament', 'Ozel Turnuva');
    }
  }

  String get emoji {
    switch (this) {
      case TournamentCategory.beautifulWomen:
        return '👸';
      case TournamentCategory.food:
        return '🍕';
      case TournamentCategory.regionalFood:
        return '🥘';
      case TournamentCategory.drinks:
        return '🍹';
      case TournamentCategory.dateIdeas:
        return '💑';
      case TournamentCategory.tripDestinations:
        return '✈️';
      case TournamentCategory.movies:
        return '🎬';
      case TournamentCategory.songs:
        return '🎵';
      case TournamentCategory.desserts:
        return '🍰';
      case TournamentCategory.custom:
        return '✨';
    }
  }
}

/// Bracket sizes available for tournaments
enum BracketSize {
  bracket4(4),
  bracket8(8),
  bracket16(16),
  bracket32(32),
  bracket64(64);

  const BracketSize(this.count);
  final int count;
}

// ══════════════════════════════════════════════════
//  RANKING CATEGORIES
// ══════════════════════════════════════════════════

enum RankingCategory {
  coupleGoals,
  travelBucket,
  foodTaste,
  movieNight,
  dateNight,
  dreamHome,
  lifeGoals,
  custom,
}

extension RankingCategoryX on RankingCategory {
  String get title {
    switch (this) {
      case RankingCategory.coupleGoals:
        return l.tr('Couple Goals', 'Cift Hedefleri');
      case RankingCategory.travelBucket:
        return l.tr('Travel Bucket', 'Seyahat Listesi');
      case RankingCategory.foodTaste:
        return l.tr('Food Taste', 'Yemek Zevki');
      case RankingCategory.movieNight:
        return l.tr('Movie Night', 'Film Gecesi');
      case RankingCategory.dateNight:
        return l.tr('Date Night', 'Date Gecesi');
      case RankingCategory.dreamHome:
        return l.tr('Dream Home', 'Hayal Ev');
      case RankingCategory.lifeGoals:
        return l.tr('Life Goals', 'Hayat Hedefleri');
      case RankingCategory.custom:
        return l.tr('Custom', 'Ozel');
    }
  }

  String get emoji {
    switch (this) {
      case RankingCategory.coupleGoals:
        return '💕';
      case RankingCategory.travelBucket:
        return '✈️';
      case RankingCategory.foodTaste:
        return '🍽️';
      case RankingCategory.movieNight:
        return '🎬';
      case RankingCategory.dateNight:
        return '💑';
      case RankingCategory.dreamHome:
        return '🏠';
      case RankingCategory.lifeGoals:
        return '🎯';
      case RankingCategory.custom:
        return '✨';
    }
  }
}
