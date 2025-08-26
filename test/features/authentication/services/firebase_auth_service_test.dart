import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_application_1/features/authentication/services/firebase_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late FirebaseAuthService authService;

  setUp(() {
    final mockUser = MockUser(uid: 'test_uid_123', email: 'new@test.com');
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
}
