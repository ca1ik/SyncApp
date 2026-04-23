// lib/core/constants/app_constants.dart
// Uygulama genelinde kullanılan sabit değerler.

class AppConstants {
  AppConstants._();

  // --- Firebase / Firestore koleksiyon isimleri ---
  static const String usersCollection = 'users';
  static const String moodLogsCollection = 'mood_logs';
  static const String coupleLinksCollection = 'couple_links';
  static const String triggerReportsCollection = 'trigger_reports';

  // --- Platform Channel ---
  static const String nativeChannelName = 'com.syncapp.couples/native_bridge';
  static const String widgetChannelName = 'com.syncapp.couples/home_widget';

  // --- RevenueCat ---
  static const String revenueCatAndroidApiKey =
      'YOUR_REVENUECAT_ANDROID_KEY'; // .env'den yüklenecek
  static const String proEntitlementId = 'sync_pro';
  static const String annualProductId = 'sync_annual_pro';

  // --- AI / NLP Sunucusu ---
  static const String aiBaseUrl = 'https://api.sync-nlp.example.com/v1';
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 20000;

  // --- Uygulama Sabitleri ---
  static const int maxEnergyLevel = 100;
  static const int criticalEnergyThreshold = 25;
  static const int lowToleranceThreshold = 30;
  static const Duration moodRefreshInterval = Duration(minutes: 5);
  static const Duration syncDebounceDelay = Duration(milliseconds: 500);

  // --- SharedPreferences anahtarları ---
  static const String prefThemeKey = 'selected_theme';
  static const String prefOnboardingKey = 'onboarding_done';
  static const String prefPartnerLinkedKey = 'partner_linked';
  static const String prefFcmTokenKey = 'fcm_token';
  static const String prefRelationshipModeKey = 'sync_relationship_mode';
  static const String prefTutorialSeenPrefix = 'sync_tutorial_seen_';
}
