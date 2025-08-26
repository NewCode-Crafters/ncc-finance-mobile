import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/widgets/primary_button.dart';
import 'package:flutter_application_1/features/authentication/screens/update_account_screen.dart';
import 'package:flutter_application_1/features/authentication/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'login_screen_test.mocks.dart';

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

  testWidgets(
    'tapping "Save Changes" button calls updateUserName on the service',
    (WidgetTester tester) async {
      final mockAuthService = MockAuthService();
      await tester.pumpWidget(
        Provider<AuthService>.value(
          value: mockAuthService,
          child: const MaterialApp(home: UpdateAccountScreen()),
        ),
      );

      when(
        mockAuthService.updateUserName(newName: anyNamed('newName')),
      ).thenAnswer((_) async {});

      final nameField = find.byKey(const Key('update_account_name_field'));
      await tester.enterText(nameField, 'New Name');

      final saveButton = find.widgetWithText(
        PrimaryButton,
        'Salvar Alterações',
      );
      await tester.tap(saveButton);

      verify(mockAuthService.updateUserName(newName: 'New Name')).called(1);
    },
  );
}
