import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

/// Yerel bildirim servisi — flutter_local_notifications kullanır.
/// Firebase Messaging kullanılmıyor.
class NotificationService {
  NotificationService({required Logger logger}) : _logger = logger;

  final Logger _logger;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Bildirim sistemini başlat.
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    _logger.i('NotificationService başlatıldı');
  }

  /// Partner mood sinyali bildirimi göster.
  Future<void> showPartnerMoodNotification({
    required String partnerName,
    required String signalLabel,
    required String signalEmoji,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'partner_mood_channel',
      'Partner Duygu Sinyalleri',
      channelDescription: 'Partner mood sinyali bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '$signalEmoji $partnerName sinyal gönderdi',
      signalLabel,
      details,
    );

    _logger.d('Partner mood bildirimi gösterildi: $signalLabel');
  }

  /// Genel bildirim göster.
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'sync_general_channel',
      'Sync Bildirimler',
      channelDescription: 'Genel uygulama bildirimleri',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Mikro-tavsiye bildirimi göster.
  Future<void> showMicroAdvice({
    required String advice,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'micro_advice_channel',
      'Mikro Tavsiyeler',
      channelDescription: 'AI destekli mikro tavsiye bildirimleri',
      importance: Importance.low,
      priority: Priority.low,
      styleInformation: BigTextStyleInformation(''),
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '💡 Mikro Tavsiye',
      advice,
      details,
    );
  }

  /// Tüm bildirimleri temizle.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  void _onNotificationTap(NotificationResponse response) {
    _logger.d('Bildirime tıklandı — payload: ${response.payload}');
  }
}
