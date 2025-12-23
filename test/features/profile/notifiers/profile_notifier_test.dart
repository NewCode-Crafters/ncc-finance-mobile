import 'dart:typed_data';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/application/notifiers/profile_notifier.dart';
import 'package:bytebank/domain/use_cases/profile/get_user_profile_use_case.dart';
import 'package:bytebank/domain/use_cases/profile/pick_and_upload_profile_picture_use_case.dart';
import 'package:bytebank/domain/entities/user_profile.dart' as domain;
import 'package:bytebank/core/services/image_picker_service.dart';

import 'package:bytebank/domain/repositories/user_repository.dart';
import 'package:bytebank/domain/entities/user_profile.dart';
import 'dart:typed_data' as typed;

class _DummyRepo implements IUserRepository {
  @override
  Future<UserProfile?> getUserProfile({required String userId}) async => null;

  @override
  Future<String> uploadAvatar({
    required String userId,
    required typed.Uint8List bytes,
    required String filename,
  }) async => '';

  @override
  Future<String?> pickAndUploadAvatar({
    required ImageSourceType source,
  }) async => null;
}

class FakeGetUserProfileUseCase extends GetUserProfileUseCase {
  final domain.UserProfile? profile;
  FakeGetUserProfileUseCase(this.profile) : super(repository: _DummyRepo());

  @override
  Future<domain.UserProfile?> call({required String userId}) async => profile;
}

class FakePickAndUploadProfilePictureUseCase
    extends PickAndUploadProfilePictureUseCase {
  final String? url;
  FakePickAndUploadProfilePictureUseCase(this.url)
    : super(repository: _DummyRepo());

  @override
  Future<String?> call({required ImageSourceType source}) async => url;
}

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

      // initialize state with a feature model
      notifier.setStateForTest(
        ProfileState(
          userProfile: domain.UserProfile(
            uid: 'u1',
            name: 'Bob',
            email: 'b@b.com',
            photoUrl: null,
            createdAt: DateTime.now(),
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
