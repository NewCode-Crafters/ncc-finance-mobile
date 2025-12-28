import 'dart:typed_data';

import 'package:bytebank/domain/repositories/user_repository.dart';
import 'package:bytebank/domain/entities/user_profile.dart';
import 'package:bytebank/domain/use_cases/profile/upload_profile_picture_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepo implements IUserRepository {
  final String url;
  FakeRepo(this.url);

  @override
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String filename,
  }) async => url;

  @override
  Future<UserProfile?> getUserProfile({required String userId}) async {
    throw UnimplementedError();
  }
  @override
  Future<String?> pickAndUploadAvatar({required source}) async {
    return null;
  }
}

void main() {
  test('upload returns url', () async {
    final repo = FakeRepo('http://url');
    final usecase = UploadProfilePictureUseCase(repository: repo);

    final bytes = Uint8List.fromList([1, 2, 3]);
    final url = await usecase.call(
      userId: 'u1',
      bytes: bytes,
      filename: 'a.jpg',
    );
    expect(url, 'http://url');
  });
}
