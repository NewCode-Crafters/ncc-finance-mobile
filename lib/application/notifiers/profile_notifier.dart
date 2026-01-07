import 'package:flutter/foundation.dart';

import 'package:bytebank/domain/entities/user_profile.dart' as domain;
import 'package:bytebank/domain/entities/image_source_type.dart';
import 'package:bytebank/domain/use_cases/profile/get_user_profile_use_case.dart';
import 'package:bytebank/domain/use_cases/profile/pick_and_upload_profile_picture_use_case.dart';
import 'package:bytebank/application/core/async_status.dart';

/// Immutable state for ProfileNotifier.
///
/// Uses [AsyncStatus] to track operation status (idle/loading/success/error).
class ProfileState {
  final domain.UserProfile? userProfile;
  final AsyncStatus status;
  final String? errorMessage;

  const ProfileState({
    this.userProfile,
    this.status = AsyncStatus.idle,
    this.errorMessage,
  });

  ProfileState copyWith({
    domain.UserProfile? userProfile,
    AsyncStatus? status,
    String? errorMessage,
  }) {
    return ProfileState(
      userProfile: userProfile ?? this.userProfile,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Helper getters for common status checks
  bool get isLoading => status.isLoading;
  bool get isIdle => status.isIdle;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;
}

class ProfileNotifier extends ChangeNotifier {
  final GetUserProfileUseCase _getUserProfile;
  final PickAndUploadProfilePictureUseCase _pickAndUploadProfilePicture;

  ProfileState _state = const ProfileState();

  ProfileState get state => _state;

  ProfileNotifier({
    required GetUserProfileUseCase getUserProfile,
    required PickAndUploadProfilePictureUseCase pickAndUploadProfilePicture,
  })  : _getUserProfile = getUserProfile,
        _pickAndUploadProfilePicture = pickAndUploadProfilePicture;

  /// Fetches user profile for the given userId.
  ///
  /// State transitions:
  /// - idle -> loading -> success (on success)
  /// - idle -> loading -> error (on failure)
  ///
  /// Skips fetch if already loading or if profile is already loaded (unless forceRefresh).
  Future<void> fetchUserProfile({
    required String userId,
    bool forceRefresh = false,
  }) async {
    // Skip if already loading
    if (_state.isLoading) return;

    // Skip if profile already loaded for this user (unless force refresh)
    if (!forceRefresh &&
        _state.userProfile != null &&
        _state.userProfile!.uid == userId) {
      return;
    }

    _setState(_state.copyWith(status: AsyncStatus.loading));

    try {
      final domainProfile = await _getUserProfile.call(userId: userId);
      _setState(
        _state.copyWith(
          userProfile: domainProfile,
          status: AsyncStatus.success,
          errorMessage: null,
        ),
      );
    } catch (e) {
      _setState(
        _state.copyWith(
          status: AsyncStatus.error,
          errorMessage: 'Failed to fetch profile: ${e.toString()}',
        ),
      );
    }
  }

  /// Updates user avatar by picking and uploading an image.
  ///
  /// State transitions:
  /// - current -> loading -> success (on success)
  /// - current -> loading -> error (on failure)
  Future<void> updateUserAvatar({
    required String userId,
    required ImageSourceType source,
  }) async {
    // Skip if already loading
    if (_state.isLoading) return;

    _setState(_state.copyWith(status: AsyncStatus.loading));

    try {
      final newPhotoUrl = await _pickAndUploadProfilePicture.call(
        source: source,
      );

      if (newPhotoUrl != null && newPhotoUrl.isNotEmpty) {
        final updatedProfile = _state.userProfile?.copyWith(
          photoUrl: newPhotoUrl,
        );
        _setState(
          _state.copyWith(
            userProfile: updatedProfile,
            status: AsyncStatus.success,
            errorMessage: null,
          ),
        );
      } else {
        // User cancelled picker
        _setState(_state.copyWith(status: AsyncStatus.idle));
      }
    } catch (e) {
      _setState(
        _state.copyWith(
          status: AsyncStatus.error,
          errorMessage: 'Failed to upload avatar: ${e.toString()}',
        ),
      );
    }
  }

  /// Internal method to update state and notify listeners.
  ///
  /// Only notifies if state actually changed (reduces redundant rebuilds).
  void _setState(ProfileState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  // Helper used in tests
  @visibleForTesting
  void setStateForTest(ProfileState newState) {
    _state = newState;
    notifyListeners();
  }
}
