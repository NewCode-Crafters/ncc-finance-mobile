import 'package:bytebank/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<void> call(String email, String password) async {
    return _repository.login(email, password);
  }
}
