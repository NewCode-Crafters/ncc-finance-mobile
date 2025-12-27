import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_auth/firebase_auth.dart' show UserCredential;
import 'package:bytebank/infrastructure/repositories/firebase_auth_repository.dart';
import 'package:bytebank/infrastructure/data_sources/remote/firebase_auth_data_source.dart';

// Minimal in-memory Firestore-like classes used only for tests.
class _InMemoryFirestore {
  final Map<String, Map<String, dynamic>> _store = {};

  _Collection collection(String name) => _Collection(_store, name);
}

class _Collection {
  final Map<String, Map<String, dynamic>> _store;
  final String name;
  _Collection(this._store, this.name);

  _Doc doc(String id) => _Doc(name, id, _store);
}

class _Doc {
  final String collectionName;
  final String id;
  final Map<String, Map<String, dynamic>> _store;
  _Doc(this.collectionName, this.id, this._store);

  Future<void> set(Map<String, dynamic> data) async => _store['$collectionName/$id'] = data;

  Future<void> update(Map<String, dynamic> data) async {
    final key = '$collectionName/$id';
    _store[key] = {...?_store[key], ...data};
  }

  Future<_Snapshot> get() async => _Snapshot(id, _store['$collectionName/$id']);

  _SubCollection collection(String name) => _SubCollection(_store, '$collectionName/$id/$name');
}

class _SubCollection {
  final Map<String, Map<String, dynamic>> _store;
  final String path;
  _SubCollection(this._store, this.path);

  Future<void> add(Map<String, dynamic> data) async {
    final key = '$path/${_store.length}';
    _store[key] = data;
  }
}

class _Snapshot {
  final String id;
  final Map<String, dynamic>? dataMap;
  _Snapshot(this.id, this.dataMap);
  bool get exists => dataMap != null;
  Map<String, dynamic>? data() => dataMap;
}

class _FakeUser implements fb.User {
  @override
  final String uid;
  _FakeUser(this.uid);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserCredential implements UserCredential {
  final fb.User _user;
  _FakeUserCredential(this._user);
  @override
  fb.User? get user => _user;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFirebaseAuthDataSource implements FirebaseAuthDataSource {
  _FakeUser? _user;
  final _InMemoryFirestore inMemory = _InMemoryFirestore();

  @override
  Future<UserCredential> createUserWithEmailAndPassword({required String email, required String password}) async {
    _user = _FakeUser('uid_test');
    return _FakeUserCredential(_user!);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) async {
    _user = _FakeUser('uid_test');
    return _FakeUserCredential(_user!);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> signOut() async => _user = null;

  @override
  fb.User? get currentUser => _user;

  @override
  dynamic get firestore => inMemory;
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
    final ds = FakeFirebaseAuthDataSource();
    final repo = FirebaseAuthRepository(ds);

    // Simulate a signed-in user and a user document
    final cred = await ds.createUserWithEmailAndPassword(email: 'a@b.com', password: 'p');
    final user = cred.user!;
    // write a user doc
    final fs = ds.firestore as _InMemoryFirestore;
    await fs.collection('users').doc(user.uid).set({'name': 'Test', 'email': 'a@b.com', 'photoUrl': null});

    final profile = await repo.getCurrentUserProfile();
    expect(profile, isNotNull);
    expect(profile!.uid, user.uid);
    expect(profile.name, 'Test');
  });
}
