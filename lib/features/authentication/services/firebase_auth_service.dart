import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/features/authentication/services/auth_exceptions.dart';
import 'package:flutter_application_1/features/authentication/services/auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService(this._firebaseAuth);

  @override
  Future<void> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw InvalidCredentialsException();
      } else {
        throw Exception('An unknown error occurred: ${e.code}');
      }
    } catch (e) {
      throw Exception('An unknown error occurred');
    }
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    // TODO: implement signUp
    throw UnimplementedError();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    // TODO: implement sendPasswordResetEmail
    throw UnimplementedError();
  }
  
  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }
}
