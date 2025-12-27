import 'package:flutter/material.dart';
import 'package:bytebank/core/widgets/primary_button.dart';
import 'package:bytebank/application/notifiers/auth_notifier.dart';
import 'package:bytebank/presentation/screens/authentication/register_screen.dart';
import 'package:bytebank/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:bytebank/domain/use_cases/auth/login_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/signup_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/send_password_reset_email_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/logout_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/mocks/fake_auth_service.dart';

void main() {
  late FakeAuthService mockAuthService;

  Future<void> createRegisterScreen(WidgetTester tester) async {
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

    expect(find.text('Crie uma nova conta'), findsOneWidget);
  });

  testWidgets('Register Screen should display a name field', (
    WidgetTester tester,
  ) async {
    await createRegisterScreen(tester);
    expect(find.byKey(const Key('register_name_field')), findsOneWidget);
  });

  testWidgets('Register Screen should display an email field', (
    WidgetTester tester,
  ) async {
    await createRegisterScreen(tester);
    expect(find.byKey(const Key('register_email_field')), findsOneWidget);
  });

  testWidgets('Register Screen should display a password field', (
    WidgetTester tester,
  ) async {
    await createRegisterScreen(tester);
    final passwordFieldFinder = find.byKey(
      const Key('register_password_field'),
    );
    final textField = tester.widget<TextField>(passwordFieldFinder);

    expect(textField.obscureText, isTrue);
  });

  testWidgets("Register Screen should display a 'Criar conta' button", (
    WidgetTester tester,
  ) async {
    await createRegisterScreen(tester);
    expect(find.widgetWithText(PrimaryButton, 'Criar conta'), findsOneWidget);
  });
}

// Top-level adapters so they can be used from the test constructors
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
