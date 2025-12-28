import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Data source that exposes lower-level FirebaseAuth and Firestore operations.
abstract class FirebaseAuthDataSource {
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> signOut();
  User? get currentUser;

  /// Firestore client instance. Kept as `dynamic` to allow test injection
  /// of a lightweight fake in unit/integration tests.
  dynamic get firestore;
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _firebaseAuth.sendPasswordResetEmail(email: email);

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  FirebaseFirestore get firestore => _firestore;
}
