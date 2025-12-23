import 'package:bytebank/domain/entities/user_profile.dart';
import 'package:bytebank/domain/repositories/user_repository.dart';

class GetUserProfileUseCase {
  final IUserRepository repository;

  GetUserProfileUseCase({required this.repository});

  Future<UserProfile?> call({required String userId}) async {
    return await repository.getUserProfile(userId: userId);
  }
}
