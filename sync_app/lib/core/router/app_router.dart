import 'package:get/get.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/partner_link_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String partnerLink = '/partner-link';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
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
  ];
}
