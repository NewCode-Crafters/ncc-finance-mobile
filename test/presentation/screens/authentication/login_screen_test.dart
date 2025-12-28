import 'package:flutter/material.dart';
import 'package:bytebank/application/notifiers/auth_notifier.dart';
import 'package:bytebank/presentation/screens/authentication/login_screen.dart';
import 'package:bytebank/presentation/screens/authentication/register_screen.dart';
import 'package:bytebank/domain/use_cases/auth/login_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/signup_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/send_password_reset_email_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/logout_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/mocks/fake_auth_service.dart';

void main() {
  late FakeAuthService mockAuthService;

  Future<void> createLoginScreen(WidgetTester tester) async {
    mockAuthService = FakeAuthService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthNotifier>(
            create: (context) => AuthNotifier(
              login: _LoginAdapter(mockAuthService),
              signUp: _SignUpAdapter(mockAuthService),
              sendReset: _SendResetAdapter(mockAuthService),
              logout: _LogoutAdapter(mockAuthService),
            ),
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

  testWidgets('Login screen should display an email text field', (
    WidgetTester tester,
  ) async {
    await createLoginScreen(tester);

    final emailFieldFinder = find.byKey(const Key('login_email_field'));

    expect(emailFieldFinder, findsOneWidget);
  });

  testWidgets('Login screen should display a password text field', (
    WidgetTester tester,
  ) async {
    await createLoginScreen(tester);

    final passwordFieldFinder = find.byKey(const Key('login_password_field'));
    expect(passwordFieldFinder, findsOneWidget);

    final textField = tester.widget<TextField>(passwordFieldFinder);
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
    expect(find.text('Esqueci a senha?'), findsOneWidget);
  });

  testWidgets("Login screen should display a 'Cadastre-se' link", (
    WidgetTester tester,
  ) async {
    await createLoginScreen(tester);

    expect(find.text('Cadastre-se'), findsOneWidget);
  });

  testWidgets("Tapping 'Cadastre-se' link navigates to RegisterScreen", (
    WidgetTester tester,
  ) async {
    await createLoginScreen(tester);

    final signUpLinkFinder = find.text('Cadastre-se');
    expect(signUpLinkFinder, findsOneWidget);

    await tester.tap(signUpLinkFinder);
    // Rebuild the widget tree after navigation.
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}

// Top-level adapters bridging MockAuthService to domain use-cases
class _LoginAdapter implements LoginUseCase {
  final FakeAuthService _service;
  _LoginAdapter(this._service);
  @override
  Future<void> call(String email, String password) =>
      _service.login(email, password);
}

class _SignUpAdapter implements SignUpUseCase {
  final FakeAuthService _service;
  _SignUpAdapter(this._service);
  @override
  Future<void> call({
    required String name,
    required String email,
    required String password,
  }) => _service.signUp(name: name, email: email, password: password);
}

class _SendResetAdapter implements SendPasswordResetEmailUseCase {
  final FakeAuthService _service;
  _SendResetAdapter(this._service);
  @override
  Future<void> call({required String email}) =>
      _service.sendPasswordResetEmail(email: email);
}

class _LogoutAdapter implements LogoutUseCase {
  final FakeAuthService _service;
  _LogoutAdapter(this._service);
  @override
  Future<void> call() => _service.logout();
}
