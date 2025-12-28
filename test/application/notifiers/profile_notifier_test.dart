import 'dart:typed_data';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/application/notifiers/profile_notifier.dart';
import 'package:bytebank/domain/entities/user_profile.dart' as domain;
import 'package:bytebank/domain/entities/image_source_type.dart';

import '../../helpers/profile/profile_notifier_test_helpers.dart';

// Minimal XFile stub used by a fake ImagePickerService in tests
class XFile {
  final String path;
  XFile(this.path);
  Future<Uint8List> readAsBytes() async => File(path).readAsBytes();
}

// No image picker needed: pick/upload is handled by use-case in tests via FakePickAndUploadProfilePictureUseCase.

void main() {
  test(
    'fetchUserProfile loads domain profile and maps to feature model',
    () async {
      final now = DateTime.now();
      final domainProfile = domain.UserProfile(
        uid: 'u1',
        name: 'Alice',
        email: 'a@a.com',
        photoUrl: null,
        createdAt: now,
      );

      final notifier = ProfileNotifier(
        getUserProfile: FakeGetUserProfileUseCase(domainProfile),
        pickAndUploadProfilePicture: FakePickAndUploadProfilePictureUseCase(
          null,
        ),
      );

      await notifier.fetchUserProfile(userId: 'u1');

      final result = notifier.state.userProfile;
      expect(result, isNotNull);
      expect(result!.uid, 'u1');
      expect(result.name, 'Alice');
      expect(result.email, 'a@a.com');
    },
  );

  test(
    'updateUserAvatar picks file, uploads bytes and updates state',
    () async {
      final tmp = File('${Directory.systemTemp.path}/tmp_profile.jpg');
      await tmp.writeAsBytes([1, 2, 3]);

      final notifier = ProfileNotifier(
        getUserProfile: FakeGetUserProfileUseCase(null),
        pickAndUploadProfilePicture: FakePickAndUploadProfilePictureUseCase(
          'http://uploaded/url.jpg',
        ),
      );

      // initialize state with a domain model then map to feature for notifier
      final domainInitial = domain.UserProfile(
        uid: 'u1',
        name: 'Bob',
        email: 'b@b.com',
        photoUrl: null,
      );

      notifier.setStateForTest(
        ProfileState(
          userProfile: domain.UserProfile(
            uid: domainInitial.uid,
            name: domainInitial.name,
            email: domainInitial.email,
            photoUrl: domainInitial.photoUrl,
          ),
        ),
      );

      await notifier.updateUserAvatar(
        userId: 'u1',
        source: ImageSourceType.gallery,
      );

      expect(notifier.state.isLoading, false);
      expect(notifier.state.userProfile?.photoUrl, 'http://uploaded/url.jpg');

      await tmp.delete();
    },
  );
}
