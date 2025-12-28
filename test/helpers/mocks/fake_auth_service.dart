import 'package:bytebank/domain/entities/user_profile.dart';

/// Lightweight fake used in widget tests to stand in for the old AuthService.
/// Records calls so tests can assert behavior without depending on mockito
/// generated files.
class FakeAuthService {
  String? lastUpdatedName;
  int updateUserNameCallCount = 0;

  Future<void> login(String email, String password) async {}

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {}

  Future<void> sendPasswordResetEmail({required String email}) async {}

  Future<void> logout() async {}

  Future<void> updateUserName({required String newName}) async {
    lastUpdatedName = newName;
    updateUserNameCallCount += 1;
  }

  Future<void> updateUserPhotoUrl({required String url}) async {}

  Future<UserProfile?> getCurrentUserProfile() async => null;
}
