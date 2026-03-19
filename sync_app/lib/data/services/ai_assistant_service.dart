import 'dart:math';

import '../../core/services/locale_service.dart';

enum AiAssistantType {
  relationshipCoach,
  astrologyAssistant,
}

extension AiAssistantTypeX on AiAssistantType {
  String get title => switch (this) {
        AiAssistantType.relationshipCoach =>
          l.tr('Relationship Coach', 'Iliski Kocu'),
        AiAssistantType.astrologyAssistant =>
          l.tr('Astrology Assistant', 'Burc Asistani'),
      };

  String get emoji => switch (this) {
        AiAssistantType.relationshipCoach => '💕',
        AiAssistantType.astrologyAssistant => '🔮',
      };

  String get description => switch (this) {
        AiAssistantType.relationshipCoach => l.tr(
            'Tips to strengthen your relationship, communication techniques and couples therapy approaches.',
            'Iliskinizi guclendirmek icin tavsiyeler, iletisim teknikleri ve cift terapisi yaklasimlari.'),
        AiAssistantType.astrologyAssistant => l.tr(
            'Zodiac compatibility, daily horoscopes, planetary transits and astrological relationships.',
            'Burc uyumu, gunluk yorumlar, gezegen gecisleri ve astrolojik iliskiler.'),
      };

  String get systemPrompt => switch (this) {
        AiAssistantType.relationshipCoach => l.tr(
            'You are an experienced relationship coach. You only talk about relationships, communication, emotional intelligence, couples therapy and romantic relationships. On other topics you politely redirect the conversation to relationships.',
            'Sen deneyimli bir iliski kocusun. Sadece iliski, iletisim, duygusal zeka, cift terapisi ve romantik iliskiler hakkinda konusursun. Diger konularda kibarca konuyu iliskiye yonlendirirsin.'),
        AiAssistantType.astrologyAssistant => l.tr(
            'You are an expert astrology consultant. You only talk about zodiac signs, planetary transits, zodiac compatibility, natal charts, daily/weekly/monthly horoscopes. On other topics you politely redirect the conversation to astrology.',
            'Sen uzman bir astroloji danismanisin. Sadece burclar, gezegen gecisleri, burc uyumu, natal harita, gunluk/haftalik/aylik burc yorumlari hakkinda konusursun. Diger konularda kibarca konuyu astrolojiye yonlendirirsin.'),
      };

  List<String> get capabilities => switch (this) {
        AiAssistantType.relationshipCoach => [
            l.tr('Communication strategies', 'Iletisim stratejileri'),
            l.tr('Trust building', 'Guven insasi'),
            l.tr('Conflict resolution', 'Catisma cozumu'),
            l.tr('Romance advice', 'Romantizm tavsiyeleri'),
            l.tr('Emotional intelligence', 'Duygusal zeka'),
            l.tr('Couples therapy techniques', 'Cift terapisi teknikleri'),
            l.tr('Love languages analysis', 'Ask dilleri analizi'),
            l.tr('Setting boundaries', 'Sinir belirleme'),
            l.tr('Attachment styles', 'Baglanma stilleri'),
          ],
        AiAssistantType.astrologyAssistant => [
            l.tr('Zodiac analysis (12 signs)', 'Burc analizi (12 burc)'),
            l.tr('Zodiac compatibility', 'Burc uyumu'),
            l.tr('Planetary transits', 'Gezegen gecisleri'),
            l.tr('Birth chart', 'Dogum haritasi'),
            l.tr('Daily/weekly horoscopes', 'Gunluk/haftalik yorumlar'),
            l.tr('Element analysis', 'Element analizi'),
            l.tr('Love astrology', 'Ask astrolojisi'),
            l.tr('Retrograde effects', 'Retrograd etkileri'),
            l.tr('Moon phases', 'Ay evreleri'),
          ],
      };
}

class AiChatMessage {
  const AiChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String text;
  final bool isUser;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AiChatMessage.fromJson(Map<String, dynamic> json) => AiChatMessage(
        text: json['text'] as String,
        isUser: json['isUser'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

/// Local AI response engine — generates contextual responses
/// based on keyword matching and rich response banks.
class LocalAiEngine {
  static final _rng = Random();

  static String generateResponse(AiAssistantType type, String userMessage) {
    final msg = userMessage.toLowerCase();

    if (type == AiAssistantType.relationshipCoach) {
      return _relationshipResponse(msg);
    }
    return _astrologyResponse(msg);
  }

  // ══════════════════════════════════════
  //  RELATIONSHIP COACH RESPONSES
  // ══════════════════════════════════════
  static String _relationshipResponse(String msg) {
    // Off-topic detection
    if (_isOffTopicForRelationship(msg)) {
      return _pick(_offTopicRelationship);
    }

    // Greeting
    if (_matchesAny(msg, [
      'merhaba',
      'selam',
      'hey',
      'naber',
      'nasil',
      'hello',
      'hi',
      'how are you',
    ])) {
      return _pick(_greetingsRelationship);
    }

    // Communication issues
    if (_matchesAny(msg, [
      'iletisim',
      'konusmak',
      'konusamiyoruz',
      'anlasam',
      'dinle',
      'tartis',
      'kavga',
      'communication',
      'talk',
      'listen',
      'argue',
      'fight',
      'quarrel',
    ])) {
      return _pick(_communicationAdvice);
    }

    // Trust / jealousy
    if (_matchesAny(msg, [
      'guven',
      'kiskanc',
      'aldatma',
      'sadakat',
      'ihanet',
      'yalan',
      'trust',
      'jealous',
      'cheat',
      'loyalty',
      'betrayal',
      'lie',
    ])) {
      return _pick(_trustAdvice);
    }

    // Love / romance
    if (_matchesAny(msg, [
      'ask',
      'sev',
      'romantik',
      'romantizm',
      'tutku',
      'ozlem',
      'ozle',
      'love',
      'romantic',
      'romance',
      'passion',
      'miss',
      'longing',
    ])) {
      return _pick(_loveAdvice);
    }

    // Distance / breakup
    if (_matchesAny(msg, [
      'uzak',
      'ayrilik',
      'bitir',
      'bosanma',
      'soguma',
      'mesafe',
      'ayril',
      'distance',
      'breakup',
      'divorce',
      'separate',
      'apart',
      'cold',
    ])) {
      return _pick(_distanceAdvice);
    }

    // Family / in-laws
    if (_matchesAny(msg, [
      'aile',
      'kayin',
      'anne',
      'baba',
      'evlilik',
      'evlen',
      'nikah',
      'family',
      'in-law',
      'mother',
      'father',
      'marriage',
      'wedding',
    ])) {
      return _pick(_familyAdvice);
    }

    // Sex / intimacy
    if (_matchesAny(msg, [
      'yakinlik',
      'dokunma',
      'fiziksel',
      'cinsel',
      'mahremiyet',
      'intimacy',
      'touch',
      'physical',
      'sexual',
      'privacy',
    ])) {
      return _pick(_intimacyAdvice);
    }

    // Conflict resolution
    if (_matchesAny(msg, [
      'cozum',
      'baris',
      'ozur',
      'affet',
      'uzlas',
      'anlas',
      'solution',
      'peace',
      'apologize',
      'forgive',
      'reconcile',
      'understand',
    ])) {
      return _pick(_conflictResolution);
    }

    // General fallback
    return _pick(_generalRelationship);
  }

  static bool _isOffTopicForRelationship(String msg) {
    return _matchesAny(msg, [
      'hava durumu',
      'weather',
      'futbol',
      'football',
      'soccer',
      'mac',
      'match',
      'programlama',
      'programming',
      'coding',
      'kod',
      'code',
      'yemek tarif',
      'recipe',
      'siyaset',
      'politics',
      'ekonomi',
      'economy',
      'borsa',
      'stock market',
      'kripto',
      'crypto',
      'bitcoin',
      'spor',
      'sports',
    ]);
  }

  static final _offTopicRelationship = [
    l.tr(
        'I\'m a relationship coach 💕 I can\'t help with this topic, but would you like to ask a question about your relationship?',
        'Ben bir iliski kocuyum 💕 Bu konuda yardimci olamam ama iliskinizle ilgili bir soru sormak ister misiniz?'),
    l.tr(
        'My area of expertise is relationships! I don\'t know about this topic, but how can I help you with your relationship?',
        'Uzmanlik alanim iliskiler! Bu konuyu bilmiyorum ama size iliskinizde nasil yardimci olabilirim?'),
    l.tr(
        'Hmm, this is not my area. But if something in your relationship is bothering you, I\'m ready to listen 💕',
        'Hmm, bu benim alanim degil. Ama iliskinizde bir sey sizi rahatsiz ediyorsa dinlemeye hazirim 💕'),
  ];

  static final _greetingsRelationship = [
    l.tr(
        'Hello! 💕 I\'m here to strengthen your relationship. How can I help you?',
        'Merhaba! 💕 Iliskinizi guclendirmek icin buradayim. Size nasil yardimci olabilirim?'),
    l.tr(
        'Welcome! I\'m your relationship coach. You can ask me anything about your relationship 💕',
        'Hosgeldiniz! Ben iliski kocunuzum. Iliskinizle ilgili aklinizdaki her seyi sorabilirsiz 💕'),
    l.tr(
        'Hi! What\'s going on in your relationship today? Let\'s talk about it 🌸',
        'Selam! Bugün iliskinizde neler oluyor? Birlikte konusalim 🌸'),
  ];

  static final _communicationAdvice = [
    l.tr(
        '💬 The most important rule in communication: speak with "I" language. Instead of "You always..." say "I feel...".\n\nFor example: Instead of "You don\'t listen to me" say "I feel unheard, and it upsets me."',
        '💬 Iletisimde en onemli kural: "Ben" diliyle konusmak. "Sen hep..." yerine "Ben ... hissediyorum" deyin.\n\nOrnegin: "Sen beni dinlemiyorsun" yerine "Dinlenmadigimi hissediyorum, bu beni uzuyor."'),
    l.tr(
        '🎯 Try active listening techniques:\n1. Make eye contact\n2. Repeat what your partner said in your own words\n3. Say "I understand you"\n4. Acknowledge the emotion before offering solutions',
        '🎯 Aktif dinleme teknigi deneyin:\n1. Goz temasi kurun\n2. Partnerin soylediklerini kendi kelimelerinizle tekrar edin\n3. "Seni anliyorum" deyin\n4. Cozum sunmadan once duyguyu kabul edin'),
    l.tr(
        '⏰ Try the "20 minute rule": If tensions rise during an argument, take a 20-minute break. This time is enough for your brain to calm down.\n\nAfter the break, you can talk more constructively.',
        '⏰ "20 dakika kurali"ni deneyin: Tartismada tansiyonlar yukseldiyse 20 dk mola verin. Bu sure beyninizin sakinlesmesi icin yeterli.\n\nMoladan sonra daha yapiclbir sekilde konusabilirsiniz.'),
    l.tr(
        '🧊 Stonewalling is one of the most dangerous relationship patterns. If your partner shuts down:\n- Don\'t pressure them\n- Say "I want to talk when you\'re ready"\n- Create a safe environment',
        '🧊 Soguk iletisim ("stone-walling") en tehlikeli iliski kaliplarindandir. Partneriniz kapatiyorsa:\n- Baski yapmayin\n- "Hazir olduğunda konusmak istiyorum" deyin\n- Guvenli ortam yaratin'),
    l.tr(
        '📝 Have a weekly "check-in" meeting. For 15 minutes:\n- What made you happy this week?\n- What upset you this week?\n- What do you want next week?\n\nThis simple practice improves communication by 40%.',
        '📝 Haftada bir "check-in" toplantisi yapin. 15 dk boyunca:\n- Bu hafta seni mutlu eden ne?\n- Bu hafta seni uzen ne?\n- Gelecek hafta ne istersin?\n\nBu basit pratik iletisimi %40 iyilestirir.'),
  ];

  static final _trustAdvice = [
    l.tr(
        '🔒 Trust can be rebuilt but it takes time. Steps:\n1. Full transparency (zero hidden information)\n2. Consistent behavior\n3. Patience — trust comes drop by drop\n4. Get professional support',
        '🔒 Guven yeniden insa edilebilir ama zaman ister. Adimlar:\n1. Tam seffaflik (sifir sakli bilgi)\n2. Tutarli davranislar\n3. Sabir — guven damla damla gelir\n4. Profesyonel destek alin'),
    l.tr(
        '💚 Jealousy is natural but excessive jealousy comes from the desire to control. Ask yourself:\n- Is there a real threat?\n- Are my past experiences influencing me?\n- If I trust my partner, why am I afraid?',
        '💚 Kiskanclik dogal ama asiri kiskanclik kontrol arzusundan gelir. Kendinize sorun:\n- Gercekten bir tehdit var mi?\n- Gecmis deneyimlerim beni etkiliyor mu?\n- Partnerime guveniyorsam neden korkuyorum?'),
    l.tr(
        '🛡️ If you are experiencing a trust crisis:\n- Don\'t suppress your feelings, express them\n- State your needs instead of blaming\n- Set boundaries together\n- Consider couples therapy if needed',
        '🛡️ Guven krizi yasiyorsaniz:\n- Duygularinizi bastirmayin, ifade edin\n- Suclama yerine ihtiyacinizi soyeyin\n- Birlikte sinirlar belirleyin\n- Gerekirse cift terapisi dusunun'),
  ];

  static final _loveAdvice = [
    l.tr(
        '❤️ Have you discovered the love languages? 5 love languages:\n1. Words of affirmation\n2. Quality time\n3. Receiving gifts\n4. Acts of service\n5. Physical touch\n\nKnowing your partner\'s love language changes everything!',
        '❤️ Ask dillerini kesfetdiniz mi? 5 ask dili:\n1. Onaylayici sozler\n2. Kaliteli zaman\n3. Hediye alma\n4. Hizmet etme\n5. Fiziksel temas\n\nPartnerinizin ask dilini bilmek her seyi degistirir!'),
    l.tr(
        '🌹 "Micro-romance" to keep romance alive:\n- Send an unexpected message\n- Try a new cafe together\n- Watch the sunset together\n- Find different ways to say "I love you"',
        '🌹 Romantizmi canli tutmak icin "mikro-romantizm":\n- Beklenmedik bir mesaj gonder\n- Yeni bir cafe dene birlikte\n- Beraber sunset izle\n- "Seni seviyorum" un farkli yollarini bul'),
    l.tr(
        '🔥 Passion doesn\'t decrease over time, it just changes form. To nurture passion:\n- Experience new things together\n- Surprise each other\n- Protect your individual spaces\n- Keep the sense of curiosity alive',
        '🔥 Tutku zamanla azalmaz, sadece form degistirir. Tutkuyu beslemek icin:\n- Birlikte yeni deneyimler yasamak\n- Birbirinizi sasirtmak\n- Bireysel alanlarinizi korumak\n- Merak duygusunu canli tutmak'),
  ];

  static final _distanceAdvice = [
    l.tr(
        '🌉 Distance is not always a sign of ending. Sometimes the need for personal space is healthy.\n\nBut for prolonged cooling off:\n- Speak directly and gently\n- Give the message "I want this relationship"\n- Suggest concrete steps for change',
        '🌉 Mesafe her zaman bitisin isareti degildir. Bazen kisisel alan ihtiyaci sagliklidir.\n\nAma uzun sureli soguma icin:\n- Dogrudan ve yumusak konusun\n- "Bu iliskiyi istiyorum" mesaji verin\n- Degisim icin somut adimlar onerun'),
    l.tr(
        '💔 If you\'re thinking about breaking up, ask yourself:\n- Is this a temporary crisis or a chronic problem?\n- How much effort has been made to find a solution together?\n- Has professional help been sought?\n\nDon\'t rush, but don\'t neglect yourself either.',
        '💔 Ayrilik dusuncesi varsa kendinize sorun:\n- Bu geçici bir kriz mi yoksa kronik bir sorun mu?\n- Birlikte cozüm icin ne kadar caba gosterildi?\n- Profesyonel yardim alindi mi?\n\nAcele etmeyin, ama kendinizi de ihmal etmeyin.'),
    l.tr(
        '🔄 Try a "fresh start ritual" during cooling periods:\n- Plan like your first date\n- Write letters to each other\n- Set shared goals\n- Create a gratitude list',
        '🔄 Soguma donemlerinde "yeniden baslangic ritüeli" deneyin:\n- Ilk bulusmadaki gibi plan yapin\n- Birbirinize mektup yazin\n- Ortak hedefler belirleyin\n- Minnet listesi olusturun'),
  ];

  static final _familyAdvice = [
    l.tr(
        '👨‍👩‍👧 Set family boundaries together. You need to be clear as a "we" team with your families.\n\nSaying "We decided together" instead of "My mom wants it that way" strengthens the relationship.',
        '👨‍👩‍👧 Aile sinirlarini birlikte belirleyin. "Biz" takim olarak ailelere karsi net olmalisiniz.\n\n"Annem oyle istiyor" yerine "Biz birlikte karar verdik" demek iliskiyi guclendirir.'),
    l.tr(
        '💒 Things to discuss before the marriage decision:\n- Money management\n- Desire for children and timing\n- Lifestyle expectations\n- Family boundaries\n- Career priorities',
        '💒 Evlilik kararindan once konusulmasi gerekenler:\n- Para yonetimi\n- Cocuk istegi ve zamanlama\n- Yasam tarzı beklentileri\n- Aile sinirlari\n- Kariyer oncelikleri'),
    l.tr(
        '🏠 For in-law problems:\n- Your partner should talk to their own family\n- Don\'t take the "bad guy" role\n- Set boundaries together\n- Maintain respect but don\'t compromise',
        '🏠 Kaynana/kayinpeder sorunlari icin:\n- Partneriniz kendi ailesiyle konusmali\n- Siz "kotu cop" rolune girmeyin\n- Sinirlari birlikte koyun\n- Saygiyi koruyun ama taviz vermeyin'),
  ];

  static final _intimacyAdvice = [
    l.tr(
        '🤝 Emotional intimacy is the foundation of physical intimacy. First create a safe emotional space.\n\nEven 10 minutes of daily phone-free, eye-to-eye conversation makes a big difference.',
        '🤝 Duygusal yakinlik fiziksel yakinligin temelidir. Once guvenli bir duygusal alan olusturun.\n\nGunluk 10 dk goz goze, telefonsuz sohbet bile buyuk fark yaratir.'),
    l.tr(
        '💫 The most important thing in physical intimacy: communication. Clearly stating what you want and don\'t want puts both you and your partner at ease.',
        '💫 Fiziksel yakinlikta en onemli sey: iletisim. Ne istediginizi ve ne istemediginizi acikca soylemek hem sizi hem partnerinizi rahatlatir.'),
    l.tr(
        '🌸 Intimacy issues are very common and nothing to be ashamed of. For solutions:\n- Open communication\n- Patience and understanding\n- Professional support if needed',
        '🌸 Yakinlik sorunlari cok yaygindir ve utanilacak bir sey degildir. Cozum icin:\n- Acik iletisim\n- Sabir ve anlayis\n- Gerekirse profesyonel destek'),
  ];

  static final _conflictResolution = [
    l.tr(
        '🕊️ Gottman Method: Successful couples resolve conflicts like this:\n1. Soft startup (without blame)\n2. Repair attempt ("Let\'s take a break")\n3. Compromise (both give a little)\n4. Acceptance (not everything has to be resolved)',
        '🕊️ Gottman Yontemi: Basarili ciftler catismalari soyle cozer:\n1. Yumusak baslangic (suclama olmadan)\n2. Onarim girisimi ("Mola alalim")\n3. Uzlasma (ikisi de biraz taviz)\n4. Kabul (her sey cozulmek zorunda degil)'),
    l.tr(
        '✅ To apologize:\n1. Acknowledge what you did\n2. Validate your partner\'s feelings\n3. Say what you will do in the future\n4. Don\'t use sentences starting with "But..."\n\n"You were right, I was wrong" is one of the most powerful sentences.',
        '✅ Ozur dilemek icin:\n1. Ne yaptiginizi kabul edin\n2. Partnerinizin duygusunu onaylayin\n3. Gelecekte ne yapacaginizi soyeyin\n4. "Ama..." ile baslayan cumle kullanmayin\n\n"Hakliydin, ben yanlistim" en guclu cumlelrdenbiridir.'),
    l.tr(
        '🔄 Recurring fights usually stem from unresolved "core needs". Find the emotion beneath the fight:\n- Insecurity?\n- Feeling unvalued?\n- Fear of abandonment?\n\nOnce you find the real issue, the solution gets closer.',
        '🔄 Tekrarlanan kavgalar genellikle cozulmemis "temel ihtiyac"lardan kaynaklanir. Kavganin altindaki duyguyu bulun:\n- Guvensizlik mi?\n- Deger gorememe mi?\n- Terk edilme korkusu mu?\n\nGercek konuyu bulunca cozum yaklasir.'),
  ];

  static final _generalRelationship = [
    l.tr(
        '💕 The 3 foundations of a healthy relationship:\n1. Trust — transparency and consistency\n2. Communication — open, honest, gentle\n3. Respect — for boundaries and differences\n\nStrengthen these 3, and the relationship strengthens.',
        '💕 Saglikli bir iliskinin 3 temeli:\n1. Guven — seffaflik ve tutarlilik\n2. Iletisim — acik, durust, yumusak\n3. Saygi — sinirlara ve farkliliklara\n\nBu 3\'unu guclendirin, iliski guclenir.'),
    l.tr(
        '🌟 A special suggestion for you: This week, tell your partner 3 things:\n1. Something you appreciate about them\n2. How important they are to you\n3. Something you dream of doing together',
        '🌟 Size ozel bir oneri: Bu hafta partnerinize 3 sey soyeyin:\n1. Onu takdir ettiginiz bir sey\n2. Sizin icin ne kadar onemli oldugu\n3. Birlikte yapmayi hayal ettiginiz bir sey'),
    l.tr(
        '📊 Research shows: 69% of happy couples live with unsolvable problems. What matters is not solving everything, but learning to live together.',
        '📊 Arastirmalar gosteriyor: Mutlu ciftlerin %69\'u cozumsuz sorunlarla yasayor. Onemli olan her seyi cozmek degil, birlikte yasamayi ogrenmek.'),
    l.tr(
        '💡 Would you like to ask about a specific topic regarding your relationship? I can give detailed advice on topics like communication, trust, romance, conflict resolution.',
        '💡 Iliskinizle ilgili spesifik bir konu hakkida soru sormak ister misiniz? Iletisim, guven, romantizm, catisma cozumu gibi konularda detayli tavsiyelr verebilirim.'),
  ];

  // ══════════════════════════════════════
  //  ASTROLOGY RESPONSES
  // ══════════════════════════════════════
  static String _astrologyResponse(String msg) {
    if (_isOffTopicForAstrology(msg)) {
      return _pick(_offTopicAstrology);
    }

    if (_matchesAny(msg, [
      'merhaba',
      'selam',
      'hey',
      'naber',
      'hello',
      'hi',
    ])) {
      return _pick(_greetingsAstrology);
    }

    // Specific zodiac signs
    if (_matchesAny(msg, ['koc', 'aries'])) return _pick(_ariesInfo);
    if (_matchesAny(msg, ['boga', 'taurus'])) return _pick(_taurusInfo);
    if (_matchesAny(msg, ['ikizler', 'gemini'])) return _pick(_geminiInfo);
    if (_matchesAny(msg, ['yengec', 'cancer'])) return _pick(_cancerInfo);
    if (_matchesAny(msg, ['aslan', 'leo'])) return _pick(_leoInfo);
    if (_matchesAny(msg, ['basak', 'virgo'])) return _pick(_virgoInfo);
    if (_matchesAny(msg, ['terazi', 'libra'])) return _pick(_libraInfo);
    if (_matchesAny(msg, ['akrep', 'scorpio'])) return _pick(_scorpioInfo);
    if (_matchesAny(msg, ['yay', 'sagittarius']))
      return _pick(_sagittariusInfo);
    if (_matchesAny(msg, ['oglak', 'capricorn'])) return _pick(_capricornInfo);
    if (_matchesAny(msg, ['kova', 'aquarius'])) return _pick(_aquariusInfo);
    if (_matchesAny(msg, ['balik', 'pisces'])) return _pick(_piscesInfo);

    // Compatibility
    if (_matchesAny(msg, [
      'uyum',
      'uyumlu',
      'eslesiyor',
      'partnerm',
      'compatibility',
      'compatible',
      'partner',
    ])) {
      return _pick(_compatibilityAstro);
    }

    // Planets / transits
    if (_matchesAny(msg, [
      'gezegen',
      'transit',
      'retrograd',
      'merkur',
      'venus',
      'mars',
      'jupiter',
      'saturn',
      'planet',
      'mercury',
      'retrograde',
    ])) {
      return _pick(_planetInfo);
    }

    // Daily/weekly
    if (_matchesAny(msg, [
      'bugun',
      'gunluk',
      'haftalik',
      'aylik',
      'yorum',
      'today',
      'daily',
      'weekly',
      'monthly',
      'horoscope',
    ])) {
      return _pick(_dailyAstro);
    }

    // Natal chart
    if (_matchesAny(msg, [
      'natal',
      'dogum',
      'harita',
      'yukseleni',
      'ay burcu',
      'birth',
      'chart',
      'ascendant',
      'rising',
      'moon sign',
    ])) {
      return _pick(_natalChart);
    }

    // Elements
    if (_matchesAny(msg, [
      'ates',
      'toprak',
      'hava',
      'su',
      'element',
      'fire',
      'earth',
      'air',
      'water',
    ])) {
      return _pick(_elementInfo);
    }

    return _pick(_generalAstrology);
  }

  static bool _isOffTopicForAstrology(String msg) {
    return _matchesAny(msg, [
      'futbol',
      'football',
      'soccer',
      'mac',
      'match',
      'programlama',
      'programming',
      'coding',
      'kod',
      'code',
      'yemek tarif',
      'recipe',
      'siyaset',
      'politics',
      'ekonomi',
      'economy',
      'borsa',
      'stock market',
      'kripto',
      'crypto',
      'bitcoin',
    ]);
  }

  static final _offTopicAstrology = [
    l.tr(
        'I\'m an astrology assistant 🔮 I don\'t have knowledge on this topic, but would you like to ask something about your zodiac sign?',
        'Ben bir astroloji asistaniyim 🔮 Bu konuda bilgim yok ama burcunuzla ilgili bir sey sormak ister misiniz?'),
    l.tr(
        'My expertise is stars and planets! I don\'t know about this topic but I can do your horoscope reading 🌙',
        'Uzmanlik alanim yildizlar ve gezegenler! Bu konuyu bilmiyorum ama burc yorumunuzu yapabilirim 🌙'),
    l.tr('Hmm, my area is astrology. Shall we talk about your zodiac sign? ✨',
        'Hmm, benim alanim astroloji. Burcunuz hakkinda mi konusalim? ✨'),
  ];

  static final _greetingsAstrology = [
    l.tr(
        'Hello! 🔮 The stars are shining for you! What\'s your zodiac sign, let\'s find out together?',
        'Merhaba! 🔮 Yildizlar isiginizda! Burcunuz ne, birlikte bakalim?'),
    l.tr(
        'Welcome! ✨ Welcome to the world of astrology. Which zodiac sign would you like to talk about?',
        'Hosgeldiniz! ✨ Astroloji dunyasina hosgeldiniz. Hangi burc hakkinda konusmak istersiniz?'),
    l.tr(
        'Hi! 🌙 Are you curious about what the planets are saying for you today?',
        'Selam! 🌙 Bugun gezegenler sizin icin ne soyluyor merak ediyor musunuz?'),
  ];

  static final _ariesInfo = [
    l.tr(
        '♈ ARIES (March 21 - April 19)\n\nElement: Fire 🔥\nPlanet: Mars\nTraits: Brave, energetic, leadership spirit, impatient\n\nLove life: Passionate and excitement-seeking Aries can\'t stand boring relationships. Bold moves and surprises attract them.\n\nCompatible signs: Leo, Sagittarius, Gemini',
        '♈ KOC BURCU (21 Mart - 19 Nisan)\n\nElement: Ates 🔥\nGezegen: Mars\nOzellikler: Cesur, enerjik, lider ruhlu, sabirsiz\n\nAsk hayati: Tutkulu ve heyecan arayan Koc, sikilgan iliskilere dayanamaz. Cesur hareketler ve surprizler onlari cezbeder.\n\nUyumlu burclar: Aslan, Yay, Ikizler'),
    l.tr(
        '♈ Aries is full of Mars energy this period! A time open to new beginnings. It\'s the perfect time to take initiative in your relationship.\n\nWarning: Your impatience may overwhelm your partner. The "stop and listen" mantra works.',
        '♈ Koc burcu bu donemde Mars enerjisiyle dolu! Yeni baslangiclara acik bir donem. Iliskinizde inisiyatif almanin tam zamani.\n\nDikkat: Sabirsizliginiz partnerinizi bunaltabilir. "Dur ve dinle" mantrasi isine yarar.'),
  ];

  static final _taurusInfo = [
    l.tr(
        '♉ TAURUS (April 20 - May 20)\n\nElement: Earth 🌍\nPlanet: Venus\nTraits: Loyal, determined, sensual, stubborn\n\nLove life: Taurus seeks security. Builds slow but deep bonds. Once attached? Forever!\n\nCompatible signs: Virgo, Capricorn, Cancer',
        '♉ BOGA BURCU (20 Nisan - 20 Mayis)\n\nElement: Toprak 🌍\nGezegen: Venus\nOzellikler: Sadik, kararlı, duyusal, inatci\n\nAsk hayati: Boga guvenlik arar. Yavaş ama derin baglar kurar. Bir kere baglandigi mi? Sonsuza kadar!\n\nUyumlu burclar: Basak, Oglak, Yengec'),
    l.tr(
        '♉ Taurus is the master of romance under Venus! This period, material and emotional security take priority.\n\nRelationship advice: Make physical gestures to your partner — holding hands, hugging are very valuable for Taurus.',
        '♉ Boga burcu Venus yonetiminde romantizmin efendisidir! Bu donem maddi ve duygusal guvenlik on planda.\n\nIliski tavsiysesi: Partnerinize fiziksel jestler yapin — el tutma, sarilma Bogalar icin cok degerli.'),
  ];

  static final _geminiInfo = [
    l.tr(
        '♊ GEMINI (May 21 - June 20)\n\nElement: Air 💨\nPlanet: Mercury\nTraits: Curious, social, versatile, indecisive\n\nLove life: Gemini seeks mental stimulation. Someone they can converse with is the biggest attraction.\n\nCompatible signs: Libra, Aquarius, Aries',
        '♊ IKIZLER BURCU (21 Mayis - 20 Haziran)\n\nElement: Hava 💨\nGezegen: Merkur\nOzellikler: Merakli, sosyal, cok yonlu, kararsiz\n\nAsk hayati: Ikizler zihinsel uyarilma arar. Sohbet edebildigi biri en buyuk cekim noktasidir.\n\nUyumlu burclar: Terazi, Kova, Koc'),
  ];

  static final _cancerInfo = [
    l.tr(
        '♋ CANCER (June 21 - July 22)\n\nElement: Water 💧\nPlanet: Moon\nTraits: Emotional, protective, intuitive, sensitive\n\nLove life: Cancer forms deep emotional bonds. Values home and family greatly. The feeling of security matters above all.\n\nCompatible signs: Pisces, Scorpio, Taurus',
        '♋ YENGEC BURCU (21 Haziran - 22 Temmuz)\n\nElement: Su 💧\nGezegen: Ay\nOzellikler: Duygusal, koruyucu, sezgisel, hassas\n\nAsk hayati: Yengec derin duygusal bag kurar. Evi ve aileyi cok onemsir. Guvenlik hissi her seyden onemli.\n\nUyumlu burclar: Balik, Akrep, Boga'),
  ];

  static final _leoInfo = [
    l.tr(
        '♌ LEO (July 23 - August 22)\n\nElement: Fire 🔥\nPlanet: Sun\nTraits: Charismatic, generous, dramatic, proud\n\nLove life: Leo wants royal treatment in relationships! Appreciation and admiration are their love language.\n\nCompatible signs: Aries, Sagittarius, Libra',
        '♌ ASLAN BURCU (23 Temmuz - 22 Agustos)\n\nElement: Ates 🔥\nGezegen: Gunes\nOzellikler: Karizmatik, comert, dramatik, gurur sahibi\n\nAsk hayati: Aslan iliskide kraliyet muamelesi ister! Takdir ve hayranlik onun ask dilidir.\n\nUyumlu burclar: Koc, Yay, Terazi'),
  ];

  static final _virgoInfo = [
    l.tr(
        '♍ VIRGO (August 23 - September 22)\n\nElement: Earth 🌍\nPlanet: Mercury\nTraits: Analytical, practical, meticulous, critical\n\nLove life: Virgo shows love through service. Says "I did this for you" instead of "I thought of you."\n\nCompatible signs: Taurus, Capricorn, Cancer',
        '♍ BASAK BURCU (23 Agustos - 22 Eylul)\n\nElement: Toprak 🌍\nGezegen: Merkur\nOzellikler: Analitik, pratik, titiz, elestirel\n\nAsk hayati: Basak sevgisini hizmetle gosterir. "Seni dusundum" yerine "Senin icin su yaptim" der.\n\nUyumlu burclar: Boga, Oglak, Yengec'),
  ];

  static final _libraInfo = [
    l.tr(
        '♎ LIBRA (September 23 - October 22)\n\nElement: Air 💨\nPlanet: Venus\nTraits: Balanced, diplomatic, aesthetic, indecisive\n\nLove life: Libra seeks harmony and beauty. Feels incomplete without a relationship. The sign of romance!\n\nCompatible signs: Gemini, Aquarius, Leo',
        '♎ TERAZI BURCU (23 Eylul - 22 Ekim)\n\nElement: Hava 💨\nGezegen: Venus\nOzellikler: Dengeli, diplomatik, estetik, kararsiz\n\nAsk hayati: Terazi uyum ve guzellik arar. Iliski olmadan eksik hisseder. Romantizmin burcu!\n\nUyumlu burclar: Ikizler, Kova, Aslan'),
  ];

  static final _scorpioInfo = [
    l.tr(
        '♏ SCORPIO (October 23 - November 21)\n\nElement: Water 💧\nPlanet: Pluto & Mars\nTraits: Intense, passionate, mysterious, intuitive\n\nLove life: Scorpio is an "all or nothing" lover. Wants deep, transformative relationships. Won\'t accept a half heart!\n\nCompatible signs: Cancer, Pisces, Taurus',
        '♏ AKREP BURCU (23 Ekim - 21 Kasim)\n\nElement: Su 💧\nGezegen: Pluto & Mars\nOzellikler: Yogun, tutkulu, gizemli, sezgisel\n\nAsk hayati: Akrep "ya hep ya hic" asigidir. Derin, donusturucu iliskiler ister. Yarim kalp kabul etmez!\n\nUyumlu burclar: Yengec, Balik, Boga'),
  ];

  static final _sagittariusInfo = [
    l.tr(
        '♐ SAGITTARIUS (November 22 - December 21)\n\nElement: Fire 🔥\nPlanet: Jupiter\nTraits: Adventurous, optimistic, free-spirited, blunt\n\nLove life: Sagittarius runs from relationships that restrict freedom. Wants a partner to share adventures with.\n\nCompatible signs: Aries, Leo, Libra',
        '♐ YAY BURCU (22 Kasim - 21 Aralik)\n\nElement: Ates 🔥\nGezegen: Jupiter\nOzellikler: Maceraci, iyimser, ozgur ruhlu, patavatsiz\n\nAsk hayati: Yay ozgurluğunu kisitlayan iliskilerden kacar. Birlikte macera yasayabilecegi bir partner ister.\n\nUyumlu burclar: Koc, Aslan, Terazi'),
  ];

  static final _capricornInfo = [
    l.tr(
        '♑ CAPRICORN (December 22 - January 19)\n\nElement: Earth 🌍\nPlanet: Saturn\nTraits: Disciplined, ambitious, responsible, reserved\n\nLove life: Capricorn treats relationships like investments. Progresses with slow but solid steps. Loyalty is unquestionable.\n\nCompatible signs: Taurus, Virgo, Pisces',
        '♑ OGLAK BURCU (22 Aralik - 19 Ocak)\n\nElement: Toprak 🌍\nGezegen: Saturn\nOzellikler: Disiplinli, hırsli, sorumluluk sahibi, mesafeli\n\nAsk hayati: Oglak iliskiye yatirim gibi bakar. Yavas ama saglam adimlarla ilerler. Sadakati tartismasiz.\n\nUyumlu burclar: Boga, Basak, Balik'),
  ];

  static final _aquariusInfo = [
    l.tr(
        '♒ AQUARIUS (January 20 - February 18)\n\nElement: Air 💨\nPlanet: Uranus & Saturn\nTraits: Innovative, independent, humanitarian, distant\n\nLove life: Aquarius doesn\'t fit into conventional relationships. Mental connection is more important than physical attraction. Friendship foundation is a must!\n\nCompatible signs: Gemini, Libra, Sagittarius',
        '♒ KOVA BURCU (20 Ocak - 18 Subat)\n\nElement: Hava 💨\nGezegen: Uranus & Saturn\nOzellikler: Yenilikci, bagımsiz, insancil, mesafeli\n\nAsk hayati: Kova alisilagelmis iliskilere sığmaz. Zihinsel baglanti fiziksel cekimden onemlidir. Arkadaslik temeli sart!\n\nUyumlu burclar: Ikizler, Terazi, Yay'),
  ];

  static final _piscesInfo = [
    l.tr(
        '♓ PISCES (February 19 - March 20)\n\nElement: Water 💧\nPlanet: Neptune & Jupiter\nTraits: Dreamy, empathetic, intuitive, escapist\n\nLove life: Pisces wants a fairy-tale love. Selfless and romantic, but don\'t forget to be realistic!\n\nCompatible signs: Cancer, Scorpio, Taurus',
        '♓ BALIK BURCU (19 Subat - 20 Mart)\n\nElement: Su 💧\nGezegen: Neptun & Jupiter\nOzellikler: Hayalperest, empatik, sezgisel, kaçış egılımlı\n\nAsk hayati: Balik masal gibi bir ask ister. Fedakar ve romantik ama gercekciligi unutmayin!\n\nUyumlu burclar: Yengec, Akrep, Boga'),
  ];

  static final _compatibilityAstro = [
    l.tr(
        '🔮 For zodiac compatibility, look at both signs\' elements:\n\n🔥 Fire (Aries, Leo, Sagittarius) + Air = Perfect!\n💧 Water (Cancer, Scorpio, Pisces) + Earth = Compatible!\n🔥 Fire + Water = Difficult but passionate\n💨 Air + Earth = Balancing\n\nWhich two signs are you curious about?',
        '🔮 Burc uyumu icin her iki burcun elementine bakin:\n\n🔥 Ates (Koç, Aslan, Yay) + Hava = Mukemmel!\n💧 Su (Yengeç, Akrep, Balık) + Toprak = Uyumlu!\n🔥 Ates + Su = Zor ama tutkulu\n💨 Hava + Toprak = Dengeleyici\n\nHangi iki burcu merak ediyorsunuz?'),
    l.tr(
        '💫 Zodiac compatibility is not limited to sun signs! For true compatibility:\n- Sun sign (core personality)\n- Moon sign (emotional needs)\n- Venus (love style)\n- Mars (passion and energy)\n\nTell me the sign, and I\'ll do a detailed analysis!',
        '💫 Burc uyumu sadece gunes burcuyla sinirli degildir! Gercek uyum icin:\n- Gunes burcu (temel kisilik)\n- Ay burcu (duygusal ihtiyaclar)\n- Venus (ask tarzı)\n- Mars (tutku ve enerji)\n\nBurcu soyleyin, detayli analiz yapayim!'),
    l.tr(
        '⚡ Most compatible couples:\n♈♌ Aries-Leo: Fire + Fire = Brilliant!\n♉♍ Taurus-Virgo: Earth harmony\n♊♎ Gemini-Libra: Air dance\n♋♏ Cancer-Scorpio: Water depth\n♐♒ Sagittarius-Aquarius: Freedom lovers\n♑♓ Capricorn-Pisces: Yin-Yang balance',
        '⚡ En uyumlu ciftler:\n♈♌ Koc-Aslan: Ates + Ates = Parlak!\n♉♍ Boga-Basak: Toprak uyumu\n♊♎ Ikizler-Terazi: Hava dansi\n♋♏ Yengec-Akrep: Su derinligi\n♐♒ Yay-Kova: Ozgurluk asklari\n♑♓ Oglak-Balik: Yin-Yang dengesi'),
  ];

  static final _planetInfo = [
    l.tr(
        '🪐 Planetary influences directly affect your relationship:\n\n💕 Venus: Love, attraction, aesthetics\n🔥 Mars: Passion, sexuality, conflict\n🧠 Mercury: Communication, understanding\n🌙 Moon: Emotions, needs\n☀️ Sun: Self, ego\n\nWhich planet would you like to know about?',
        '🪐 Gezegen etkileri iliskinizi dogrudan etkiler:\n\n💕 Venus: Ask, cekim, estetik\n🔥 Mars: Tutku, cinsellik, catisma\n🧠 Merkur: Iletisim, anlayis\n🌙 Ay: Duygular, ihtiyaclar\n☀️ Gunes: Benlik, ego\n\nHangi gezegen hakkında bilgi istersiniz?'),
    l.tr(
        '⚠️ Mercury retrograde causes communication accidents:\n- You may get a message from an ex\n- Misunderstandings increase\n- Think twice before important conversations\n\nMake clear decisions after the retrograde ends.',
        '⚠️ Merkur retrogradi iletisim kazalarina yol acar:\n- Eski sevgiliden mesaj gelebilir\n- Yanlis anlasilmalar artar\n- Onemli konusmalardan once 2 kez dusunun\n\nRetrograd bittikten sonra net kararlas alin.'),
    l.tr(
        '💕 Venus transits directly affect your love life:\n- Venus in Aries: Sudden crushes\n- Venus in Taurus: Sensual pleasures\n- Venus in Scorpio: Deep bonds\n- Venus in Pisces: Fairy-tale romance',
        '💕 Venus gecisleri ask hayatinizi dogrudan etkiler:\n- Venus Koc\'ta: Ani asikliklar\n- Venus Boga\'da: Duyusal zevkler\n- Venus Akrep\'te: Derin baglar\n- Venus Balik\'ta: Masal gibi romantizm'),
  ];

  static final _dailyAstro = [
    l.tr(
        '🌟 Today\'s general energy: Moon is in Libra! Balance and harmony energy is high. An ideal day for compromise and romantic gestures in your relationship.\n\n💡 Suggestion: Give your partner an unexpected compliment.',
        '🌟 Bugun genel enerji: Ay Terazi burcunda! Dengepve uyum enerjisi yuksek. Iliskinizde uzlasma ve romantik jestler icin ideal bir gun.\n\n💡 Onerı: Partnerinize beklenmedik bir iltifat edin.'),
    l.tr(
        '✨ Today the Venus-Mars aspect is active! Passion and romance energy is on the rise. Attractiveness and charm are heightened.\n\n💕 Flirt energy: ⭐⭐⭐⭐\n🔥 Passion energy: ⭐⭐⭐⭐⭐\n🧘 Peace: ⭐⭐⭐',
        '✨ Bugun Venus-Mars acisi aktif! Tutku ve romantizm enerjisi yukseliste. Cekicilik ve cekim gucu artmis durumda.\n\n💕 Flort enerjisi: ⭐⭐⭐⭐\n🔥 Tutku enerjisi: ⭐⭐⭐⭐⭐\n🧘 Huzur: ⭐⭐⭐'),
    l.tr(
        '🌙 Today could be an emotional day based on the Moon\'s position. Trust your intuition!\n\nTell me your sign, and I\'ll make a personal reading for you ✨',
        '🌙 Bugun Ay\'in durumuna gore duygusal bir gun olabilir. Sezgilerinize guvenin!\n\nBurcunuzu soyleyin, size ozel yorum yapayim ✨'),
  ];

  static final _natalChart = [
    l.tr(
        '🗺️ Your birth chart is your personal astrological identity:\n\n☀️ Sun sign: Who you are\n🌙 Moon sign: What you feel\n⬆️ Ascendant: How the world sees you\n💕 Venus: How you love\n🔥 Mars: How you act\n\nIf you know your birth date, time and place, I can do a detailed analysis!',
        '🗺️ Dogum haritaniz kisisel astrolojik kimliginizdir:\n\n☀️ Gunes burcu: Kim oldugunuz\n🌙 Ay burcu: Ne hissettiginiz\n⬆️ Yukseleni: Dünyaya nasil gorundugunuz\n💕 Venus: Nasil sevdiginiz\n🔥 Mars: Nasil hareket ettiginiz\n\nDogum tarihi, saati ve yerini biliyorsaniz detayli analiz yapabilirim!'),
    l.tr(
        '⬆️ Your ascendant sign is your first impression:\n- Aries rising: Energetic, brave appearance\n- Taurus: Calm, trustworthy\n- Gemini: Social, curious\n- Scorpio: Mysterious, attractive\n\nWhat is your ascendant sign?',
        '⬆️ Yükseleni burcunuz ilk izleniminizdir:\n- Koc yukeleni: Enerjik, cesur gorünüm\n- Boga: Sakin, guvenilir\n- Ikizler: Sosyal, merakli\n- Akrep: Gizemli, çekici\n\nYukseleni burcunuz ne?'),
  ];

  static final _elementInfo = [
    l.tr(
        '🔥💧💨🌍 4 Elements and Relationship Styles:\n\n🔥 FIRE (Aries, Leo, Sagittarius):\nPassionate, exciting, spontaneous lovers\n\n🌍 EARTH (Taurus, Virgo, Capricorn):\nLoyal, determined, reliable partners\n\n💨 AIR (Gemini, Libra, Aquarius):\nIntellectual, social, open to communication\n\n💧 WATER (Cancer, Scorpio, Pisces):\nEmotional, intuitive, forming deep bonds',
        '🔥💧💨🌍 4 Element ve Iliski Tarzlari:\n\n🔥 ATES (Koc, Aslan, Yay):\nTutkulu, heyecanli, spontane asiklar\n\n🌍 TOPRAK (Boga, Basak, Oglak):\nSadik, kararlı, guvenilir partnerler\n\n💨 HAVA (Ikizler, Terazi, Kova):\nZihinsel, sosyal, iletisime acik\n\n💧 SU (Yengec, Akrep, Balik):\nDuygusal, sezgisel, derin baglar kuranlar'),
  ];

  static final _generalAstrology = [
    l.tr(
        '✨ Welcome to the world of astrology! I can help with:\n\n🔮 Zodiac analysis\n💫 Zodiac compatibility\n🪐 Planetary transits\n🗺️ Birth chart\n🌟 Daily/weekly horoscopes\n\nWhat would you like to talk about?',
        '✨ Astroloji dunyasina hosgeldiniz! Su konularda yardimci olabilirim:\n\n🔮 Burc analizi\n💫 Burc uyumu\n🪐 Gezegen gecisleri\n🗺️ Dogum haritasi\n🌟 Gunluk/haftalik yorumlar\n\nNe hakkinda konusmak istersiniz?'),
    l.tr(
        '🌙 Tell me a zodiac sign, and I\'ll create its love map for you! Personality traits, relationship qualities, and compatible signs...',
        '🌙 Bir burc soyleyin, size o burcun ask haritasini cikariyim! Hem kisilik hem iliski özellikleri hem de uyumlu burclar...'),
    l.tr(
        '🔮 The stars always carry a message. Tell me your sign or an astrological topic you\'re curious about, let\'s explore together ✨',
        '🔮 Yildizlar her zaman bir mesaj tasir. Burcunuzu veya merak ettiginiz bir astrolojik konuyu soyleyin, birlikte kesfedelim ✨'),
  ];

  // ── Helpers ──
  static bool _matchesAny(String msg, List<String> keywords) {
    return keywords.any((k) => msg.contains(k));
  }

  static String _pick(List<String> list) {
    return list[_rng.nextInt(list.length)];
  }
}
