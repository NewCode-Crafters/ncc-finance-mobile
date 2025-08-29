import 'package:flutter/material.dart';
import 'package:bytebank/core/widgets/primary_button.dart';
import 'package:bytebank/features/authentication/screens/update_account_screen.dart';
import 'package:bytebank/features/authentication/services/auth_service.dart';
import 'package:bytebank/features/profile/models/user_profile.dart';
import 'package:bytebank/features/profile/notifers/profile_notifier.dart';
import 'package:bytebank/features/profile/services/profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../profile/notifiers/profile_notifier_test.mocks.dart';
import 'login_screen_test.mocks.dart';

@GenerateMocks([ProfileService])
void main() {
  late MockAuthService mockAuthService;
  late MockProfileService mockProfileService;
  late ProfileNotifier profileNotifier;
  late UserProfile fakeUserProfile;

  setUp(() {
    mockAuthService = MockAuthService();
    mockProfileService = MockProfileService();
    profileNotifier = ProfileNotifier(mockProfileService);

    fakeUserProfile = UserProfile(
      uid: 'user-123',
      name: 'Initial Name',
      email: 'initial@test.com',
    );

    profileNotifier.setStateForTest(ProfileState(userProfile: fakeUserProfile));
  });

  Future<void> pumpUpdateAccountScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuthService),
          ChangeNotifierProvider<ProfileNotifier>.value(value: profileNotifier),
        ],
        child: const MaterialApp(home: UpdateAccountScreen()),
      ),
    );
  }

  testWidgets('Update account screen should display a name text field', (
    WidgetTester tester,
  ) async {
    await pumpUpdateAccountScreen(tester);

    expect(find.byKey(const Key("update_account_name_field")), findsOneWidget);
  });

  testWidgets('Update account screen should display an email text field', (
    WidgetTester tester,
  ) async {
    await pumpUpdateAccountScreen(tester);

    expect(find.byKey(const Key("update_account_email_field")), findsOneWidget);
  });

  testWidgets(
    'Update account screen should display a "Salvar Alterações" button',
    (WidgetTester tester) async {
      await pumpUpdateAccountScreen(tester);

      expect(
        find.widgetWithText(PrimaryButton, "Salvar Alterações"),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'tapping "Save Changes" button calls updateUserName on the service',
    (WidgetTester tester) async {
      await pumpUpdateAccountScreen(tester);

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
