import 'package:bytebank/domain/repositories/user_repository.dart';
import 'package:bytebank/core/services/image_picker_service.dart';

class PickAndUploadProfilePictureUseCase {
  final IUserRepository repository;

  PickAndUploadProfilePictureUseCase({required this.repository});

  Future<String?> call({required ImageSourceType source}) async {
    return await repository.pickAndUploadAvatar(source: source);
  }
}
