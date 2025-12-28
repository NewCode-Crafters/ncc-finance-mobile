import 'dart:typed_data';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:bytebank/domain/entities/image_source_type.dart';
import 'package:bytebank/infrastructure/services/image_picker_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bytebank/domain/entities/user_profile.dart';
import 'package:bytebank/domain/repositories/user_repository.dart';
import 'package:bytebank/infrastructure/mappers/user_profile_mapper.dart';

class FirebaseUserRepository implements IUserRepository {
  final FirebaseFirestore _firestore;
  final UserProfileMapper _mapper;
  final StorageUploader _uploader;

  FirebaseUserRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    StorageUploader? uploader,
    UserProfileMapper? mapper,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _mapper = mapper ?? const UserProfileMapper(),
       _uploader = uploader ?? FirebaseStorageUploader(storage: storage);

  @override
  Future<UserProfile?> getUserProfile({required String userId}) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return _mapper.toDomain(doc: doc);
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String filename,
  }) async {
    final path = 'avatars/$userId/$filename';

    final downloadUrl = await _uploader.upload(path, bytes);

    await _firestore.collection('users').doc(userId).update({
      'photoUrl': downloadUrl,
    });

    return downloadUrl;
  }

  /// Convenience method that mirrors the legacy `ProfileService.pickAndUploadAvatar`.
  ///
  /// Picks an image using `ImagePickerService`, uploads it to storage and
  /// persists the `photoUrl` on the user's Firestore document. Returns the
  /// download URL or `null` if the user cancelled image picking.
  Future<String?> _pickAndUploadAvatarInternal({
    required ImageSourceType source,
    FirebaseAuth? firebaseAuth,
    ImagePickerService? imagePicker,
    String filename = 'profile.jpg',
  }) async {
    final auth = firebaseAuth ?? FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user == null) throw Exception('No authenticated user found.');

    final picker = imagePicker ?? ImagePickerService();
    final imageFile = await picker.pickImage(source: source);

    if (imageFile == null) return null;

    final bytes = await File(imageFile.path).readAsBytes();

    return await uploadAvatar(
      userId: user.uid,
      bytes: bytes,
      filename: filename,
    );
  }

  // Implement interface compatibility: pickAndUploadAvatar without optional params
  @override
  Future<String?> pickAndUploadAvatar({required ImageSourceType source}) async {
    return await _pickAndUploadAvatarInternal(source: source);
  }
}

abstract class StorageUploader {
  Future<String> upload(String path, Uint8List bytes);
}

class FirebaseStorageUploader implements StorageUploader {
  final FirebaseStorage? storage;

  FirebaseStorageUploader({this.storage});

  @override
  Future<String> upload(String path, Uint8List bytes) async {
    final ref = (storage ?? FirebaseStorage.instance).ref().child(path);
    final uploadTask = ref.putData(bytes);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }
}
