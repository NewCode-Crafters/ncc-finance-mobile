import 'package:bytebank/domain/repositories/auth_repository.dart';

class UpdateUserPhotoUrlUseCase {
  final AuthRepository _repository;

  UpdateUserPhotoUrlUseCase(this._repository);

  Future<void> call({required String url}) async {
    return _repository.updateUserPhotoUrl(url: url);
  }
}
