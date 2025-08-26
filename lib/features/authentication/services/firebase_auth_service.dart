import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/features/authentication/services/auth_exceptions.dart';
import 'package:flutter_application_1/features/authentication/services/auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

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
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception('User creation failed, please try again later.');
      }

      final userDocRef = _firestore.collection("users").doc(user.uid);

      await userDocRef.set({
        "name": name,
        "email": email,
        "createdAt": FieldValue.serverTimestamp(),
      });

      await userDocRef.collection("balances").add({
        "accountType": "CHECKING_ACCOUNT",
        "amount": 0.0,
        "currency": "BRL",
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseException();
      } else {
        throw Exception('An unknown Firebase error occurred: ${e.code}');
      }
    } catch (e) {
      throw Exception('An unknown error occurred');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('An unknown Firebase error occurred: ${e.code}');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('An error occurred during logout.');
    }
  }

  @override
  Future<void> updateUserPhotoUrl({required String url}) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw Exception("No authenticated user found.");
      }

      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': url,
      });
    } catch (e) {
      throw Exception('Failed to update photo URL.');
    }
  }
}
