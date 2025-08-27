import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/authentication/screens/update_account_screen.dart';
import 'package:flutter_application_1/features/authentication/services/auth_service.dart';
import 'package:flutter_application_1/features/profile/models/user_profile.dart';
import 'package:flutter_application_1/features/profile/notifers/profile_notifier.dart';
import 'package:flutter_application_1/features/profile/screens/my_profile_screen.dart';
import 'package:flutter_application_1/features/profile/services/profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

import '../../authentication/screens/login_screen_test.mocks.dart';
import '../notifiers/profile_notifier_test.mocks.dart';

@GenerateMocks([ProfileService])
void main() {
  late MockProfileService mockProfileService;
  late ProfileNotifier profileNotifier;
  late MockAuthService mockAuthService;

  setUp(() {
    mockProfileService = MockProfileService();
    profileNotifier = ProfileNotifier(mockProfileService);
    mockAuthService = MockAuthService();

    final fakeProfile = UserProfile(
      uid: '1',
      name: 'matosJoe',
      email: 'joeltonmatos@ncc.com',
    );

    profileNotifier.setStateForTest(ProfileState(userProfile: fakeProfile));
  });

  Future<void> pumpMyProfileScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfileNotifier>.value(value: profileNotifier),
          Provider<AuthService>.value(value: mockAuthService),
        ],
        child: MaterialApp(
          home: const MyProfileScreen(), // The screen now takes no arguments.
          routes: {
            UpdateAccountScreen.routeName: (context) =>
                const UpdateAccountScreen(),
          },
        ),
      ),
    );
  }

  group("MyProfileScreen", () {
    testWidgets('should display user name from notifier', (
      WidgetTester tester,
    ) async {
      // ARRANGE: Build the screen using our new helper.
      await pumpMyProfileScreen(tester);

      // ASSERT: The test now looks for the data from the notifier's state.
      expect(find.text('matosJoe'), findsOneWidget);
    });

    testWidgets('should display user email from notifier', (
      WidgetTester tester,
    ) async {
      await pumpMyProfileScreen(tester);
      expect(find.text('joeltonmatos@ncc.com'), findsOneWidget);
    });

    testWidgets('should display a large CircleAvatar', (
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

    testWidgets('should display a "Meu cadastro" option', (
      WidgetTester tester,
    ) async {
      await pumpMyProfileScreen(tester);

      expect(find.text('Meu cadastro'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('should display an "Encerrar sessão" option', (
      WidgetTester tester,
    ) async {
      await pumpMyProfileScreen(tester);

      expect(find.text('Encerrar sessão'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });
    testWidgets(
      'tapping "Meu cadastro" should navigate to UpdateAccountScreen',
      (WidgetTester tester) async {
        await pumpMyProfileScreen(tester);
        await tester.tap(find.text('Meu cadastro'));
        await tester.pumpAndSettle();
        expect(find.byType(UpdateAccountScreen), findsOneWidget);
      },
    );
  });
}
