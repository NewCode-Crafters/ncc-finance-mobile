import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_application_1/features/profile/services/profile_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ProfileService profileService;
  const userId = 'test_user_id';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    profileService = ProfileService(firestore: fakeFirestore);
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
