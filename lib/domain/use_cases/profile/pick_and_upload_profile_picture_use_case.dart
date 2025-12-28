import 'package:bytebank/domain/repositories/user_repository.dart';
import 'package:bytebank/domain/entities/image_source_type.dart';

class PickAndUploadProfilePictureUseCase {
  final IUserRepository repository;

  PickAndUploadProfilePictureUseCase({required this.repository});

  Future<String?> call({required ImageSourceType source}) async {
    return await repository.pickAndUploadAvatar(source: source);
  }
}
