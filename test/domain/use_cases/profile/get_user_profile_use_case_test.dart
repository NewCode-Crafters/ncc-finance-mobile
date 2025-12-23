import 'package:bytebank/domain/entities/user_profile.dart';
import 'package:bytebank/domain/repositories/user_repository.dart';
import 'package:bytebank/domain/use_cases/profile/get_user_profile_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepo implements IUserRepository {
  final UserProfile? profile;
  FakeRepo(this.profile);

  @override
  Future<UserProfile?> getUserProfile({required String userId}) async =>
      profile;

  @override
  Future<String> uploadAvatar({
    required String userId,
    required bytes,
    required String filename,
  }) {
    throw UnimplementedError();
  }
  @override
  Future<String?> pickAndUploadAvatar({required source}) async {
    return null;
  }
}

void main() {
  test('get user profile returns profile from repo', () async {
    final now = DateTime.now();
    final profile = UserProfile(
      uid: 'u1',
      name: 'Alice',
      email: 'a@a.com',
      photoUrl: null,
      createdAt: now,
    );

    final repo = FakeRepo(profile);
    final usecase = GetUserProfileUseCase(repository: repo);

    final result = await usecase.call(userId: 'u1');
    expect(result, profile);
  });
}
