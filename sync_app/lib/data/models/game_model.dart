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

/// Difficulty level for tutorial system
enum GameDifficulty { easy, medium, hard }

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
  // ── Arena Wave 2 (Pummel Party Inspired) ──
  colorMatch, // Renk Eşleştirme
  meteorShower, // Meteor Yağmuru
  balloonPop, // Balon Patlatma
  treasureDive, // Hazine Dalışı
  bombPass, // Bomba Pas
  towerStack, // Kule Yığma
  fruitCatch, // Meyve Toplama
  targetShot, // Hedef Vurma
  lavaFloor, // Lav Zemin
  paintWar, // Boya Savaşı
  snakeArena, // Yılan Arenası
  asteroidBreaker, // Asteroid Kırma
  rhythmTap, // Ritim Dokun
  mazeRunner, // Labirent Koşusu
  shieldBlock, // Kalkan Blok
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
      case CoupleGameType.colorMatch:
        return l.tr('Color Match', 'Renk Eslestirme');
      case CoupleGameType.meteorShower:
        return l.tr('Meteor Shower', 'Meteor Yagmuru');
      case CoupleGameType.balloonPop:
        return l.tr('Balloon Pop', 'Balon Patlatma');
      case CoupleGameType.treasureDive:
        return l.tr('Treasure Dive', 'Hazine Dalisi');
      case CoupleGameType.bombPass:
        return l.tr('Bomb Pass', 'Bomba Pas');
      case CoupleGameType.towerStack:
        return l.tr('Tower Stack', 'Kule Yigma');
      case CoupleGameType.fruitCatch:
        return l.tr('Fruit Catch', 'Meyve Toplama');
      case CoupleGameType.targetShot:
        return l.tr('Target Shot', 'Hedef Vurma');
      case CoupleGameType.lavaFloor:
        return l.tr('Lava Floor', 'Lav Zemin');
      case CoupleGameType.paintWar:
        return l.tr('Paint War', 'Boya Savasi');
      case CoupleGameType.snakeArena:
        return l.tr('Snake Arena', 'Yilan Arenasi');
      case CoupleGameType.asteroidBreaker:
        return l.tr('Asteroid Breaker', 'Asteroid Kirma');
      case CoupleGameType.rhythmTap:
        return l.tr('Rhythm Tap', 'Ritim Dokun');
      case CoupleGameType.mazeRunner:
        return l.tr('Maze Runner', 'Labirent Kosusu');
      case CoupleGameType.shieldBlock:
        return l.tr('Shield Block', 'Kalkan Blok');
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
      case CoupleGameType.colorMatch:
        return '🎨';
      case CoupleGameType.meteorShower:
        return '☄️';
      case CoupleGameType.balloonPop:
        return '🎈';
      case CoupleGameType.treasureDive:
        return '💎';
      case CoupleGameType.bombPass:
        return '💥';
      case CoupleGameType.towerStack:
        return '🏗️';
      case CoupleGameType.fruitCatch:
        return '🍎';
      case CoupleGameType.targetShot:
        return '🎯';
      case CoupleGameType.lavaFloor:
        return '🌋';
      case CoupleGameType.paintWar:
        return '🖌️';
      case CoupleGameType.snakeArena:
        return '🐍';
      case CoupleGameType.asteroidBreaker:
        return '🪨';
      case CoupleGameType.rhythmTap:
        return '🎵';
      case CoupleGameType.mazeRunner:
        return '🏃';
      case CoupleGameType.shieldBlock:
        return '🛡️';
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
      case CoupleGameType.colorMatch:
        return l.tr('Match the falling colors! Fast fingers win!',
            'Dusen renkleri esle! Hizli parmaklar kazanir!');
      case CoupleGameType.meteorShower:
        return l.tr('Dodge the meteors! Survive the rain of fire!',
            'Meteorlardan kac! Ates yagmurundan kurtul!');
      case CoupleGameType.balloonPop:
        return l.tr('Pop balloons as fast as you can! Most pops wins!',
            'Balonlari hizla patlat! En cok patlatan kazanir!');
      case CoupleGameType.treasureDive:
        return l.tr('Dive deep and collect treasures before time runs out!',
            'Derine dal ve sure bitmeden hazineleri topla!');
      case CoupleGameType.bombPass:
        return l.tr('Pass the bomb before it explodes! Last holder loses!',
            'Bombayi patlamadan pas ver! Son tutan kaybeder!');
      case CoupleGameType.towerStack:
        return l.tr('Stack blocks precisely! Tallest tower wins!',
            'Bloklari duzgun yigin! En yuksek kule kazanir!');
      case CoupleGameType.fruitCatch:
        return l.tr('Catch falling fruits! Avoid the rotten ones!',
            'Dusen meyveleri yakala! Curuklerden kacin!');
      case CoupleGameType.targetShot:
        return l.tr('Hit the targets! Accuracy and speed count!',
            'Hedefleri vur! Dogruluk ve hiz sayilir!');
      case CoupleGameType.lavaFloor:
        return l.tr('Jump between platforms! The lava is rising!',
            'Platformlar arasi zipla! Lav yukseliyor!');
      case CoupleGameType.paintWar:
        return l.tr('Paint the arena your color! Most coverage wins!',
            'Arayi kendi renginle boya! En cok boyayan kazanir!');
      case CoupleGameType.snakeArena:
        return l.tr('Grow your snake! Dont crash into walls or yourself!',
            'Yilanini buyut! Duvarlara ve kendine carpma!');
      case CoupleGameType.asteroidBreaker:
        return l.tr('Break asteroids before they hit! Tap fast!',
            'Asteroidleri carpmadan kir! Hizli dokun!');
      case CoupleGameType.rhythmTap:
        return l.tr('Tap on beat! Perfect rhythm scores the most!',
            'Ritimde dokun! Mukemmel ritim en cok puan kazanir!');
      case CoupleGameType.mazeRunner:
        return l.tr('Race through the maze! Find the exit first!',
            'Labirentte kosun! Cikisi ilk bul!');
      case CoupleGameType.shieldBlock:
        return l.tr('Block incoming projectiles with your shield!',
            'Kalkaninla gelen mermi leri engelle!');
    }
  }

  bool get isProOnly {
    switch (this) {
      // ── Free games (18) ──
      case CoupleGameType.countTrap:
      case CoupleGameType.truthOrDare:
      case CoupleGameType.wouldYouRather:
      case CoupleGameType.quickTapDuel:
      case CoupleGameType.diceDuel:
      case CoupleGameType.sumoBall:
      case CoupleGameType.balloonPop:
      case CoupleGameType.bombPass:
      case CoupleGameType.meteorShower:
      case CoupleGameType.knowMeQuiz:
      case CoupleGameType.finishSentence:
      case CoupleGameType.emojiGuess:
      case CoupleGameType.colorMatch:
      case CoupleGameType.memoryMatch:
      case CoupleGameType.reactionRace:
      case CoupleGameType.fruitCatch:
      case CoupleGameType.targetShot:
      case CoupleGameType.towerStack:
        return false;
      // ── PRO-only games (remaining) ──
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
      case CoupleGameType.bombPass:
      case CoupleGameType.paintWar:
      case CoupleGameType.snakeArena:
        return [PlayerMode.multi];
      case CoupleGameType.colorMatch:
      case CoupleGameType.meteorShower:
      case CoupleGameType.balloonPop:
      case CoupleGameType.treasureDive:
      case CoupleGameType.towerStack:
      case CoupleGameType.fruitCatch:
      case CoupleGameType.targetShot:
      case CoupleGameType.lavaFloor:
      case CoupleGameType.asteroidBreaker:
      case CoupleGameType.rhythmTap:
      case CoupleGameType.mazeRunner:
      case CoupleGameType.shieldBlock:
        return [PlayerMode.solo, PlayerMode.multi];
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
      case CoupleGameType.colorMatch:
      case CoupleGameType.meteorShower:
      case CoupleGameType.balloonPop:
      case CoupleGameType.treasureDive:
      case CoupleGameType.bombPass:
      case CoupleGameType.towerStack:
      case CoupleGameType.fruitCatch:
      case CoupleGameType.targetShot:
      case CoupleGameType.lavaFloor:
      case CoupleGameType.paintWar:
      case CoupleGameType.snakeArena:
      case CoupleGameType.asteroidBreaker:
      case CoupleGameType.rhythmTap:
      case CoupleGameType.mazeRunner:
      case CoupleGameType.shieldBlock:
        return GameCategory.arena;
    }
  }

  /// Difficulty level — hard games get blur-guided tutorial
  GameDifficulty get difficulty {
    switch (this) {
      case CoupleGameType.truthOrDare:
      case CoupleGameType.wouldYouRather:
      case CoupleGameType.diceDuel:
      case CoupleGameType.balloonPop:
      case CoupleGameType.bombPass:
      case CoupleGameType.secretMessage:
        return GameDifficulty.easy;
      case CoupleGameType.countTrap:
      case CoupleGameType.knowMeQuiz:
      case CoupleGameType.tripMeter:
      case CoupleGameType.finishSentence:
      case CoupleGameType.emojiGuess:
      case CoupleGameType.quickTapDuel:
      case CoupleGameType.reactionRace:
      case CoupleGameType.memoryMatch:
      case CoupleGameType.wordBomb:
      case CoupleGameType.compatibilityTest:
      case CoupleGameType.meteorShower:
      case CoupleGameType.colorMatch:
      case CoupleGameType.towerStack:
      case CoupleGameType.fruitCatch:
      case CoupleGameType.targetShot:
      case CoupleGameType.rhythmTap:
      case CoupleGameType.rateAndRank:
        return GameDifficulty.medium;
      case CoupleGameType.sumoBall:
      case CoupleGameType.miniPool:
      case CoupleGameType.carRace:
      case CoupleGameType.laserDodge:
      case CoupleGameType.icePlatform:
      case CoupleGameType.loveMap:
      case CoupleGameType.bracketTournament:
      case CoupleGameType.treasureDive:
      case CoupleGameType.lavaFloor:
      case CoupleGameType.paintWar:
      case CoupleGameType.snakeArena:
      case CoupleGameType.asteroidBreaker:
      case CoupleGameType.mazeRunner:
      case CoupleGameType.shieldBlock:
        return GameDifficulty.hard;
    }
  }

  /// Tutorial steps (Turkish | English) — shown before first play
  List<TutorialStep> get tutorialSteps {
    switch (this) {
      // ── EASY GAMES ──
      case CoupleGameType.truthOrDare:
        return [
          TutorialStep(
            icon: '🎯',
            titleEn: 'Choose: Truth or Dare',
            titleTr: 'Seç: Doğruluk mu Cesaret mi',
            descEn: 'Tap one of the two options on screen.',
            descTr: 'Ekrandaki iki seçenekten birine dokun.',
          ),
          TutorialStep(
            icon: '💬',
            titleEn: 'Answer or Complete',
            titleTr: 'Cevapla veya Tamamla',
            descEn: 'Answer the question honestly or complete the dare!',
            descTr: 'Soruyu dürüstçe cevapla veya cesareti tamamla!',
          ),
        ];
      case CoupleGameType.wouldYouRather:
        return [
          TutorialStep(
            icon: '🤔',
            titleEn: 'Pick One Side',
            titleTr: 'Bir Tarafı Seç',
            descEn: 'You\'ll see two options — choose which you prefer.',
            descTr: 'İki seçenek göreceksin — hangisini tercih ettiğini seç.',
          ),
        ];
      case CoupleGameType.diceDuel:
        return [
          TutorialStep(
            icon: '🎲',
            titleEn: 'Tap to Roll',
            titleTr: 'Zar Atmak İçin Dokun',
            descEn: 'Tap the dice to roll. Highest number wins the round!',
            descTr: 'Zar atmak için dokun. En yüksek sayı turu kazanır!',
          ),
        ];
      case CoupleGameType.balloonPop:
        return [
          TutorialStep(
            icon: '🎈',
            titleEn: 'Pop the Balloons',
            titleTr: 'Balonları Patlat',
            descEn: 'Tap balloons as they float up. Don\'t miss any!',
            descTr: 'Yükselen balonlara dokun. Hiçbirini kaçırma!',
          ),
        ];
      case CoupleGameType.bombPass:
        return [
          TutorialStep(
            icon: '💣',
            titleEn: 'Pass the Bomb',
            titleTr: 'Bombayı Pas Ver',
            descEn: 'Answer quickly and pass before time runs out!',
            descTr: 'Hızlıca cevapla ve süre dolmadan pas ver!',
          ),
        ];
      case CoupleGameType.secretMessage:
        return [
          TutorialStep(
            icon: '✉️',
            titleEn: 'Write a Secret',
            titleTr: 'Gizli Mesaj Yaz',
            descEn: 'Write a secret message for your partner to reveal later.',
            descTr: 'Partnerine sonra açılacak gizli bir mesaj yaz.',
          ),
        ];

      // ── MEDIUM GAMES ──
      case CoupleGameType.countTrap:
        return [
          TutorialStep(
            icon: '🔢',
            titleEn: 'Count Together',
            titleTr: 'Birlikte Say',
            descEn: 'Take turns counting. Don\'t say the trap number!',
            descTr: 'Sırayla say. Tuzak sayıyı söyleme!',
          ),
          TutorialStep(
            icon: '⚠️',
            titleEn: 'Avoid the Trap',
            titleTr: 'Tuzaktan Kaçın',
            descEn: 'If you say the trap number, you lose the round.',
            descTr: 'Tuzak sayıyı söylersen turu kaybedersin.',
          ),
        ];
      case CoupleGameType.knowMeQuiz:
        return [
          TutorialStep(
            icon: '❓',
            titleEn: 'Answer Questions',
            titleTr: 'Soruları Cevapla',
            descEn: 'Answer questions about your partner. +15 per correct!',
            descTr: 'Partnerin hakkında soruları cevapla. Doğru başına +15!',
          ),
        ];
      case CoupleGameType.quickTapDuel:
        return [
          TutorialStep(
            icon: '👆',
            titleEn: 'Tap Fast!',
            titleTr: 'Hızlı Dokun!',
            descEn: 'When the signal appears, tap as fast as you can!',
            descTr: 'Sinyal belirdiğinde olabildiğince hızlı dokun!',
          ),
          TutorialStep(
            icon: '⏱️',
            titleEn: 'Reaction Matters',
            titleTr: 'Reaksiyon Önemli',
            descEn: 'Fastest tap wins the round. Best of 5!',
            descTr: 'En hızlı dokunuş turu kazanır. 5 turun en iyisi!',
          ),
        ];
      case CoupleGameType.reactionRace:
        return [
          TutorialStep(
            icon: '🏁',
            titleEn: 'Wait for Green',
            titleTr: 'Yeşili Bekle',
            descEn: 'Wait for the green signal, then tap immediately!',
            descTr: 'Yeşil sinyali bekle, sonra hemen dokun!',
          ),
        ];
      case CoupleGameType.memoryMatch:
        return [
          TutorialStep(
            icon: '🧠',
            titleEn: 'Find Pairs',
            titleTr: 'Çiftleri Bul',
            descEn: 'Flip cards and match pairs. Remember positions!',
            descTr: 'Kartları çevir ve eşleştir. Pozisyonları hatırla!',
          ),
          TutorialStep(
            icon: '⚡',
            titleEn: 'Be Quick',
            titleTr: 'Hızlı Ol',
            descEn: 'Fewer moves = more points. +15 bonus for perfection!',
            descTr: 'Daha az hamle = daha fazla puan. Mükemmellik bonusu +15!',
          ),
        ];
      case CoupleGameType.wordBomb:
        return [
          TutorialStep(
            icon: '💥',
            titleEn: 'Type Fast',
            titleTr: 'Hızlı Yaz',
            descEn:
                'Type a word with the given letters before the bomb explodes!',
            descTr: 'Bomba patlamadan verilen harflerle kelime yaz!',
          ),
        ];
      case CoupleGameType.meteorShower:
        return [
          TutorialStep(
            icon: '☄️',
            titleEn: 'Dodge Meteors',
            titleTr: 'Meteorlardan Kaç',
            descEn: 'Move your character to avoid falling meteors.',
            descTr: 'Düşen meteorlardan kaçmak için karakterini hareket ettir.',
          ),
        ];
      case CoupleGameType.colorMatch:
        return [
          TutorialStep(
            icon: '🎨',
            titleEn: 'Match the Color',
            titleTr: 'Rengi Eşleştir',
            descEn: 'Tap the matching color before time runs out!',
            descTr: 'Süre dolmadan eşleşen renge dokun!',
          ),
        ];
      case CoupleGameType.towerStack:
        return [
          TutorialStep(
            icon: '🏗️',
            titleEn: 'Stack Blocks',
            titleTr: 'Blok Yığ',
            descEn:
                'Tap at the right moment to stack. Perfect alignment = bonus!',
            descTr: 'Doğru anda dokunarak yığ. Mükemmel hizalama = bonus!',
          ),
        ];
      case CoupleGameType.fruitCatch:
        return [
          TutorialStep(
            icon: '🍎',
            titleEn: 'Catch Fruits',
            titleTr: 'Meyveleri Topla',
            descEn: 'Swipe to move the basket. Catch fruits, avoid bombs!',
            descTr:
                'Sepeti kaydırarak hareket ettir. Meyveleri topla, bombalardan kaçın!',
          ),
        ];
      case CoupleGameType.targetShot:
        return [
          TutorialStep(
            icon: '🎯',
            titleEn: 'Hit the Target',
            titleTr: 'Hedefe Vur',
            descEn: 'Tap targets as they appear. Center hits = more points!',
            descTr:
                'Hedefler belirdiğinde dokun. Merkez vuruşları = daha fazla puan!',
          ),
        ];
      case CoupleGameType.rhythmTap:
        return [
          TutorialStep(
            icon: '🎵',
            titleEn: 'Follow the Rhythm',
            titleTr: 'Ritmi Takip Et',
            descEn: 'Tap in sync with the beat. Perfect timing = combo!',
            descTr: 'Ritimle senkron dokun. Mükemmel zamanlama = kombo!',
          ),
        ];
      case CoupleGameType.tripMeter:
      case CoupleGameType.finishSentence:
      case CoupleGameType.emojiGuess:
      case CoupleGameType.compatibilityTest:
      case CoupleGameType.rateAndRank:
        return [
          TutorialStep(
            icon: '📝',
            titleEn: 'Follow On-Screen Instructions',
            titleTr: 'Ekrandaki Talimatları Takip Et',
            descEn:
                'Read and respond to each prompt. Points are earned per round.',
            descTr:
                'Her bir yönergeyi oku ve cevapla. Her turda puan kazanılır.',
          ),
        ];

      // ── HARD GAMES (get blur overlay) ──
      case CoupleGameType.sumoBall:
        return [
          TutorialStep(
            icon: '🏋️',
            titleEn: 'Push Opponent Out',
            titleTr: 'Rakibi Dışarı İt',
            descEn: 'Drag your sumo ball toward the opponent to push them.',
            descTr: 'Sumo topunu rakibe doğru sürükleyerek it.',
            highlightZone: HighlightZone.center,
          ),
          TutorialStep(
            icon: '⭕',
            titleEn: 'Stay Inside the Ring',
            titleTr: 'Ringin İçinde Kal',
            descEn: 'If you fall outside the ring, you lose!',
            descTr: 'Ringin dışına düşersen kaybedersin!',
            highlightZone: HighlightZone.center,
          ),
        ];
      case CoupleGameType.miniPool:
        return [
          TutorialStep(
            icon: '🎱',
            titleEn: 'Aim and Shoot',
            titleTr: 'Nişan Al ve Vur',
            descEn: 'Drag from the cue ball to set direction and power.',
            descTr: 'İsabet topundan sürükleyerek yön ve güç ayarla.',
            highlightZone: HighlightZone.center,
          ),
          TutorialStep(
            icon: '🕳️',
            titleEn: 'Pot the Balls',
            titleTr: 'Topları Cebe At',
            descEn: 'Sink all your balls into the pockets to win!',
            descTr: 'Tüm toplarını ceplere atarak kazan!',
            highlightZone: HighlightZone.center,
          ),
        ];
      case CoupleGameType.carRace:
        return [
          TutorialStep(
            icon: '🏎️',
            titleEn: 'Tilt to Steer',
            titleTr: 'Yönlendirmek İçin Eğ',
            descEn: 'Tilt your device or use touch controls to steer.',
            descTr:
                'Yönlendirmek için cihazını eğ veya dokunmatik kontrol kullan.',
            highlightZone: HighlightZone.bottom,
          ),
          TutorialStep(
            icon: '🏆',
            titleEn: 'Reach the Finish Line',
            titleTr: 'Bitiş Çizgisine Ulaş',
            descEn: 'Avoid obstacles and finish first to win!',
            descTr: 'Engellerden kaçın ve birinci bitirip kazan!',
          ),
        ];
      case CoupleGameType.laserDodge:
        return [
          TutorialStep(
            icon: '🔴',
            titleEn: 'Dodge the Lasers',
            titleTr: 'Lazerlerden Kaç',
            descEn: 'Move your character to avoid laser beams.',
            descTr: 'Lazer ışınlarından kaçmak için karakterini hareket ettir.',
            highlightZone: HighlightZone.center,
          ),
          TutorialStep(
            icon: '⏱️',
            titleEn: 'Survive Longer',
            titleTr: 'Daha Uzun Hayatta Kal',
            descEn: 'The longer you survive, the more points you earn!',
            descTr:
                'Ne kadar uzun hayatta kalırsan, o kadar çok puan kazanırsın!',
          ),
        ];
      case CoupleGameType.icePlatform:
        return [
          TutorialStep(
            icon: '🧊',
            titleEn: 'Jump Between Platforms',
            titleTr: 'Platformlar Arası Zıpla',
            descEn: 'Tap to jump. Ice platforms are slippery!',
            descTr: 'Zıplamak için dokun. Buz platformlar kaygan!',
            highlightZone: HighlightZone.bottom,
          ),
        ];
      case CoupleGameType.loveMap:
        return [
          TutorialStep(
            icon: '💕',
            titleEn: 'Build Your Love Map',
            titleTr: 'Aşk Haritanı Oluştur',
            descEn: 'Mark meaningful places and memories on the map.',
            descTr: 'Haritada anlamlı yerleri ve anıları işaretle.',
          ),
        ];
      case CoupleGameType.bracketTournament:
        return [
          TutorialStep(
            icon: '🏅',
            titleEn: 'Tournament Bracket',
            titleTr: 'Turnuva Elemesi',
            descEn: 'Compete in elimination rounds. Win to advance!',
            descTr: 'Eleme turlarında yarış. Kazanarak ilerle!',
          ),
        ];
      case CoupleGameType.treasureDive:
        return [
          TutorialStep(
            icon: '🤿',
            titleEn: 'Dive for Treasure',
            titleTr: 'Hazine İçin Dal',
            descEn: 'Control your diver to collect treasures. Avoid obstacles!',
            descTr:
                'Dalgıcını kontrol ederek hazineleri topla. Engellerden kaçın!',
            highlightZone: HighlightZone.center,
          ),
        ];
      case CoupleGameType.lavaFloor:
        return [
          TutorialStep(
            icon: '🌋',
            titleEn: 'The Floor is Lava!',
            titleTr: 'Zemin Lav!',
            descEn: 'Jump between safe platforms. Don\'t touch the lava!',
            descTr: 'Güvenli platformlar arasında zıpla. Lava dokunma!',
            highlightZone: HighlightZone.bottom,
          ),
        ];
      case CoupleGameType.paintWar:
        return [
          TutorialStep(
            icon: '🖌️',
            titleEn: 'Paint Your Territory',
            titleTr: 'Bölgeni Boya',
            descEn: 'Swipe to paint. Cover more area than your opponent!',
            descTr: 'Kaydırarak boya. Rakibinden daha fazla alan kapla!',
            highlightZone: HighlightZone.center,
          ),
        ];
      case CoupleGameType.snakeArena:
        return [
          TutorialStep(
            icon: '🐍',
            titleEn: 'Grow Your Snake',
            titleTr: 'Yılanını Büyüt',
            descEn: 'Eat food to grow. Don\'t crash into walls or yourself!',
            descTr: 'Yiyecek ye ve büyü. Duvarlara veya kendine çarpma!',
            highlightZone: HighlightZone.center,
          ),
        ];
      case CoupleGameType.asteroidBreaker:
        return [
          TutorialStep(
            icon: '💫',
            titleEn: 'Break Asteroids',
            titleTr: 'Asteroidleri Kır',
            descEn:
                'Shoot at asteroids to break them. Smaller pieces = more points!',
            descTr:
                'Asteroidlere ateş ederek kır. Küçük parçalar = daha fazla puan!',
            highlightZone: HighlightZone.center,
          ),
        ];
      case CoupleGameType.mazeRunner:
        return [
          TutorialStep(
            icon: '🏃',
            titleEn: 'Navigate the Maze',
            titleTr: 'Labirentte İlerle',
            descEn: 'Swipe to move. Find the exit before your opponent!',
            descTr: 'Kaydırarak hareket et. Rakibinden önce çıkışı bul!',
            highlightZone: HighlightZone.center,
          ),
        ];
      case CoupleGameType.shieldBlock:
        return [
          TutorialStep(
            icon: '🛡️',
            titleEn: 'Block with Your Shield',
            titleTr: 'Kalkanınla Engelle',
            descEn: 'Move your shield to block incoming projectiles.',
            descTr: 'Gelen mermileri engellemek için kalkanını hareket ettir.',
            highlightZone: HighlightZone.center,
          ),
          TutorialStep(
            icon: '💥',
            titleEn: 'Don\'t Get Hit',
            titleTr: 'Vurulma',
            descEn: 'Each hit costs health. Survive as long as possible!',
            descTr:
                'Her vuruş can kaybettirir. Mümkün olduğunca uzun hayatta kal!',
          ),
        ];
    }
  }
}

/// Zone to highlight (keep un-blurred) during hard-mode tutorials
enum HighlightZone { center, top, bottom }

/// A single step in a game tutorial
class TutorialStep {
  const TutorialStep({
    required this.icon,
    required this.titleEn,
    required this.titleTr,
    required this.descEn,
    required this.descTr,
    this.highlightZone,
  });

  final String icon;
  final String titleEn;
  final String titleTr;
  final String descEn;
  final String descTr;
  final HighlightZone? highlightZone;

  String get title => l.tr(titleEn, titleTr);
  String get description => l.tr(descEn, descTr);
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
