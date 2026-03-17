import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_app/data/repositories/auth_repository.dart';
import 'package:sync_app/data/repositories/mood_repository.dart';
import 'package:sync_app/data/services/ai_api_client.dart';
import 'package:sync_app/data/services/notification_service.dart';
import 'package:sync_app/features/sync_engine/bloc/sync_engine_bloc.dart';
import 'package:sync_app/data/models/mood_log_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sync engine saves mood and generates advice', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final logger = Logger();
    final authRepository = AuthRepository(prefs: prefs, logger: logger);
    final moodRepository = MoodRepository(prefs: prefs, logger: logger);
    final aiApiClient = AiApiClient(dio: Dio(), logger: logger);
    final notificationService = NotificationService(logger: logger);

    await authRepository.registerWithEmail(
      email: 'user@sync.test',
      password: 'secret123',
      displayName: 'User',
    );

    final bloc = SyncEngineBloc(
      authRepository: authRepository,
      moodRepository: moodRepository,
      aiApiClient: aiApiClient,
      notificationService: notificationService,
    );

    bloc.add(const SyncEngineStarted());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    bloc.add(
      const MoodSubmitted(
        energyLevel: 35,
        toleranceLevel: 42,
        signal: MoodSignal.needSilence,
        note: 'Bugun zor.',
        shareWithPartner: false,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(bloc.state.latestMood?.signal, MoodSignal.needSilence);
    expect(bloc.state.history, isNotEmpty);
    expect(bloc.state.microAdvice, isNotEmpty);

    await bloc.close();
  });
}
