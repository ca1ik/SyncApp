import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/gamification_repository.dart';
import '../../data/repositories/games_repository.dart';
import '../../data/repositories/mood_repository.dart';
import '../../data/services/ai_api_client.dart';
import '../../data/services/notification_service.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/subscription/cubit/subscription_cubit.dart';
import '../../features/sync_engine/bloc/sync_engine_bloc.dart';
import '../../features/sync_engine/cubit/partner_mood_cubit.dart';
import '../constants/app_constants.dart';
import '../services/native_bridge_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  await getIt.reset();

  final prefs = await SharedPreferences.getInstance();
  final logger = Logger();
  final dio = Dio(
    BaseOptions(
      baseUrl: '',
      connectTimeout:
          const Duration(milliseconds: AppConstants.connectTimeoutMs),
      receiveTimeout:
          const Duration(milliseconds: AppConstants.receiveTimeoutMs),
      contentType: 'application/json',
    ),
  )..interceptors.add(PrettyDioLogger(requestBody: true, responseBody: true));

  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<Logger>(logger);
  getIt.registerSingleton<Dio>(dio);

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(prefs: getIt(), logger: getIt()),
  );
  getIt.registerLazySingleton<MoodRepository>(
    () => MoodRepository(prefs: getIt(), logger: getIt()),
  );
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(logger: getIt()),
  );
  getIt.registerLazySingleton<AiApiClient>(
    () => AiApiClient(dio: getIt(), logger: getIt()),
  );
  getIt.registerLazySingleton<NativeBridgeService>(
    () => NativeBridgeService(logger: getIt()),
  );
  getIt.registerLazySingleton<GamificationRepository>(
    () => GamificationRepository(prefs: getIt()),
  );
  getIt.registerLazySingleton<GamesRepository>(
    () => GamesRepository(prefs: getIt()),
  );

  getIt.registerFactory<AuthBloc>(
      () => AuthBloc(getIt())..add(const AuthStarted()));
  getIt.registerFactory<SubscriptionCubit>(
    () => SubscriptionCubit(prefs: getIt())..load(),
  );
  getIt.registerFactory<PartnerMoodCubit>(
    () => PartnerMoodCubit(authRepository: getIt(), moodRepository: getIt()),
  );
  getIt.registerFactory<SyncEngineBloc>(
    () => SyncEngineBloc(
      authRepository: getIt(),
      moodRepository: getIt(),
      aiApiClient: getIt(),
      notificationService: getIt(),
    )..add(const SyncEngineStarted()),
  );
}
