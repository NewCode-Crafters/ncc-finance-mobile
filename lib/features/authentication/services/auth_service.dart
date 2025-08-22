abstract class AuthService {
  Future<void> login(String email, String password);

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail({required String email});
  Future<void> logout();
}
