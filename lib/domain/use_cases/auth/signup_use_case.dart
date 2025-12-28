import 'package:bytebank/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  Future<void> call({required String name, required String email, required String password}) async {
    return _repository.signUp(name: name, email: email, password: password);
  }
}
