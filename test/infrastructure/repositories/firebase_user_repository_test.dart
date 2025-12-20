import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/infrastructure/repositories/firebase_user_repository.dart';
import 'package:bytebank/domain/entities/user_profile.dart';

class FakeStorageUploader implements StorageUploader {
  final String baseUrl;
  FakeStorageUploader({this.baseUrl = 'https://fake.storage'});

  @override
  Future<String> upload(String path, Uint8List bytes) async {
    return '$baseUrl/$path';
  }
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FakeStorageUploader mockUploader;
  late FirebaseUserRepository repo;

  const userId = 'u1';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockUploader = FakeStorageUploader();
    repo = FirebaseUserRepository(
      firestore: fakeFirestore,
      uploader: mockUploader,
    );
  });

  test('getUserProfile returns UserProfile when doc exists', () async {
    await fakeFirestore.collection('users').doc(userId).set({
      'name': 'Alice',
      'email': 'alice@example.com',
      'photoUrl': 'http://old',
      'createdAt': DateTime.now(),
    });

    final profile = await repo.getUserProfile(userId: userId);

    expect(profile, isNotNull);
    expect(profile, isA<UserProfile>());
    expect(profile!.uid, userId);
    expect(profile.name, 'Alice');
    expect(profile.email, 'alice@example.com');
  });

  test(
    'uploadAvatar uploads bytes, updates user doc and returns url',
    () async {
      // Create initial doc
      await fakeFirestore.collection('users').doc(userId).set({
        'name': 'Bob',
        'email': 'bob@example.com',
      });

      final bytes = Uint8List.fromList([1, 2, 3]);
      final url = await repo.uploadAvatar(
        userId: userId,
        bytes: bytes,
        filename: 'profile.jpg',
      );

      expect(url, contains('https://fake.storage'));

      final doc = await fakeFirestore.collection('users').doc(userId).get();
      expect(doc.data()?['photoUrl'], url);
    },
  );
}
