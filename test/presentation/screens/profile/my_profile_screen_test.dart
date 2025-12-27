import 'package:flutter/material.dart';
import 'package:bytebank/presentation/screens/authentication/update_account_screen.dart';
import '../../../helpers/mocks/fake_auth_service.dart';
import 'package:bytebank/domain/use_cases/auth/login_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/signup_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/send_password_reset_email_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/logout_use_case.dart';
import 'package:bytebank/domain/entities/user_profile.dart';
import 'package:bytebank/application/notifiers/profile_notifier.dart';
import 'package:bytebank/presentation/screens/profile/my_profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';

import '../../../helpers/profile/profile_notifier_test_helpers.dart';

void main() {
  late ProfileNotifier profileNotifier;
  late FakeAuthService mockAuthService;

  setUp(() {
    profileNotifier = ProfileNotifier(
      getUserProfile: FakeGetUserProfileUseCase(null),
      pickAndUploadProfilePicture: FakePickAndUploadProfilePictureUseCase(null),
    );
    mockAuthService = FakeAuthService();

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
          ChangeNotifierProvider(create: (_) => profileNotifier),
          ChangeNotifierProvider(create: (_) => profileNotifier),
          // Provide AuthNotifier constructed with adapters that forward to the MockAuthService
          Provider<LoginUseCase>.value(value: _LoginAdapter(mockAuthService)),
          Provider<SignUpUseCase>.value(value: _SignUpAdapter(mockAuthService)),
          Provider<SendPasswordResetEmailUseCase>.value(
            value: _SendResetAdapter(mockAuthService),
          ),
          Provider<LogoutUseCase>.value(value: _LogoutAdapter(mockAuthService)),
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

  group('MyProfileScreen', () {
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

// Adapters to bridge MockAuthService to domain use-cases
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
