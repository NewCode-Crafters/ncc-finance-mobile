import 'package:bytebank/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<void> call() async {
    return _repository.logout();
  }
}
