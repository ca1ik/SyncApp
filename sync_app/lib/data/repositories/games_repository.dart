import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/locale_service.dart';
import '../models/game_model.dart';

class GamesRepository {
  GamesRepository({required SharedPreferences prefs}) : _prefs = prefs;
  final SharedPreferences _prefs;

  static const String _pointsKey = 'sync_couple_points';
  static const String _scoresKey = 'sync_game_scores';
  static const String _questionsKey = 'sync_couple_questions';

  // ── Points ──
  Future<CouplePoints> getPoints() async {
    final raw = _prefs.getString(_pointsKey);
    if (raw == null) return const CouplePoints();
    return CouplePoints.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<CouplePoints> addPoints(int points) async {
    var cp = await getPoints();
    var newTotal = cp.totalPoints + points;
    var newLevel = cp.bondLevel;
    while (newTotal >= newLevel * 150) {
      newTotal -= newLevel * 150;
      newLevel++;
    }
    cp = cp.copyWith(
      totalPoints: newTotal,
      bondLevel: newLevel,
      gamesPlayed: cp.gamesPlayed + 1,
    );
    await _prefs.setString(_pointsKey, jsonEncode(cp.toJson()));
    return cp;
  }

  // ── Game Scores ──
  Future<List<GameScore>> getScores() async {
    final raw = _prefs.getString(_scoresKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => GameScore.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveScore(GameScore score) async {
    final scores = await getScores();
    scores.add(score);
    // Keep last 100
    if (scores.length > 100) scores.removeRange(0, scores.length - 100);
    await _prefs.setString(
        _scoresKey, jsonEncode(scores.map((s) => s.toJson()).toList()));
    await addPoints(score.totalPoints);
  }

  // ── Q&A ──
  Future<List<CoupleQuestion>> getQuestions() async {
    final raw = _prefs.getString(_questionsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => CoupleQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveQuestion(CoupleQuestion q) async {
    final questions = await getQuestions();
    final idx = questions.indexWhere((e) => e.id == q.id);
    if (idx >= 0) {
      questions[idx] = q;
    } else {
      questions.add(q);
    }
    await _prefs.setString(
        _questionsKey, jsonEncode(questions.map((e) => e.toJson()).toList()));
  }

  // ── Truth or Dare Questions ──
  static List<String> get truthQuestions => [
        l.tr('What did you think about me when you first saw me?',
            'Ilk gordugunde benim hakkimda ne dusundun?'),
        l.tr('What is your favorite thing about me?',
            'Benim en sevdigin ozelligim ne?'),
        l.tr('When was the last time you really missed me?',
            'Beni en son ne zaman cok ozledin?'),
        l.tr('What was your best moment with me?',
            'Benimle en guzel anin hangisiydi?'),
        l.tr('Do you have a secret you never told me?',
            'Bana hic soylemedigi bir sirrin var mi?'),
        l.tr('What are your biggest fears?', 'En buyuk korkularin neler?'),
        l.tr('What do you want to achieve most in life?',
            'Hayatta en cok neyi basarmak istiyorsun?'),
        l.tr('If you had a superpower for one day, what would it be?',
            'Eger bir gunku superguc olsaydi ne olurdu?'),
        l.tr('Is there a message you wanted to send me but couldn\'t?',
            'Bana yazmak isteyip de yazamadigin bir mesaj var mi?'),
        l.tr('What scares you most about relationships?',
            'Iliski hakkinda en cok neyden korkuyorsun?'),
        l.tr('Which action of mine makes you happiest?',
            'Benim hangi hareketim seni en cok mutlu eder?'),
        l.tr('Where would your dream vacation be?',
            'Hayalindeki tatil nereye olurdu?'),
        l.tr('If you hadn\'t met me, what would you be doing now?',
            'Eger benimle tanismasaydin simdi ne yapiyor olurdun?'),
        l.tr('What do you say when describing me to your family?',
            'Beni ailene anlatirken ne diyorsun?'),
        l.tr('What was your most embarrassing moment?',
            'En utanc verici anin neydi?'),
        l.tr('What would be the best gift you could buy me?',
            'Bana alabilecegi en guzel hediye ne olurdu?'),
        l.tr('What do you disagree with me on but don\'t say?',
            'Hangi konuda bana katilmiyorsun ama soylemiyorsun?'),
        l.tr('What do you want to do together in the future?',
            'Gelecekte birlikte ne yapmak istersin?'),
        l.tr('Which habit of mine do you love the most?',
            'Benim hangi aliskanligimi en cok seviyorsun?'),
        l.tr('If you were a movie character, who would you be?',
            'Eger bir film karakteri olsaydin kim olurdun?'),
        l.tr('When were you most jealous of me?',
            'Beni en cok ne zaman kiskandın?'),
        l.tr('What was your best childhood memory?',
            'Cocukluktan en guzel anin neydi?'),
        l.tr('Is there a question you can\'t ask me?',
            'Bana soremedigin bir soru var mi?'),
        l.tr('What are the 3 most important things for a relationship?',
            'Iliski icin en onemli 3 sey nedir sence?'),
        l.tr('What did you feel when you first kissed me?',
            'Beni ilk optugunde ne hissettin?'),
      ];

  static List<String> get dareQuestions => [
        l.tr('Smile at your partner for 1 minute and make eye contact!',
            'Partnerine 1 dakika boyunca gulumse ve goz kontagi kur!'),
        l.tr('Give your partner 3 compliments, each one different!',
            'Partnerine 3 iltifat et, her biri farkli olsun!'),
        l.tr('Sing your partner\'s favorite song!',
            'Partnerinin en sevdigi sarkiyi soyle!'),
        l.tr('Give your partner a 20-second massage!',
            'Partnerine 20 saniyelik bir masaj yap!'),
        l.tr('Look into your partner\'s eyes and tell them why you love them!',
            'Partnerinin gozlerinin icine bak ve onu neden sevdigini soyle!'),
        l.tr('Show your partner a funny dance!',
            'Partnerine komik bir dans goster!'),
        l.tr('Show your partner the last 3 photos on your phone!',
            'Telefonundaki son 3 fotogu partnerine goster!'),
        l.tr('Read or make up a love poem for your partner!',
            'Partnerine bir ask siiri oku veya uydur!'),
        l.tr('Give your partner a piggyback ride!',
            'Partnerine sirtindan bir tur at!'),
        l.tr('Whisper to your partner for one minute!',
            'Partnerine bir dakika boyunca fısıltıyla konus!'),
        l.tr('Promise to cook your partner\'s favorite meal!',
            'Partnerinin en sevdigi yemegi yapmaya soz ver!'),
        l.tr('Wink at your partner and say something charming!',
            'Partnerine goz kirp ve cekici bir soz soyle!'),
        l.tr('Do an animal impression, let your partner guess!',
            'Partnerine hayvan taklidi yap, o tahmin etsin!'),
        l.tr('Summarize your day in 3 emojis for your partner!',
            'Partnerine bugunku gununu 3 emojide ozetle!'),
        l.tr('Hug your partner for 10 seconds straight!',
            'Partnerine 10 saniye boyunca sarilip dur!'),
      ];

  static List<String> get wouldYouRatherOptions => [
        l.tr('Would you rather write a letter every day or hug every day?',
            'Her gün mektup mu yazmak istersin yoksa her gün sarılmak mı?'),
        l.tr('Travel the world together or build a house together?',
            'Birlikte dünya turuna mı çıkmak yoksa birlikte ev mi yapmak?'),
        l.tr(
            'Would you want your partner to read your mind or feel your emotions?',
            'Partnerin aklını mı okusun yoksa duygularını mı hissetsin?'),
        l.tr('Always laugh together or always cry together?',
            'Hep birlikte gülmek mi yoksa hep birlikte ağlamak mı?'),
        l.tr(
            'Would you want your partner to always give gifts or always compliment?',
            'Partnerin sürekli hediye mi alsın yoksa sürekli iltifat mı etsin?'),
        l.tr('Live adventures together or find peace together?',
            'Birlikte macera mı yaşamak yoksa birlikte huzur mu bulmak?'),
        l.tr('See all your partner\'s messages or none of them?',
            'Telefonunda partnerin tüm mesajlarını mı görsün yoksa hiçbirini mi?'),
        l.tr('Live apart for 1 year or be together 24/7 for 1 year?',
            '1 yıl uzakta mı yaşamak yoksa 1 yıl 24 saat birlikte mi olmak?'),
        l.tr(
            'Would you want your partner to cook perfectly or dance perfectly?',
            'Partnerin mükemmel yemek mi yapsın yoksa mükemmel dans mı etsin?'),
        l.tr('Go to the past to meet or go to the future to grow old together?',
            'Geçmişe mi gidip tanışmak yoksa geleceğe mi gidip birlikte yaşlanmak?'),
        l.tr('Would you want your partner to be very romantic or very funny?',
            'Partnerin çok romantik mi olsun yoksa çok komik mi?'),
        l.tr('Start a business together or create art together?',
            'Birlikte bir iş mi kurmak yoksa birlikte sanat mı yapmak?'),
        l.tr('Make up after every argument or never argue?',
            'Her tartışma sonrası barışmak mı yoksa hiç tartışmamak mı?'),
        l.tr('Would you want your partner to read minds or see the future?',
            'Partnerin zihin mi okusun yoksa geleceği mi görsün?'),
        l.tr('Adopt a dog together or a cat?',
            'Birlikte köpek mi sahiplenmek yoksa kedi mi?'),
        l.tr('Be together for 10 years before marrying or marry right away?',
            'Evlenmeden 10 yıl mı birlikte yoksa hemen evlenmek mi?'),
        l.tr(
            'Would you want your partner to always be right or always be happy?',
            'Partnerin her zaman haklı mı olsun yoksa her zaman mutlu mu?'),
        l.tr('Watch a horror movie together or a romantic comedy?',
            'Birlikte korku filmi mi izlemek yoksa romantik komedi mi?'),
        l.tr(
            'Would you want your partner to write you a song or paint you a picture?',
            'Partnerin sana şarkı mı yazsın yoksa tablo mu çizsin?'),
        l.tr('Surprise party for your birthday or intimate dinner for two?',
            'Doğum gününü sürpriz parti mi yoksa ikiye özel akşam yemeği mi?'),
      ];

  static List<String> get knowMeQuestions => [
        l.tr('What is my favorite color?', 'En sevdiğim renk nedir?'),
        l.tr('What is my biggest fear?', 'En büyük korkum nedir?'),
        l.tr('What did I want to be when I was a child?',
            'Çocukluğumda olmak istediğim meslek neydi?'),
        l.tr('What is my favorite food?', 'En sevdiğim yemek nedir?'),
        l.tr('Which season do I like the most?',
            'Hangi mevsimi en çok severim?'),
        l.tr('What is my favorite movie/show?', 'En sevdiğim film/dizi nedir?'),
        l.tr('What do I do first in the morning?', 'Sabahları ilk ne yaparım?'),
        l.tr('What do I do when I\'m stressed?',
            'Stresli olduğumda ne yaparım?'),
        l.tr('What is my best friend\'s name?', 'En yakın arkadaşımın adı ne?'),
        l.tr('Where is my dream vacation spot?',
            'Hayalimdeki tatil yeri neresi?'),
        l.tr('What is my favorite music genre?',
            'En sevdiğim müzik türü nedir?'),
        l.tr('Which superpower would I want?', 'Hangi supergücü isterim?'),
        l.tr('What is my favorite animal?', 'En sevdiğim hayvan nedir?'),
        l.tr('What was my favorite subject in school?',
            'Okul hayatımda en sevdiğim ders neydi?'),
        l.tr('What do I usually do when I\'m happy?',
            'Mutlu olduğumda genelde ne yaparım?'),
        l.tr('What is my most hated chore?', 'En nefret ettiğim ev işi nedir?'),
        l.tr('How old was I when I had my first relationship?',
            'Kaç yaşımda ilk sevgilim oldu?'),
        l.tr('What makes me most angry?', 'Beni en çok ne kızdırır?'),
        l.tr('Which social media do I use the most?',
            'En çok hangi sosyal medyayı kullanırım?'),
        l.tr('What is one thing I want to change in my life?',
            'Hayatımda değiştirmek istediğim bir şey ne?'),
        l.tr('What do I usually do before sleeping?',
            'Uykudan önce genelde ne yaparım?'),
        l.tr('What is my favorite dessert?', 'En sevdiğim tatlı nedir?'),
        l.tr('Which country do I want to visit the most?',
            'Hangi ülkeyi en çok görmek isterim?'),
        l.tr(
            'What makes me laugh the most?', 'Beni en çok güldüren şey nedir?'),
        l.tr('What is my hidden talent?', 'Gizli yeteneğim nedir?'),
      ];

  static List<String> get finishSentencePrompts => [
        l.tr('The happiest moment with you...',
            'Seninle en mutlu olduğum an...'),
        l.tr('When I first saw you...', 'Seni ilk gördüğümde...'),
        l.tr('The craziest thing I want to do together...',
            'Birlikte yapmak istediğim en çılgın şey...'),
        l.tr('With you, 10 years from now...', 'Seninle 10 yıl sonra...'),
        l.tr('Something I couldn\'t tell you...',
            'Sana söyleyemediğim bir şey...'),
        l.tr('If only the two of us were left in the world...',
            'Eğer dünyada sadece ikimiz kalsak...'),
        l.tr('The one thing I could give up for you...',
            'Senin için vazgeçebileceğim tek şey...'),
        l.tr('The last time we laughed together...',
            'Birlikte en son güldüğümüz an...'),
        l.tr('The moment I was most jealous of you...',
            'Seni en çok kıskandığım an...'),
        l.tr('Our next adventure together...',
            'Seninle yapacağım bir sonraki macera...'),
        l.tr('What I value most in our relationship...',
            'İlişkimizde en çok değer verdiğim şey...'),
        l.tr('The most beautiful gift I want to get you...',
            'Sana almak istediğim en güzel hediye...'),
        l.tr('When we cook together...', 'Birlikte yemek yapınca...'),
        l.tr('Before sleeping with you...', 'Seninle uyumadan önce...'),
        l.tr('If I were to dedicate a song to you...',
            'Eğer sana bir şarkı adayacak olsam...'),
        l.tr('Because I know you...', 'Seni tanıdığım için...'),
        l.tr('When we grow old together...', 'Birlikte yaşlandığımızda...'),
        l.tr('When I argue with you, I...', 'Seninle tartışınca ben...'),
        l.tr('The most important thing I learned from you...',
            'Senden en çok öğrendiğim şey...'),
        l.tr('If I ever disappear, find me...',
            'Eğer bir gün kaybolursam beni...'),
      ];

  static List<String> get emojiChallenges => [
        l.tr('🎬 Describe your favorite movie with emojis!',
            '🎬 En sevdiğiniz filmi emojilerle anlatın!'),
        l.tr('🍽️ Describe the last meal you ate with emojis!',
            '🍽️ En son yediğiniz yemeği emojilerle tarif edin!'),
        l.tr('🎵 Describe a song with emojis!',
            '🎵 Bir şarkıyı emojilerle anlatın!'),
        l.tr('📖 Summarize a fairy tale with emojis!',
            '📖 Bir masalı emojilerle özetleyin!'),
        l.tr('🏖️ Describe your dream vacation with emojis!',
            '🏖️ Hayalinizdeki tatili emojilerle anlatın!'),
        l.tr('💑 Describe your first date with emojis!',
            '💑 İlk buluşmanızı emojilerle anlatın!'),
        l.tr('🎭 Share a moment from today with emojis!',
            '🎭 Bugün yaşadığınız bir anı emojilerle paylaşın!'),
        l.tr('🌍 Describe a country you want to visit with emojis!',
            '🌍 Gitmek istediğiniz ülkeyi emojilerle tarif edin!'),
        l.tr('🎮 Describe your favorite game with emojis!',
            '🎮 En sevdiğiniz oyunu emojilerle anlatın!'),
        l.tr('📺 Summarize your favorite show with emojis!',
            '📺 En sevdiğiniz diziyi emojilerle özetleyin!'),
        l.tr('🐾 Describe an animal with emojis, let your partner guess!',
            '🐾 Bir hayvanı emojilerle anlatın, partner tahmin etsin!'),
        l.tr('🏠 Describe your dream home with emojis!',
            '🏠 Hayalinizdeki evi emojilerle anlatın!'),
        l.tr('👗 Describe what you\'re wearing today with emojis!',
            '👗 Bugün giyeceğiniz kıyafeti emojilerle tarif edin!'),
        l.tr('🎁 Describe a gift you\'d want with emojis!',
            '🎁 Almak istediğiniz hediyeyi emojilerle anlatın!'),
        l.tr('🚗 Describe a trip you want to take with emojis!',
            '🚗 Yapmak istediğiniz yolculuğu emojilerle tarif edin!'),
      ];

  static List<List<String>> get compatibilityQuestions => [
        [
          l.tr('What is the ideal weekend activity?',
              'Ideal hafta sonu ne yapmaktir?'),
          l.tr('Movie at home', 'Evde film'),
          l.tr('Outdoor activity', 'Disarida etkinlik'),
          l.tr('Walk in nature', 'Dogada yurumus'),
          l.tr('Meet friends', 'Arkadaslarla bulusma')
        ],
        [
          l.tr('What do you do during an argument?', 'Tartismada ne yaparsın?'),
          l.tr('Talk right away', 'Hemen konusurum'),
          l.tr('Wait a bit', 'Biraz beklerim'),
          l.tr('Send a message', 'Mesaj yazarim'),
          l.tr('Go quiet', 'Susarim')
        ],
        [
          l.tr('What is your love language?', 'Ask dili nedir?'),
          l.tr('Physical touch', 'Fiziksel dokunma'),
          l.tr('Compliments', 'Iltifat'),
          l.tr('Gifts', 'Hediye'),
          l.tr('Quality time', 'Birlikte vakit')
        ],
        [
          l.tr('Are you a morning or night person?',
              'Sabah kisi misin gece kisi mi?'),
          l.tr('Morning', 'Sabah'),
          l.tr('Night', 'Gece'),
          l.tr('Both', 'Ikisi de'),
          l.tr('Neither', 'Hicbiri')
        ],
        [
          l.tr('What is most important in a relationship?',
              'Iliski icin en onemli sey?'),
          l.tr('Trust', 'Guven'),
          l.tr('Communication', 'Iletisim'),
          l.tr('Passion', 'Tutku'),
          l.tr('Respect', 'Saygi')
        ],
        [
          l.tr('What do you do on vacation?', 'Tatilde ne yaparsın?'),
          l.tr('Sightsee', 'Gez-gor'),
          l.tr('Relax', 'Dinlen'),
          l.tr('Adventure', 'Macera'),
          l.tr('Try local food', 'Yemek dene')
        ],
        [
          l.tr('What do you want when stressed?', 'Stres aninda ne istersin?'),
          l.tr('A hug', 'Sarilin'),
          l.tr('Alone time', 'Yalniz kalim'),
          l.tr('Talk it out', 'Konusayim'),
          l.tr('Do something together', 'Birlikte birsey yapalim')
        ],
        [
          l.tr('How do you spend money?', 'Para harcama tarzın?'),
          l.tr('Save it', 'Tutumluyum'),
          l.tr('Balance it', 'Dengeye bakarim'),
          l.tr('Treat myself', 'Keyifime bakarim'),
          l.tr('Invest it', 'Yatirim yaparim')
        ],
        [
          l.tr('What are your future plans?', 'Gelecek planlarin?'),
          l.tr('Get married', 'Evlenmek'),
          l.tr('Career', 'Kariyer'),
          l.tr('Travel', 'Seyahat'),
          l.tr('Don\'t know yet', 'Hicbiri bilmiyorum')
        ],
        [
          l.tr('How do you resolve relationship problems?',
              'Iliski problemi cozumu?'),
          l.tr('Talk', 'Konusurum'),
          l.tr('Write', 'Yazarim'),
          l.tr('Give it time', 'Zaman veririm'),
          l.tr('Seek professional help', 'Uzman yardimiyla')
        ],
      ];

  static List<Map<String, dynamic>> get tripMeterScenarios => [
        {
          'scenario': l.tr(
              'I put a password on my phone but I\'m not telling you.',
              'Telefonuna şifre koydum ama sana söylemiyorum.'),
          'level': 2
        },
        {
          'scenario': l.tr('I\'m talking to my ex but we\'re just friends.',
              'Eski sevgilimle konuşuyorum ama sadece arkadaşız.'),
          'level': 4
        },
        {
          'scenario': l.tr('My mom doesn\'t like you but I\'m taking her side.',
              'Annem seni sevmiyor ama ben annemin tarafındayım.'),
          'level': 5
        },
        {
          'scenario': l.tr(
              'I\'m going on vacation with friends, you can\'t come.',
              'Arkadaşlarımla tatile gidiyorum, sen gelemezsin.'),
          'level': 3
        },
        {
          'scenario': l.tr('I forgot your birthday and I won\'t apologize.',
              'Doğum gününü unuttum ama özür dilemeyeceğim.'),
          'level': 4
        },
        {
          'scenario': l.tr(
              'I replied to your messages 3 hours late, no reason.',
              'Mesajlarıma 3 saat geç cevap verdim, sebebi yok.'),
          'level': 2
        },
        {
          'scenario': l.tr(
              'I had coffee with someone of the opposite sex and didn\'t tell you.',
              'Bir karşı cins arkadaşımla kahve içtim, söylemedim.'),
          'level': 5
        },
        {
          'scenario': l.tr(
              'I cancelled our plans last minute, my friends called.',
              'Planlarımızı son dakika iptal ettim, arkadaşlarım aradı.'),
          'level': 3
        },
        {
          'scenario': l.tr(
              'I liked someone\'s photo on social media and made you jealous.',
              'Sosyal medyada birinin fotoğrafını beğendim, seni kıskandırdım.'),
          'level': 3
        },
        {
          'scenario': l.tr('I\'m playing games instead of talking to you.',
              'Seninle konuşmak yerine oyun oynuyorum.'),
          'level': 2
        },
        {
          'scenario': l.tr(
              'I\'m upset with you but won\'t say why, figure it out yourself.',
              'Sana kızdım ama nedenini söylemiyorum, kendin anla.'),
          'level': 4
        },
        {
          'scenario': l.tr(
              'My family is interfering in our relationship and I\'m allowing it.',
              'Ailem bize karışıyor ama ben izin veriyorum.'),
          'level': 4
        },
        {
          'scenario': l.tr('I constantly comment on your clothing choices.',
              'Senin kıyafet seçimine karışıyorum sürekli.'),
          'level': 3
        },
        {
          'scenario': l.tr('I made a decision but didn\'t ask you.',
              'Bir karar aldım ama sana sormadım.'),
          'level': 3
        },
        {
          'scenario': l.tr(
              'I\'m giving you the silent treatment and haven\'t talked for 2 days.',
              'Sana trip atıyorum ama konuşmuyorum 2 gündür.'),
          'level': 5
        },
      ];

  String getRandomTruth() =>
      truthQuestions[Random().nextInt(truthQuestions.length)];
  String getRandomDare() =>
      dareQuestions[Random().nextInt(dareQuestions.length)];
  String getRandomWouldYouRather() =>
      wouldYouRatherOptions[Random().nextInt(wouldYouRatherOptions.length)];
  String getRandomKnowMeQuestion() =>
      knowMeQuestions[Random().nextInt(knowMeQuestions.length)];
  String getRandomFinishSentence() =>
      finishSentencePrompts[Random().nextInt(finishSentencePrompts.length)];
  String getRandomEmojiChallenge() =>
      emojiChallenges[Random().nextInt(emojiChallenges.length)];
  Map<String, dynamic> getRandomTripScenario() =>
      tripMeterScenarios[Random().nextInt(tripMeterScenarios.length)];
  List<String> getRandomCompatibilityQ() =>
      compatibilityQuestions[Random().nextInt(compatibilityQuestions.length)];
}
