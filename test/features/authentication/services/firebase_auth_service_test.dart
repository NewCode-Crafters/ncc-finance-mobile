import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_application_1/features/authentication/services/firebase_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late FirebaseAuthService authService;
  const testUserId = 'test_uid_123';

  setUp(() {
    final mockUser = MockUser(uid: testUserId, email: 'new@test.com');
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    // We need to configure fake_cloud_firestore to handle server timestamps.
    fakeFirestore = FakeFirebaseFirestore();

    authService = FirebaseAuthService(
      firebaseAuth: mockAuth,
      firestore: fakeFirestore,
    );
  });

  test(
    'signUp should create a user and a default checking account balance',
    () async {
      await authService.signUp(
        name: 'New User',
        email: 'new@test.com',
        password: 'password123',
      );

      final uid = mockAuth.currentUser?.uid ?? 'test_uid_123';
      final balancesSnapshot = await fakeFirestore
          .collection('users')
          .doc(uid)
          .collection('balances')
          .get();

      expect(balancesSnapshot.docs.length, 1);

      final balanceData = balancesSnapshot.docs.first.data();
      expect(balanceData['accountType'], 'CHECKING_ACCOUNT');
      expect(balanceData['amount'], 0.0);
    },
  );

  test(
    'updateUserPhotoUrl should update the photoUrl field in Firestore',
    () async {
      await fakeFirestore.collection('users').doc(testUserId).set({
        'name': 'Test User',
        'email': 'test@test.com',
      });

      const newPhotoUrl = 'http://example.com/photo.jpg';

      await authService.updateUserPhotoUrl(url: newPhotoUrl);

      final userDoc = await fakeFirestore
          .collection('users')
          .doc(testUserId)
          .get();

      expect(userDoc.exists, isTrue);
      expect(userDoc.data()?['photoUrl'], newPhotoUrl);
    },
  );
}
