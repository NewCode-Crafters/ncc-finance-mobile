import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:bytebank/domain/entities/user_profile.dart';
import 'package:bytebank/domain/repositories/auth_repository.dart';
import 'package:bytebank/domain/exceptions/auth_exceptions.dart';
import 'package:bytebank/infrastructure/data_sources/remote/firebase_auth_data_source.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  FirebaseAuthRepository(this._dataSource);

  @override
  Future<void> login(String email, String password) async {
    try {
      await _dataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw InvalidCredentialsException();
      } else {
        throw Exception('Ocorreu um erro desconhecido: ${e.code}');
      }
    } catch (e) {
      throw Exception('Ocorreu um erro desconhecido');
    }
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _dataSource.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user == null) {
        throw Exception(
          'Falha na criação do usuário, por favor, tente novamente mais tarde.',
        );
      }

      final firestore = _dataSource.firestore as FirebaseFirestore;
      final userDocRef = firestore.collection('users').doc(user.uid);

      await userDocRef.set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await userDocRef.collection('balances').add({
        'accountType': 'CHECKING_ACCOUNT',
        'amount': 0.0,
        'currency': 'BRL',
      });
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseException();
      } else {
        throw Exception('Ocorreu um erro desconhecido do Firebase: ${e.code}');
      }
    } catch (e) {
      throw Exception('Ocorreu um erro desconhecido');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      return _dataSource.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw Exception('Ocorreu um erro desconhecido do Firebase: ${e.code}');
    } catch (e) {
      throw Exception('Ocorreu um erro desconhecido.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      return _dataSource.signOut();
    } catch (e) {
      throw Exception('Ocorreu um erro durante o logout.');
    }
  }

  @override
  Future<void> updateUserPhotoUrl({required String url}) async {
    try {
      final user = _dataSource.currentUser;
      if (user == null) {
        throw Exception('Nenhum usuário autenticado encontrado.');
      }
      final firestore = _dataSource.firestore as FirebaseFirestore;
      await firestore.collection('users').doc(user.uid).update({
        'photoUrl': url,
      });
    } catch (e) {
      throw Exception('Falha ao atualizar a URL da foto.');
    }
  }

  @override
  Future<void> updateUserName({required String newName}) async {
    try {
      final user = _dataSource.currentUser;
      if (user == null) {
        throw Exception(
          'Não é possível atualizar o nome de um usuário não autenticado.',
        );
      }
      final firestore = _dataSource.firestore as FirebaseFirestore;
      await firestore.collection('users').doc(user.uid).update({
        'name': newName,
      });
    } catch (e) {
      throw Exception('Falha ao atualizar o nome do usuário.');
    }
  }

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _dataSource.currentUser;
    if (user == null) return null;

    final firestore = _dataSource.firestore as FirebaseFirestore;
    final doc = await firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    final map = doc.data();
    return UserProfile.fromMap(map ?? {}, uid: doc.id);
  }
}
