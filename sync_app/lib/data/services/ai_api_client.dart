import 'dart:math';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../models/mood_log_model.dart';
import '../models/trigger_report_model.dart';
import '../../core/services/locale_service.dart';

/// Basit AI istemcisi.
/// Uzak API bağlanana kadar yerel fallback içgörüler üretir.
class AiApiClient {
  AiApiClient({required Dio dio, required Logger logger})
      : _dio = dio,
        _logger = logger;

  final Dio _dio;
  final Logger _logger;

  /// Mood geçmişine göre kısa mikro-tavsiye üret.
  Future<String> generateMicroAdvice({
    required MoodLogModel currentMood,
    required MoodLogModel? partnerMood,
  }) async {
    try {
      if (_dio.options.baseUrl.isNotEmpty) {
        final response = await _dio.post<Map<String, dynamic>>(
          '/micro-advice',
          data: {
            'currentMood': currentMood.toJson(),
            'partnerMood': partnerMood?.toJson(),
          },
        );
        final advice = response.data?['advice'] as String?;
        if (advice != null && advice.isNotEmpty) {
          return advice;
        }
      }
    } on Object catch (e) {
      _logger.w(
        'Uzak AI isteği başarısız, yerel fallback kullanılacak',
        error: e,
      );
    }

    return _localAdvice(currentMood, partnerMood);
  }

  /// Basit tetikleyici raporu oluştur.
  Future<TriggerReportModel> generateTriggerReport({
    required String coupleId,
    required List<MoodLogModel> history,
  }) async {
    try {
      if (_dio.options.baseUrl.isNotEmpty) {
        final response = await _dio.post<Map<String, dynamic>>(
          '/trigger-report',
          data: {
            'coupleId': coupleId,
            'history': history.map((e) => e.toJson()).toList(),
          },
        );
        final data = response.data;
        if (data != null) {
          return TriggerReportModel.fromJson(data);
        }
      }
    } on Object catch (e) {
      _logger.w(
        'Uzak trigger raporu isteği başarısız, yerel fallback kullanılacak',
        error: e,
      );
    }

    return _localTriggerReport(coupleId: coupleId, history: history);
  }

  String _localAdvice(MoodLogModel currentMood, MoodLogModel? partnerMood) {
    if (currentMood.signal == MoodSignal.needSilence) {
      return l.tr(
          'Short and gentle sentences work better right now. Give space, don\'t pressure.',
          'Şu an kısa ve yumuşak cümleler daha iyi çalışır. Alan tanıyın, baskı kurmayın.');
    }
    if (currentMood.signal == MoodSignal.needHug) {
      return l.tr(
          'Physical touch can be reassuring. Try a short message asking permission first.',
          'Fiziksel temas güven verici olabilir. Önce izin isteyen kısa bir mesaj deneyin.');
    }
    if (currentMood.signal == MoodSignal.exhausted) {
      return l.tr(
          'Fatigue seems elevated. Focus on reducing the load rather than solving problems.',
          'Yorgunluk yükselmiş görünüyor. Problem çözmek yerine yük azaltmaya odaklanın.');
    }
    if (partnerMood?.signal == MoodSignal.anxious) {
      return l.tr(
          'If both of you feel tense, regulate instead of explaining: lower your tone, pick one topic.',
          'İkinizde de gerginlik varsa açıklama değil düzenleme yapın: ses tonunu düşürün, tek konu seçin.');
    }
    return l.tr(
        'Name the emotion first, then state the need. Short and clear sentences are the safest choice.',
        'Önce duyguyu adlandırın, sonra ihtiyacı söyleyin. Kısa ve net cümleler en güvenli seçenek.');
  }

  TriggerReportModel _localTriggerReport({
    required String coupleId,
    required List<MoodLogModel> history,
  }) {
    final sorted = [...history]..sort((a, b) => (a.timestamp ?? DateTime(2000))
        .compareTo(b.timestamp ?? DateTime(2000)));

    final patterns = <TriggerPattern>[];
    final groupedBySignal = <MoodSignal, List<MoodLogModel>>{};

    for (final log in sorted) {
      groupedBySignal.putIfAbsent(log.signal, () => []).add(log);
    }

    groupedBySignal.forEach((signal, logs) {
      if (logs.isEmpty) {
        return;
      }
      final sample = logs.first;
      final timestamp = sample.timestamp ?? DateTime.now();
      patterns.add(
        TriggerPattern(
          description: l.tr('${signal.label} signal repeats frequently',
              '${signal.label} sinyali sık tekrar ediyor'),
          dayOfWeek: timestamp.weekday,
          hour: timestamp.hour,
          frequency: logs.length / max(sorted.length, 1),
          intensity:
              ((100 - sample.energyLevel) + (100 - sample.toleranceLevel)) /
                  200,
        ),
      );
    });

    final avgRisk = history.isEmpty
        ? 0.12
        : history
                .map((e) =>
                    ((100 - e.energyLevel) + (100 - e.toleranceLevel)) / 200)
                .reduce((a, b) => a + b) /
            history.length;

    return TriggerReportModel(
      id: const Uuid().v4(),
      coupleId: coupleId,
      summaryText: l.tr(
          'Local analysis shows that energy and tolerance drops cluster with certain signals.',
          'Yerel analiz, enerji ve tolerans düşüşlerinin belirli sinyallerle kümelendiğini gösteriyor.'),
      patterns: patterns,
      recommendations: [
        l.tr('Avoid bringing up difficult topics on low-energy days.',
            'Enerji seviyesi düşük günlerde yeni zor konular açmayın.'),
        l.tr('In the first 3 minutes, aim to regulate rather than solve.',
            'İlk 3 dakikada çözüm değil düzenleme hedefleyin.'),
        l.tr('When a signal comes, respond by repeating your partner\'s need.',
            'Sinyal geldiğinde partnerin ihtiyacını tekrar ederek yanıt verin.'),
      ],
      generatedAt: DateTime.now(),
      periodStart: sorted.isEmpty
          ? DateTime.now().subtract(const Duration(days: 7))
          : (sorted.first.timestamp ?? DateTime.now()),
      periodEnd: sorted.isEmpty
          ? DateTime.now()
          : (sorted.last.timestamp ?? DateTime.now()),
      conflictRiskScore: avgRisk.clamp(0.0, 1.0),
    );
  }
}
