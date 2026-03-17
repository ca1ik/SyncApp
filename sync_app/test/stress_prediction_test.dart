import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:sync_app/data/models/mood_log_model.dart';
import 'package:sync_app/data/services/ai_api_client.dart';

void main() {
  test('local trigger report returns bounded risk score and patterns',
      () async {
    final client = AiApiClient(dio: Dio(), logger: Logger());
    final history = <MoodLogModel>[
      MoodLogModel(
        id: '1',
        userId: 'u1',
        energyLevel: 25,
        toleranceLevel: 35,
        signal: MoodSignal.exhausted,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MoodLogModel(
        id: '2',
        userId: 'u1',
        energyLevel: 40,
        toleranceLevel: 30,
        signal: MoodSignal.needSpace,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    final report = await client.generateTriggerReport(
      coupleId: 'c1',
      history: history,
    );

    expect(report.patterns, isNotEmpty);
    expect(report.conflictRiskScore, inInclusiveRange(0.0, 1.0));
    expect(report.summaryText, isNotEmpty);
  });
}
