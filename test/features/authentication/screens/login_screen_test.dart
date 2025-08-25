import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/authentication/notifiers/auth_notifier.dart';
import 'package:flutter_application_1/features/authentication/screens/login_screen.dart';
import 'package:flutter_application_1/features/authentication/screens/register_screen.dart';
import 'package:flutter_application_1/features/authentication/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

import '../notifiers/auth_notifier_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  Future<void> createLoginScreen(WidgetTester tester) async {
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
          home: const LoginScreen(),
          routes: {
            RegisterScreen.routeName: (context) => const RegisterScreen(),
          },
        ),
      ),
    );
  }

  testWidgets('Login screen should diplay the Bytebank logo', (
    WidgetTester tester,
  ) async {
    await createLoginScreen(tester);

    final logoFinder = find.image(
      const AssetImage('assets/images/bytebank_logo.png'),
    );

    expect(logoFinder, findsOneWidget);
  });

  testWidgets("Login screen should display an email text field", (
    WidgetTester tester,
  ) async {
    await createLoginScreen(tester);

    final emailFieldFinder = find.byKey(const Key('login_email_field'));

    expect(emailFieldFinder, findsOneWidget);
  });

  testWidgets("Login screen should display a password text field", (
    WidgetTester tester,
  ) async {
    await createLoginScreen(tester);

    final passwordFieldFinder = find.byKey(const Key('login_password_field'));
    expect(passwordFieldFinder, findsOneWidget);

    final textField = tester.widget<TextField>(
      find.descendant(
        of: passwordFieldFinder,
        matching: find.byType(TextField),
      ),
    );
    expect(textField.obscureText, isTrue);
  });

  testWidgets("Login screen should display an 'Acessar' button", (
    WidgetTester tester,
  ) async {
    await createLoginScreen(tester);

    final accessButtonFinder = find.byKey(const Key('login_access_button'));
    expect(accessButtonFinder, findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Acessar'), findsOneWidget);
  });

  testWidgets("Login screen should display a 'Forgot Password?' link", (
    WidgetTester tester,
  ) async {
    await createLoginScreen(tester);
    expect(find.text("Esqueci a senha?"), findsOneWidget);
  });

  testWidgets("Login screen should display a 'Cadastre-se' link", (
    WidgetTester tester,
  ) async {
    await createLoginScreen(tester);

    expect(find.text("Cadastre-se"), findsOneWidget);
  });

  testWidgets("Tapping 'Cadastre-se' link navigates to RegisterScreen", (
    WidgetTester tester,
  ) async {
    await createLoginScreen(tester);

    final signUpLinkFinder = find.text("Cadastre-se");
    expect(signUpLinkFinder, findsOneWidget);

    await tester.tap(signUpLinkFinder);
    // Rebuild the widget tree after navigation.
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
