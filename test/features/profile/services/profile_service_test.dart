import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_application_1/features/profile/services/profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_storage/firebase_storage.dart';
// Mock for FirebaseStorage

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ProfileService profileService;
  late MockFirebaseStorage mockStorage;
  late MockFirebaseAuth mockAuth;
  const userId = 'test_user_id';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    mockAuth = MockFirebaseAuth(mockUser: MockUser(uid: userId));
    profileService = ProfileService(
      firestore: fakeFirestore,
      storage: mockStorage,
      firebaseAuth: mockAuth,
    );
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
