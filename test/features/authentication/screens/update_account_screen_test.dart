import 'dart:core';

import 'package:flutter/material.dart';
import 'package:bytebank/core/widgets/primary_button.dart';
import 'package:bytebank/presentation/screens/authentication/update_account_screen.dart';
import 'package:bytebank/domain/repositories/auth_repository.dart';
import 'package:bytebank/domain/entities/user_profile.dart';
import 'package:bytebank/application/notifiers/profile_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'login_screen_test.mocks.dart';
import '../../../helpers/profile/profile_notifier_test_helpers.dart';

void main() {
  late MockAuthService mockAuthService;
  late ProfileNotifier profileNotifier;
  late UserProfile fakeUserProfile;

  setUp(() {
    mockAuthService = MockAuthService();
    profileNotifier = ProfileNotifier(
      getUserProfile: FakeGetUserProfileUseCase(null),
      pickAndUploadProfilePicture: FakePickAndUploadProfilePictureUseCase(null),
    );

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
          Provider<AuthRepository>.value(value: _RepoAdapter(mockAuthService)),
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

    expect(find.byKey(const Key('update_account_name_field')), findsOneWidget);
  });

  testWidgets('Update account screen should display an email text field', (
    WidgetTester tester,
  ) async {
    await pumpUpdateAccountScreen(tester);

    expect(find.byKey(const Key('update_account_email_field')), findsOneWidget);
  });

  testWidgets(
    'Update account screen should display a "Salvar Alterações" button',
    (WidgetTester tester) async {
      await pumpUpdateAccountScreen(tester);

      expect(
        find.widgetWithText(PrimaryButton, 'Salvar Alterações'),
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

// Adapter that implements AuthRepository but forwards to MockAuthService.
class _RepoAdapter implements AuthRepository {
  final MockAuthService _service;
  _RepoAdapter(this._service);

  @override
  Future<void> login(String email, String password) =>
      _service.login(email, password);

  @override
  Future<void> logout() => _service.logout();

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _service.sendPasswordResetEmail(email: email);

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) => _service.signUp(name: name, email: email, password: password);

  @override
  Future<void> updateUserName({required String newName}) =>
      _service.updateUserName(newName: newName);

  @override
  Future<void> updateUserPhotoUrl({required String url}) =>
      _service.updateUserPhotoUrl(url: url);

  @override
  Future<UserProfile?> getCurrentUserProfile() async => null;
}
