import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/mood_log_model.dart';

/// Yerel mood log repository — SharedPreferences + in-memory stream.
/// Firebase kullanılmıyor; mood log'lar cihaz üzerinde saklanır.
class MoodRepository {
  MoodRepository({required SharedPreferences prefs, required Logger logger})
      : _prefs = prefs,
        _logger = logger {
    _loadFromPrefs();
  }

  final SharedPreferences _prefs;
  final Logger _logger;

  static const String _moodLogsKey = 'sync_mood_logs';

  final List<MoodLogModel> _logs = [];

  // Broadcast stream controllers
  final _myMoodController = StreamController<MoodLogModel?>.broadcast();
  final _partnerMoodController = StreamController<MoodLogModel?>.broadcast();

  /// Kullanıcının en son mood'unu dinle.
  Stream<MoodLogModel?> watchMyLatestMood(String userId) {
    // İlk değeri gönder
    final latest = _latestForUser(userId);
    _myMoodController.add(latest);
    return _myMoodController.stream;
  }

  /// Partner'in en son mood'unu dinle.
  Stream<MoodLogModel?> watchPartnerLatestMood(String partnerUid) {
    final latest = _latestForUser(partnerUid);
    _partnerMoodController.add(latest);
    return _partnerMoodController.stream;
  }

  /// Yeni mood log kaydet.
  Future<void> saveMoodLog(MoodLogModel log) async {
    final logWithId = log.id.isEmpty
        ? log.copyWith(
            id: const Uuid().v4(),
            timestamp: log.timestamp ?? DateTime.now(),
          )
        : log.copyWith(timestamp: log.timestamp ?? DateTime.now());

    _logs.add(logWithId);
    await _saveToPrefs();

    // Stream'lere bildir
    _myMoodController.add(logWithId);
    if (logWithId.isSharedWithPartner) {
      _partnerMoodController.add(logWithId);
    }

    _logger
        .d('Mood log kaydedildi: ${logWithId.id} (${logWithId.signal.name})');
  }

  /// Kullanıcının mood geçmişini getir (en yeniden en eskiye).
  Future<List<MoodLogModel>> fetchMoodHistory({
    required String userId,
    int limit = 50,
  }) async {
    final userLogs = _logs.where((l) => l.userId == userId).toList()
      ..sort((a, b) => (b.timestamp ?? DateTime(2000))
          .compareTo(a.timestamp ?? DateTime(2000)));
    return userLogs.take(limit).toList();
  }

  /// Belirli tarih aralığındaki mood log'ları getir.
  Future<List<MoodLogModel>> fetchMoodRange({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    return _logs
        .where((l) =>
            l.userId == userId &&
            l.timestamp != null &&
            l.timestamp!.isAfter(start) &&
            l.timestamp!.isBefore(end))
        .toList()
      ..sort((a, b) => (b.timestamp ?? DateTime(2000))
          .compareTo(a.timestamp ?? DateTime(2000)));
  }

  /// Tüm mood log'ları temizle (debug/test).
  Future<void> clearAll() async {
    _logs.clear();
    await _prefs.remove(_moodLogsKey);
    _myMoodController.add(null);
    _partnerMoodController.add(null);
  }

  // ── Private Helpers ──

  MoodLogModel? _latestForUser(String userId) {
    final userLogs = _logs.where((l) => l.userId == userId).toList();
    if (userLogs.isEmpty) return null;
    userLogs.sort((a, b) => (b.timestamp ?? DateTime(2000))
        .compareTo(a.timestamp ?? DateTime(2000)));
    return userLogs.first;
  }

  void _loadFromPrefs() {
    final raw = _prefs.getString(_moodLogsKey);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _logs.addAll(
        list.map((e) => MoodLogModel.fromJson(e as Map<String, dynamic>)),
      );
      _logger.d('${_logs.length} mood log yüklendi');
    } on Object catch (e) {
      _logger.e('Mood log parse hatası', error: e);
    }
  }

  Future<void> _saveToPrefs() async {
    final json = _logs.map((l) => l.toJson()).toList();
    await _prefs.setString(_moodLogsKey, jsonEncode(json));
  }

  void dispose() {
    _myMoodController.close();
    _partnerMoodController.close();
  }
}
