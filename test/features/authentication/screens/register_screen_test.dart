import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/primary_button.dart';
import 'package:flutter_application_1/features/authentication/screens/register_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Register screen should display the title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    expect(find.text("Crie uma nova conta"), findsOneWidget);
  });

  testWidgets("Register Screen should display a name field", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
    expect(find.byKey(const Key("register_name_field")), findsOneWidget);
  });

  testWidgets("Register Screen should display an email field", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
    expect(find.byKey(const Key("register_email_field")), findsOneWidget);
  });

  testWidgets("Register Screen should display a password field", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
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
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
    expect(find.widgetWithText(PrimaryButton, "Criar conta"), findsOneWidget);
  });
}
