import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_auth/firebase_auth.dart' show UserCredential;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../../test_helpers/fake_firestore_helpers.dart';
import 'package:bytebank/infrastructure/repositories/firebase_auth_repository.dart';
import 'package:bytebank/infrastructure/data_sources/remote/firebase_auth_data_source.dart';

class FakeUser implements fb.User {
  @override
  final String uid;
  FakeUser(this.uid);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUserCredential implements UserCredential {
  final fb.User _user;
  FakeUserCredential(this._user);
  @override
  fb.User? get user => _user;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFirebaseAuthDataSource implements FirebaseAuthDataSource {
  FakeUser? _user;
  final FakeFirebaseFirestore _firestore;

  FakeFirebaseAuthDataSource({FakeFirebaseFirestore? firestore})
    : _firestore = firestore ?? FakeFirebaseFirestore();

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _user = FakeUser('uid_test');
    return FakeUserCredential(_user!);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _user = FakeUser('uid_test');
    return FakeUserCredential(_user!);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> signOut() async => _user = null;

  @override
  fb.User? get currentUser => _user;

  @override
  dynamic get firestore => _firestore;
}

void main() {
  test('signUp completes without throwing', () async {
    final ds = FakeFirebaseAuthDataSource();
    final repo = FirebaseAuthRepository(ds);

    await repo.signUp(name: 'name', email: 'e@e.com', password: 'p');
  });

  test('getCurrentUserProfile returns null when no user', () async {
    final ds = FakeFirebaseAuthDataSource();
    final repo = FirebaseAuthRepository(ds);

    final profile = await repo.getCurrentUserProfile();
    expect(profile, isNull);
  });

  test('getCurrentUserProfile returns profile when doc exists', () async {
    final fakeFs = makeFakeFirestore();
    final ds = FakeFirebaseAuthDataSource(firestore: fakeFs);
    final repo = FirebaseAuthRepository(ds);

    // Simulate a signed-in user and a user document
    final cred = await ds.createUserWithEmailAndPassword(
      email: 'a@b.com',
      password: 'p',
    );
    final user = cred.user!;

    // write a user doc using the shared helper
    await seedUserDoc(fakeFs, user.uid, {
      'name': 'Test',
      'email': 'a@b.com',
      'photoUrl': null,
    });

    final profile = await repo.getCurrentUserProfile();
    expect(profile, isNotNull);
    expect(profile!.uid, user.uid);
    expect(profile.name, 'Test');
  });
}
