import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// Helper factory for tests that need a fake Firestore instance.
FakeFirebaseFirestore makeFakeFirestore() => FakeFirebaseFirestore();

/// Seed a minimal user document into `fakeFs` for tests.
Future<void> seedUserDoc(
  FakeFirebaseFirestore fakeFs,
  String userId,
  Map<String, dynamic> data,
) async {
  await fakeFs.collection('users').doc(userId).set(data);
}
