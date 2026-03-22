import 'package:get/get.dart';

import '../../data/models/game_model.dart';
import '../../features/achievements/presentation/pages/achievements_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/partner_link_page.dart';
import '../../features/breathing/presentation/pages/breathing_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/games/presentation/pages/game_play_page.dart';
import '../../features/games/presentation/pages/games_hub_page.dart';
import '../../features/ai_assistant/presentation/pages/ai_assistant_page.dart';
import '../../features/games/presentation/pages/qa_system_page.dart';
import '../../features/games/presentation/pages/tournament_page.dart';
import '../../features/games/presentation/pages/ranking_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String partnerLink = '/partner-link';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  static const String subscription = '/subscription';
  static const String breathing = '/breathing';
  static const String achievements = '/achievements';
  static const String gamesHub = '/games-hub';
  static const String gamePlay = '/game-play';
  static const String qaSystem = '/qa-system';
  static const String aiAssistant = '/ai-assistant';
  static const String tournament = '/tournament';
  static const String ranking = '/ranking';
}

class AppRouter {
  AppRouter._();

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.onboarding, page: OnboardingPage.new),
    GetPage(name: AppRoutes.login, page: LoginPage.new),
    GetPage(name: AppRoutes.partnerLink, page: PartnerLinkPage.new),
    GetPage(name: AppRoutes.home, page: HomePage.new),
    GetPage(name: AppRoutes.dashboard, page: DashboardPage.new),
    GetPage(name: AppRoutes.settings, page: SettingsPage.new),
    GetPage(name: AppRoutes.subscription, page: SubscriptionPage.new),
    GetPage(name: AppRoutes.breathing, page: BreathingPage.new),
    GetPage(name: AppRoutes.achievements, page: AchievementsPage.new),
    GetPage(name: AppRoutes.gamesHub, page: GamesHubPage.new),
    GetPage(
      name: AppRoutes.gamePlay,
      page: () => GamePlayPage(gameType: Get.arguments as CoupleGameType),
    ),
    GetPage(name: AppRoutes.qaSystem, page: QASystemPage.new),
    GetPage(name: AppRoutes.aiAssistant, page: AiAssistantPage.new),
    GetPage(name: AppRoutes.tournament, page: TournamentPage.new),
    GetPage(name: AppRoutes.ranking, page: RankingPage.new),
  ];
}
