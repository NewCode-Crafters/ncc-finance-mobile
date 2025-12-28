import 'dart:typed_data';

import 'package:bytebank/domain/use_cases/profile/get_user_profile_use_case.dart';
import 'package:bytebank/domain/use_cases/profile/pick_and_upload_profile_picture_use_case.dart';
import 'package:bytebank/domain/entities/user_profile.dart';
import 'package:bytebank/domain/repositories/user_repository.dart';
import 'package:bytebank/domain/entities/image_source_type.dart';

class _DummyRepo implements IUserRepository {
  @override
  Future<UserProfile?> getUserProfile({required String userId}) async => null;

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

class FakeGetUserProfileUseCase extends GetUserProfileUseCase {
  final UserProfile? _result;
  FakeGetUserProfileUseCase(this._result) : super(repository: _DummyRepo());

  @override
  Future<UserProfile?> call({required String userId}) async => _result;
}

class FakePickAndUploadProfilePictureUseCase
    extends PickAndUploadProfilePictureUseCase {
  final String? _result;
  FakePickAndUploadProfilePictureUseCase(this._result)
    : super(repository: _DummyRepo());

  @override
  Future<String?> call({required ImageSourceType source}) async => _result;
}
