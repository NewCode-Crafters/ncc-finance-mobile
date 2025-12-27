import 'package:bytebank/domain/repositories/auth_repository.dart';

class UpdateUserNameUseCase {
  final AuthRepository _repository;

  UpdateUserNameUseCase(this._repository);

  Future<void> call({required String newName}) async {
    return _repository.updateUserName(newName: newName);
  }
}
