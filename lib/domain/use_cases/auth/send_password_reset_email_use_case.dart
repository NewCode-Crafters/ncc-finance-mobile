import 'package:bytebank/domain/repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase {
  final AuthRepository _repository;

  SendPasswordResetEmailUseCase(this._repository);

  Future<void> call({required String email}) async {
    return _repository.sendPasswordResetEmail(email: email);
  }
}
