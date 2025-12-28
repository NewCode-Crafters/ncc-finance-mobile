import 'dart:typed_data';

import 'package:bytebank/domain/entities/user_profile.dart';
import 'package:bytebank/domain/entities/image_source_type.dart';

abstract class IUserRepository {
  /// Fetch the `UserProfile` for the given `userId`, or `null` if not found.
  Future<UserProfile?> getUserProfile({required String userId});

  /// Uploads an avatar image for the given user and returns the download URL.
  /// Implementations are free to accept bytes (for testability) and a filename/path.
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String filename,
  });

  /// Convenience method: pick an image and upload it for the currently
  /// authenticated user. Returns the download URL or `null` if picking was
  /// cancelled.
  Future<String?> pickAndUploadAvatar({required ImageSourceType source});
}
