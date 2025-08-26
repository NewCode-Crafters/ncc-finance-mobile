import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/authentication/screens/update_account_screen.dart';
import 'package:flutter_application_1/features/profile/screens/my_profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("MyProfileScreen", () {
    Future<void> pumpMyProfileScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MyProfileScreen(
            userName: 'matosJoe',
            userEmail: 'joeltonmatos@ncc.com',
          ),
          routes: {
            UpdateAccountScreen.routeName: (context) =>
                const UpdateAccountScreen(),
          },
        ),
      );
    }

    testWidgets('MyProfileScreen should display a large CircleAvatar', (
      WidgetTester tester,
    ) async {
      await pumpMyProfileScreen(tester);
      final largeAvatarFinder = find.byWidgetPredicate(
        (widget) =>
            widget is CircleAvatar &&
            widget.radius != null &&
            widget.radius! >= 40,
      );

      expect(largeAvatarFinder, findsOneWidget);
    });

    testWidgets('MyProfileScreen should display user name', (
      WidgetTester tester,
    ) async {
      await pumpMyProfileScreen(tester);

      expect(find.text('matosJoe'), findsOneWidget);
    });

    testWidgets('MyProfileScreen should display user email', (
      WidgetTester tester,
    ) async {
      await pumpMyProfileScreen(tester);

      expect(find.text('joeltonmatos@ncc.com'), findsOneWidget);
    });

    testWidgets('MyProfileScreen should display a "Meu cadastro" option', (
      WidgetTester tester,
    ) async {
      await pumpMyProfileScreen(tester);

      expect(find.text('Meu cadastro'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('MyProfileScreen should display an "Encerrar sessão" option', (
      WidgetTester tester,
    ) async {
      await pumpMyProfileScreen(tester);

      expect(find.text('Encerrar sessão'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });
    testWidgets(
      'MyProfileScreen tapping "Meu cadastro" should navigate to UpdateAccountScreen',
      (WidgetTester tester) async {
        await pumpMyProfileScreen(tester);

        final myAccountLink = find.text('Meu cadastro');
        await tester.tap(myAccountLink);
        await tester.pumpAndSettle();

        expect(find.byType(UpdateAccountScreen), findsOneWidget);
      },
    );
  });
}
