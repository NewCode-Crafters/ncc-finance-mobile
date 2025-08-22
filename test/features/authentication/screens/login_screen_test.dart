import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/authentication/screens/login_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Login screen should diplay the Bytebank logo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    final logoFinder = find.image(
      const AssetImage('assets/images/bytebank_logo.png'),
    );

    expect(logoFinder, findsOneWidget);
  });

  testWidgets("Login screen should display an email text field", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    final emailFieldFinder = find.byKey(const Key('login_email_field'));

    expect(emailFieldFinder, findsOneWidget);
  });

  testWidgets("Login screen should display a password text field", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

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
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    final accessButtonFinder = find.byKey(const Key('login_access_button'));
    expect(accessButtonFinder, findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Acessar'), findsOneWidget);
  });

  testWidgets("Login screen should display a 'Forgot Password?' link", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text("Esqueci a senha?"), findsOneWidget);
  });
}
