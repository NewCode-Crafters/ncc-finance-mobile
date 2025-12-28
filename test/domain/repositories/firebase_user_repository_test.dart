import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:bytebank/infrastructure/repositories/firebase_user_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_storage/firebase_storage.dart';
// Mock for FirebaseStorage

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirebaseUserRepository profileService;

  const userId = 'test_user_id';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    profileService = FirebaseUserRepository(firestore: fakeFirestore);
  });

  test(
    'getUserProfile should return a UserProfile object for a given user',
    () async {
      await fakeFirestore.collection('users').doc(userId).set({
        'name': 'Joelton Matos',
        'email': 'joelton@ncc.com',
        'photoUrl': 'http://example.com/photo.jpg',
      });

      final userProfile = await profileService.getUserProfile(userId: userId);

      expect(userProfile, isNotNull);
      expect(userProfile!.name, 'Joelton Matos');
      expect(userProfile.email, 'joelton@ncc.com');
      expect(userProfile.photoUrl, 'http://example.com/photo.jpg');
    },
  );
}
