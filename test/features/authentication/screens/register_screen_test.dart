import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/primary_button.dart';
import 'package:flutter_application_1/features/authentication/notifiers/auth_notifier.dart';
import 'package:flutter_application_1/features/authentication/screens/register_screen.dart';
import 'package:flutter_application_1/features/authentication/services/auth_service.dart';
import 'package:flutter_application_1/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

import '../notifiers/auth_notifier_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  Future<void> createRegisterScreen(WidgetTester tester) async {
    mockAuthService = MockAuthService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuthService),
          ChangeNotifierProvider<AuthNotifier>(
            create: (context) => AuthNotifier(mockAuthService),
          ),
        ],
        child: MaterialApp(
          home: const RegisterScreen(),
          routes: {
            DashboardScreen.routeName: (context) => const DashboardScreen(),
          },
        ),
      ),
    );
  }

  testWidgets('Register screen should display the title', (
    WidgetTester tester,
  ) async {
    await createRegisterScreen(tester);

    expect(find.text("Crie uma nova conta"), findsOneWidget);
  });

  testWidgets("Register Screen should display a name field", (
    WidgetTester tester,
  ) async {
    await createRegisterScreen(tester);
    expect(find.byKey(const Key("register_name_field")), findsOneWidget);
  });

  testWidgets("Register Screen should display an email field", (
    WidgetTester tester,
  ) async {
    await createRegisterScreen(tester);
    expect(find.byKey(const Key("register_email_field")), findsOneWidget);
  });

  testWidgets("Register Screen should display a password field", (
    WidgetTester tester,
  ) async {
    await createRegisterScreen(tester);
    final passwordFieldFinder = find.byKey(
      const Key("register_password_field"),
    );
    final textField = tester.widget<TextField>(
      find.descendant(
        of: passwordFieldFinder,
        matching: find.byType(TextField),
      ),
    );

    expect(textField.obscureText, isTrue);
  });

  testWidgets("Register Screen should display a 'Criar conta' button", (
    WidgetTester tester,
  ) async {
    await createRegisterScreen(tester);
    expect(find.widgetWithText(PrimaryButton, "Criar conta"), findsOneWidget);
  });
}
