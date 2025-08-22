import 'package:flutter_application_1/features/authentication/notifiers/auth_notifier.dart';
import 'package:flutter_application_1/features/authentication/services/auth_exceptions.dart';
import 'package:flutter_application_1/features/authentication/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_notifier_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;
  late AuthNotifier authNotifier;

  setUp(() {
    mockAuthService = MockAuthService();
    authNotifier = AuthNotifier(mockAuthService);
  });

  group("AuthNotifier", () {
    test("initial state must be correct (not loading, not error)", () {
      final notifier = AuthNotifier(mockAuthService);

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, isNull);
    });

    test('login succeeds and state is updated', () async {
      when(mockAuthService.login(any, any)).thenAnswer((_) async {});

      await authNotifier.login('test@test.com', 'password');

      expect(authNotifier.state.isAuthenticated, isTrue);
      expect(authNotifier.state.isLoading, isFalse);
      expect(authNotifier.state.errorMessage, isNull);
    });

    test(
      "login fails with wrong password and state is updated with error message",
      () async {
        when(
          mockAuthService.login(any, any),
        ).thenThrow(InvalidCredentialsException());

        await authNotifier.login('test@test.com', 'wrong_password');

        expect(
          authNotifier.state.errorMessage,
          "Invalid credentials. Please try again.",
        );
        expect(authNotifier.state.isAuthenticated, isFalse);
        expect(authNotifier.state.isLoading, isFalse);
      },
    );

    test(
      "login fails with user not found and state is updated with error message",
      () async {
        when(
          mockAuthService.login(any, any),
        ).thenThrow(UserNotFoundException());

        await authNotifier.login('not_found@test.com', 'password');

        expect(
          authNotifier.state.errorMessage,
          "User not found. Please check the email or sign up.",
        );
        expect(authNotifier.state.isAuthenticated, isFalse);
        expect(authNotifier.state.isLoading, isFalse);
      },
    );

    test(
      'login does not call service and sets error message for invalid email',
      () async {
        const invalidEmail = 'invalid_email';

        await authNotifier.login(invalidEmail, 'password');

        expect(authNotifier.state.errorMessage, "Please enter a valid email.");
        expect(authNotifier.state.isLoading, isFalse);

        verifyNever(mockAuthService.login(any, any));
      },
    );

    test('signUp succeeds and state is updated to authenticated', () async {
      when(
        mockAuthService.signUp(
          name: anyNamed('name'),
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async {});

      await authNotifier.signUp(
        name: 'New User',
        email: 'new@test.com',
        password: 'password123',
      );

      expect(authNotifier.state.isAuthenticated, isTrue);
      expect(authNotifier.state.isLoading, isFalse);
      expect(authNotifier.state.errorMessage, isNull);
    });

    test(
      'sendPasswordResetEmail succeeds and sets a success message ',
      () async {
        when(
          mockAuthService.sendPasswordResetEmail(email: anyNamed('email')),
        ).thenAnswer((_) async {});

        await authNotifier.sendPasswordResetEmail(email: 'test@test.com');

        expect(
          authNotifier.state.successMessage,
          'Password reset email sent. Please check your inbox.',
        );
        expect(authNotifier.state.isLoading, isFalse);
        expect(authNotifier.state.errorMessage, isNull);
      },
    );

    test("logout succeeds and clears authentication state", () async {
      when(mockAuthService.logout()).thenAnswer((_) async {});

      await authNotifier.logout();

      expect(authNotifier.state.isAuthenticated, isFalse);
      expect(authNotifier.state.isLoading, isFalse);
      expect(authNotifier.state.errorMessage, isNull);
      expect(authNotifier.state.successMessage, isNull);

      verify(mockAuthService.logout()).called(1);
    });
  });
}
