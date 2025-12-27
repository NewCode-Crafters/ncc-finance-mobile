import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/domain/repositories/auth_repository.dart';
import 'package:bytebank/domain/entities/user_profile.dart';
import 'package:bytebank/domain/use_cases/auth/login_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/signup_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/send_password_reset_email_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/logout_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/update_user_photo_url_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/update_user_name_use_case.dart';
import 'package:bytebank/domain/use_cases/auth/get_current_user_profile_use_case.dart';

class FakeAuthRepository implements AuthRepository {
  String? lastLoginEmail;
  String? lastLoginPassword;

  Map<String, String>? lastSignUpArgs;

  String? lastResetEmail;

  bool logoutCalled = false;

  String? lastPhotoUrl;
  String? lastNewName;

  UserProfile? profileToReturn;

  @override
  Future<void> login(String email, String password) async {
    lastLoginEmail = email;
    lastLoginPassword = password;
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    lastSignUpArgs = {'name': name, 'email': email, 'password': password};
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    lastResetEmail = email;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  Future<void> updateUserPhotoUrl({required String url}) async {
    lastPhotoUrl = url;
  }

  @override
  Future<void> updateUserName({required String newName}) async {
    lastNewName = newName;
  }

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    return profileToReturn;
  }
}

void main() {
  late FakeAuthRepository repo;

  setUp(() {
    repo = FakeAuthRepository();
  });

  test('LoginUseCase calls repository.login', () async {
    final useCase = LoginUseCase(repo);

    await useCase.call('a@b.com', 'pass');

    expect(repo.lastLoginEmail, 'a@b.com');
    expect(repo.lastLoginPassword, 'pass');
  });

  test('SignUpUseCase calls repository.signUp', () async {
    final useCase = SignUpUseCase(repo);

    await useCase.call(name: 'n', email: 'a@b.com', password: 'p');

    expect(repo.lastSignUpArgs, isNotNull);
    expect(repo.lastSignUpArgs!['name'], 'n');
  });

  test('SendPasswordResetEmailUseCase calls repository', () async {
    final useCase = SendPasswordResetEmailUseCase(repo);

    await useCase.call(email: 'a@b.com');

    expect(repo.lastResetEmail, 'a@b.com');
  });

  test('LogoutUseCase calls repository.logout', () async {
    final useCase = LogoutUseCase(repo);

    await useCase.call();

    expect(repo.logoutCalled, isTrue);
  });

  test(
    'UpdateUserPhotoUrlUseCase calls repository.updateUserPhotoUrl',
    () async {
      final useCase = UpdateUserPhotoUrlUseCase(repo);

      await useCase.call(url: 'u');

      expect(repo.lastPhotoUrl, 'u');
    },
  );

  test('UpdateUserNameUseCase calls repository.updateUserName', () async {
    final useCase = UpdateUserNameUseCase(repo);

    await useCase.call(newName: 'n');

    expect(repo.lastNewName, 'n');
  });

  test(
    'GetCurrentUserProfileUseCase returns profile from repository',
    () async {
      final useCase = GetCurrentUserProfileUseCase(repo);
      final profile = UserProfile(uid: '1', name: 'n', email: 'a@b.com');
      repo.profileToReturn = profile;

      final result = await useCase.call();

      expect(result, profile);
    },
  );
}
