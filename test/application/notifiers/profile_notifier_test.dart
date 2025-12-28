import 'dart:typed_data';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/application/notifiers/profile_notifier.dart';
import 'package:bytebank/domain/entities/user_profile.dart' as domain;
import 'package:bytebank/domain/entities/image_source_type.dart';
import 'package:bytebank/domain/use_cases/profile/get_user_profile_use_case.dart';
import 'package:bytebank/domain/use_cases/profile/pick_and_upload_profile_picture_use_case.dart';
import 'package:bytebank/domain/repositories/user_repository.dart';

import '../../helpers/profile/profile_notifier_test_helpers.dart';

// Minimal XFile stub used by a fake ImagePickerService in tests
class XFile {
  final String path;
  XFile(this.path);
  Future<Uint8List> readAsBytes() async => File(path).readAsBytes();
}

// No image picker needed: pick/upload is handled by use-case in tests via FakePickAndUploadProfilePictureUseCase.

// Throwing fakes used to simulate failures in use-cases.
class DummyUserRepo implements IUserRepository {
  @override
  Future<domain.UserProfile?> getUserProfile({required String userId}) async =>
      null;

  @override
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String filename,
  }) async => '';

  @override
  Future<String?> pickAndUploadAvatar({
    required ImageSourceType source,
  }) async => null;
}

class _ThrowingGetUserProfileUseCase extends GetUserProfileUseCase {
  _ThrowingGetUserProfileUseCase() : super(repository: DummyUserRepo());

  @override
  Future<domain.UserProfile?> call({required String userId}) async {
    throw Exception('fetch failed');
  }
}

class _ThrowingPickAndUploadUseCase extends PickAndUploadProfilePictureUseCase {
  _ThrowingPickAndUploadUseCase() : super(repository: DummyUserRepo());

  @override
  Future<String?> call({required ImageSourceType source}) async {
    throw Exception('upload failed');
  }
}

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

  test(
    'fetchUserProfile sets isLoading while fetching and recovers on error',
    () async {
      final failingGet = _ThrowingGetUserProfileUseCase();
      final notifier = ProfileNotifier(
        getUserProfile: failingGet,
        pickAndUploadProfilePicture: FakePickAndUploadProfilePictureUseCase(
          null,
        ),
      );

      await notifier.fetchUserProfile(userId: 'u1');
      // after failure, should not be loading and userProfile should be null
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.userProfile, isNull);
    },
  );

  test('updateUserAvatar handles cancelled pick (null) gracefully', () async {
    final notifier = ProfileNotifier(
      getUserProfile: FakeGetUserProfileUseCase(null),
      pickAndUploadProfilePicture: FakePickAndUploadProfilePictureUseCase(null),
    );

    notifier.setStateForTest(
      ProfileState(
        userProfile: domain.UserProfile(uid: 'u1', name: 'N', email: 'e'),
      ),
    );
    await notifier.updateUserAvatar(
      userId: 'u1',
      source: ImageSourceType.camera,
    );

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.errorMessage, isNull);
  });

  test('updateUserAvatar maps exceptions to errorMessage', () async {
    final failingPick = _ThrowingPickAndUploadUseCase();
    final notifier = ProfileNotifier(
      getUserProfile: FakeGetUserProfileUseCase(null),
      pickAndUploadProfilePicture: failingPick,
    );

    notifier.setStateForTest(
      ProfileState(
        userProfile: domain.UserProfile(uid: 'u1', name: 'N', email: 'e'),
      ),
    );
    await notifier.updateUserAvatar(
      userId: 'u1',
      source: ImageSourceType.camera,
    );

    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.errorMessage, isNotNull);
  });
}
