import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
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
  static final List<String> truthQuestions = [
    'Ilk gordugunde benim hakkimda ne dusundun?',
    'Benim en sevdigin ozelligim ne?',
    'Beni en son ne zaman cok ozledin?',
    'Benimle en guzel anin hangisiydi?',
    'Bana hic soylemedigi bir sirrin var mi?',
    'En buyuk korkularin neler?',
    'Hayatta en cok neyi basarmak istiyorsun?',
    'Eger bir gunku superguc olsaydi ne olurdu?',
    'Bana yazmak isteyip de yazamadigin bir mesaj var mi?',
    'Iliski hakkinda en cok neyden korkuyorsun?',
    'Benim hangi hareketim seni en cok mutlu eder?',
    'Hayalindeki tatil nereye olurdu?',
    'Eger benimle tanismasaydin simdi ne yapiyor olurdun?',
    'Beni ailene anlatirken ne diyorsun?',
    'En utanc verici anin neydi?',
    'Bana alabilecegi en guzel hediye ne olurdu?',
    'Hangi konuda bana katilmiyorsun ama soylemiyorsun?',
    'Gelecekte birlikte ne yapmak istersin?',
    'Benim hangi aliskanligimi en cok seviyorsun?',
    'Eger bir film karakteri olsaydin kim olurdun?',
    'Beni en cok ne zaman kiskandın?',
    'Cocukluktan en guzel anin neydi?',
    'Bana soremedigin bir soru var mi?',
    'Iliski icin en onemli 3 sey nedir sence?',
    'Beni ilk optugunde ne hissettin?',
  ];

  static final List<String> dareQuestions = [
    'Partnerine 1 dakika boyunca gulumse ve goz kontagi kur!',
    'Partnerine 3 iltifat et, her biri farkli olsun!',
    'Partnerinin en sevdigi sarkiyi soyle!',
    'Partnerine 20 saniyelik bir masaj yap!',
    'Partnerinin gozlerinin icine bak ve onu neden sevdigini soyle!',
    'Partnerine komik bir dans goster!',
    'Telefonundaki son 3 fotogu partnerine goster!',
    'Partnerine bir ask siiri oku veya uydur!',
    'Partnerine sirtindan bir tur at!',
    'Partnerine bir dakika boyunca fısıltıyla konus!',
    'Partnerinin en sevdigi yemegi yapmaya soz ver!',
    'Partnerine goz kirp ve cekici bir soz soyle!',
    'Partnerine hayvan taklidi yap, o tahmin etsin!',
    'Partnerine bugunku gununu 3 emojide ozetle!',
    'Partnerine 10 saniye boyunca sarilip dur!',
  ];

  static final List<String> wouldYouRatherOptions = [
    'Her gün mektup mu yazmak istersin yoksa her gün sarılmak mı?',
    'Birlikte dünya turuna mı çıkmak yoksa birlikte ev mi yapmak?',
    'Partnerin aklını mı okusun yoksa duygularını mı hissetsin?',
    'Hep birlikte gülmek mi yoksa hep birlikte ağlamak mı?',
    'Partnerin sürekli hediye mi alsın yoksa sürekli iltifat mı etsin?',
    'Birlikte macera mı yaşamak yoksa birlikte huzur mu bulmak?',
    'Telefonunda partnerin tüm mesajlarını mı görsün yoksa hiçbirini mi?',
    '1 yıl uzakta mı yaşamak yoksa 1 yıl 24 saat birlikte mi olmak?',
    'Partnerin mükemmel yemek mi yapsın yoksa mükemmel dans mı etsin?',
    'Geçmişe mi gidip tanışmak yoksa geleceğe mi gidip birlikte yaşlanmak?',
    'Partnerin çok romantik mi olsun yoksa çok komik mi?',
    'Birlikte bir iş mi kurmak yoksa birlikte sanat mı yapmak?',
    'Her tartışma sonrası barışmak mı yoksa hiç tartışmamak mı?',
    'Partnerin zihin mi okusun yoksa geleceği mi görsün?',
    'Birlikte köpek mi sahiplenmek yoksa kedi mi?',
    'Evlenmeden 10 yıl mı birlikte yoksa hemen evlenmek mi?',
    'Partnerin her zaman haklı mı olsun yoksa her zaman mutlu mu?',
    'Birlikte korku filmi mi izlemek yoksa romantik komedi mi?',
    'Partnerin sana şarkı mı yazsın yoksa tablo mu çizsin?',
    'Doğum gününü sürpriz parti mi yoksa ikiye özel akşam yemeği mi?',
  ];

  static final List<String> knowMeQuestions = [
    'En sevdiğim renk nedir?',
    'En büyük korkum nedir?',
    'Çocukluğumda olmak istediğim meslek neydi?',
    'En sevdiğim yemek nedir?',
    'Hangi mevsimi en çok severim?',
    'En sevdiğim film/dizi nedir?',
    'Sabahları ilk ne yaparım?',
    'Stresli olduğumda ne yaparım?',
    'En yakın arkadaşımın adı ne?',
    'Hayalimdeki tatil yeri neresi?',
    'En sevdiğim müzik türü nedir?',
    'Hangi supergücü isterim?',
    'En sevdiğim hayvan nedir?',
    'Okul hayatımda en sevdiğim ders neydi?',
    'Mutlu olduğumda genelde ne yaparım?',
    'En nefret ettiğim ev işi nedir?',
    'Kaç yaşımda ilk sevgilim oldu?',
    'Beni en çok ne kızdırır?',
    'En çok hangi sosyal medyayı kullanırım?',
    'Hayatımda değiştirmek istediğim bir şey ne?',
    'Uykudan önce genelde ne yaparım?',
    'En sevdiğim tatlı nedir?',
    'Hangi ülkeyi en çok görmek isterim?',
    'Beni en çok güldüren şey nedir?',
    'Gizli yeteneğim nedir?',
  ];

  static final List<String> finishSentencePrompts = [
    'Seninle en mutlu olduğum an...',
    'Seni ilk gördüğümde...',
    'Birlikte yapmak istediğim en çılgın şey...',
    'Seninle 10 yıl sonra...',
    'Sana söyleyemediğim bir şey...',
    'Eğer dünyada sadece ikimiz kalsak...',
    'Senin için vazgeçebileceğim tek şey...',
    'Birlikte en son güldüğümüz an...',
    'Seni en çok kıskandığım an...',
    'Seninle yapacağım bir sonraki macera...',
    'İlişkimizde en çok değer verdiğim şey...',
    'Sana almak istediğim en güzel hediye...',
    'Birlikte yemek yapınca...',
    'Seninle uyumadan önce...',
    'Eğer sana bir şarkı adayacak olsam...',
    'Seni tanıdığım için...',
    'Birlikte yaşlandığımızda...',
    'Seninle tartışınca ben...',
    'Senden en çok öğrendiğim şey...',
    'Eğer bir gün kaybolursam beni...',
  ];

  static final List<String> emojiChallenges = [
    '🎬 En sevdiğiniz filmi emojilerle anlatın!',
    '🍽️ En son yediğiniz yemeği emojilerle tarif edin!',
    '🎵 Bir şarkıyı emojilerle anlatın!',
    '📖 Bir masalı emojilerle özetleyin!',
    '🏖️ Hayalinizdeki tatili emojilerle anlatın!',
    '💑 İlk buluşmanızı emojilerle anlatın!',
    '🎭 Bugün yaşadığınız bir anı emojilerle paylaşın!',
    '🌍 Gitmek istediğiniz ülkeyi emojilerle tarif edin!',
    '🎮 En sevdiğiniz oyunu emojilerle anlatın!',
    '📺 En sevdiğiniz diziyi emojilerle özetleyin!',
    '🐾 Bir hayvanı emojilerle anlatın, partner tahmin etsin!',
    '🏠 Hayalinizdeki evi emojilerle anlatın!',
    '👗 Bugün giyeceğiniz kıyafeti emojilerle tarif edin!',
    '🎁 Almak istediğiniz hediyeyi emojilerle anlatın!',
    '🚗 Yapmak istediğiniz yolculuğu emojilerle tarif edin!',
  ];

  static final List<List<String>> compatibilityQuestions = [
    [
      'Ideal hafta sonu ne yapmaktir?',
      'Evde film',
      'Disarida etkinlik',
      'Dogada yurumus',
      'Arkadaslarla bulusma'
    ],
    [
      'Tartismada ne yaparsın?',
      'Hemen konusurum',
      'Biraz beklerim',
      'Mesaj yazarim',
      'Susarim'
    ],
    [
      'Ask dili nedir?',
      'Fiziksel dokunma',
      'Iltifat',
      'Hediye',
      'Birlikte vakit'
    ],
    ['Sabah kisi misin gece kisi mi?', 'Sabah', 'Gece', 'Ikisi de', 'Hicbiri'],
    ['Iliski icin en onemli sey?', 'Guven', 'Iletisim', 'Tutku', 'Saygi'],
    ['Tatilde ne yaparsın?', 'Gez-gor', 'Dinlen', 'Macera', 'Yemek dene'],
    [
      'Stres aninda ne istersin?',
      'Sarilin',
      'Yalniz kalim',
      'Konusayim',
      'Birlikte birsey yapalim'
    ],
    [
      'Para harcama tarzın?',
      'Tutumluyum',
      'Dengeye bakarim',
      'Keyifime bakarim',
      'Yatirim yaparim'
    ],
    [
      'Gelecek planlarin?',
      'Evlenmek',
      'Kariyer',
      'Seyahat',
      'Hicbiri bilmiyorum'
    ],
    [
      'Iliski problemi cozumu?',
      'Konusurum',
      'Yazarim',
      'Zaman veririm',
      'Uzman yardimiyla'
    ],
  ];

  // ── Trip Meter Questions (boundary-testing) ──
  static final List<Map<String, dynamic>> tripMeterScenarios = [
    {'scenario': 'Telefonuna şifre koydum ama sana söylemiyorum.', 'level': 2},
    {
      'scenario': 'Eski sevgilimle konuşuyorum ama sadece arkadaşız.',
      'level': 4
    },
    {
      'scenario': 'Annem seni sevmiyor ama ben annemin tarafındayım.',
      'level': 5
    },
    {
      'scenario': 'Arkadaşlarımla tatile gidiyorum, sen gelemezsin.',
      'level': 3
    },
    {'scenario': 'Doğum gününü unuttum ama özür dilemeyeceğim.', 'level': 4},
    {
      'scenario': 'Mesajlarıma 3 saat geç cevap verdim, sebebi yok.',
      'level': 2
    },
    {
      'scenario': 'Bir karşı cins arkadaşımla kahve içtim, söylemedim.',
      'level': 5
    },
    {
      'scenario': 'Planlarımızı son dakika iptal ettim, arkadaşlarım aradı.',
      'level': 3
    },
    {
      'scenario':
          'Sosyal medyada birinin fotoğrafını beğendim, seni kıskandırdım.',
      'level': 3
    },
    {'scenario': 'Seninle konuşmak yerine oyun oynuyorum.', 'level': 2},
    {
      'scenario': 'Sana kızdım ama nedenini söylemiyorum, kendin anla.',
      'level': 4
    },
    {'scenario': 'Ailem bize karışıyor ama ben izin veriyorum.', 'level': 4},
    {'scenario': 'Senin kıyafet seçimine karışıyorum sürekli.', 'level': 3},
    {'scenario': 'Bir karar aldım ama sana sormadım.', 'level': 3},
    {'scenario': 'Sana trip atıyorum ama konuşmuyorum 2 gündür.', 'level': 5},
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
