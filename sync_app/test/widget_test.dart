import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sync_app/core/di/injection.dart';
import 'package:sync_app/core/router/app_router.dart';
import 'package:sync_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login page renders after app bootstrap',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();

    await tester.pumpWidget(const MyApp(initialRoute: AppRoutes.login));
    await tester.pumpAndSettle();

    expect(find.text('Sync'), findsWidgets);
    expect(find.text('Giris yap'), findsOneWidget);
  });
}
