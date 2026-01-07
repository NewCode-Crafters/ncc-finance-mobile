import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/application/notifiers/profile_notifier.dart';
import 'package:bytebank/application/core/async_status.dart';
import 'package:bytebank/domain/entities/user_profile.dart';
import 'package:bytebank/domain/entities/image_source_type.dart';
import 'package:bytebank/domain/repositories/user_repository.dart';
import 'package:bytebank/domain/use_cases/profile/get_user_profile_use_case.dart';
import 'package:bytebank/domain/use_cases/profile/pick_and_upload_profile_picture_use_case.dart';

void main() {
  group('ProfileNotifier State Transitions', () {
    late ProfileNotifier notifier;
    late _FakeGetUserProfileUseCase fakeGetProfile;
    late _FakePickAndUploadUseCase fakePickAndUpload;

    setUp(() {
      fakeGetProfile = _FakeGetUserProfileUseCase();
      fakePickAndUpload = _FakePickAndUploadUseCase();
      notifier = ProfileNotifier(
        getUserProfile: fakeGetProfile,
        pickAndUploadProfilePicture: fakePickAndUpload,
      );
    });

    test('initial state is idle with no profile', () {
      expect(notifier.state.status, equals(AsyncStatus.idle));
      expect(notifier.state.userProfile, isNull);
      expect(notifier.state.errorMessage, isNull);
    });

    test('fetchUserProfile transitions from idle -> loading -> success',
        () async {
      final states = <AsyncStatus>[];

      notifier.addListener(() {
        states.add(notifier.state.status);
      });

      // Setup fake data
      fakeGetProfile.mockProfile = UserProfile(
        uid: 'user1',
        name: 'John Doe',
        email: 'john@example.com',
      );

      await notifier.fetchUserProfile(userId: 'user1');

      // Verify state transitions: loading -> success
      expect(states, equals([AsyncStatus.loading, AsyncStatus.success]));

      // Verify final state
      expect(notifier.state.status, equals(AsyncStatus.success));
      expect(notifier.state.userProfile, isNotNull);
      expect(notifier.state.userProfile!.uid, equals('user1'));
      expect(notifier.state.userProfile!.name, equals('John Doe'));
      expect(notifier.state.errorMessage, isNull);
    });

    test('fetchUserProfile transitions from idle -> loading -> error on failure',
        () async {
      final states = <AsyncStatus>[];

      notifier.addListener(() {
        states.add(notifier.state.status);
      });

      // Setup fake to throw error
      fakeGetProfile.shouldThrow = true;

      await notifier.fetchUserProfile(userId: 'user1');

      // Verify state transitions: loading -> error
      expect(states, equals([AsyncStatus.loading, AsyncStatus.error]));

      // Verify final state
      expect(notifier.state.status, equals(AsyncStatus.error));
      expect(notifier.state.userProfile, isNull);
      expect(notifier.state.errorMessage, isNotNull);
      expect(notifier.state.errorMessage, contains('Failed to fetch profile'));
    });

    test('fetchUserProfile skips fetch if already loading', () async {
      var callCount = 0;

      notifier.addListener(() {
        callCount++;
      });

      // Setup slow fetch
      fakeGetProfile.delayMs = 100;
      fakeGetProfile.mockProfile = UserProfile(
        uid: 'user1',
        name: 'John',
        email: 'john@example.com',
      );

      // Trigger first fetch
      final future1 = notifier.fetchUserProfile(userId: 'user1');

      // Wait a bit to ensure it's loading
      await Future.delayed(const Duration(milliseconds: 10));

      // Trigger second fetch while first is loading
      await notifier.fetchUserProfile(userId: 'user1');

      // Wait for first to complete
      await future1;

      // Should only have 2 state changes from first fetch
      expect(callCount, equals(2));
    });

    test('fetchUserProfile skips if profile already loaded for same userId',
        () async {
      var callCount = 0;

      // First fetch
      fakeGetProfile.mockProfile = UserProfile(
        uid: 'user1',
        name: 'John',
        email: 'john@example.com',
      );

      await notifier.fetchUserProfile(userId: 'user1');

      // Add listener after first fetch
      notifier.addListener(() {
        callCount++;
      });

      // Second fetch for same user (should skip)
      await notifier.fetchUserProfile(userId: 'user1');

      // Should not notify (skip fetch)
      expect(callCount, equals(0));
    });

    test('fetchUserProfile with forceRefresh re-fetches even if loaded',
        () async {
      // First fetch
      fakeGetProfile.mockProfile = UserProfile(
        uid: 'user1',
        name: 'John',
        email: 'john@example.com',
      );

      await notifier.fetchUserProfile(userId: 'user1');

      var callCount = 0;
      notifier.addListener(() {
        callCount++;
      });

      // Second fetch with forceRefresh
      fakeGetProfile.mockProfile = UserProfile(
        uid: 'user1',
        name: 'John Updated',
        email: 'john@example.com',
      );

      await notifier.fetchUserProfile(userId: 'user1', forceRefresh: true);

      // Should notify (re-fetch happened)
      expect(callCount, equals(2)); // loading, success
      expect(notifier.state.userProfile!.name, equals('John Updated'));
    });

    test('updateUserAvatar transitions from idle -> loading -> success',
        () async {
      // Setup initial profile
      notifier.setStateForTest(
        ProfileState(
          userProfile: UserProfile(
            uid: 'user1',
            name: 'John',
            email: 'john@example.com',
            photoUrl: 'old_photo.jpg',
          ),
          status: AsyncStatus.idle,
        ),
      );

      final states = <AsyncStatus>[];
      notifier.addListener(() {
        states.add(notifier.state.status);
      });

      // Setup fake to return new photo URL
      fakePickAndUpload.mockPhotoUrl = 'new_photo.jpg';

      await notifier.updateUserAvatar(
        userId: 'user1',
        source: ImageSourceType.gallery,
      );

      // Verify state transitions: loading -> success
      expect(states, equals([AsyncStatus.loading, AsyncStatus.success]));

      // Verify final state
      expect(notifier.state.status, equals(AsyncStatus.success));
      expect(notifier.state.userProfile!.photoUrl, equals('new_photo.jpg'));
      expect(notifier.state.errorMessage, isNull);
    });

    test('updateUserAvatar transitions to error on failure', () async {
      notifier.setStateForTest(
        ProfileState(
          userProfile: UserProfile(
            uid: 'user1',
            name: 'John',
            email: 'john@example.com',
          ),
          status: AsyncStatus.idle,
        ),
      );

      final states = <AsyncStatus>[];
      notifier.addListener(() {
        states.add(notifier.state.status);
      });

      // Setup fake to throw error
      fakePickAndUpload.shouldThrow = true;

      await notifier.updateUserAvatar(
        userId: 'user1',
        source: ImageSourceType.gallery,
      );

      // Verify state transitions: loading -> error
      expect(states, equals([AsyncStatus.loading, AsyncStatus.error]));

      // Verify final state
      expect(notifier.state.status, equals(AsyncStatus.error));
      expect(notifier.state.errorMessage, isNotNull);
      expect(notifier.state.errorMessage, contains('Failed to upload avatar'));
    });

    test('updateUserAvatar returns to idle if user cancels picker', () async {
      notifier.setStateForTest(
        ProfileState(
          userProfile: UserProfile(
            uid: 'user1',
            name: 'John',
            email: 'john@example.com',
          ),
          status: AsyncStatus.idle,
        ),
      );

      final states = <AsyncStatus>[];
      notifier.addListener(() {
        states.add(notifier.state.status);
      });

      // Setup fake to return null (user cancelled)
      fakePickAndUpload.mockPhotoUrl = null;

      await notifier.updateUserAvatar(
        userId: 'user1',
        source: ImageSourceType.camera,
      );

      // Verify state transitions: loading -> idle
      expect(states, equals([AsyncStatus.loading, AsyncStatus.idle]));
    });

    test('state only notifies listeners when state changes', () async {
      var notifyCount = 0;

      notifier.addListener(() {
        notifyCount++;
      });

      fakeGetProfile.mockProfile = UserProfile(
        uid: 'user1',
        name: 'John',
        email: 'john@example.com',
      );

      await notifier.fetchUserProfile(userId: 'user1');

      // Should notify exactly 2 times: loading, success
      expect(notifyCount, equals(2));
    });
  });
}

// Fake use cases for testing
class _FakeGetUserProfileUseCase implements GetUserProfileUseCase {
  UserProfile? mockProfile;
  bool shouldThrow = false;
  int delayMs = 0;

  @override
  IUserRepository get repository => throw UnimplementedError();

  @override
  Future<UserProfile> call({required String userId}) async {
    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }

    if (shouldThrow) {
      throw Exception('Simulated error');
    }

    if (mockProfile == null) {
      throw Exception('No mock profile set');
    }

    return mockProfile!;
  }
}

class _FakePickAndUploadUseCase
    implements PickAndUploadProfilePictureUseCase {
  String? mockPhotoUrl;
  bool shouldThrow = false;

  @override
  IUserRepository get repository => throw UnimplementedError();

  @override
  Future<String?> call({required ImageSourceType source}) async {
    if (shouldThrow) {
      throw Exception('Simulated error');
    }

    return mockPhotoUrl;
  }
}
