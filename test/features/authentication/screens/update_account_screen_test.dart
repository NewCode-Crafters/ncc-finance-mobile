import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/primary_button.dart';
import 'package:flutter_application_1/features/authentication/screens/update_account_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Update account screen should display a name text field', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: UpdateAccountScreen()));

    expect(find.byKey(const Key("update_account_name_field")), findsOneWidget);
  });

  testWidgets('Update account screen should display an email text field', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: UpdateAccountScreen()));

    expect(find.byKey(const Key("update_account_email_field")), findsOneWidget);
  });

  testWidgets(
    'Update account screen should display a "Salvar Alterações" button',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: UpdateAccountScreen()));

      expect(
        find.widgetWithText(PrimaryButton, "Salvar Alterações"),
        findsOneWidget,
      );
    },
  );
}
