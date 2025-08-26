import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/features/profile/models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore;

  ProfileService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserProfile?> getUserProfile({required String userId}) async {
    final doc = await _firestore.collection('users').doc(userId).get();

    if (doc.exists) {
      return UserProfile.fromFirestore(doc);
    }
    return null;
  }
}
