import 'dart:typed_data';

import 'package:bytebank/domain/repositories/user_repository.dart';

class UploadProfilePictureUseCase {
  final IUserRepository repository;

  UploadProfilePictureUseCase({required this.repository});

  /// Upload file bytes and return the download URL.
  Future<String> call({
    required String userId,
    required Uint8List bytes,
    required String filename,
  }) async {
    return await repository.uploadAvatar(
      userId: userId,
      bytes: bytes,
      filename: filename,
    );
  }
}
