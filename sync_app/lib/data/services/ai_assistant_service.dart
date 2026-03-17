import 'dart:math';

enum AiAssistantType {
  relationshipCoach,
  astrologyAssistant,
}

extension AiAssistantTypeX on AiAssistantType {
  String get title => switch (this) {
        AiAssistantType.relationshipCoach => 'Iliski Kocu',
        AiAssistantType.astrologyAssistant => 'Burc Asistani',
      };

  String get emoji => switch (this) {
        AiAssistantType.relationshipCoach => '💕',
        AiAssistantType.astrologyAssistant => '🔮',
      };

  String get description => switch (this) {
        AiAssistantType.relationshipCoach =>
          'Iliskinizi guclendirmek icin tavsiyeler, iletisim teknikleri ve cift terapisi yaklasimlari.',
        AiAssistantType.astrologyAssistant =>
          'Burc uyumu, gunluk yorumlar, gezegen gecisleri ve astrolojik iliskiler.',
      };

  String get systemPrompt => switch (this) {
        AiAssistantType.relationshipCoach =>
          'Sen deneyimli bir iliski kocusun. Sadece iliski, iletisim, duygusal zeka, cift terapisi ve romantik iliskiler hakkinda konusursun. Diger konularda kibarca konuyu iliskiye yonlendirirsin.',
        AiAssistantType.astrologyAssistant =>
          'Sen uzman bir astroloji danismanisin. Sadece burclar, gezegen gecisleri, burc uyumu, natal harita, gunluk/haftalik/aylik burc yorumlari hakkinda konusursun. Diger konularda kibarca konuyu astrolojiye yonlendirirsin.',
      };

  List<String> get capabilities => switch (this) {
        AiAssistantType.relationshipCoach => [
            'Iletisim stratejileri',
            'Guven insasi',
            'Catisma cozumu',
            'Romantizm tavsiyeleri',
            'Duygusal zeka',
            'Cift terapisi teknikleri',
            'Ask dilleri analizi',
            'Sinir belirleme',
            'Baglanma stilleri',
          ],
        AiAssistantType.astrologyAssistant => [
            'Burc analizi (12 burc)',
            'Burc uyumu',
            'Gezegen gecisleri',
            'Dogum haritasi',
            'Gunluk/haftalik yorumlar',
            'Element analizi',
            'Ask astrolojisi',
            'Retrograd etkileri',
            'Ay evreleri',
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
    if (_matchesAny(msg, ['merhaba', 'selam', 'hey', 'naber', 'nasil'])) {
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
      'kavga'
    ])) {
      return _pick(_communicationAdvice);
    }

    // Trust / jealousy
    if (_matchesAny(
        msg, ['guven', 'kiskanc', 'aldatma', 'sadakat', 'ihanet', 'yalan'])) {
      return _pick(_trustAdvice);
    }

    // Love / romance
    if (_matchesAny(msg,
        ['ask', 'sev', 'romantik', 'romantizm', 'tutku', 'ozlem', 'ozle'])) {
      return _pick(_loveAdvice);
    }

    // Distance / breakup
    if (_matchesAny(msg,
        ['uzak', 'ayrilik', 'bitir', 'bosanma', 'soguma', 'mesafe', 'ayril'])) {
      return _pick(_distanceAdvice);
    }

    // Family / in-laws
    if (_matchesAny(
        msg, ['aile', 'kayin', 'anne', 'baba', 'evlilik', 'evlen', 'nikah'])) {
      return _pick(_familyAdvice);
    }

    // Sex / intimacy
    if (_matchesAny(
        msg, ['yakinlik', 'dokunma', 'fiziksel', 'cinsel', 'mahremiyet'])) {
      return _pick(_intimacyAdvice);
    }

    // Conflict resolution
    if (_matchesAny(
        msg, ['cozum', 'baris', 'ozur', 'affet', 'uzlas', 'anlas'])) {
      return _pick(_conflictResolution);
    }

    // General fallback
    return _pick(_generalRelationship);
  }

  static bool _isOffTopicForRelationship(String msg) {
    return _matchesAny(msg, [
      'hava durumu',
      'futbol',
      'mac',
      'programlama',
      'kod',
      'yemek tarif',
      'siyaset',
      'ekonomi',
      'borsa',
      'kripto',
      'bitcoin',
      'spor',
    ]);
  }

  static const _offTopicRelationship = [
    'Ben bir iliski kocuyum 💕 Bu konuda yardimci olamam ama iliskinizle ilgili bir soru sormak ister misiniz?',
    'Uzmanlik alanim iliskiler! Bu konuyu bilmiyorum ama size iliskinizde nasil yardimci olabilirim?',
    'Hmm, bu benim alanim degil. Ama iliskinizde bir sey sizi rahatsiz ediyorsa dinlemeye hazirim 💕',
  ];

  static const _greetingsRelationship = [
    'Merhaba! 💕 Iliskinizi guclendirmek icin buradayim. Size nasil yardimci olabilirim?',
    'Hosgeldiniz! Ben iliski kocunuzum. Iliskinizle ilgili aklinizdaki her seyi sorabilirsiz 💕',
    'Selam! Bugün iliskinizde neler oluyor? Birlikte konusalim 🌸',
  ];

  static const _communicationAdvice = [
    '💬 Iletisimde en onemli kural: "Ben" diliyle konusmak. "Sen hep..." yerine "Ben ... hissediyorum" deyin.\n\nOrnegin: "Sen beni dinlemiyorsun" yerine "Dinlenmadigimi hissediyorum, bu beni uzuyor."',
    '🎯 Aktif dinleme teknigi deneyin:\n1. Goz temasi kurun\n2. Partnerin soylediklerini kendi kelimelerinizle tekrar edin\n3. "Seni anliyorum" deyin\n4. Cozum sunmadan once duyguyu kabul edin',
    '⏰ "20 dakika kurali"ni deneyin: Tartismada tansiyonlar yukseldiyse 20 dk mola verin. Bu sure beyninizin sakinlesmesi icin yeterli.\n\nMoladan sonra daha yapiclbir sekilde konusabilirsiniz.',
    '🧊 Soguk iletisim ("stone-walling") en tehlikeli iliski kaliplarindandir. Partneriniz kapatiyorsa:\n- Baski yapmayin\n- "Hazir olduğunda konusmak istiyorum" deyin\n- Guvenli ortam yaratin',
    '📝 Haftada bir "check-in" toplantisi yapin. 15 dk boyunca:\n- Bu hafta seni mutlu eden ne?\n- Bu hafta seni uzen ne?\n- Gelecek hafta ne istersin?\n\nBu basit pratik iletisimi %40 iyilestirir.',
  ];

  static const _trustAdvice = [
    '🔒 Guven yeniden insa edilebilir ama zaman ister. Adimlar:\n1. Tam seffaflik (sifir sakli bilgi)\n2. Tutarli davranislar\n3. Sabir — guven damla damla gelir\n4. Profesyonel destek alin',
    '💚 Kiskanclik dogal ama asiri kiskanclik kontrol arzusundan gelir. Kendinize sorun:\n- Gercekten bir tehdit var mi?\n- Gecmis deneyimlerim beni etkiliyor mu?\n- Partnerime guveniyorsam neden korkuyorum?',
    '🛡️ Guven krizi yasiyorsaniz:\n- Duygularinizi bastirmayin, ifade edin\n- Suclama yerine ihtiyacinizi soyeyin\n- Birlikte sinirlar belirleyin\n- Gerekirse cift terapisi dusunun',
  ];

  static const _loveAdvice = [
    '❤️ Ask dillerini kesfetdiniz mi? 5 ask dili:\n1. Onaylayici sozler\n2. Kaliteli zaman\n3. Hediye alma\n4. Hizmet etme\n5. Fiziksel temas\n\nPartnerinizin ask dilini bilmek her seyi degistirir!',
    '🌹 Romantizmi canli tutmak icin "mikro-romantizm":\n- Beklenmedik bir mesaj gonder\n- Yeni bir cafe dene birlikte\n- Beraber sunset izle\n- "Seni seviyorum" un farkli yollarini bul',
    '🔥 Tutku zamanla azalmaz, sadece form degistirir. Tutkuyu beslemek icin:\n- Birlikte yeni deneyimler yasamak\n- Birbirinizi sasirtmak\n- Bireysel alanlarinizi korumak\n- Merak duygusunu canli tutmak',
  ];

  static const _distanceAdvice = [
    '🌉 Mesafe her zaman bitisin isareti degildir. Bazen kisisel alan ihtiyaci sagliklidir.\n\nAma uzun sureli soguma icin:\n- Dogrudan ve yumusak konusun\n- "Bu iliskiyi istiyorum" mesaji verin\n- Degisim icin somut adimlar onerun',
    '💔 Ayrilik dusuncesi varsa kendinize sorun:\n- Bu geçici bir kriz mi yoksa kronik bir sorun mu?\n- Birlikte cozüm icin ne kadar caba gosterildi?\n- Profesyonel yardim alindi mi?\n\nAcele etmeyin, ama kendinizi de ihmal etmeyin.',
    '🔄 Soguma donemlerinde "yeniden baslangic ritüeli" deneyin:\n- Ilk bulusmadaki gibi plan yapin\n- Birbirinize mektup yazin\n- Ortak hedefler belirleyin\n- Minnet listesi olusturun',
  ];

  static const _familyAdvice = [
    '👨‍👩‍👧 Aile sinirlarini birlikte belirleyin. "Biz" takim olarak ailelere karsi net olmalisiniz.\n\n"Annem oyle istiyor" yerine "Biz birlikte karar verdik" demek iliskiyi guclendirir.',
    '💒 Evlilik kararindan once konusulmasi gerekenler:\n- Para yonetimi\n- Cocuk istegi ve zamanlama\n- Yasam tarzı beklentileri\n- Aile sinirlari\n- Kariyer oncelikleri',
    '🏠 Kaynana/kayinpeder sorunlari icin:\n- Partneriniz kendi ailesiyle konusmali\n- Siz "kotu cop" rolune girmeyin\n- Sinirlari birlikte koyun\n- Saygiyi koruyun ama taviz vermeyin',
  ];

  static const _intimacyAdvice = [
    '🤝 Duygusal yakinlik fiziksel yakinligin temelidir. Once guvenli bir duygusal alan olusturun.\n\nGunluk 10 dk goz goze, telefonsuz sohbet bile buyuk fark yaratir.',
    '💫 Fiziksel yakinlikta en onemli sey: iletisim. Ne istediginizi ve ne istemediginizi acikca soylemek hem sizi hem partnerinizi rahatlatir.',
    '🌸 Yakinlik sorunlari cok yaygindir ve utanilacak bir sey degildir. Cozum icin:\n- Acik iletisim\n- Sabir ve anlayis\n- Gerekirse profesyonel destek',
  ];

  static const _conflictResolution = [
    '🕊️ Gottman Yontemi: Basarili ciftler catismalari soyle cozer:\n1. Yumusak baslangic (suclama olmadan)\n2. Onarim girisimi ("Mola alalim")\n3. Uzlasma (ikisi de biraz taviz)\n4. Kabul (her sey cozulmek zorunda degil)',
    '✅ Ozur dilemek icin:\n1. Ne yaptiginizi kabul edin\n2. Partnerinizin duygusunu onaylayin\n3. Gelecekte ne yapacaginizi soyeyin\n4. "Ama..." ile baslayan cumle kullanmayin\n\n"Hakliydin, ben yanlistim" en guclu cumlelrdenbiridir.',
    '🔄 Tekrarlanan kavgalar genellikle cozulmemis "temel ihtiyac"lardan kaynaklanir. Kavganin altindaki duyguyu bulun:\n- Guvensizlik mi?\n- Deger gorememe mi?\n- Terk edilme korkusu mu?\n\nGercek konuyu bulunca cozum yaklasir.',
  ];

  static const _generalRelationship = [
    '💕 Saglikli bir iliskinin 3 temeli:\n1. Guven — seffaflik ve tutarlilik\n2. Iletisim — acik, durust, yumusak\n3. Saygi — sinirlara ve farkliliklara\n\nBu 3\'unu guclendirin, iliski guclenir.',
    '🌟 Size ozel bir oneri: Bu hafta partnerinize 3 sey soyeyin:\n1. Onu takdir ettiginiz bir sey\n2. Sizin icin ne kadar onemli oldugu\n3. Birlikte yapmayi hayal ettiginiz bir sey',
    '📊 Arastirmalar gosteriyor: Mutlu ciftlerin %69\'u cozumsuz sorunlarla yasayor. Onemli olan her seyi cozmek degil, birlikte yasamayi ogrenmek.',
    '💡 Iliskinizle ilgili spesifik bir konu hakkida soru sormak ister misiniz? Iletisim, guven, romantizm, catisma cozumu gibi konularda detayli tavsiyelr verebilirim.',
  ];

  // ══════════════════════════════════════
  //  ASTROLOGY RESPONSES
  // ══════════════════════════════════════
  static String _astrologyResponse(String msg) {
    if (_isOffTopicForAstrology(msg)) {
      return _pick(_offTopicAstrology);
    }

    if (_matchesAny(msg, ['merhaba', 'selam', 'hey', 'naber'])) {
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
    if (_matchesAny(msg, ['uyum', 'uyumlu', 'eslesiyor', 'partnerm'])) {
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
      'saturn'
    ])) {
      return _pick(_planetInfo);
    }

    // Daily/weekly
    if (_matchesAny(msg, ['bugun', 'gunluk', 'haftalik', 'aylik', 'yorum'])) {
      return _pick(_dailyAstro);
    }

    // Natal chart
    if (_matchesAny(
        msg, ['natal', 'dogum', 'harita', 'yukseleni', 'ay burcu'])) {
      return _pick(_natalChart);
    }

    // Elements
    if (_matchesAny(msg, ['ates', 'toprak', 'hava', 'su', 'element'])) {
      return _pick(_elementInfo);
    }

    return _pick(_generalAstrology);
  }

  static bool _isOffTopicForAstrology(String msg) {
    return _matchesAny(msg, [
      'futbol',
      'mac',
      'programlama',
      'kod',
      'yemek tarif',
      'siyaset',
      'ekonomi',
      'borsa',
      'kripto',
      'bitcoin',
    ]);
  }

  static const _offTopicAstrology = [
    'Ben bir astroloji asistaniyim 🔮 Bu konuda bilgim yok ama burcunuzla ilgili bir sey sormak ister misiniz?',
    'Uzmanlik alanim yildizlar ve gezegenler! Bu konuyu bilmiyorum ama burc yorumunuzu yapabilirim 🌙',
    'Hmm, benim alanim astroloji. Burcunuz hakkinda mi konusalim? ✨',
  ];

  static const _greetingsAstrology = [
    'Merhaba! 🔮 Yildizlar isiginizda! Burcunuz ne, birlikte bakalim?',
    'Hosgeldiniz! ✨ Astroloji dunyasina hosgeldiniz. Hangi burc hakkinda konusmak istersiniz?',
    'Selam! 🌙 Bugun gezegenler sizin icin ne soyluyor merak ediyor musunuz?',
  ];

  static const _ariesInfo = [
    '♈ KOC BURCU (21 Mart - 19 Nisan)\n\nElement: Ates 🔥\nGezegen: Mars\nOzellikler: Cesur, enerjik, lider ruhlu, sabirsiz\n\nAsk hayati: Tutkulu ve heyecan arayan Koc, sikilgan iliskilere dayanamaz. Cesur hareketler ve surprizler onlari cezbeder.\n\nUyumlu burclar: Aslan, Yay, Ikizler',
    '♈ Koc burcu bu donemde Mars enerjisiyle dolu! Yeni baslangiclara acik bir donem. Iliskinizde inisiyatif almanin tam zamani.\n\nDikkat: Sabirsizliginiz partnerinizi bunaltabilir. "Dur ve dinle" mantrasi isine yarar.',
  ];

  static const _taurusInfo = [
    '♉ BOGA BURCU (20 Nisan - 20 Mayis)\n\nElement: Toprak 🌍\nGezegen: Venus\nOzellikler: Sadik, kararlı, duyusal, inatci\n\nAsk hayati: Boga guvenlik arar. Yavaş ama derin baglar kurar. Bir kere baglandigi mi? Sonsuza kadar!\n\nUyumlu burclar: Basak, Oglak, Yengec',
    '♉ Boga burcu Venus yonetiminde romantizmin efendisidir! Bu donem maddi ve duygusal guvenlik on planda.\n\nIliski tavsiysesi: Partnerinize fiziksel jestler yapin — el tutma, sarilma Bogalar icin cok degerli.',
  ];

  static const _geminiInfo = [
    '♊ IKIZLER BURCU (21 Mayis - 20 Haziran)\n\nElement: Hava 💨\nGezegen: Merkur\nOzellikler: Merakli, sosyal, cok yonlu, kararsiz\n\nAsk hayati: Ikizler zihinsel uyarilma arar. Sohbet edebildigi biri en buyuk cekim noktasidir.\n\nUyumlu burclar: Terazi, Kova, Koc',
  ];

  static const _cancerInfo = [
    '♋ YENGEC BURCU (21 Haziran - 22 Temmuz)\n\nElement: Su 💧\nGezegen: Ay\nOzellikler: Duygusal, koruyucu, sezgisel, hassas\n\nAsk hayati: Yengec derin duygusal bag kurar. Evi ve aileyi cok onemsir. Guvenlik hissi her seyden onemli.\n\nUyumlu burclar: Balik, Akrep, Boga',
  ];

  static const _leoInfo = [
    '♌ ASLAN BURCU (23 Temmuz - 22 Agustos)\n\nElement: Ates 🔥\nGezegen: Gunes\nOzellikler: Karizmatik, comert, dramatik, gurur sahibi\n\nAsk hayati: Aslan iliskide kraliyet muamelesi ister! Takdir ve hayranlik onun ask dilidir.\n\nUyumlu burclar: Koc, Yay, Terazi',
  ];

  static const _virgoInfo = [
    '♍ BASAK BURCU (23 Agustos - 22 Eylul)\n\nElement: Toprak 🌍\nGezegen: Merkur\nOzellikler: Analitik, pratik, titiz, elestirel\n\nAsk hayati: Basak sevgisini hizmetle gosterir. "Seni dusundum" yerine "Senin icin su yaptim" der.\n\nUyumlu burclar: Boga, Oglak, Yengec',
  ];

  static const _libraInfo = [
    '♎ TERAZI BURCU (23 Eylul - 22 Ekim)\n\nElement: Hava 💨\nGezegen: Venus\nOzellikler: Dengeli, diplomatik, estetik, kararsiz\n\nAsk hayati: Terazi uyum ve guzellik arar. Iliski olmadan eksik hisseder. Romantizmin burcu!\n\nUyumlu burclar: Ikizler, Kova, Aslan',
  ];

  static const _scorpioInfo = [
    '♏ AKREP BURCU (23 Ekim - 21 Kasim)\n\nElement: Su 💧\nGezegen: Pluto & Mars\nOzellikler: Yogun, tutkulu, gizemli, sezgisel\n\nAsk hayati: Akrep "ya hep ya hic" asigidir. Derin, donusturucu iliskiler ister. Yarim kalp kabul etmez!\n\nUyumlu burclar: Yengec, Balik, Boga',
  ];

  static const _sagittariusInfo = [
    '♐ YAY BURCU (22 Kasim - 21 Aralik)\n\nElement: Ates 🔥\nGezegen: Jupiter\nOzellikler: Maceraci, iyimser, ozgur ruhlu, patavatsiz\n\nAsk hayati: Yay ozgurluğunu kisitlayan iliskilerden kacar. Birlikte macera yasayabilecegi bir partner ister.\n\nUyumlu burclar: Koc, Aslan, Terazi',
  ];

  static const _capricornInfo = [
    '♑ OGLAK BURCU (22 Aralik - 19 Ocak)\n\nElement: Toprak 🌍\nGezegen: Saturn\nOzellikler: Disiplinli, hırsli, sorumluluk sahibi, mesafeli\n\nAsk hayati: Oglak iliskiye yatirim gibi bakar. Yavas ama saglam adimlarla ilerler. Sadakati tartismasiz.\n\nUyumlu burclar: Boga, Basak, Balik',
  ];

  static const _aquariusInfo = [
    '♒ KOVA BURCU (20 Ocak - 18 Subat)\n\nElement: Hava 💨\nGezegen: Uranus & Saturn\nOzellikler: Yenilikci, bagımsiz, insancil, mesafeli\n\nAsk hayati: Kova alisilagelmis iliskilere sığmaz. Zihinsel baglanti fiziksel cekimden onemlidir. Arkadaslik temeli sart!\n\nUyumlu burclar: Ikizler, Terazi, Yay',
  ];

  static const _piscesInfo = [
    '♓ BALIK BURCU (19 Subat - 20 Mart)\n\nElement: Su 💧\nGezegen: Neptun & Jupiter\nOzellikler: Hayalperest, empatik, sezgisel, kaçış egılımlı\n\nAsk hayati: Balik masal gibi bir ask ister. Fedakar ve romantik ama gercekciligi unutmayin!\n\nUyumlu burclar: Yengec, Akrep, Boga',
  ];

  static const _compatibilityAstro = [
    '🔮 Burc uyumu icin her iki burcun elementine bakin:\n\n🔥 Ates (Koç, Aslan, Yay) + Hava = Mukemmel!\n💧 Su (Yengeç, Akrep, Balık) + Toprak = Uyumlu!\n🔥 Ates + Su = Zor ama tutkulu\n💨 Hava + Toprak = Dengeleyici\n\nHangi iki burcu merak ediyorsunuz?',
    '💫 Burc uyumu sadece gunes burcuyla sinirli degildir! Gercek uyum icin:\n- Gunes burcu (temel kisilik)\n- Ay burcu (duygusal ihtiyaclar)\n- Venus (ask tarzı)\n- Mars (tutku ve enerji)\n\nBurcu soyleyin, detayli analiz yapayim!',
    '⚡ En uyumlu ciftler:\n♈♌ Koc-Aslan: Ates + Ates = Parlak!\n♉♍ Boga-Basak: Toprak uyumu\n♊♎ Ikizler-Terazi: Hava dansi\n♋♏ Yengec-Akrep: Su derinligi\n♐♒ Yay-Kova: Ozgurluk asklari\n♑♓ Oglak-Balik: Yin-Yang dengesi',
  ];

  static const _planetInfo = [
    '🪐 Gezegen etkileri iliskinizi dogrudan etkiler:\n\n💕 Venus: Ask, cekim, estetik\n🔥 Mars: Tutku, cinsellik, catisma\n🧠 Merkur: Iletisim, anlayis\n🌙 Ay: Duygular, ihtiyaclar\n☀️ Gunes: Benlik, ego\n\nHangi gezegen hakkında bilgi istersiniz?',
    '⚠️ Merkur retrogradi iletisim kazalarina yol acar:\n- Eski sevgiliden mesaj gelebilir\n- Yanlis anlasilmalar artar\n- Onemli konusmalardan once 2 kez dusunun\n\nRetrograd bittikten sonra net kararlas alin.',
    '💕 Venus gecisleri ask hayatinizi dogrudan etkiler:\n- Venus Koc\'ta: Ani asikliklar\n- Venus Boga\'da: Duyusal zevkler\n- Venus Akrep\'te: Derin baglar\n- Venus Balik\'ta: Masal gibi romantizm',
  ];

  static const _dailyAstro = [
    '🌟 Bugun genel enerji: Ay Terazi burcunda! Dengepve uyum enerjisi yuksek. Iliskinizde uzlasma ve romantik jestler icin ideal bir gun.\n\n💡 Onerı: Partnerinize beklenmedik bir iltifat edin.',
    '✨ Bugun Venus-Mars acisi aktif! Tutku ve romantizm enerjisi yukseliste. Cekicilik ve cekim gucu artmis durumda.\n\n💕 Flort enerjisi: ⭐⭐⭐⭐\n🔥 Tutku enerjisi: ⭐⭐⭐⭐⭐\n🧘 Huzur: ⭐⭐⭐',
    '🌙 Bugun Ay\'in durumuna gore duygusal bir gun olabilir. Sezgilerinize guvenin!\n\nBurcunuzu soyleyin, size ozel yorum yapayim ✨',
  ];

  static const _natalChart = [
    '🗺️ Dogum haritaniz kisisel astrolojik kimliginizdir:\n\n☀️ Gunes burcu: Kim oldugunuz\n🌙 Ay burcu: Ne hissettiginiz\n⬆️ Yukseleni: Dünyaya nasil gorundugunuz\n💕 Venus: Nasil sevdiginiz\n🔥 Mars: Nasil hareket ettiginiz\n\nDogum tarihi, saati ve yerini biliyorsaniz detayli analiz yapabilirim!',
    '⬆️ Yükseleni burcunuz ilk izleniminizdir:\n- Koc yukeleni: Enerjik, cesur gorünüm\n- Boga: Sakin, guvenilir\n- Ikizler: Sosyal, merakli\n- Akrep: Gizemli, çekici\n\nYukseleni burcunuz ne?',
  ];

  static const _elementInfo = [
    '🔥💧💨🌍 4 Element ve Iliski Tarzlari:\n\n🔥 ATES (Koc, Aslan, Yay):\nTutkulu, heyecanli, spontane asiklar\n\n🌍 TOPRAK (Boga, Basak, Oglak):\nSadik, kararlı, guvenilir partnerler\n\n💨 HAVA (Ikizler, Terazi, Kova):\nZihinsel, sosyal, iletisime acik\n\n💧 SU (Yengec, Akrep, Balik):\nDuygusal, sezgisel, derin baglar kuranlar',
  ];

  static const _generalAstrology = [
    '✨ Astroloji dunyasina hosgeldiniz! Su konularda yardimci olabilirim:\n\n🔮 Burc analizi\n💫 Burc uyumu\n🪐 Gezegen gecisleri\n🗺️ Dogum haritasi\n🌟 Gunluk/haftalik yorumlar\n\nNe hakkinda konusmak istersiniz?',
    '🌙 Bir burc soyleyin, size o burcun ask haritasini cikariyim! Hem kisilik hem iliski özellikleri hem de uyumlu burclar...',
    '🔮 Yildizlar her zaman bir mesaj tasir. Burcunuzu veya merak ettiginiz bir astrolojik konuyu soyleyin, birlikte kesfedelim ✨',
  ];

  // ── Helpers ──
  static bool _matchesAny(String msg, List<String> keywords) {
    return keywords.any((k) => msg.contains(k));
  }

  static String _pick(List<String> list) {
    return list[_rng.nextInt(list.length)];
  }
}
