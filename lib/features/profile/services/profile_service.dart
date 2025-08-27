import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/core/services/image_picker_service.dart';
import 'package:flutter_application_1/features/profile/models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final ImagePickerService _imagePicker;
  final FirebaseAuth _firebaseAuth;

  ProfileService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    ImagePickerService? imagePicker,
    FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _imagePicker = imagePicker ?? ImagePickerService(),
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<UserProfile?> getUserProfile({required String userId}) async {
    final doc = await _firestore.collection('users').doc(userId).get();

    if (doc.exists) {
      return UserProfile.fromFirestore(doc);
    }
    return null;
  }

  Future<String?> pickAndUploadAvatar({required ImageSourceType source}) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw Exception("No authenticated user found.");
      }

      final imageFile = await _imagePicker.pickImage(source: source);

      // User canceled the picker
      if (imageFile == null) {
        return null;
      }

      // Upload to Firebase Storage
      final filePath = 'avatars/${user.uid}/profile.jpg';
      final ref = _storage.ref().child(filePath);
      await ref.putFile(File(imageFile.path));

      final downloadUrl = await ref.getDownloadURL();

      // Save the URL to the user's Firestore document
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar.');
    }
  }
}
