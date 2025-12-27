import 'package:bytebank/domain/entities/user_profile.dart';
import 'package:bytebank/domain/repositories/auth_repository.dart';

class GetCurrentUserProfileUseCase {
  final AuthRepository _repository;

  GetCurrentUserProfileUseCase(this._repository);

  Future<UserProfile?> call() async {
    return _repository.getCurrentUserProfile();
  }
}
