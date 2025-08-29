import 'package:bytebank/features/profile/models/user_profile.dart';
import 'package:bytebank/features/profile/notifers/profile_notifier.dart';
import 'package:bytebank/features/profile/services/profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'profile_notifier_test.mocks.dart';

@GenerateMocks([ProfileService])
void main() {
  late MockProfileService mockProfileService;
  late ProfileNotifier profileNotifier;

  setUp(() {
    mockProfileService = MockProfileService();
    profileNotifier = ProfileNotifier(mockProfileService);
  });

  test('fetchUserProfile should update state with the user profile', () async {
    final fakeProfile = UserProfile(
      uid: 'test_uid',
      name: 'Joelton Matos',
      email: 'joelton@ncc.com',
    );

    when(
      mockProfileService.getUserProfile(userId: anyNamed('userId')),
    ).thenAnswer((_) async => fakeProfile);

    await profileNotifier.fetchUserProfile(userId: 'test_uid');

    expect(profileNotifier.state.userProfile, fakeProfile);
    expect(profileNotifier.state.isLoading, isFalse);
  });
}
