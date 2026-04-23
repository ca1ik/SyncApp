import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async' show unawaited;
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/services/game_audio_service.dart';
import 'core/services/locale_service.dart';
import 'core/theme/theme_provider.dart';
import 'data/repositories/auth_repository.dart';
import 'data/services/ads_service.dart';
import 'data/services/notification_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/subscription/cubit/subscription_cubit.dart';
import 'features/sync_engine/bloc/sync_engine_bloc.dart';
import 'features/sync_engine/cubit/partner_mood_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<NotificationService>().initialize();
  await LocaleService.instance.load();
  await GameAudioService.instance.init();
  // AdMob başlatma — hata olursa uygulamayı bloke etmesin
  unawaited(getIt<AdsService>().init());

  final themeProvider = AppThemeProvider();
  await themeProvider.loadSavedTheme();
  final initialRoute = await _resolveInitialRoute();

  runApp(MyApp(initialRoute: initialRoute, themeProvider: themeProvider));
}

Future<String> _resolveInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool(AppConstants.prefOnboardingKey) ?? false;
  if (!onboardingDone) {
    return AppRoutes.onboarding;
  }

  // Check if user selected a relationship mode
  final modeSelected =
      prefs.getString(AppConstants.prefRelationshipModeKey) != null;
  if (!modeSelected) {
    return AppRoutes.modeSelection;
  }

  final user = await getIt<AuthRepository>().getCurrentUserProfile();
  if (user == null) {
    return AppRoutes.login;
  }
  if (user.partnerUid == null) {
    return AppRoutes.partnerLink;
  }
  return AppRoutes.home;
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.initialRoute,
    this.themeProvider,
  });

  final String initialRoute;
  final AppThemeProvider? themeProvider;

  @override
  Widget build(BuildContext context) {
    final provider = themeProvider ?? AppThemeProvider();

    return ChangeNotifierProvider<AppThemeProvider>.value(
      value: provider,
      child: ListenableBuilder(
        listenable: LocaleService.instance,
        builder: (context, _) => MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
            BlocProvider<SubscriptionCubit>(
                create: (_) => getIt<SubscriptionCubit>()),
            BlocProvider<PartnerMoodCubit>(
                create: (_) => getIt<PartnerMoodCubit>()),
            BlocProvider<SyncEngineBloc>(
                create: (_) => getIt<SyncEngineBloc>()),
          ],
          child: Consumer<AppThemeProvider>(
            builder: (context, theme, _) {
              return GetMaterialApp(
                key: ValueKey('locale_${l.locale}'),
                title: 'Sync',
                debugShowCheckedModeBanner: false,
                theme: theme.themeData,
                locale: l.materialLocale,
                supportedLocales:
                    AppLocale.supported.map((e) => Locale(e.code)).toList(),
                initialRoute: initialRoute,
                getPages: AppRouter.pages,
              );
            },
          ),
        ),
      ),
    );
  }
}
