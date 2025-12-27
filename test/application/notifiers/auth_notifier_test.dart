import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/application/notifiers/auth_notifier.dart';
import 'package:bytebank/domain/use_cases/auth/login_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/signup_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/send_password_reset_email_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/logout_use_case.dart';
import 'package:bytebank/domain/exceptions/auth_exceptions.dart';

class _FakeLogin implements LoginUseCase {
  final Future<void> Function() action;
  _FakeLogin(this.action);
  @override
  Future<void> call(String email, String password) => action();
}

class _FakeSignUp implements SignUpUseCase {
  final Future<void> Function() action;
  _FakeSignUp(this.action);
  @override
  Future<void> call({
    required String name,
    required String email,
    required String password,
  }) => action();
}

class _FakeSendReset implements SendPasswordResetEmailUseCase {
  final Future<void> Function() action;
  _FakeSendReset(this.action);
  @override
  Future<void> call({required String email}) => action();
}

class _FakeLogout implements LogoutUseCase {
  final Future<void> Function() action;
  _FakeLogout(this.action);
  @override
  Future<void> call() => action();
}

// Spy fakes to verify calls and capture arguments
class _SpyLogin implements LoginUseCase {
  bool called = false;
  String? email;
  String? password;

  @override
  Future<void> call(String email, String password) async {
    called = true;
    this.email = email;
    this.password = password;
  }
}

class _SpySignUp implements SignUpUseCase {
  bool called = false;
  String? name;
  String? email;
  String? password;

  @override
  Future<void> call({
    required String name,
    required String email,
    required String password,
  }) async {
    called = true;
    this.name = name;
    this.email = email;
    this.password = password;
  }
}

class _SpySendReset implements SendPasswordResetEmailUseCase {
  bool called = false;
  String? email;

  @override
  Future<void> call({required String email}) async {
    called = true;
    this.email = email;
  }
}

class _SpyLogout implements LogoutUseCase {
  int callCount = 0;
  @override
  Future<void> call() async {
    callCount += 1;
  }
}

void main() {
  test('login success sets authenticated', () async {
    final notifier = AuthNotifier(
      login: _FakeLogin(() async {}),
      signUp: _FakeSignUp(() async {}),
      sendReset: _FakeSendReset(() async {}),
      logout: _FakeLogout(() async {}),
    );

    final res = await notifier.login('a@b.com', 'p');
    expect(res, isTrue);
    expect(notifier.state.isAuthenticated, isTrue);
  });

  test('login invalid credentials maps to error', () async {
    final notifier = AuthNotifier(
      login: _FakeLogin(() async {
        throw InvalidCredentialsException();
      }),
      signUp: _FakeSignUp(() async {}),
      sendReset: _FakeSendReset(() async {}),
      logout: _FakeLogout(() async {}),
    );

    final res = await notifier.login('a@b.com', 'p');
    expect(res, isFalse);
    expect(notifier.state.errorMessage, isNotNull);
  });

  test('signUp weak password maps to error', () async {
    final notifier = AuthNotifier(
      login: _FakeLogin(() async {}),
      signUp: _FakeSignUp(() async {
        throw WeakPasswordException();
      }),
      sendReset: _FakeSendReset(() async {}),
      logout: _FakeLogout(() async {}),
    );

    final res = await notifier.signUp(
      name: 'n',
      email: 'a@b.com',
      password: 'p',
    );
    expect(res, isFalse);
    expect(notifier.state.errorMessage, contains('fraca'));
  });

  test('send reset success sets success message', () async {
    final notifier = AuthNotifier(
      login: _FakeLogin(() async {}),
      signUp: _FakeSignUp(() async {}),
      sendReset: _FakeSendReset(() async {}),
      logout: _FakeLogout(() async {}),
    );

    await notifier.sendPasswordResetEmail(email: 'a@b.com');
    expect(notifier.state.successMessage, isNotNull);
  });

  test('logout resets state', () async {
    final notifier = AuthNotifier(
      login: _FakeLogin(() async {}),
      signUp: _FakeSignUp(() async {}),
      sendReset: _FakeSendReset(() async {}),
      logout: _FakeLogout(() async {}),
    );

    await notifier.logout();
    expect(notifier.state.isAuthenticated, isFalse);
  });

  test('initial state must be correct (not loading, not error)', () {
    final notifier = AuthNotifier(
      login: _SpyLogin(),
      signUp: _SpySignUp(),
      sendReset: _SpySendReset(),
      logout: _SpyLogout(),
    );

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.errorMessage, isNull);
  });

  test('login succeeds and state is updated', () async {
    final spyLogin = _SpyLogin();
    final notifier = AuthNotifier(
      login: spyLogin,
      signUp: _SpySignUp(),
      sendReset: _SpySendReset(),
      logout: _SpyLogout(),
    );

    final result = await notifier.login('user@test.com', 'password');

    expect(result, isTrue);
    expect(notifier.state.isAuthenticated, isTrue);
    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.errorMessage, isNull);
    expect(spyLogin.called, isTrue);
    expect(spyLogin.email, 'user@test.com');
  });

  test(
    'login fails with wrong password and state maps to invalid credentials message',
    () async {
      final notifier = AuthNotifier(
        login: _FakeLogin(() async {
          throw InvalidCredentialsException();
        }),
        signUp: _SpySignUp(),
        sendReset: _SpySendReset(),
        logout: _SpyLogout(),
      );

      final res = await notifier.login('a@b.com', 'p');
      expect(res, isFalse);
      expect(
        notifier.state.errorMessage,
        'Credenciais inválidas. Por favor, tente novamente.',
      );
    },
  );

  test(
    'login fails with user not found and maps to not found message',
    () async {
      final notifier = AuthNotifier(
        login: _FakeLogin(() async {
          throw UserNotFoundException();
        }),
        signUp: _SpySignUp(),
        sendReset: _SpySendReset(),
        logout: _SpyLogout(),
      );

      final res = await notifier.login('notfound@test.com', 'p');
      expect(res, isFalse);
      expect(
        notifier.state.errorMessage,
        'Usuário não encontrado. Por favor, verifique o e-mail ou cadastre-se.',
      );
    },
  );

  test(
    'login does not call use case and sets error message for invalid email',
    () async {
      final spyLogin = _SpyLogin();
      final notifier = AuthNotifier(
        login: spyLogin,
        signUp: _SpySignUp(),
        sendReset: _SpySendReset(),
        logout: _SpyLogout(),
      );

      const invalidEmail = 'invalid_email';
      final res = await notifier.login(invalidEmail, 'password');

      expect(res, isFalse);
      expect(
        notifier.state.errorMessage,
        'Por favor, insira um e-mail válido.',
      );
      expect(notifier.state.isLoading, isFalse);
      expect(spyLogin.called, isFalse);
    },
  );

  test(
    'signUp succeeds and state is updated to authenticated and call recorded',
    () async {
      final spySignUp = _SpySignUp();
      final notifier = AuthNotifier(
        login: _SpyLogin(),
        signUp: spySignUp,
        sendReset: _SpySendReset(),
        logout: _SpyLogout(),
      );

      final res = await notifier.signUp(
        name: 'New User',
        email: 'new@test.com',
        password: 'password123',
      );

      expect(res, isTrue);
      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, isNull);
      expect(spySignUp.called, isTrue);
      expect(spySignUp.email, 'new@test.com');
    },
  );

  test(
    'sendPasswordResetEmail succeeds and sets a success message and calls use case',
    () async {
      final spySend = _SpySendReset();
      final notifier = AuthNotifier(
        login: _SpyLogin(),
        signUp: _SpySignUp(),
        sendReset: spySend,
        logout: _SpyLogout(),
      );

      await notifier.sendPasswordResetEmail(email: 'test@test.com');

      expect(
        notifier.state.successMessage,
        'E-mail de redefinição de senha enviado. Por favor, verifique sua caixa de entrada.',
      );
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, isNull);
      expect(spySend.called, isTrue);
      expect(spySend.email, 'test@test.com');
    },
  );

  test(
    'logout succeeds and clears authentication state and calls logout once',
    () async {
      final spyLogout = _SpyLogout();
      final notifier = AuthNotifier(
        login: _SpyLogin(),
        signUp: _SpySignUp(),
        sendReset: _SpySendReset(),
        logout: spyLogout,
      );

      await notifier.logout();

      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, isNull);
      expect(notifier.state.successMessage, isNull);
      expect(spyLogout.callCount, 1);
    },
  );
}
